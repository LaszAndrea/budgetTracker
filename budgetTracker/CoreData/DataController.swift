//
//  DataController.swift
//  budgetTracker
//
import CoreData

class DataController: ObservableObject {
    
    static let shared = DataController()
    
    //prepare core date to load Expense data model
    let container = NSPersistentContainer(name: "ExpenseModel")
    
    //let core data to acces our data, not load it all
    init(){
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
}
