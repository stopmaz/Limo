//
//  AddSubscriptionView.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI
import SwiftData

struct AddSubscriptionView: View {
    
    // The subscription to edit (nil if adding)
    let subscription: Subscription?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AddSubscriptionViewModel()
    
    @State private var showErrorAlert = false
    
    init(subscription: Subscription? = nil) {
        self.subscription = subscription
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title (e.g., Netflix)", text: $viewModel.title)
                    
                    TextField("Price", text: $viewModel.priceStr)
                        .keyboardType(.decimalPad)
                        .font(.system(.body, design: .monospaced))
                }
                
                Section("Cycle") {
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(viewModel.categories) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Picker("Billing Cycle", selection: $viewModel.cycle) {
                        ForEach(viewModel.cycles) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    
                    DatePicker("First Payment Date", selection: $viewModel.paymentDate, displayedComponents: .date)
                }
                
                Section("Customization") {
                    // Color Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.colorSwatches, id: \.self) { hex in
                                colorSwatchCircle(for: hex)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: false)
                }
                
                Section {
                    PrimaryButton(title: "Save Subscription") {
                        save()
                    }
                    .disabled(!viewModel.isFormValid)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle(subscription == nil ? "Add Subscription" : "Edit Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let subscription {
                    viewModel.loadSubscription(subscription)
                }
            }
            // 1. Switched to the simpler alert syntax to fix all type-checking issues.
            .alert(
                viewModel.saveError?.errorDescription ?? "Save Error", // Title
                isPresented: $showErrorAlert // State binding
            ) { // Actions
                Button("OK") {
                    // Reset the error when the user dismisses it
                    viewModel.saveError = nil
                }
            } message: {
                // Message (using recoverySuggestion safely)
                Text(viewModel.saveError?.recoverySuggestion ?? "An unknown error occurred.")
            }
        }
    }
    
    private func colorSwatchCircle(for hex: String) -> some View {
        Circle()
            .fill(Color(hex: hex) ?? .gray)
            .frame(width: 36, height: 36)
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: viewModel.selectedColorHex == hex ? 2 : 0)
            )
            .padding(2)
            .onTapGesture {
                viewModel.selectedColorHex = hex
            }
    }
    
    private func save() {
        do {
            try viewModel.saveSubscription(context: modelContext, existingSubscription: subscription)
            dismiss()
        } catch let error as AddSubscriptionViewModel.SaveError {
            // Set the specific error type
            viewModel.saveError = error
            // Ensure the alert state is set to true
            showErrorAlert = true
        } catch {
            // Handle other unexpected errors if necessary
            print("Unknown save error: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    // Preview for Adding
    NavigationStack {
        AddSubscriptionView()
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}

#Preview("Editing") {
    // Preview for Editing
    @MainActor
    func setupPreview() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Subscription.self, configurations: config)
            let sub = Subscription(title: "Netflix", price: 15.49, category: .media, cycle: .monthly, paymentDate: Date(), colorHex: "E50914")
            container.mainContext.insert(sub)
            
            return container
            
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
    
    return NavigationStack {
        // We need to pass the *actual* subscription from the container
        let container = setupPreview()
        let sub = try! container.mainContext.fetch(FetchDescriptor<Subscription>()).first!
        return AddSubscriptionView(subscription: sub)
            .modelContainer(container)
    }
}
