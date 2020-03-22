//
//  PlacesViewController.swift
//  Assignment
//
//  Created by Martijn Breet on 20/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate enum PlacesSortingSegments : Int {
    case rating = 0
    case name = 1
    case openNow = 2
    case distance = 3
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .rating
        case 1: self = .name
        case 2: self = .openNow
        case 3: self = .distance
        default: return nil
        }
    }
}

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var userLocation = Location(lat: 52.378001, lng: 4.899570) // default location (Amsterdam CS)
    var searchRadius = 1000 // default search radius in meters
    var listOfPlaces = [Place]() {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.title = "Nearby places (\(self.listOfPlaces.count))"
            }
        }
    }

    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Actions
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        showSpinner(on: tableView)
        
        /* Because the Places API does not support multi-type search,
        * we need to make 3 separate api calls in order to show cafes, bars and restaurants.
        */
        let types = [PlaceTypes.bar, PlaceTypes.cafe, PlaceTypes.restaurant]
        listOfPlaces = [Place]() // start with an empty list of places
        
        // to wait for the completion of all three calls we use Dispatch Groups
        let dispatchGroup = DispatchGroup()

        for type in types {
            dispatchGroup.enter()

            PlacesAPIClient.shared.getNearByPlacesByRadius(location: userLocation, radius: searchRadius, type: type) { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(with: "API error: \(error.localizedDescription)")
                        dispatchGroup.leave()
                    }
                    
                case .success(let places):
                    DispatchQueue.main.async {
                        self.listOfPlaces.append(contentsOf: places)
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.removeSpinner(on: self.tableView)
            // some places are both listed as a bar, cafe AND restaurant
            // so we need to remove any duplicates
            self.listOfPlaces = Array(Set(self.listOfPlaces))
            
            // sort the places by rating
            self.listOfPlaces.sort(by: Place.rating)
            // showtime!
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        switch PlacesSortingSegments(rawValue: sender.selectedSegmentIndex) {
        case .rating: listOfPlaces.sort(by: Place.rating)
        case .name: listOfPlaces.sort(by: Place.name)
        case .openNow: listOfPlaces.sort(by: Place.openNow)
        case .distance: listOfPlaces.sort(by: Place.distance)
        default: listOfPlaces.sort(by: Place.rating)
        }
        tableView.reloadData()
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current user location ------
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        // Start location updates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell

        // Configure the cell...
        let place = listOfPlaces[indexPath.row]
        cell.placeNameLabel?.text = place.name
        if let rating = place.rating {
            cell.ratingLabel?.text = String(rating)
            cell.ratingView.rating = place.rating
            if let userRatingsTotal = place.userRatingsTotal {
                cell.reviewCountLabel?.text = "(\(userRatingsTotal))"
            }
        } else {
            // no rating
            cell.ratingLabel?.text = "No ratings or reviews"
            cell.ratingView.isHidden = true
            cell.reviewCountLabel.isHidden = true
        }
        
        if let openNow = place.openingHours?.openNow {
            if openNow {
                cell.openClosedLabel?.isHidden = false
                cell.openClosedLabel?.textColor = UIColor.systemGreen
                cell.openClosedLabel?.text = "Open"
            } else {
                cell.openClosedLabel?.isHidden = false
                cell.openClosedLabel?.textColor = UIColor.systemRed
                cell.openClosedLabel?.text = "Closed"
            }
        }
        else {
            cell.openClosedLabel?.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 72.0
    }
    
    // MARK: - CLLocationManager Delegate
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.userLocation = Location(lat: locValue.latitude, lng: locValue.longitude)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let detailVC = segue.destination as! PlaceDetailsViewController
            detailVC.place = listOfPlaces[indexPath.row]
        }
    }

}
