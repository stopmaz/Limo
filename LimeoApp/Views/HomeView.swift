//
//  HomeView.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query(sort: \Subscription.paymentDate, order: .forward)
    private var subscriptions: [Subscription]
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. Changed @StateObject to @State
    @State private var viewModel = HomeViewModel()
    
    @State private var showAddSheet = false
    
    @AppStorage("upcomingWindow") private var upcomingWindow: Int = 7

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                // MARK: - Total Monthly Cost Section
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Monthly Cost")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(viewModel.totalMonthlyCost, format: .currency(code: "USD"))
                            .font(.system(.title, design: .monospaced, weight: .bold))
                            .foregroundStyle(Color.accentGreen)
                    }
                    .padding(.vertical, 8)
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .listRowBackground(Color(.systemGroupedBackground))

                // MARK: - Upcoming Reminders Section
                if !viewModel.upcomingSubscriptions.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.upcomingSubscriptions) { sub in
                                    UpcomingSubscriptionCard(subscription: sub)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                    } header: {
                        Text("Upcoming (Next \(upcomingWindow) Days)")
                            .font(.headline)
                            .padding(.top, 16)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                // MARK: - All Subscriptions by Category
                ForEach(viewModel.categorizedSubscriptions.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                    
                    Section(header: Text(category.rawValue)) {
                        ForEach(viewModel.categorizedSubscriptions[category]!) { subscription in
                            NavigationLink {
                                SubscriptionDetailView(subscription: subscription)
                            } label: {
                                SubscriptionRow(subscription: subscription)
                            }
                        }
                        .onDelete { offsets in
                            // Find the subscriptions specific to this category to delete
                            let subsToDelete = viewModel.categorizedSubscriptions[category] ?? []
                            viewModel.deleteSubscription(at: offsets, from: subsToDelete, context: modelContext)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Limeo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            
            // MARK: - Floating Add Button
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(.title, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(Color.accentGreen)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5, x: 0, y: 4)
            }
            .padding()
        }
        .sheet(isPresented: $showAddSheet) {
            AddSubscriptionView()
        }
        // MARK: - View Logic
        .onAppear {
            // Process data when view appears
            viewModel.processSubscriptions(subscriptions, upcomingWindow: upcomingWindow)
        }
        .onChange(of: subscriptions) {
            // Re-process when SwiftData reports a change
            viewModel.processSubscriptions(subscriptions, upcomingWindow: upcomingWindow)
        }
        .onChange(of: upcomingWindow) {
             // Re-process when the user changes the setting
            viewModel.processSubscriptions(subscriptions, upcomingWindow: upcomingWindow)
        }
    }
}

// MARK: - Upcoming Subscription Card (Internal Component)
struct UpcomingSubscriptionCard: View {
    let subscription: Subscription
    
    private var isOverdue: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return subscription.nextPaymentDate <= today
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoryIcon(category: subscription.category, size: 36)
                Spacer()
                
                Text(isOverdue ? "DUE" : "UPCOMING")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(isOverdue ? Color.red : Color.orange)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Text(subscription.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(subscription.price, format: .currency(code: "USD"))
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
            
            Text(subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 160, height: 130)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            NavigationLink {
                SubscriptionDetailView(subscription: subscription)
            } label: {
                EmptyView()
            }
            .opacity(0) // Make the link cover the card
        }
    }
}

// MARK: - Preview
#Preview {
    // Setup in-memory container for preview
    @MainActor
    func setupPreview() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Subscription.self, configurations: config)
            
            let sub1 = Subscription(title: "Netflix", price: 15.49, category: .media, cycle: .monthly, paymentDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, colorHex: "E50914")
            let sub2 = Subscription(title: "Spotify", price: 9.99, category: .media, cycle: .monthly, paymentDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, colorHex: "1DB954")
            let sub3 = Subscription(title: "Rent", price: 1200, category: .home, cycle: .monthly, paymentDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, colorHex: "007AFF")
            
            container.mainContext.insert(sub1)
            container.mainContext.insert(sub2)
            container.mainContext.insert(sub3)
            
            return container
            
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
    
    return NavigationStack { HomeView() }.modelContainer(setupPreview())
}
