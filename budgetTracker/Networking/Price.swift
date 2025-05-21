//
//  Price.swift
//  budgetTracker
//
//

//price struct because the json has an array for the prices
struct Price: Codable {
    //unit price
    let unitAmount: Double
    //actual price
    let amount: Int
}

