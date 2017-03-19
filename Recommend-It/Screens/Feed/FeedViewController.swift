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

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private enum ReuseIdentifier {
        static let header = "FeedHeader"
        static let recommendationCell = "RecommendationCell"
    }

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

        setupCollectionView()

        showMigrationMessageIfNecessary()
        self.getData()

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

        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.register(UINib(nibName: ReuseIdentifier.recommendationCell, bundle: nil), forCellWithReuseIdentifier: ReuseIdentifier.recommendationCell)
        (feedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = CGSize(width: 225, height: 175)
    }

    // MARK: - Data Helpers

    private func getData() {
        activityIndicator.startAnimating()
        recommendationsLoading = true

        DataProvider<Recommendation>().fetchData(privateDB: false, forCurrentUser: true) { [weak self] (recommendations: [Recommendation]) in

            self?.recommendationsLoading = false
            self?.recommendations = recommendations
            self?.activityIndicator.stopAnimating()
            self?.updateScreen()
        }
    }

    private func updateScreen() {

        guard !recommendationsLoading else {
            return
        }

        // FIXME: No idea why this is necessary. Posted question on SO for help: http://stackoverflow.com/questions/42891597/uicollectionview-cells-only-display-after-second-call-to-reloaddata
        feedCollectionView.reloadData()
        feedCollectionView.reloadData()

        initialEmptyView?.removeFromSuperview()

        if recommendations.count == 0 {
            initialEmptyView = UIView.loadFromNib(type: InitialEmptyView.self)

            if let initialEmptyView = initialEmptyView {
                initialEmptyView.frame = CGRect(x: 10.0, y: 140.0, width: view.bounds.width - 20.0, height: 375.0)
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

        guard let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as? RecommendationCell else {
            return UICollectionViewCell()
        }

        // cell.containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20.0).isActive = true
        // return cell
        return configure(cell: cell, recommendation: recommendations[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return feedCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseIdentifier.header, for: indexPath) as? FeedHeaderReusableView ?? UICollectionReusableView()
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

    // MARK: - Private helpers

    private func configure(cell: RecommendationCell, recommendation: Recommendation) -> RecommendationCell {

        cell.nameLabel.text = recommendation.name
        cell.notesLabel.text = recommendation.notes

        // if there's an image, show it
        if let thumbnailURLString = recommendation.thumbnailURL,
            let thumbailURL = URL(string: thumbnailURLString) {
            cell.image.sd_setImage(with: thumbailURL)
        } else {
            cell.image.image = UIImage(named: "RecImagePlaceholder")
        }

        if let location = recommendation.location {
            cell.locationLabel.text = location
        } else {
            cell.locationLabel.text = "Unknown Location"
        }

        cell.onTapYelp = { [weak self] in
            self?.didPressYelp(for: recommendation)
        }

        cell.onTapArchive = { [weak self] in
            self?.didPressArchive(for: recommendation)
        }

        cell.onTapRemove = { [weak self] in
            self?.didPressRemove(for: recommendation)
        }

        // Setup anchor constraints for correct sizing
        let widthConstraint = cell.containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20.0)
        widthConstraint.priority = 999.0
        widthConstraint.isActive = true

        // reset the delete overlay
        cell.confirmRemoveButton.isHidden = true
        cell.confirmRemoveButton.alpha = 0.0

        cell.layer.cornerRadius = 2.0

        return cell
    }

    // Gets the AddEditViewController from the AddEdit.storyboard
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

    // MARK: Actions

    private func didPressArchive(for recommendation: Recommendation) {

        let alert = UIAlertController(title: "Just so you know...", message: "The archive feature isn't ready for prime time quite yet. By continuing, you will set this recommendation as archived, which means it will no longer show on your feed, but there currently isn't a way to view recommendations you've archived. Don't fret - there will be soon!", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Let's do it!", style: .default) {
            [weak self] (action) in
            recommendation.archived = true
            CoreDataManager.sharedInstance.saveContext()
            self?.feedCollectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Nevermind, I'll wait", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {}
    }

    private func didPressYelp(for recommendation: Recommendation) {

        if let url = URL(string: "http://yelp.com/biz/\(recommendation.yelpId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func didPressRemove(for recommendation: Recommendation) {

        guard let recordId = recommendation.cloudKitRecordId else {
            return
        }

        DataProvider<Recommendation>().deleteRecord(recordId: recordId, privateDB: false)
        recommendations = recommendations.filter { $0.yelpId != recommendation.yelpId }
        updateScreen()
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
        present(getAddEditViewController(), animated: true, completion: nil)
    }

}
