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
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var containerView: UIView!

    var borderLayer: CALayer?

    // Button Action Closures
    var onTapYelp: (() -> ())?
    var onTapRemove: (() -> ())?
    var onTapArchive: (() -> ())?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        configureUpperBorderFor(view: buttonContainerView)
    }

    @IBAction func cancelRemoveButtonPressed(_ sender: AnyObject) {
        confirmRemoveButton.alpha = 0.0
        cancelRemoveButton.alpha = 0.0
        confirmRemoveButton.isHidden = true
        cancelRemoveButton.isHidden = true
    }

    @IBAction func confirmRemovePressed(_ sender: AnyObject) {
        onTapRemove?()
    }

    @IBAction func removePressed(_ sender: AnyObject) {

        confirmRemoveButton.isHidden = false
        cancelRemoveButton.isHidden = false

        UIView.animate(withDuration: 0.3, animations: {
            [weak self] () -> Void in

            self?.confirmRemoveButton.alpha = 0.80
            self?.cancelRemoveButton.alpha = 1.0
        })
    }

    @IBAction func archivePressed(_ sender: AnyObject) {
        onTapArchive?()
    }

    @IBAction func yelpPressed(_ sender: AnyObject) {
        onTapYelp?()
    }

    // MARK: - Private helpers

    private func configureUpperBorderFor(view: UIView) {

        if let borderLayer = borderLayer {
            borderLayer.removeFromSuperlayer()
        } else {
            borderLayer = CALayer()
        }

        guard let borderLayer = borderLayer else {
            return
        }

        borderLayer.removeFromSuperlayer()
        borderLayer.backgroundColor = UIColor.black.cgColor
        borderLayer.opacity = 0.10
        borderLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        view.layer.addSublayer(borderLayer)
    }
}
