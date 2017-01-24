//
//  UISearchBar+.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

extension UISearchBar {
    func textColor(_ color: UIColor) {
        for subView in self.subviews {
            for secondLevelSubview in subView.subviews {
                if secondLevelSubview.isKind(of: UITextField.self) {
                    if let searchBarTextField: UITextField = secondLevelSubview as? UITextField {
                        searchBarTextField.textColor = color
                        break
                    }
                }
            }
        }
    }
}
