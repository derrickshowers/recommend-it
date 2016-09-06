//
//  RecommendationCellDelegate.swift
//  Recommend-It
//
//  Created by Derrick Showers on 7/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

protocol RecommendationCellDelegate {
    func didPressRemoveAtIndex(cellIndex: Int)
    func didPressArchiveAtIndex(cellIndex: Int)
    func didPressYelpAtIndex(cellIndex: Int)
    func didPressConfirmRemove(cellIndex: Int)
}
