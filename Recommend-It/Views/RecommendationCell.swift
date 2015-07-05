//
//  RecommendationCell.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class RecommendationCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var image: UIImageView!

    var delegate: RecommendationCellDelegate?
    var cellIndex: Int?

    @IBAction func removePressed(sender: AnyObject) {
        if let delegate = delegate, cellIndex = cellIndex {
            delegate.didPressRemoveAtIndex(cellIndex)
        }
    }
    @IBAction func archivePressed(sender: AnyObject) {
        if let delegate = delegate, cellIndex = cellIndex {
            delegate.didPressArchiveAtIndex(cellIndex)
        }
    }
    @IBAction func yelpPressed(sender: AnyObject) {
        if let delegate = delegate, cellIndex = cellIndex {
            delegate.didPressYelpAtIndex(cellIndex)
        }
    }

}