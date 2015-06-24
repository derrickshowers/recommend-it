//
//  NavigationController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func makeLight() {
        self.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.shadowImage = UIImage()
        self.translucent = true
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.tintColor = UIColor.whiteColor()
        self.barTintColor = UIColor.clearColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    func makeDefaultBlue() {
        self.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.shadowImage = nil
        self.translucent = true
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.tintColor = UIColor.whiteColor()
        self.barTintColor = UIColor(red: 68/255, green: 108/255, blue: 149/255, alpha: 1.0)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
}
