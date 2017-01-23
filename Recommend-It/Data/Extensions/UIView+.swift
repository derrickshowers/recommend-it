//
//  UIView.swift
//  Recommend-It
//
//  Created by Derrick Showers on 10/22/16.
//  Copyright © 2016 Derrick Showers. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNib<T: UIView>(type: T.Type, bundle: Bundle? = nil) -> T? {
        guard let view = UINib(nibName: NSStringFromClass(T.self).components(separatedBy: ".").last!, bundle: bundle).instantiate(withOwner: self, options: nil).first as? T else {
            return nil
        }
        return view
    }
}
