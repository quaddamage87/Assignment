//
//  PlaceRequest.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation

enum PlacesAPIResource: String {
    case nearbysearch, details
}

private enum Parameters: String {
    case radius, location // required parameters
    
    case keyword // optional parameters
    case language
    case minprice
    case maxprice
    case opennow
    case rankby
    case type
    case fields
    case placeId = "place_id"
    case photoreference
    case maxwidth
}

private enum DetailsFields: String {
    case phonenumber = "international_phone_number"
    case addresscomponents = "address_components"
    case reviews = "reviews"
    case photos = "photos"
}

enum PlacesError: Error {
    case noDataAvailable
    case cannotProcessData
}

enum PlaceTypes: String {
    case cafe
    case bar
    case restaurant
}

private enum OutputFormats: String {
    case json
    case photo
}

struct PlacesAPIRequest {
    var urlComponents = URLComponents()
    let baseParameters: [URLQueryItem]
    let PROTOCOL = "https"
    let HOST = "maps.googleapis.com"
    let BASE_PATH = "/maps/api/place/"
    let OUTPUT_FORMAT = "json"
    let API_KEY = "<YOUR_GOOGLE_PLACES_API_KEY_HERE>"
    let DEFAULT_RADIUS = 500 //default radius of 500m
    let MAX_IMAGE_WIDTH = 256
    
    
    init() {
        urlComponents.scheme = PROTOCOL
        urlComponents.host = HOST
        let key = URLQueryItem(name: "key", value: API_KEY)
        baseParameters = [key]
    }
    
    private func fetch(with resource: PlacesAPIResource,
                       parameters: [URLQueryItem],
                       outputFormat: String,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void)  {
        var urlComponents = self.urlComponents
        urlComponents.path = "\(BASE_PATH + resource.rawValue)/\(outputFormat)"
        urlComponents.queryItems = self.baseParameters + parameters
        
        guard let url = urlComponents.url else {fatalError()}
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // MARK - Place Search
    
    private func getNearByPlaces(location: Location, radius: Int?, type: PlaceTypes,
                         rankBy: String?, completion: @escaping(Result<[Place], Error>) -> Void) {
        
        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: Parameters.location.rawValue, value: "\(location.lat),\(location.lng)"))
        
        // optional params
        if let radius = radius {
            parameters.append(URLQueryItem(name: Parameters.radius.rawValue, value: "\(radius)")) // radius
        }
        parameters.append(URLQueryItem(name: Parameters.type.rawValue, value: "\(type.rawValue)")) // type
        if let rankBy = rankBy {
            parameters.append(URLQueryItem(name: Parameters.rankby.rawValue, value: "\(rankBy)")) // rankBy
        }
        
        fetch(with: .nearbysearch, parameters: parameters, outputFormat: OutputFormats.json.rawValue) { (data, _, error) in
            guard let jsonData = data else {
                completion(.failure(error!))
                return
            }
            do {
                let decoder = JSONDecoder()
                let placesResponse = try decoder.decode(PlacesApiResponse.self, from: jsonData)
                let places = placesResponse.results
                completion(.success(places))
            } catch {
                print(error)
            }
        }
    }
    
    func getNearByPlacesByRadius(location: Location,
                                 radius: Int,
                                 type: PlaceTypes,
                                 completion: @escaping(Result<[Place], Error>) -> Void) {
        getNearByPlaces(location: location, radius: radius, type: .restaurant, rankBy: nil, completion: completion)
    }
    
    func getNearByPlacesByDistance(location: Location,
                                 type: PlaceTypes,
                                 completion: @escaping(Result<[Place], Error>) -> Void) {
        getNearByPlaces(location: location, radius: nil, type: .restaurant, rankBy: "distance", completion: completion)
    }
    
    // MARK - Place Details
    
    func getPlaceDetails(placeID: String,
                                 completion: @escaping(Result<PlaceDetails, Error>) -> Void) {
        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: Parameters.placeId.rawValue, value: placeID))
        var fields = [String]()
        fields.append(DetailsFields.phonenumber.rawValue)
        fields.append(DetailsFields.addresscomponents.rawValue)
        fields.append(DetailsFields.photos.rawValue)
        fields.append(DetailsFields.reviews.rawValue)
        parameters.append(URLQueryItem(name: Parameters.fields.rawValue, value: fields.joined(separator: ",")))
        
        fetch(with: .details, parameters: parameters, outputFormat: OutputFormats.json.rawValue) { (data, response, error) in
            guard let jsonData = data else {
                completion(.failure(error!))
                return
            }
            do {
                let decoder = JSONDecoder()
                let placeDetailsResponse = try decoder.decode(PlaceDetailsApiResponse.self, from: jsonData)
                let placeDetails = placeDetailsResponse.result
                completion(.success(placeDetails))
                
            } catch {
                print(error)
            }
        }
    }
    
    // MARK - Place Photos
    
    func getPlacePhotoURL(photoReference: String) -> URL {
        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: Parameters.photoreference.rawValue, value: photoReference))
        parameters.append(URLQueryItem(name: Parameters.maxwidth.rawValue, value: String(MAX_IMAGE_WIDTH)))
        var urlComponents = self.urlComponents
        urlComponents.path = "\(BASE_PATH + OutputFormats.photo.rawValue)"
        urlComponents.queryItems = self.baseParameters + parameters
        
        guard let url = urlComponents.url else {fatalError()}
        return url
    }
}
