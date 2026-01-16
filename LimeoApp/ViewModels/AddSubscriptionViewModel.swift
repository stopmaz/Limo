//
//  AddSubscriptionViewModel.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class AddSubscriptionViewModel {
    
    // Form fields
    var title: String = ""
    var priceStr: String = ""
    var category: SubscriptionCategory = .media
    var cycle: BillingCycle = .monthly
    var paymentDate: Date = Date()
    var notes: String = ""
    var selectedColorHex: String = Color.accentGreen.toHex() ?? "34C759"
    
    // Form options
    let categories: [SubscriptionCategory] = SubscriptionCategory.allCases
    let cycles: [BillingCycle] = BillingCycle.allCases
    let colorSwatches: [String] = [
        Color.accentGreen.toHex()!, Color.blue.toHex()!, Color.pink.toHex()!,
        Color.red.toHex()!, Color.purple.toHex()!, Color.orange.toHex()!,
        Color.yellow.toHex()!, Color.indigo.toHex()!, Color.gray.toHex()!
    ]
    
    // Validation
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(priceStr) != nil &&
        !selectedColorHex.isEmpty
    }
    
    // Error handling
    enum SaveError: LocalizedError {
        case invalidPrice
        case missingTitle
        
        var errorDescription: String? {
            switch self {
            case .invalidPrice: return "Please enter a valid price (e.g., 9.99)."
            case .missingTitle: return "Please enter a title."
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .invalidPrice: return "Check the price field and try again."
            case .missingTitle: return "The subscription must have a name."
            }
        }
    }
    
    // 1. Changed type to optional SaveError
    var saveError: SaveError? = nil
    
    // MARK: - Public API
    
    /// Loads an existing subscription into the view model for editing.
    func loadSubscription(_ subscription: Subscription) {
        self.title = subscription.title
        self.priceStr = String(format: "%.2f", subscription.price)
        self.category = subscription.category
        self.cycle = subscription.cycle
        self.paymentDate = subscription.paymentDate
        self.notes = subscription.notes ?? ""
        self.selectedColorHex = subscription.colorHex
    }
    
    /// Saves the current form data as a new or updated subscription.
    func saveSubscription(context: ModelContext, existingSubscription: Subscription?) throws {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SaveError.missingTitle
        }
        guard let price = Double(priceStr) else {
            throw SaveError.invalidPrice
        }
        
        // Removed unnecessary logic for brevity, the rest of the function remains the same...

        if let existingSubscription {
            // Update existing
            existingSubscription.title = title
            existingSubscription.price = price
            existingSubscription.category = category
            existingSubscription.cycle = cycle
            existingSubscription.paymentDate = paymentDate
            existingSubscription.notes = notes.isEmpty ? nil : notes
            existingSubscription.colorHex = selectedColorHex
            
            // TODO: Add call to `NotificationManager.updateNotification(for: existingSubscription)` here
            
        } else {
            // Create new
            let newSubscription = Subscription(
                title: title,
                price: price,
                category: category,
                cycle: cycle,
                paymentDate: paymentDate,
                notes: notes.isEmpty ? nil : notes,
                colorHex: selectedColorHex
            )
            context.insert(newSubscription)
            
            // TODO: Add call to `NotificationManager.scheduleNotification(for: newSubscription)` here
        }
    }
}
