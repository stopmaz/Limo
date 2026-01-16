//
//  SubscriptionDetailViewModel.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Observation // <-- 1. Added Observation

@Observable // <-- 2. Changed to @Observable
class SubscriptionDetailViewModel {
    
    func deleteSubscription(_ subscription: Subscription, context: ModelContext, dismiss: () -> Void) {
        // TODO: Add call to `NotificationManager.removeNotification(for: subscription)` here
        context.delete(subscription)
        
        // After deletion, dismiss the detail view
        dismiss()
    }
    
    /// Simulates "Mark as Paid" by advancing the payment date by one cycle.
    /// This is a common in-app action.
    func markAsPaid(_ subscription: Subscription) {
        
        // 3. Simplified the function to fix the warning.
        // We just advance the base payment date to the *next* payment date.
        // This "completes" the current upcoming payment, and the
        // `nextPaymentDate` property will automatically compute the *new* one.
        
        subscription.paymentDate = subscription.nextPaymentDate
        
        // TODO: Reschedule notification for the new date
        // NotificationManager.updateNotification(for: subscription)
    }
}
