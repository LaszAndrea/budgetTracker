//
//  ChartView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

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
