//
//  Product.swift
//  budgetTracker
//
//

//product struct which uses more struct because the way the json is
struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let unit: String
    let imageUrl: String
    let pricesOfChainStores: [Stores]
}

