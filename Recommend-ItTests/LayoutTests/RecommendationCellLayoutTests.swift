//
//  RecommendationCellLayoutTests.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/8/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import XCTest
import LayoutTest
@testable import Recommend_It

class RecommendationCellLayoutTests: LayoutTestCase {
    
    func testLayout() {
        runLayoutTests(withViewProvider: RecommendationCell.self) { (view: RecommendationCell, data: [AnyHashable : Any], context: Any?) in

            XCTAssert(view.locationLabel.below(view.nameLabel))
            XCTAssert(view.notesLabel.below(view.locationLabel))
            XCTAssert(view.buttonContainerView.below(view.notesLabel))
        }
    }
    
}
