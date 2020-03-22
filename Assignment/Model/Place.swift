//
//  Place.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation

struct PlacesApiResponse: Codable {
    var htmlAttributions: [String]
    var nextPageToken: String
    var results: [Place]
    var status: String

    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case nextPageToken = "next_page_token"
        case results, status
    }
}

// MARK: - Result
struct Place: Codable {
    var geometry: Geometry
    var icon: String
    var id, name: String
    var openingHours: OpeningHours?
    var photos: [Photo]?
    var placeID: String
    var plusCode: PlusCode?
    var rating: Double?
    var reference, scope: String
    var types: [String]
    var userRatingsTotal: Int?
    var vicinity: String
    var distance: Int?

    enum CodingKeys: String, CodingKey {
        case geometry, icon, id, name
        case openingHours = "opening_hours"
        case photos
        case placeID = "place_id"
        case plusCode = "plus_code"
        case rating, reference, scope, types
        case userRatingsTotal = "user_ratings_total"
        case vicinity
        case distance
    }
}

extension Place {
    static func rating (lhs: Place, rhs: Place) -> Bool {
        lhs.rating ?? 0 > rhs.rating ?? 0
    }
    
    static func name (lhs: Place, rhs: Place) -> Bool {
        lhs.name < rhs.name
    }
    
    static func openNow (lhs: Place, rhs: Place) -> Bool {
        var result = false
        if let openingHoursA = lhs.openingHours {
            if let openingHoursB = rhs.openingHours {
                result = (openingHoursA.openNow ? 1 : 0) > (openingHoursB.openNow ? 1 : 0)
            } else {
                result = true // open/closed take precedence over unknown
            }
        } else if let openingHoursB = rhs.openingHours {
            if !openingHoursB.openNow {
                result = true // put A(unknown opening hours) in front of B
            } else {
                result = false
            }
        }
        return result
    }
    
    static func distance (lhs: Place, rhs: Place) -> Bool {
        lhs.distance ?? 0 < rhs.distance ?? 0
    }
    
//    func sortByRating(a: Place, b: Place) -> Bool {
//        a.rating ?? 0 < b.rating ?? 0
//    }
//    func sortByName(a: Place, b: Place) -> Bool {
//        a.rating ?? 0 < b.rating ?? 0
//    }
}

// MARK: - Geometry
struct Geometry: Codable {
    var location: Location
    var viewport: Viewport
}

// MARK: - Location
struct Location: Codable {
    var lat, lng: Double
}

// MARK: - Viewport
struct Viewport: Codable {
    var northeast, southwest: Location
}

// MARK: - OpeningHours
struct OpeningHours: Codable {
    var openNow: Bool

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// MARK: - Photo
struct Photo: Codable {
    var height: Int
    var htmlAttributions: [String]
    var photoReference: String
    var width: Int

    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
}

// MARK: - PlusCode
struct PlusCode: Codable {
    var compoundCode, globalCode: String

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
