//
//  UINavigationBar+.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func makeLight() {
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tintColor = UIColor.white
        self.barTintColor = UIColor.clear
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
    }
    func makeDefaultBlue() {
        self.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.shadowImage = nil
        self.isTranslucent = true
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tintColor = UIColor.white
        self.barTintColor = UIColor(red: 68/255, green: 108/255, blue: 149/255, alpha: 1.0)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
    }
}
