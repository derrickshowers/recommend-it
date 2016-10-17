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
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var confirmRemoveButton: UIButton!
    @IBOutlet weak var cancelRemoveButton: UIButton!

    var delegate: RecommendationCellDelegate?
    var cellIndex: Int?

    @IBAction func cancelRemoveButtonPressed(_ sender: AnyObject) {
        confirmRemoveButton.alpha = 0.0
        cancelRemoveButton.alpha = 0.0
        confirmRemoveButton.isHidden = true
        cancelRemoveButton.isHidden = true
    }
    @IBAction func confirmRemovePressed(_ sender: AnyObject) {
        if let delegate = delegate, let cellIndex = cellIndex {
            delegate.didPressConfirmRemove(cellIndex)
        }
    }
    @IBAction func removePressed(_ sender: AnyObject) {
        if let delegate = delegate, let cellIndex = cellIndex {
            delegate.didPressRemoveAtIndex(cellIndex)
        }
    }
    @IBAction func archivePressed(_ sender: AnyObject) {
        if let delegate = delegate, let cellIndex = cellIndex {
            delegate.didPressArchiveAtIndex(cellIndex)
        }
    }
    @IBAction func yelpPressed(_ sender: AnyObject) {
        if let delegate = delegate, let cellIndex = cellIndex {
            delegate.didPressYelpAtIndex(cellIndex)
        }
    }

}
