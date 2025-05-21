//
//  Modified2ContetnView.swift
//  budgetTracker
//

import SwiftUI
import CoreData
import Charts
import WebKit


struct ContentView: View {
    
    //accessing the managed objects from core data with enviroment
    @StateObject private var viewModel: ExpenseViewModel
    
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



