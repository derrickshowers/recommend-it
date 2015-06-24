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


    // MARK: Overriden UICollectionViewFlowLayout methods

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var layoutAttributes = super.layoutAttributesForElementsInRect(rect) as? [UICollectionViewLayoutAttributes]

        for (index, attrs) in enumerate(layoutAttributes!) {
            if attrs.representedElementCategory == .SupplementaryView && attrs.representedElementKind == UICollectionElementKindSectionHeader {
                let newAttrs = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: attrs.indexPath)
                layoutAttributes![index] = newAttrs
            } else {
                let newAttributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                layoutAttributes!.append(newAttributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
        if elementKind == UICollectionElementKindSectionHeader {
            var y: CGFloat = 0.0
            var height = headerReferenceSize.height
            let posFromTop = collectionView!.contentOffset.y + collectionView!.contentInset.top

            if (posFromTop >= 134.0) {
                y = posFromTop - (headerReferenceSize.height - NAVBAR_HEIGHT)
            }
            if (posFromTop < 0) {
                y = posFromTop
                height = headerReferenceSize.height + -posFromTop
            }

            attributes.frame = CGRectMake(0.0, y, collectionView!.frame.width, height)
            attributes.zIndex = 1
        }
        return attributes
    }
}
