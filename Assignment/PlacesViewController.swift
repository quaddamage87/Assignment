//
//  PlacesViewController.swift
//  Assignment
//
//  Created by Martijn Breet on 20/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit
import CoreLocation

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var userLocation = Location(lat: 52.378001, lng: 4.899570)
    var searchRadius = 1000 // default search radius in meters
    var listOfPlaces = [Place]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Actions
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        showSpinner(on: tableView)
        PlacesAPIClient.shared.getNearByPlacesByRadius(location: userLocation, radius: searchRadius, type: .restaurant) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.removeSpinner(on: self.tableView)
                    self.showAlert(with: "API error: \(error.localizedDescription)")
                }
                
                
            case .success(let places):
                DispatchQueue.main.async {
                    self.removeSpinner(on: self.tableView)
                    self.listOfPlaces = places
                    self.tableView.reloadData()
                }
            }
        }
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
    
    // MARK - private methods
    
//    private func getNearByPlaces() {
//        let placesRequest = PlacesAPIRequest()
//        placesRequest.getNearByPlacesByRadius(location: myLocation, radius: 5000, type: .restaurant, completion: { [weak self] result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let places):
//                self?.listOfPlaces = places
//            }
//        })
//    }
    
    
    
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
                cell.openClosedLabel?.textColor = UIColor.green
                cell.openClosedLabel?.text = "Open"
            } else {
                cell.openClosedLabel?.isHidden = false
                cell.openClosedLabel?.textColor = UIColor.red
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
