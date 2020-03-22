//
//  PlacesDetailViewController.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit
import SDWebImage

class PlaceDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var place: Place?
    var details: PlaceDetails?
    var listOfReviews = [Review]()

    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reviewsTableView.delegate = self
        self.reviewsTableView.dataSource = self
        
        if let place = place {
            // fill our views with the content
            placeNameLabel.text = place.name
            
            if let rating = place.rating {
                ratingLabel.text = String(rating)
                ratingView.rating = place.rating
                if let userRatingsTotal = place.userRatingsTotal {
                    reviewCountLabel.text = "(\(userRatingsTotal))"
                }
            } else {
                // no rating
                ratingLabel.text = "No ratings or reviews"
                ratingView.isHidden = true
                reviewCountLabel.isHidden = true
            }
        }
        
        // Feth the place details
        let placesRequest = PlacesAPIClient()
        
        if let place = place {
            placesRequest.getPlaceDetails(placeID: place.placeID, completion: { [weak self] result in
                    switch result {
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self?.showAlert(with: "API error: \(error.localizedDescription)")
                            }
                        case .success(let details):
                            self?.details = details
                            self?.listOfReviews = details.reviews
                            self?.fillDetails()
                    }
            })
        }
        

        
    }

    func fillDetails() -> Void {
        // load photos
        if let photos = details?.photos {
            if photos.count > 0 {
                let placesRequest = PlacesAPIClient()
                var imageUrl = placesRequest.getPlacePhotoURL(photoReference: photos[0].photoReference)
                leftImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
                if photos.count > 1 {
                    imageUrl = placesRequest.getPlacePhotoURL(photoReference: photos[1].photoReference)
                    rightImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named:
                    "placeholder.png"))
                }
                
            }
        }
        // reload our review table view
        DispatchQueue.main.async {
            self.reviewsTableView.reloadData()
        }
    
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        175
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        
        // Configure the cell...
        let review = listOfReviews[indexPath.row]
        guard let imageUrl = URL(string: review.profilePhotoURL) else {fatalError()}
        cell.profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
        cell.authorLabel.text = review.authorName
//        cell.ratingView.rating = Double(review.rating)
        cell.relativeTimeLabel.text = review.relativeTimeDescription
        cell.reviewTextLabel.text = review.text
        
        return cell
    }
}
