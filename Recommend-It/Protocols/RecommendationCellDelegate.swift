//
//  RecommendationCellDelegate.swift
//  Recommend-It
//
//  Created by Derrick Showers on 7/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

protocol RecommendationCellDelegate {
    func didPressRemoveAtIndex(_ cellIndex: Int)
    func didPressArchiveAtIndex(_ cellIndex: Int)
    func didPressYelpAtIndex(_ cellIndex: Int)
    func didPressConfirmRemove(_ cellIndex: Int)
}
