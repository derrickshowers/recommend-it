//
//  NavigationController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

extension UISearchBar {
    func textColor(color: UIColor) {
        for subView in self.subviews {
            for secondLevelSubview in subView.subviews {
                if (secondLevelSubview.isKindOfClass(UITextField)) {
                    if let searchBarTextField:UITextField = secondLevelSubview as? UITextField {
                        searchBarTextField.textColor = color
                        break;
                    }
                    
                }
            }
        }
    }
}
