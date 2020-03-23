//
//  PlaceRequest.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation
import CoreLocation

enum PlaceTypes: String {
    case cafe
    case bar
    case restaurant
}

// MARK -- API Resources / Endpoints

struct PlacesNearbySearchResource: APIResource {
    typealias Response = PlacesApiResponse
    
    var path: String = "/maps/api/place/nearbysearch/json"
    var httpRequestMethod: HTTPRequestMethod = .get
    var additionalHeaders: [String : String]?
    var httpBody: Data?
    var queryItems: [URLQueryItem]?
}

struct PlaceDetailsResource: APIResource {
    typealias Response = PlaceDetailsApiResponse
    
    var path: String = "/maps/api/place/details/json"
    var httpRequestMethod: HTTPRequestMethod = .get
    var additionalHeaders: [String : String]?
    var httpBody: Data?
    var queryItems: [URLQueryItem]?
}

struct PlacePhotoResource: APIResource {
    typealias Response = URL
    
    var path: String = "/maps/api/place/photo"
    var httpRequestMethod: HTTPRequestMethod = .get
    var additionalHeaders: [String : String]?
    var httpBody: Data?
    var queryItems: [URLQueryItem]?
}

class PlacesAPIClient : APIClient {
    static let shared = PlacesAPIClient()
    
    let API_KEY = "<INSERT_YOUR_PLACES_API_KEY_HERE>"
    let DEFAULT_RADIUS = 500 //default radius of 500m
    let MAX_IMAGE_WIDTH = 256
    
    var baseUrlComponents: URLComponents = {
        var components = URLComponents()
        components.host = "maps.googleapis.com"
        components.scheme = "https"
        return components
    }()
    
    func getNearByPlacesByRadius(location: Location,
                                 radius: Int,
                                 type: PlaceTypes,
                                 completion: @escaping(Result<[Place], APIError>) -> Void) {
        var resource = PlacesNearbySearchResource()
        resource.queryItems = [
        URLQueryItem(name: "key", value: API_KEY),
        URLQueryItem(name: "location", value: "\(location.lat),\(location.lng)"),
        URLQueryItem(name: "radius", value: "\(radius)"),
        URLQueryItem(name: "type", value: "\(type)")
        ]
        
        fetch(with: resource) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                completion(.success(result.results))
            }
        }
    }
    
    func getNearByPlacesByRadius(location: Location,
                                 radius: Int,
                                 types: [PlaceTypes],
                                 completion: @escaping(Result<[Place], APIError>) -> Void) {
        // to wait for the completion of all three calls we use Dispatch Groups
        let dispatchGroup = DispatchGroup()
        var listOfPlaces = [Place]()

        /* Because the Places API does not support multi-type search,
        * we need to make 3 separate api calls in order to show cafes, bars and restaurants.
        */
        for type in types {
            dispatchGroup.enter()

            getNearByPlacesByRadius(location: location, radius: radius, type: type) { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                        dispatchGroup.leave()
                    }
                    
                case .success(let places):
                    DispatchQueue.main.async {
                        listOfPlaces.append(contentsOf: places)
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            // places are listed by multiple types
            // so we need to remove any duplicates
            listOfPlaces = Array(Set(listOfPlaces))
            
            // calculate and update the distances of each place from user location
            listOfPlaces = self.populateDistances(of: listOfPlaces, basedOn: location)
            
            // sort the places by rating
            listOfPlaces.sort(by: Place.rating)
            // showtime!
            completion(.success(listOfPlaces))
        }
        
    }
    
    func populateDistances(of places: [Place], basedOn userLocation: Location) -> [Place] {
        // calculate and update the distances of each place from user location
        var updatedPlaces = places
        let userCoordinate = CLLocation(latitude: userLocation.lat, longitude: userLocation.lng)
        for i in 0..<updatedPlaces.count {
            let placeCoordinate = CLLocation(latitude:  places[i].geometry.location.lat, longitude:  places[i].geometry.location.lng)
            let distanceInMeters = placeCoordinate.distance(from: userCoordinate)
            updatedPlaces[i].distance = distanceInMeters
        }
        return updatedPlaces
    }
    
    func getPlaceDetails(placeID: String,
                                 completion: @escaping(Result<PlaceDetails, APIError>) -> Void) {
        var resource = PlaceDetailsResource()
        let fields = [
            "international_phone_number",
            "address_components",
            "reviews",
            "photos"
        ].joined(separator: ",")
        
        resource.queryItems = [
        URLQueryItem(name: "key", value: API_KEY),
        URLQueryItem(name: "place_id", value: "\(placeID)"),
        URLQueryItem(name: "fields", value: "\(fields)")
        ]
        
        fetch(with: resource) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                completion(.success(result.result))
            }
        }
    }
    
    func getPlacePhotoURL(photoReference: String) -> URL? {
        var resource = PlacePhotoResource()
        resource.queryItems = [
            URLQueryItem(name: "key", value: API_KEY),
            URLQueryItem(name: "photoreference", value: "\(photoReference)"),
            URLQueryItem(name: "maxwidth", value: "\(MAX_IMAGE_WIDTH)")
        ]
        guard
            let url = resource.buildUrl(withBaseUrl: baseUrlComponents.url!)
        else {
            NSLog("Couldn't generate place photo URL")
            return nil
        }
        return url
    }
}
