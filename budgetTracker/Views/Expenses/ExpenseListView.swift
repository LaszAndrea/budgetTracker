//
//  ExpenseListView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

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

