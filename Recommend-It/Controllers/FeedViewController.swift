//
//  FeedViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/29/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var feedCollectionView: UICollectionView!

    // MARK: Other
    var recommendationStore: RecommendationStore?
    var feedHeaderView: FeedHeaderReusableView?

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        // setup feed collection view
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.sharedApplication().delegate as! AppDelegate).recommendationStore

        // make the navigation bar transparent
        self.navigationController?.navigationBar.makeLight()
    }

    override func viewWillAppear(animated: Bool) {
        feedCollectionView.reloadData()
    }

    // MARK: - CollectionView Methods
    // MARK: Datasource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfRecs = recommendationStore?.allRecommendations.count {
            return numOfRecs
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCellWithReuseIdentifier("LocationCell", forIndexPath: indexPath) as! RecomendationCell
        
        cell.nameLabel.text = recommendationStore?.allRecommendations[indexPath.row].name
        cell.notesLabel.text = recommendationStore?.allRecommendations[indexPath.row].notes
        
        // if there's an image, show it
        if let imageData = recommendationStore?.allRecommendations[indexPath.row].thumbnail {
            cell.image.image = UIImage(data: imageData, scale: 1.0)!
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        feedHeaderView = feedCollectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FeedHeader", forIndexPath: indexPath) as? FeedHeaderReusableView
        return feedHeaderView!
    }

    // MARK: Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var aevc = getAddEditViewController()
        aevc.currentRecommendation = recommendationStore!.allRecommendations[indexPath.row]
        self.showViewController(aevc, sender: self)
    }
    
    // MARK: DelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let cell = feedCollectionView.cellForItemAtIndexPath(indexPath) {
            return CGSizeMake(self.view.bounds.width - 20, cell.frame.height)
        } else {
            return CGSizeMake(self.view.bounds.width - 20, 100)
        }
    }

    // MARK: - ScrollView Methods

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + 64.0
        if let feedHeaderView = feedHeaderView {
            if offset < 134.0 {
                feedHeaderView.feedHeaderImage.alpha = 0.8 - (offset / 134.0)
            } else {
                feedHeaderView.feedHeaderImage.alpha = 0.0
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Gets the AddEditViewController from the AddEdit.storyboard
    func getAddEditViewController() -> AddEditViewController {
        let sb = UIStoryboard(name: "AddEdit", bundle: nil)
        let aevc = sb.instantiateInitialViewController() as! AddEditViewController
        return aevc
    }
    
    // MARK: - IBAction Functions
    
    @IBAction func addPressed(sender: AnyObject) {
        self.presentViewController(getAddEditViewController(), animated: true, completion: nil)
    }

}
