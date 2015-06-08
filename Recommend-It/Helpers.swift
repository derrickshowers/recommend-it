//
//  Helpers.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/7/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

func debounce (delay: NSTimeInterval, #queue: dispatch_queue_t, action: (() -> ())) -> () -> () {
    
    var lastFireTime:dispatch_time_t = 0
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