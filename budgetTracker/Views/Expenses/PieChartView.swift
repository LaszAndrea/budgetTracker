//
//  PieChartView.swift
//  budgetTracker
//
//

import SwiftUICore
import Charts

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

