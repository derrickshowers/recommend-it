//
//  RecommendationCell.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

protocol RecommendationCellDelegate {
    func didPressRemoveAtIndex(_ cellIndex: Int)
    func didPressArchiveAtIndex(_ cellIndex: Int)
    func didPressYelpAtIndex(_ cellIndex: Int)
    func didPressConfirmRemove(_ cellIndex: Int)
}

class RecommendationCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var confirmRemoveButton: UIButton!
    @IBOutlet weak var cancelRemoveButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!

    var delegate: RecommendationCellDelegate?
    var borderLayer: CALayer?
    var cellIndex: Int?

    // MARK: - Lifecycle
    override func awakeFromNib() {

        super.awakeFromNib()
        setup()
    }

    // MARK: - Setup
    func setup() {

//        configureUpperBorderFor(view: buttonContainerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        configureUpperBorderFor(view: buttonContainerView)
    }

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

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return layoutAttributes
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

    // MARK: - Class methods

    class func loadNib() -> RecommendationCell? {

        var cell: RecommendationCell?
        let nibViews = Bundle.main.loadNibNamed("RecommendationCell", owner: nil, options: nil)

        nibViews?.forEach({ (nibView: Any) in
            if let nibView = nibView as? RecommendationCell {
                cell = nibView
            }
        })

        return cell
    }

}
