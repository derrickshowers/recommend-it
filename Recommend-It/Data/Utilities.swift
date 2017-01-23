//
//  Helpers.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/7/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation
import UIKit

/**
    This will take care of debouncing an action that needs some sort of delay applied.

    An example might be pinging a server for something typed into a search box. Instead of
    pinging the server each time, set a delay to give the user time to type a few characters first.

    - parameter delay: length of the delay
    - parameter queue: thread to be used for action
    - parameter action: a func that executes if delay time has passed

    - returns: a closure that is called instead of the actual action
*/
func debounce(_ delay: TimeInterval, queue: DispatchQueue, action: @escaping (() -> ())) -> () -> () {

    var lastFireTime: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))

    return {
        lastFireTime = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
        queue.asyncAfter(
            deadline: DispatchTime.now() + Double(dispatchDelay) / Double(NSEC_PER_SEC)) {
                let now = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
                let when = lastFireTime + Double(dispatchDelay) / Double(NSEC_PER_SEC)
                if now >= when {
                    action()
                }
        }
    }
}

/**
    Helps to figure out the height of an object that has a label in it that contains an
    unkown amount of text (say a UICollectionViewCell for instance)

    - parameter initialHeight: height of the object before the label
    - parameter width: the label's width
    - parameter font: the label's font
    - parameter text: the text value of the label

    - returns: the new height of the object
*/
func heightFromDynamicLabel(initialHeight: CGFloat, width: CGFloat, font: UIFont, text: String?) -> CGFloat {
    let rect: CGRect
    if let text = text {
        rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    } else {
        rect = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    return initialHeight + ceil(rect.height)
}
