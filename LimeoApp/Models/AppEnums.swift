//
//  AppEnums.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation
import SwiftUI

// Using enums for categories and cycles is much safer and more
// maintainable than raw strings. We store their `rawValue` (a String)
// in SwiftData to match the prompt's requirements.

enum SubscriptionCategory: String, CaseIterable, Identifiable, Codable {
    case media = "Media"
    case home = "Home"
    case health = "Health"
    case education = "Education"
    case productivity = "Productivity"
    case transport = "Transport"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var symbolName: String {
        switch self {
        case .media: "play.tv"
        case .home: "house.fill"
        case .health: "heart.fill"
        case .education: "books.vertical.fill"
        case .productivity: "briefcase.fill"
        case .transport: "car.fill"
        case .other: "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .media: .red
        case .home: .blue
        case .health: .pink
        case .education: .purple
        case .productivity: .orange
        case .transport: .green
        case .other: .gray
        }
    }
}

enum BillingCycle: String, CaseIterable, Identifiable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { self.rawValue }
    
    /// Calculates the equivalent monthly cost for a given price.
    func monthlyEquivalent(price: Double) -> Double {
        switch self {
        case .weekly:
            return (price * 52) / 12 // Average weeks in a year
        case .monthly:
            return price
        case .yearly:
            return price / 12
        }
    }
}
