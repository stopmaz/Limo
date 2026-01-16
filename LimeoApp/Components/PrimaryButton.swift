//
//  PrimaryButton.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isEnabled ? Color.accentGreen : Color.gray.opacity(0.5))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        PrimaryButton(title: "Enabled") {}
        PrimaryButton(title: "Disabled") {}
            .disabled(true)
    }
    .padding()
}
