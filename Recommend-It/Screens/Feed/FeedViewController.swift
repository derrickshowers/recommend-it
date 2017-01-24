//
//  FeedViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/29/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import SDWebImage
import CloudKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RecommendationCellDelegate {

    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var feedCollectionView: UICollectionView!

    // MARK: Other
    var recommendationStore: RecommendationStore?
    var feedHeaderView: FeedHeaderReusableView?
    var initialEmptyView: InitialEmptyView?
    var recommendations: [Recommendation]?

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        // setup feed collection view
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self

        showMigrationMessageIfNecessary()
        self.getData()

        NotificationCenter.default.addObserver(self, selector: #selector(newRecommendationSaved), name: Notification.Name("newRecommendationSaved"), object: nil)

        // get reservations from the AppDelegate
        // recommendationStore = RecommendationStore.sharedInstance

        // make the navigation bar transparent
        self.navigationController?.navigationBar.makeLight()
    }

    // MARK: - Data and updaate helpers

    private func getData() {
        DataProvider<Recommendation>().fetchData(privateDB: false, forCurrentUser: true) { [weak self] (recommendations: [Recommendation]) in
            self?.recommendations = recommendations
            self?.updateScreen()
        }
    }

    private func updateScreen() {
        feedCollectionView.reloadData()

        initialEmptyView?.removeFromSuperview()

        if recommendations?.count == 0 {
            initialEmptyView = UIView.loadFromNib(type: InitialEmptyView.self)

            if let initialEmptyView = initialEmptyView {
                initialEmptyView.frame = CGRect(x: 10.0, y: 140.0, width: view.bounds.width - 20.0, height: view.bounds.height - 150.0)
                initialEmptyView.onTapAddRecommendation = { sender in
                    self.present(self.getAddEditViewController(), animated: true, completion: nil)
                }
                view.addSubview(initialEmptyView)
            }
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
        if let numOfRecs = recommendations?.count {
            return numOfRecs
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as! RecommendationCell

        cell.nameLabel.text = recommendations?[(indexPath as NSIndexPath).row].name
        cell.notesLabel.text = recommendations?[(indexPath as NSIndexPath).row].notes

        // if there's an image, show it
        if let thumbnailURLString = recommendations?[(indexPath as NSIndexPath).row].thumbnailURL,
            let thumbailURL = URL(string: thumbnailURLString) {
            cell.image.sd_setImage(with: thumbailURL)
        } else {
            cell.image.image = UIImage(named: "RecImagePlaceholder")
        }

        if let location = recommendations?[(indexPath as NSIndexPath).row].location {
            cell.locationLabel.text = location
        } else {
            cell.locationLabel.text = "Unknown Location"
        }

        cell.delegate = self
        cell.cellIndex = (indexPath as NSIndexPath).row

        // reset the delete overlay
        cell.confirmRemoveButton.isHidden = true
        cell.confirmRemoveButton.alpha = 0.0

        cell.layer.cornerRadius = 2.0

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        feedHeaderView = feedCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeader", for: indexPath) as? FeedHeaderReusableView
        return feedHeaderView!
    }

    // MARK: DelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width - 20
        let height = heightFromDynamicLabel(initialHeight: 140.0, width: width, font: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightThin), text: recommendations?[(indexPath as NSIndexPath).row].notes)
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
        let alert = UIAlertController(title: "Just so you know...", message: "The archive feature isn't ready for prime time quite yet. By continuing, you will set this recommendation as archived, which means it will no longer show on your feed, but there currently isn't a way to view recommendations you've archived. Don't fret - there will be soon!", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Let's do it!", style: .default) {
            [weak self] action in
            self?.recommendations?[cellIndex].archived = true
            CoreDataManager.sharedInstance.saveContext()
            self?.feedCollectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Nevermind, I'll wait", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {}
    }

    func didPressYelpAtIndex(_ cellIndex: Int) {
        let rec = recommendations?[cellIndex]

        if let id = rec?.yelpId, let url = URL(string: "http://yelp.com/biz/\(id)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func didPressConfirmRemove(_ cellIndex: Int) {

        guard let recordId = recommendations?[cellIndex].cloudKitRecordId else {
            return
        }

        DataProvider<Recommendation>().deleteRecord(recordId: recordId, privateDB: false) { (recordId: CKRecordID?) in
            print("deleted")
        }
        recommendations?.remove(at: cellIndex)
        feedCollectionView.reloadData()
    }

    // MARK: - Private helpers

    /// Gets the AddEditViewController from the AddEdit.storyboard
    private func getAddEditViewController() -> AddEditViewController {
        let sb = UIStoryboard(name: "AddEdit", bundle: nil)
        let aevc = sb.instantiateInitialViewController() as! AddEditViewController
        return aevc
    }

    private func showMigrationMessageIfNecessary() {

        let migrationStoryboard = UIStoryboard(name: "MigrationViewController", bundle: nil)

        guard let migrationViewController = migrationStoryboard.instantiateInitialViewController(),
            !UserDefaults.standard.bool(forKey: MigrationViewController.UserDefaultsKey.messageShown) else {
            return
        }

        self.present(migrationViewController, animated: true, completion: nil)
    }

    // MARK: - Notifications

    @objc private func newRecommendationSaved(notification: Notification) {

        guard let recommendation = notification.userInfo?["recommendation"] as? Recommendation else {
            return
        }

        recommendations?.append(recommendation)
        updateScreen()
    }

    // MARK: - IBAction Functions

    @IBAction func addPressed(_ sender: AnyObject) {
        self.present(getAddEditViewController(), animated: true, completion: nil)
    }

}
