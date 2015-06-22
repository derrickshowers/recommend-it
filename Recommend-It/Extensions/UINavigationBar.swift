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
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}
