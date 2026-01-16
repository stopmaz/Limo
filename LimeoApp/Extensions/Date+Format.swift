//
//  Date+Format.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import Foundation

extension Date {
    /// Formats the date as a string (e.g., "Nov 16, 2025").
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
