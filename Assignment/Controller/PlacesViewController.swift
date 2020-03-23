//
//  PlacesViewController.swift
//  Assignment
//
//  Created by Martijn Breet on 20/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit
import CoreLocation

enum PlacesSortingSegments : Int {
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
    let METERS_IN_KM = 1000.0
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
        
        // reset sorting to by rating
        segmentedControl.selectedSegmentIndex = PlacesSortingSegments.rating.rawValue
        getNearByPlaces()
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
        
        getUserLocation()
    }
    
    // MARK: - Private methods
    
    func getNearByPlaces() {
        let types = [PlaceTypes.bar, PlaceTypes.cafe, PlaceTypes.restaurant]
        
        // user our own multi-type search
        PlacesAPIClient.shared.getNearByPlacesByRadius(location: userLocation, radius: searchRadius, types: types) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.showAlert(with: "API error: \(error.localizedDescription)")
                }
                
            case .success(let places):
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.listOfPlaces = places
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getUserLocation() {
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
    
    func populatePlaceCell(cell: PlaceCell, with place: Place) {
        // Populate the cell...
        
        // name
        cell.placeNameLabel?.text = place.name
        
        // rating
        if let rating = place.rating {
            cell.ratingView.isHidden = false
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
        
        // open now
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
        
        // distance
        if let distance = place.distance {
            if distance < METERS_IN_KM {
                cell.distanceLabel?.text = String(format: "%.0f m", distance)
            } else {
                cell.distanceLabel?.text = String(format: "%.1f km", distance)
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        let place = listOfPlaces[indexPath.row]
        
        populatePlaceCell(cell: cell, with: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 76.0
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
