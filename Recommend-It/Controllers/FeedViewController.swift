//
//  FeedViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/29/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RecommendationCellDelegate {

    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var initialInformationView: UIView!

    // MARK: Other
    var recommendationStore: RecommendationStore?
    var feedHeaderView: FeedHeaderReusableView?

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        // setup feed collection view
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self

        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.shared.delegate as! AppDelegate).recommendationStore

        // make the navigation bar transparent
        self.navigationController?.navigationBar.makeLight()
    }

    override func viewWillAppear(_ animated: Bool) {
        feedCollectionView.reloadData()

        if recommendationStore?.allRecommendations.count > 0 {
            self.initialInformationView.hidden = true
        }

        if self.feedCollectionView.bounds.origin.y < 134.0 {
            navigationController?.navigationBar.makeLight()
        } else {
            navigationController?.navigationBar.makeDefaultBlue()
        }
    }

    // MARK: - CollectionView Methods
    // MARK: Datasource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfRecs = recommendationStore?.allRecommendations.count {
            return numOfRecs
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as! RecommendationCell

        cell.nameLabel.text = recommendationStore?.allRecommendations[(indexPath as NSIndexPath).row].name
        cell.notesLabel.text = recommendationStore?.allRecommendations[(indexPath as NSIndexPath).row].notes

        // if there's an image, show it
        if let imageData = recommendationStore?.allRecommendations[(indexPath as NSIndexPath).row].thumbnail {
            cell.image.image = UIImage(data: imageData as Data, scale: 1.0)!
        } else {
            cell.image.image = UIImage(named: "RecImagePlaceholder")
        }

        if let location = recommendationStore?.allRecommendations[(indexPath as NSIndexPath).row].location {
            cell.locationLabel.text = location
        } else {
            cell.locationLabel.text = "Unknown Location"
        }

        cell.delegate = self
        cell.cellIndex = (indexPath as NSIndexPath).row

        // reset the delete overlay
        cell.confirmRemoveButton.isHidden = true
        cell.confirmRemoveButton.alpha = 0.0

        // make it pretty
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath

        // fix autolayout bug
        // http://stackoverflow.com/questions/27197813/autolayout-is-complaining-about-leading-trailing-space-for-uiimageview
        cell.contentView.frame = cell.bounds

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        feedHeaderView = feedCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeader", for: indexPath) as? FeedHeaderReusableView
        return feedHeaderView!
    }

    // MARK: DelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width - 20
        let height = heightFromDynamicLabel(initialHeight: 140.0, width: width, font: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightThin), text: recommendationStore!.allRecommendations[(indexPath as NSIndexPath).row].notes)
        return CGSize(width: self.view.bounds.width - 20, height: height)
    }

    // MARK: - ScrollView Methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + 64.0

        // first we need to check if the view is loaded, otherwise this will be applied to stacked views
        if self.isViewLoaded && view.window != nil {
            if let feedHeaderView = feedHeaderView {
                if offset < 134.0 {
                    feedHeaderView.backgroundColor = UIColor(red: 97/255, green: 131/255, blue: 166/255, alpha: 1.0)
                    feedHeaderView.feedHeaderImage.alpha = 0.8 - (offset / 134.0)
                    navigationController?.navigationBar.makeLight()
                } else {
                    feedHeaderView.backgroundColor = UIColor.clear
                    navigationController?.navigationBar.makeDefaultBlue()
                }
            }
        }
    }

    // MARK: - RecommendationCell Methods
    func didPressRemoveAtIndex(_ cellIndex: Int) {
        let cell = feedCollectionView.cellForItem(at: IndexPath(item: cellIndex, section: 0)) as! RecommendationCell
        cell.confirmRemoveButton.isHidden = false
        cell.cancelRemoveButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            cell.confirmRemoveButton.alpha = 0.80
            cell.cancelRemoveButton.alpha = 1.0
        })
    }
    func didPressArchiveAtIndex(_ cellIndex: Int) {
        recommendationStore?.allRecommendations[cellIndex].archived = true
        feedCollectionView.reloadData()
    }
    func didPressYelpAtIndex(_ cellIndex: Int) {
        UIAlertView(title: "Coming Soon", message: "This feature has not yet been enabled", delegate: nil, cancelButtonTitle: "Ok").show()
    }
    func didPressConfirmRemove(_ cellIndex: Int) {
        recommendationStore?.allRecommendations.remove(at: cellIndex)
        feedCollectionView.deleteItems(at: [IndexPath(item: cellIndex, section: 0)])
        feedCollectionView.reloadSections(IndexSet(integer: 0))
    }

    // MARK: - Helper Functions

    /// Gets the AddEditViewController from the AddEdit.storyboard
    func getAddEditViewController() -> AddEditViewController {
        let sb = UIStoryboard(name: "AddEdit", bundle: nil)
        let aevc = sb.instantiateInitialViewController() as! AddEditViewController
        return aevc
    }

    // MARK: - IBAction Functions

    @IBAction func addPressed(_ sender: AnyObject) {
        self.present(getAddEditViewController(), animated: true, completion: nil)
    }

}
