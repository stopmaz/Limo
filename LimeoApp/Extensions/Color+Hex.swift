//
//  Color+Hex.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI

// Add an accent color constant for easy reuse
extension Color {
    static let accentGreen = Color(red: 52/255, green: 199/255, blue: 89/255) // #34C759
}

extension Color {
    /// Initializes a Color from a hex string.
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }

    /// Converts the Color to a hex string (e.g., "FF0000").
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            // Try black/white for non-RGB colors
            if UIColor(self) == .black { return "000000" }
            if UIColor(self) == .white { return "FFFFFF" }
            return nil
        }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
