//
//  Colors.swift
//  Finances
//
//  Created by Felipe Felicio on 17/07/25.
//

import UIKit

struct AppColors {
    
    // MARK: - Brand Colors
    static let magenta = UIColor(hex: "#DA4BDD")
    static let red = UIColor(hex: "#D93A4A")
    static let green = UIColor(hex: "#1FA342")
    
    // MARK: - Gray Scale
    static let gray100 = UIColor(hex: "#F9FBF9")
    static let gray200 = UIColor(hex: "#EFF0EF")
    static let gray300 = UIColor(hex: "#E5E6E5")
    static let gray400 = UIColor(hex: "#A1A2A1")
    static let gray500 = UIColor(hex: "#676767")
    static let gray600 = UIColor(hex: "#494A49")
    static let gray700 = UIColor(hex: "#0F0F0F")
    
}

// MARK: - UIColor Extension for Hex Support
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
