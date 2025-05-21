//
//  AddExpenseView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

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


