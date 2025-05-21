//
//  Stores.swift
//  budgetTracker
//
//

//store struct if a product is in more than one store
struct Stores: Identifiable, Codable {
    let id: String
    let name: String
    let prices: [Price]
}

