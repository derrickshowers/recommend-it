//
//  AddEditViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import UITextView_Placeholder
import DataLayer

class AddEditViewController: UIViewController, DataProviderErrorDelegate {

    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Other
    var selectedYelpBiz: YelpBiz?
    var recommendationsDataProvider = DataProvider<Recommendation>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        recommendationsDataProvider.errorDelegate = self

        // show the blue version of nav controller
        navigationController?.navigationBar.makeDefaultBlue()

        notesTextView.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        configure()
    }

    // MARK: - DataProviderErrorDelegate

    func dataProviderDidError(error: Error?) {
        let title = "Something went wrong 😱"
        let message = "Yeah, yeah... Recommend It isn't all too smart when it comes to handling bad network connections, so that's likely the issue 😞.\n\nIt also could be you, though 😉! Make sure you're logged in to iCloud and Recommend It has permission to backup data (Settings -> iCloud -> iCloud Drive).\n\nAll else fails, why not give it another shot?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Private Helpers

    private func configure() {

        guard let selectedYelpBiz = selectedYelpBiz else {
            return
        }

        nameField.text = selectedYelpBiz.name
        scrollView.alwaysBounceVertical = true
        thumbnailImageView.sd_setImage(with: URL(string: selectedYelpBiz.thumbnailURL ?? ""), placeholderImage: UIImage(named: "RecImagePlaceholder"))
        notesTextView.placeholder = "What do you know about this place?"
        notesTextView.placeholderColor = UIColor.lightGray
        notesTextView.becomeFirstResponder()
    }

    // MARK: - IBActions

    @IBAction func cancelPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: UIButton) {

        guard let name = nameField.text,
            let notes = notesTextView.text,
            let yelpId = selectedYelpBiz?.yelpId else {
                return
        }

        sender.isEnabled = false

        // save the location
        var location = ""

        if let city = selectedYelpBiz?.city {
            location = "\(city)"
        }

        if let state = selectedYelpBiz?.state {
            if !location.isEmpty {
                location = "\(location), \(state)"
            } else {
                location = "\(state)"
            }
        }

        let recommendation = Recommendation(yelpId: yelpId, name: name, notes: notes, location: location, thumbnailURL: selectedYelpBiz?.thumbnailURL)

        recommendationsDataProvider.saveData(model: recommendation, privateDB: false) { (savedRecommendation: Recommendation) in
            NotificationCenter.default.post(name: Notification.Name("newRecommendationSaved"), object: nil, userInfo: ["recommendation": savedRecommendation])
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Presentation

    class func present(from viewController: UIViewController?, selectedYelpBiz: YelpBiz, completion: (() -> Void)? = nil) {

        guard let addEditViewController = UIStoryboard(name: "AddEdit", bundle: nil).instantiateInitialViewController() as? AddEditViewController else {
            return
        }

        addEditViewController.selectedYelpBiz = selectedYelpBiz
        viewController?.present(addEditViewController, animated: true, completion: completion)
    }
}
