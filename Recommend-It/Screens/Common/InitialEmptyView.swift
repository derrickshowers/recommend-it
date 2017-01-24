//
//  InitialEmptyView.swift
//  Recommend-It
//
//  Created by Derrick Showers on 10/22/16.
//  Copyright © 2016 Derrick Showers. All rights reserved.
//

import UIKit

class InitialEmptyView: UIView {

    var onTapAddRecommendation: ((UIButton) -> Void)?

    @IBAction func didTapAddRecommendation(_ sender: UIButton) {
        onTapAddRecommendation?(sender)
    }

}
