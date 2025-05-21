//
//  ProductDetailsView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

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

