//
//  Subscription.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation
import SwiftData

@Model
class Subscription {
    @Attribute(.unique) var id: UUID
    var title: String
    var price: Double
    var categoryRaw: String // Stores the rawValue of SubscriptionCategory
    var cycleRaw: String    // Stores the rawValue of BillingCycle
    var paymentDate: Date
    var notes: String?
    var colorHex: String    // Stored as hex string
    
    init(id: UUID = UUID(), title: String, price: Double, category: SubscriptionCategory, cycle: BillingCycle, paymentDate: Date, notes: String? = nil, colorHex: String) {
        self.id = id
        self.title = title
        self.price = price
        self.categoryRaw = category.rawValue
        self.cycleRaw = cycle.rawValue
        self.paymentDate = paymentDate
        self.notes = notes
        self.colorHex = colorHex
    }
    
    // Computed properties for easy enum access
    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    
    var cycle: BillingCycle {
        get { BillingCycle(rawValue: cycleRaw) ?? .monthly }
        set { cycleRaw = newValue.rawValue }
    }
    
    /// Calculates the next payment date based on the current one.
    func a_r(to date: Date, byAdding component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: date) ?? date
    }

    var nextPaymentDate: Date {
        // Find the next payment date that is *after* today
        var nextDate = paymentDate
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        while nextDate <= today {
            switch cycle {
            case .weekly:
                nextDate = a_r(to: nextDate, byAdding: .weekOfYear, value: 1)
            case .monthly:
                nextDate = a_r(to: nextDate, byAdding: .month, value: 1)
            case .yearly:
                nextDate = a_r(to: nextDate, byAdding: .year, value: 1)
            }
        }
        return nextDate
    }
    
    /// Calculates the equivalent monthly cost for this subscription.
    var monthlyCost: Double {
        return cycle.monthlyEquivalent(price: price)
    }
}
