//
//  ProductCard.swift
//  budgetTracker
//
//

import SwiftUICore
import UIKit

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

