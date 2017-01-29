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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Other
    var feedHeaderView: FeedHeaderReusableView?
    var initialEmptyView: InitialEmptyView?
    var recommendationsLoading: Bool = false
    var recommendations = [Recommendation]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        // setup feed collection view
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self

        showMigrationMessageIfNecessary()
        self.getData()

        setupCollectionView()

        // Setup notifications for when new recommendations are saved
        NotificationCenter.default.addObserver(self, selector: #selector(newRecommendationSaved), name: Notification.Name("newRecommendationSaved"), object: nil)

        // make the navigation bar transparent
        self.navigationController?.navigationBar.makeLight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateScreen()
    }

    // MARK: - Setup

    private func setupCollectionView() {

        feedCollectionView.register(UINib(nibName: "RecommendationCell", bundle: nil), forCellWithReuseIdentifier: "RecommendationCell")
    }

    // MARK: - Data Helpers

    private func getData() {
        activityIndicator.startAnimating()
        recommendationsLoading = true

        DataProvider<Recommendation>().fetchData(privateDB: false, forCurrentUser: true) { [weak self] (recommendations: [Recommendation]) in
            self?.recommendationsLoading = false
            self?.activityIndicator.stopAnimating()
            self?.recommendations = recommendations
            self?.updateScreen()
        }
    }

    private func updateScreen() {

        guard !recommendationsLoading else {
            return
        }

        feedCollectionView.reloadData()

        initialEmptyView?.removeFromSuperview()

        if recommendations.count == 0 {
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

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations.count
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell

        cell.nameLabel.text = recommendations[(indexPath as NSIndexPath).row].name
        cell.notesLabel.text = recommendations[(indexPath as NSIndexPath).row].notes

        // if there's an image, show it
        if let thumbnailURLString = recommendations[(indexPath as NSIndexPath).row].thumbnailURL,
            let thumbailURL = URL(string: thumbnailURLString) {
            cell.image.sd_setImage(with: thumbailURL)
        } else {
            cell.image.image = UIImage(named: "RecImagePlaceholder")
        }

        if let location = recommendations[(indexPath as NSIndexPath).row].location {
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

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        /**
         TODO: Wish there was a cleaner way to do this, but using automatic sizing doesn't seem to work. Tried both
         approaches in this article: https://possiblemobile.com/2016/02/sizing-uicollectionviewcell-fit-multiline-uilabel/
         Setting estimatedItemSize removes cells from the view, `collectionView:cellForItemAt` doesn't even get called. :(
         For now, we'll just figure out the height of the label and use that to set the height of the cell.
         */

        let width = self.view.bounds.width - 20
        let height = heightFromDynamicLabel(initialHeight: 140.0, width: width, font: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightThin), text: recommendations[(indexPath as NSIndexPath).row].notes)

        return CGSize(width: self.view.bounds.width - 20, height: height)
    }

    // MARK: - UIScrollViewDelegate

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

    // MARK: - RecommendationCellDelegate

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
            self?.recommendations[cellIndex].archived = true
            CoreDataManager.sharedInstance.saveContext()
            self?.feedCollectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Nevermind, I'll wait", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {}
    }

    func didPressYelpAtIndex(_ cellIndex: Int) {
        let rec = recommendations[cellIndex]

        if let url = URL(string: "http://yelp.com/biz/\(rec.yelpId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func didPressConfirmRemove(_ cellIndex: Int) {

        guard let recordId = recommendations[cellIndex].cloudKitRecordId else {
            return
        }

        DataProvider<Recommendation>().deleteRecord(recordId: recordId, privateDB: false) { (recordId: CKRecordID?) in
            print("deleted")
        }
        recommendations.remove(at: cellIndex)
        updateScreen()
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

        recommendations.append(recommendation)
        updateScreen()
    }

    // MARK: - IBActions

    @IBAction func addPressed(_ sender: AnyObject) {
        self.present(getAddEditViewController(), animated: true, completion: nil)
    }

}
