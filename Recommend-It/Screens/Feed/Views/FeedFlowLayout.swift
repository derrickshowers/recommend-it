//
//  FeedFlowLayout.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class FeedFlowLayout: UICollectionViewFlowLayout {

    // MARK: CONSTANTS
    let NAVBAR_HEIGHT: CGFloat = 63.0
    let HEADER_OVERFLOW: CGFloat = 50.0


    // MARK: Overriden UICollectionViewFlowLayout methods

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)! as [UICollectionViewLayoutAttributes]

        for (index, attrs) in (layoutAttributes).enumerated() {
            if attrs.representedElementCategory == .supplementaryView && attrs.representedElementKind == UICollectionElementKindSectionHeader {
                let replacementAttrs = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: attrs.indexPath)
                layoutAttributes[index] = replacementAttrs
            } else {
                let newAttrs = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0))
                layoutAttributes.append(newAttrs)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)!
        if elementKind == UICollectionElementKindSectionHeader {

            var y: CGFloat = 0.0
            let posFromTop = collectionView!.contentOffset.y + collectionView!.contentInset.top
            var height = (headerReferenceSize.height + HEADER_OVERFLOW) * (1.0 - (posFromTop / 680.0))

            if posFromTop >= 134.0 {
                y = posFromTop - (headerReferenceSize.height - NAVBAR_HEIGHT)
            }

            if posFromTop <= 0 {
                y = posFromTop
                height = headerReferenceSize.height + -posFromTop  + HEADER_OVERFLOW
            }

            attributes.frame = CGRect(x: 0.0, y: y, width: collectionView!.frame.width, height: height)
            attributes.zIndex = -1
        }

        return attributes
    }
}
