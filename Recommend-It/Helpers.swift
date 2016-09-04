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
func debounce(delay: NSTimeInterval, queue: dispatch_queue_t, action: (() -> ())) -> () -> () {
    
    var lastFireTime: dispatch_time_t = 0
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
    
    return {
        lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            queue) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(lastFireTime, dispatchDelay)
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
func heightFromDynamicLabel(initialHeight initialHeight: CGFloat, width: CGFloat, font: UIFont, text: String?) -> CGFloat {
    let rect: CGRect
    if let text = text {
        rect = NSString(string: text).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    } else {
        rect = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    return initialHeight + ceil(rect.height)
}