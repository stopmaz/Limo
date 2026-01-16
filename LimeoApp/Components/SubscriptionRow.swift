//
//  SubscriptionRow.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(
                category: subscription.category,
                color: Color(hex: subscription.colorHex)
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.price, format: .currency(code: "USD"))
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                Text(subscription.cycle.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    let sub = Subscription(title: "Long Subscription Title That Might Be Truncated", price: 199.99, category: .productivity, cycle: .yearly, paymentDate: Date(), colorHex: "FF9500")
    
    return List {
        SubscriptionRow(subscription: sub)
    }
    .listStyle(.insetGrouped)
}
