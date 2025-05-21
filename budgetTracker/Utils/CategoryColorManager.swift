//
//  CategoryColorManager.swift
//  budgetTracker
//
//

import SwiftUICore

//class for having the same color as the category color and as the piechart color
class CategoryColorManager {
    static let shared = CategoryColorManager()
    
    private var categoryColors: [String: Color] = [:]
    
    private init() {
        assignColorsToCategories()
    }
    
    private func assignColorsToCategories() {
        let predefinedColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow]
        let categories = ["Élelmiszer", "Lakhatás", "Autó", "Szórakozás", "Egyéb"]
        
        for (index, category) in categories.enumerated() {
            categoryColors[category] = predefinedColors[index % predefinedColors.count]
        }
    }
    
    func getColor(for category: String) -> Color {
        return categoryColors[category] ?? .gray
    }
}

extension Color {
    static func random() -> Color {
        return Color(hue: Double.random(in: 0...1), saturation: 0.8, brightness: 0.9)
    }
}
