//
//  SearchForProductsView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

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

