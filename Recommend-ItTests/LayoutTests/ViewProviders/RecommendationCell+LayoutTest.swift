//
//  RecommendationCell+LayoutTest.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/8/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import LayoutTest
@testable import Recommend_It

extension RecommendationCell: ViewProvider {

    public static func dataSpecForTest() -> [AnyHashable : Any] {
        return [
            "title": StringValues(),
            "location": StringValues(),
            "notes": StringValues()
        ]
    }

    public static func sizesForView() -> [ViewSize] {
        return [
            ViewSize(width: LYTiPhone4Width),
            ViewSize(width: LYTiPhone6PlusWidth)
        ]
    }

    public static func view(forData data: [AnyHashable : Any], reuse reuseView: UIView?, size: ViewSize?, context: AutoreleasingUnsafeMutablePointer<AnyObject?>?) -> UIView {

        let cell: RecommendationCell = {
            if let reuseView = reuseView as? RecommendationCell {
                return reuseView
            } else {
                return Bundle.main.loadNibNamed(String(describing: RecommendationCell.self), owner: nil, options: nil)!.first as! RecommendationCell
            }
        }()

        cell.nameLabel.text = data["title"] as? String
        cell.locationLabel.text = data["location"] as? String
        cell.notesLabel.text = data["notes"] as? String

        return cell
    }

    public static func adjustViewSize(_ view: UIView, data: [AnyHashable : Any], size: ViewSize?, context: Any?) {

        guard let cell = view as? RecommendationCell,
            let width = size?.width else {
            return
        }

        // Set width (same logic as collection view setup)
        let widthConstraint = cell.containerView.widthAnchor.constraint(equalToConstant: width - 20.0)
        widthConstraint.priority = 999.0
        widthConstraint.isActive = true

        // Set height from autolayout
        cell.height = cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
}
