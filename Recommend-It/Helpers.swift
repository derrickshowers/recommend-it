//
//  Helpers.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/7/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

/**
    This will take care of debouncing an action that needs some sort of delay applied. 

    An example might be pinging a server for something typed into a search box. Instead of 
    pinging the server each time, set a delay to give the user time to type a few characters first.

    :param: delay length of the delay
    :param: queue thread to be used for action
    :param: action a func that executes if delay time has passed
    
    :returns: a closure that is called instead of the actual action
*/
func debounce (delay: NSTimeInterval, #queue: dispatch_queue_t, action: (() -> ())) -> () -> () {
    
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