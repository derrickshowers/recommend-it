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

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElementsInRect(rect)! as [UICollectionViewLayoutAttributes]

        for (index, attrs) in (layoutAttributes).enumerate() {
            if attrs.representedElementCategory == .SupplementaryView && attrs.representedElementKind == UICollectionElementKindSectionHeader {
                let replacementAttrs = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: attrs.indexPath)
                layoutAttributes[index] = replacementAttrs
            } else {
                let newAttrs = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                layoutAttributes.append(newAttrs)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)!
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

            attributes.frame = CGRectMake(0.0, y, collectionView!.frame.width, height)
            attributes.zIndex = -1
        }

        return attributes
    }
}
