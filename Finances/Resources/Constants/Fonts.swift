//
//  Fonts.swift
//  Finances
//
//  Created by Felipe Felicio on 17/07/25.
//

import UIKit

struct AppFonts {
    
    // MARK: - Font Weights
    private enum LatoWeight: String {
        case regular = "Lato-Regular"
        case bold = "Lato-Bold"
        case black = "Lato-Black"
    }
    
    // MARK: - Primary Font Sizes
    static func titleLg(size: CGFloat = 28) -> UIFont {
        return latoFont(.black, size: size)
    }
    
    static func titleMd(size: CGFloat = 16) -> UIFont {
        return latoFont(.bold, size: size)
    }
    
    static func titleSm(size: CGFloat = 14) -> UIFont {
        return latoFont(.bold, size: size)
    }
    
    static func titleXs(size: CGFloat = 12) -> UIFont {
        return latoFont(.bold, size: size)
    }
    
    static func title2Xs(size: CGFloat = 10) -> UIFont {
        return latoFont(.bold, size: size)
    }
    
    static func textSm(size: CGFloat = 14) -> UIFont {
        return latoFont(.regular, size: size)
    }
    
    static func textXs(size: CGFloat = 12) -> UIFont {
        return latoFont(.regular, size: size)
    }
    
    static func input(size: CGFloat = 16) -> UIFont {
        return latoFont(.regular, size: size)
    }
    static func buttonMd(size: CGFloat = 16) -> UIFont {
        return latoFont(.bold, size: size)
    }
    
    static func buttonSm(size: CGFloat = 14) -> UIFont {
        return latoFont(.bold, size: size)
    }
    // MARK: - Helper Methods
    private static func latoFont(_ weight: LatoWeight, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: size) else {
            print("⚠️ Font \(weight.rawValue) not found, using system font")
            return .systemFont(ofSize: size, weight: .regular)
        }
        return font
    }
}
