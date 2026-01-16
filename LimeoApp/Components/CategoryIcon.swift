//
//  CategoryIcon.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI

struct CategoryIcon: View {
    let category: SubscriptionCategory
    var size: CGFloat = 44
    var color: Color? = nil
    
    private var iconColor: Color {
        color ?? category.color
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(iconColor.opacity(0.15))
            
            Image(systemName: category.symbolName)
                .font(.system(size: size * 0.5))
                .foregroundStyle(iconColor)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
// Updated to the new Preview macro syntax
#Preview(traits: .sizeThatFitsLayout) {
    HStack(spacing: 10) {
        CategoryIcon(category: .media)
        CategoryIcon(category: .home, size: 60)
        CategoryIcon(category: .health, color: .green)
        CategoryIcon(category: .productivity)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
