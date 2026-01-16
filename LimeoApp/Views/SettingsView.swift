//
//  SettingsView.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // 0 = System, 1 = Light, 2 = Dark
    @AppStorage("preferredTheme") private var preferredTheme: Int = 0
    @AppStorage("upcomingWindow") private var upcomingWindow: Int = 7
    
    @State private var showResetAlert = false
    
    private let upcomingWindowOptions = [3, 7, 14, 30]

    var body: some View {
        Form {
            Section("Reminders") {
                Picker("Upcoming Window", selection: $upcomingWindow) {
                    ForEach(upcomingWindowOptions, id: \.self) { days in
                        Text("\(days) days").tag(days)
                    }
                }
                .pickerStyle(.segmented)
                
                Text("Shows in-app reminders for subscriptions due within this many days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("Appearance") {
                Picker("Theme", selection: $preferredTheme) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.segmented)
            }
            
            Section("Data") {
                Button("Reset All Data", role: .destructive) {
                    showResetAlert = true
                }
            }
            
            Section("Future Features") {
                HStack {
                    Image(systemName: "bell.badge")
                    Text("Enable system reminders")
                }
                .foregroundStyle(.secondary)
                
                Text("This will require notification permissions and can be enabled in a future update.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("About") {
                LabeledContent("App Version", value: appVersion)
            }
        }
        .navigationTitle("Settings")
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                resetData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete all subscriptions? This cannot be undone.")
        }
    }
    
    private func resetData() {
        do {
            // Deletes all objects of type `Subscription`
            try modelContext.delete(model: Subscription.self)
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
