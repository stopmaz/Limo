//
//  SubscriptionDetailView.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    
    // The model is passed in, SwiftData tracks its changes
    @Bindable var subscription: Subscription
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = SubscriptionDetailViewModel()
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            // MARK: - Header Section
            Section {
                HStack(alignment: .top, spacing: 16) {
                    CategoryIcon(
                        category: subscription.category,
                        size: 60,
                        color: Color(hex: subscription.colorHex)
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscription.title)
                            .font(.title.bold())
                        
                        Text(subscription.price, format: .currency(code: "USD"))
                            .font(.system(.title2, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text(subscription.cycle.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // MARK: - Actions Section
            Section {
                Button {
                    viewModel.markAsPaid(subscription)
                } label: {
                    Label("Mark as Paid (Advance 1 Cycle)", systemImage: "checkmark.circle")
                }
                .tint(.blue)
            }
            
            // MARK: - Details Section
            Section("Details") {
                LabeledContent("Next Payment", value: subscription.nextPaymentDate.formatted(date: .long, time: .omitted))
                LabeledContent("Category", value: subscription.category.rawValue)
                
                if let notes = subscription.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes").font(.caption).foregroundStyle(.secondary)
                        Text(notes)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(subscription.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            // Pass the bindable subscription to the edit sheet
            AddSubscriptionView(subscription: subscription)
        }
        .alert("Delete Subscription?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteSubscription(subscription, context: modelContext, dismiss: { dismiss() })
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(subscription.title)? This action cannot be undone.")
        }
    }
}

// MARK: - Preview
#Preview {
    @MainActor
    func setupPreview() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            // 1. Fixed typo: Changed .model to .self
            let container = try ModelContainer(for: Subscription.self, configurations: config)
            let sub = Subscription(title: "Netflix", price: 15.49, category: .media, cycle: .monthly, paymentDate: Date(), notes: "This is a note.", colorHex: "E50914")
            container.mainContext.insert(sub)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
    
    return NavigationStack {
        let container = setupPreview()
        let sub = try! container.mainContext.fetch(FetchDescriptor<Subscription>()).first!
        SubscriptionDetailView(subscription: sub)
            .modelContainer(container)
    }
}
