//
//  PersistentContainer.swift
//  Recommend-It
//
//  Created by Derrick Showers on 10/22/16.
//  Copyright © 2016 Derrick Showers. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) as URL
    }
}
