//
//  ExpenseViewModell.swift
//  budgetTracker
//
//

import Foundation
import CoreData

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
        getAllExpenses() // Az inicializáláskor töltse be az adatokat
    }
    
    
    //get all expenses to the date from the persistent core data
    func getAllExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
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
    
    //
    func getCategorySummary() -> [String: Int] {
        var summary: [String: Int] = [:]
        for expense in expenses {
            summary[expense.category ?? "N/A", default: 0] += Int(expense.amount)
        }
        return summary
    }
    
    //get all expenses for selected month
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



