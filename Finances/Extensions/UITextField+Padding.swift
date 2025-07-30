//
//  UITextField.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import Foundation
import UIKit

// MARK: - UITextField Extension for Padding
extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat) {
        // Left padding
        let leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: left, height: frame.height)
        )
        self.leftView = leftView
        self.leftViewMode = .always

        // Right padding
        let rightView = UIView(
            frame: CGRect(x: 0, y: 0, width: right, height: frame.height)
        )
        self.rightView = rightView
        self.rightViewMode = .always
    }
}
