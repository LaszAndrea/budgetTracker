import SwiftUI
import CoreData
import Charts
import WebKit

class ExpenseViewModel: ObservableObject {
    // expense entities array
    @Published var expenses: [ExpenseEntity] = []
    // managed object for saving data to context
    private var moc: NSManagedObjectContext
    //selected expense when modifying an object
    @Published var selectedExpense: ExpenseEntity?
    //selected month in listing the expenses, in first loading its the current month
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    //same as before just with year
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    //selected category in adding expense view, firstly its set to all
    @Published var selectedCategory: String = "Összes"
    
    //creating the categories and month names list
    let categories = ["Összes", "Élelmiszer", "Lakhatás", "Autó", "Szórakozás", "Egyéb"]
    let monthNames = ["Január", "Február", "Március", "Április", "Május", "Június", "Július", "Augusztus", "Szeptember", "Október", "November", "December"]
    
    
    
    init(context: NSManagedObjectContext) {
        self.moc = context
        getAllExpenses()
    }
    
    
    //get all expenses to the date from the persistent core data
    func getAllExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
	//filter request to current month
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        
        do {
            expenses = try moc.fetch(request)
        } catch {
            print("Hiba a kiadások lekérésekor: \(error.localizedDescription)")
        }
    }
    
    //adding an expense or updating an expense, with the core data
    func addExpense(name: String, amount: Int64, date: Date, category: String) {
        if let editingExpense = selectedExpense {
            editingExpense.name = name
            editingExpense.amount = amount
            editingExpense.date = date
            editingExpense.category = category
            
            //setting the selectedExpense back to none
            selectedExpense = nil
            
        } else {
            let newExpense = ExpenseEntity(context: moc)
            newExpense.id = UUID()
            newExpense.name = name
            newExpense.amount = amount
            newExpense.date = date
            newExpense.category = category
        }
        
        updateAllContext()
    }
    
    //deleting expense
    func deleteExpense(deletingValue: ExpenseEntity){
        moc.delete(deletingValue)
        updateAllContext()
    }
    
    //update all context, with every action
    func updateAllContext(){
        do{
            try moc.save()
            getAllExpenses()
        }catch {
            print("Hiba a mentés során!")
        }
    }
    
    //category summary for the pie chart
    func getCategorySummary() -> [String: Int] {
        var summary: [String: Int] = [:]
        for expense in expenses {
            summary[expense.category ?? "N/A", default: 0] += Int(expense.amount)
        }
        return summary
    }
    
    //get all expenses for selected month for pie chart
    func getAllExpensesAmount() -> Int {
        var sum = 0
        let calendar = Calendar.current
        for(expense) in expenses {
            if(calendar.component(.month, from: expense.date ?? Date()) == selectedMonth){
                sum += Int(expense.amount)
            }
        }
        return sum
    }
    
    
}

//class for having the same color as the category color and as the piechart color
class CategoryColorManager {
    static let shared = CategoryColorManager()
    
    private var categoryColors: [String: Color] = [:]
    
    private init() {
        assignColorsToCategories()
    }
    
    private func assignColorsToCategories() {
        let predefinedColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow]
        let categories = ["Élelmiszer", "Lakhatás", "Autó", "Szórakozás", "Egyéb"]
        
        for (index, category) in categories.enumerated() {
            categoryColors[category] = predefinedColors[index % predefinedColors.count]
        }
    }
    
    func getColor(for category: String) -> Color {
        return categoryColors[category] ?? .gray
    }
}

//listing current expenses for the month
struct ExpenseListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var isEditing = false
    @State private var showToast = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.expenses) { expense in
                        HStack {
                            //?? and adding N/A because core date automatically set the attributes to optional despite having them not set to that
                            VStack(alignment: .leading) {
                                Text(expense.name ?? "N/A").font(.headline)
                                Text(expense.category ?? "N/A").font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "%d Ft", expense.amount))
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.selectedExpense = expense
                                isEditing = true
                            } label: {
                                VStack {
                                    Image(systemName: "pencil")
                                    Text("Módosítás")
                                }
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing){
                            Button {
                                viewModel.deleteExpense(deletingValue: expense)
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showToast = false
                                }
                            } label: {
                                VStack {
                                    Image(systemName: "trash")
                                    Text("Törlés")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Kiadások")
                .toolbar {
                    Picker("Hónap", selection: $viewModel.selectedMonth) {
                        ForEach(1..<13, id: \.self) { month in
                            Text(viewModel.monthNames[month - 1]).tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .onChange(of: viewModel.selectedMonth) { _ in
                        viewModel.getAllExpenses()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(
                NavigationLink("", destination: AddExpenseView(viewModel: viewModel), isActive: $isEditing)
                    .hidden()
            )
        }.overlay(
            VStack {
                if showToast {
                    Text("Termék törölve!")
                        .padding()
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut, value: showToast)
                }
            }
                .padding(.top, 60)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        )
    }
}

//adding an expense view
struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var date = Date()
    @State private var category = "Élelmiszer"
    @Environment(\.presentationMode) var presentationMode
    @State private var showToast = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Megnevezés", text: $name)
                TextField("Összeg", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Dátum", selection: $date, displayedComponents: .date)
                Picker("Kategória", selection: $category) {
                    ForEach(viewModel.categories.filter { $0 != "Összes" }, id: \.self) {
                        Text($0)
                    }
                }
            }.onSubmit {
                if let amountValue = Int64(amount) {
                    viewModel.addExpense(name: name, amount: amountValue, date: date, category: category)
                    presentationMode.wrappedValue.dismiss()
                    
		    //set back the fields to the original fields
                    name = ""
                    amount = ""
                    date = Date()
                    category = "Élelmiszer"
                    
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showToast = false
                    }
                }
                
            }
            .onAppear {
                if let expense = viewModel.selectedExpense {
                    name = expense.name ?? "N/A"
                    amount = String(expense.amount)
                    date = expense.date ?? Date()
                    category = expense.category ?? "N/A"
                }
            }
            .navigationTitle(viewModel.selectedExpense == nil ? "Új kiadás" : "Kiadás módosítása")
            .toolbar {
                Button(viewModel.selectedExpense == nil ? "Hozzáadás" : "Módosítás") {
                    if let amountValue = Int64(amount) {
			//deciding if its modifying or adding new expense
                        viewModel.addExpense(name: name, amount: amountValue, date: date, category: category)
                        name = ""
                        amount = ""
                        date = Date()
                        category = "Élelmiszer"
                        
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showToast = false
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onDisappear {
                viewModel.selectedExpense = nil
            }
        }.overlay(
            VStack {
                if showToast {
                    Text("Termék hozzáadva!")
                        .padding()
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut, value: showToast)
                }
            }
                .padding(.top, 60)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        )
    }
}

//pie chart view
struct ChartView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        let categorySummary = viewModel.getCategorySummary()
        let total = categorySummary.values.reduce(0, +)
        
        VStack {
            Text("Kiadások megoszlása")
                .font(.title2)
                .padding()
            
            PieChartView(viewModel: viewModel,data: categorySummary)
                .frame(height: 300)
            
            List(categorySummary.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                HStack {
                    Rectangle()
                        .fill(CategoryColorManager.shared.getColor(for: category))
                        .frame(width: 20, height: 20)
                        .cornerRadius(5)
                    Text(category)
                    Spacer()
                    Text(String(format: "%d Ft", amount))
                    Text(String(format: "(%.1f%%)", (Double(amount) / Double(total)) * 100))
                        .foregroundColor(.gray)
                }
                .padding(5)
            }
        }
        .navigationTitle("Diagram")
    }
}

struct PieChartView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    let data: [String: Int]
    
    var body: some View {
        Chart {
            ForEach(data.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                SectorMark(angle: .value("Összeg", amount), innerRadius: .ratio(0.7), angularInset: 2)
                    .foregroundStyle(CategoryColorManager.shared.getColor(for: category))
                    .cornerRadius(4)
            }
        }
        .chartLegend(.hidden)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                if let anchor = chartProxy.plotFrame {
                    let frame = geometry[anchor]
                    Text("\(viewModel.getAllExpensesAmount()) Ft")
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }
}

extension Color {
    static func random() -> Color {
        return Color(hue: Double.random(in: 0...1), saturation: 0.8, brightness: 0.9)
    }
}

//searching for products via api service
struct SearchForProductsView: View {
    
    @StateObject private var viewModel = APIService()
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @State private var showPriceSelection = false
    @State private var selectedProduct: Product?
    
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Keresés...", text: $viewModel.queryString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        viewModel.fetchProducts()
                    }
                
                List {
                    ForEach(viewModel.products) { product in
                        ProductCard(product: product, expenseViewModel: expenseViewModel)
                            .swipeActions(edge: .leading) {
                                Button {
                                    if product.pricesOfChainStores.count > 1 {
					//if we have multiple stores then have a pop up question for which one to buy
                                        showPriceSelection = true
                                        selectedProduct = product
                                    } else if let store = product.pricesOfChainStores.first, let price = store.prices.first {
                                        expenseViewModel.addExpense(name: product.name, amount: Int64(price.amount), date: Date(), category: "Élelmiszer")
                                    }
                                } label: {
                                    Label("Megvettem", systemImage: "cart.badge.plus")
                                }
                                .tint(.orange)

                            }
                            .confirmationDialog("Válassz árat", isPresented: $showPriceSelection, titleVisibility: .visible) {
                                if let product = selectedProduct {
                                    ForEach(product.pricesOfChainStores, id: \.name) { store in
                                        if let price = store.prices.first {
                                            Button("\(store.name) - \(price.amount) Ft") {
                                                expenseViewModel.addExpense(name: product.name, amount: Int64(price.amount), date: Date(), category: "Élelmiszer")
                                                showPriceSelection = false
                                                selectedProduct = nil
                                            }
                                        }
                                    }
                                }
                            }

                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Árfigyelés")
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
}

//view for how we want the products to show
struct ProductCard: View {
    
    let product: Product
    @ObservedObject var expenseViewModel: ExpenseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProductImageView(imageUrl: product.imageUrl)
            
            ProductDetailsView(product: product)
                .padding()
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.vertical, 8)
        
    }
}

//how we want to image to show on the card
struct ProductImageView: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
    }
}

//how we want the details to be shown on the card
struct ProductDetailsView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Divider()
            
            ForEach(product.pricesOfChainStores, id: \.id) { store in
                HStack {
                    Text(store.name)
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    if let price = store.prices.first {
                        VStack(alignment: .trailing) {
                            Text("\(price.amount) Ft")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("\(Int(price.unitAmount)) Ft/\(product.unit)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Nincs ár")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

//main content view for the bottom list
struct ContentView: View {
    
    //accessing the managed objects from core data with enviroment
    @StateObject private var viewModel: ExpenseViewModel
    
    //initializing to use the core data
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(context: context))
    }
    
    var body: some View {
        TabView {
            ExpenseListView(viewModel: viewModel)
                .tabItem {
                    Label("Lista", systemImage: "list.bullet")
                }
            AddExpenseView(viewModel: viewModel)
                .tabItem {
                    Label("Hozzáadás", systemImage: "plus.circle.fill")
                }
            ChartView(viewModel: viewModel)
                .tabItem {
                    Label("Diagram", systemImage: "chart.pie.fill")
                }
            SearchForProductsView(expenseViewModel: viewModel)
                .tabItem {
                    Label("Árfigyelő", systemImage: "magnifyingglass")
                }
        }
    }
}



