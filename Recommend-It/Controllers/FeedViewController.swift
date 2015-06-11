//
//  FeedViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/29/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    var recommendationStore: RecommendationStore?
    
    override func viewDidLoad() {
        // setup feed collection view
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.sharedApplication().delegate as! AppDelegate).recommendationStore
    }
    
    override func viewWillAppear(animated: Bool) {
        feedCollectionView.reloadData()
    }
    
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var aevc = getAddEditViewController()
        aevc.currentRecommendation = recommendationStore!.allRecommendations[indexPath.row]
        self.presentViewController(aevc, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let cell = feedCollectionView.cellForItemAtIndexPath(indexPath) {
            return CGSizeMake(self.view.bounds.width - 20, cell.frame.height)
        } else {
            return CGSizeMake(self.view.bounds.width - 20, 100)
        }
    }
    
    func getAddEditViewController() -> AddEditViewController {
        let sb = UIStoryboard(name: "AddEdit", bundle: nil)
        let aevc = sb.instantiateInitialViewController() as! AddEditViewController
        return aevc
    }
    
    @IBAction func addPressed(sender: AnyObject) {
        self.presentViewController(getAddEditViewController(), animated: true, completion: nil)
    }

}
