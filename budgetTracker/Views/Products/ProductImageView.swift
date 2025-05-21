//
//  ProductImageView.swift
//  budgetTracker
//
//

import SwiftUICore
import SwiftUI

struct ProductImageView: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
    }
}
