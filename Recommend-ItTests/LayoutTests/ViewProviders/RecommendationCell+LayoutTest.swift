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

    public class func dataSpecForTest() -> [AnyHashable : Any] {
        return [
            "title": StringValues(),
            "location": StringValues(),
            "notes": StringValues()
        ]
    }

    public class func sizesForView() -> [ViewSize] {
        return [
            ViewSize(width: LYTiPhone4Width),
            ViewSize(width: LYTiPhone6PlusWidth)
        ]
    }

    public class func view(forData data: [AnyHashable : Any], reuse reuseView: UIView?, size: ViewSize?, context: AutoreleasingUnsafeMutablePointer<AnyObject?>?) -> UIView {

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
}
