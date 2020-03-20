//
//  PlaceDetails.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation

// MARK: - ResultSet
struct PlaceDetailsApiResponse: Codable {
    var htmlAttributions: [String]
    var result: PlaceDetails
    var status: String

    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case result, status
    }
}

// MARK: - Result
struct PlaceDetails: Codable {
    var addressComponents: [AddressComponent]
    var adrAddress, formattedAddress, formattedPhoneNumber: String?
    var geometry: Geometry?
    var icon: String?
    var id: String?
    var internationalPhoneNumber: String
    var name: String?
    var openingHours: OpeningHoursDetail?
    var photos: [PhotoDetail]
    var placeID: String?
    var plusCode: PlusCode?
    var rating: Double?
    var reference: String?
    var reviews: [Review]
    var scope: String?
    var types: [String]?
    var url: String?
    var userRatingsTotal, utcOffset: Int?
    var vicinity: String?
    var website: String?

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case adrAddress = "adr_address"
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case geometry, icon, id
        case internationalPhoneNumber = "international_phone_number"
        case name
        case openingHours = "opening_hours"
        case photos
        case placeID = "place_id"
        case plusCode = "plus_code"
        case rating, reference, reviews, scope, types, url
        case userRatingsTotal = "user_ratings_total"
        case utcOffset = "utc_offset"
        case vicinity, website
    }
}

// MARK: - AddressComponent
struct AddressComponent: Codable {
    var longName, shortName: String
    var types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

// MARK: - OpeningHours
struct OpeningHoursDetail: Codable {
    var openNow: Bool
    var periods: [Period]
    var weekdayText: [String]

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }
}

// MARK: - Period
struct Period: Codable {
    var close, periodOpen: Close

    enum CodingKeys: String, CodingKey {
        case close
        case periodOpen = "open"
    }
}

// MARK: - Close
struct Close: Codable {
    var day: Int
    var time: String
}

// MARK: - Photo
struct PhotoDetail: Codable {
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

// MARK: - Review
struct Review: Codable {
    var authorName: String
    var authorURL: String
    var language: String
    var profilePhotoURL: String
    var rating: Int
    var relativeTimeDescription, text: String
    var time: Int

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case authorURL = "author_url"
        case language
        case profilePhotoURL = "profile_photo_url"
        case rating
        case relativeTimeDescription = "relative_time_description"
        case text, time
    }
}





