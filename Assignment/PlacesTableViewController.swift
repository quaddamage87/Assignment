//
//  PlacesTableViewController.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit
import CoreLocation

class PlacesTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var myLocation = Location(lat: 52.327893, lng: 4.593639)
    var listOfPlaces = [Place]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = "\(self.listOfPlaces.count) places found"
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

        // start location updates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Actions
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        let placesRequest = PlacesAPIRequest()
        placesRequest.getNearByPlacesByRadius(location: myLocation, radius: 5000, type: .restaurant, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let places):
                self?.listOfPlaces = places
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfPlaces.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        cell.distanceLabel?.text = "500 m"
        if let openNow = place.openingHours?.openNow {
            if openNow {
                cell.openClosedLabel?.textColor = UIColor.green
                cell.openClosedLabel?.text = "Open"
            } else {
                cell.openClosedLabel?.textColor = UIColor.red
                cell.openClosedLabel?.text = "Closed"
            }
        }
        else {
            cell.openClosedLabel?.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 72.0
    }
    
    // MARK: - CLLocationManager Delegate
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
       self.myLocation = Location(lat: locValue.latitude, lng: locValue.longitude)
   }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let detailVC = segue.destination as! PlaceDetailsViewController
            detailVC.place = listOfPlaces[indexPath.row]
        }
    }

}
