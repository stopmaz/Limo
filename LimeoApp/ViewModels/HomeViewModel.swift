//
//  HomeViewModel.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation
import SwiftUI
import SwiftData
import Observation // <-- 1. Added Observation

@Observable // <-- 2. Changed to @Observable
class HomeViewModel {
    
    // 3. Removed all @Published wrappers
    var totalMonthlyCost: Double = 0.0
    var upcomingSubscriptions: [Subscription] = []
    var categorizedSubscriptions: [SubscriptionCategory: [Subscription]] = [:]
    
    /// Processes the fetched subscriptions to update all published properties.
    func processSubscriptions(_ subscriptions: [Subscription], upcomingWindow: Int) {
        calculateTotalMonthlyCost(subscriptions)
        filterUpcomingSubscriptions(subscriptions, upcomingWindow: upcomingWindow)
        groupSubscriptions(subscriptions)
    }
    
    /// Calculates the total monthly cost from all subscriptions.
    private func calculateTotalMonthlyCost(_ subscriptions: [Subscription]) {
        totalMonthlyCost = subscriptions.reduce(0) { $0 + $1.monthlyCost }
    }
    
    /// Filters subscriptions that are due within the specified window.
    private func filterUpcomingSubscriptions(_ subscriptions: [Subscription], upcomingWindow: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate the end date of the window
        guard let windowEndDate = calendar.date(byAdding: .day, value: upcomingWindow, to: today) else {
            upcomingSubscriptions = []
            return
        }
        
        upcomingSubscriptions = subscriptions.filter {
            let nextPayment = $0.nextPaymentDate
            // Due if next payment is on or after today AND before the window ends
            return (nextPayment >= today && nextPayment < windowEndDate)
        }.sorted { $0.nextPaymentDate < $1.nextPaymentDate } // Sort by soonest
    }

    /// Groups subscriptions by their category.
    private func groupSubscriptions(_ subscriptions: [Subscription]) {
        // Group and then sort the keys so "Media" always comes before "Home"
        let grouped = Dictionary(grouping: subscriptions, by: { $0.category })
        
        let sortedGrouped = grouped.sorted { $0.key.rawValue < $1.key.rawValue }
        
        var newCategorizedSubs: [SubscriptionCategory: [Subscription]] = [:]
        for (key, value) in sortedGrouped {
            // Sort subs within each category by title
            newCategorizedSubs[key] = value.sorted(by: { $0.title < $1.title })
        }
        categorizedSubscriptions = newCategorizedSubs
    }
    
    /// Deletes a subscription from the ModelContext.
    func deleteSubscription(at offsets: IndexSet, from subscriptions: [Subscription], context: ModelContext) {
        for index in offsets {
            let subscription = subscriptions[index]
            // TODO: Add call to `NotificationManager.removeNotification(for: subscription)` here
            context.delete(subscription)
        }
        // SwiftData will automatically update the @Query, triggering a UI refresh.
    }
    
    /// Checks if a subscription's next payment date is today or in the past.
    func isSubscriptionOverdue(_ subscription: Subscription) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return subscription.nextPaymentDate <= today
    }
}
