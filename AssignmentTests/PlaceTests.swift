//
//  PlaceTests.swift
//  AssignmentTests
//
//  Created by Martijn Breet on 23/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import XCTest
@testable import Assignment

class PlaceTests: XCTestCase {
    
    var place: Place!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let loc = Location(lat: 52.378001, lng: 4.899570)
        let geo = Geometry(location: loc, viewport: Viewport(northeast: loc, southwest: loc))
        let open = OpeningHours(openNow: true)
        place = Place(geometry: geo, icon: nil, id: "a", name: "placeA", openingHours: open , photos: nil, placeID: "a", plusCode: nil, rating: 5, reference: nil, scope: nil, types: nil, userRatingsTotal: nil, vicinity: nil, distance: 500)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        place = nil
        super.tearDown()
    }

    func testEqualsWithSamePlace() {
        // given
        let placeA = place
        let placeB = place
        
        XCTAssertTrue(placeA == placeB)
    }
    
    func testEqualsWithSameObjectButDifferentPlaceID() {
        // given
        var placeA = place
        var placeB = place
        placeA?.placeID = "a"
        placeB?.placeID = "b"
        
        XCTAssertFalse(placeA == placeB)
    }
    
    func testSortByRating() {
        // given
        var placeA = place
        var placeB = place
        placeA?.rating = 5.0
        placeB?.rating = 4.0
        
        XCTAssertTrue(Place.rating(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByRatingWithRatedAndNonRated() {
        // given
        var placeA = place
        var placeB = place
        placeA?.rating = nil
        placeB?.rating = 5.0
        
        XCTAssertFalse(Place.rating(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByRatingWithAllNonRated() {
        // given
        var placeA = place
        var placeB = place
        placeA?.rating = nil
        placeB?.rating = nil
        
        XCTAssertFalse(Place.rating(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByName() {
        // given
        var placeA = place
        var placeB = place
        placeA?.name = "A"
        placeB?.name = "B"
        
        XCTAssertTrue(Place.name(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByNameWithSpecialChar() {
        // given
        var placeA = place
        var placeB = place
        placeA?.name = "A"
        placeB?.name = "'"
        
        XCTAssertFalse(Place.name(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByOpenNow() {
        // given
        var placeA = place
        var placeB = place
        placeA?.openingHours?.openNow = false
        placeB?.openingHours?.openNow = true
        
        XCTAssertFalse(Place.openNow(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByOpenNowWithOpenAndUnknown() {
        // given
        var placeA = place
        var placeB = place
        placeA?.openingHours = nil
        placeB?.openingHours?.openNow = true
        
        XCTAssertFalse(Place.openNow(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByOpenNowWithClosedAndUnknown() {
        // given
        var placeA = place
        var placeB = place
        placeA?.openingHours?.openNow = false
        placeB?.openingHours = nil
        
        XCTAssertFalse(Place.openNow(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByOpenNowWithdUnknownAndClosed() {
        // given
        var placeA = place
        var placeB = place
        placeA?.openingHours = nil
        placeB?.openingHours?.openNow = false
        
        XCTAssertTrue(Place.openNow(lhs: placeA!, rhs: placeB!))
    }
    
    func testSortByDistance() {
        // given
        var placeA = place
        var placeB = place
        placeA?.distance = 500
        placeB?.distance = 1000
        
        XCTAssertTrue(Place.distance(lhs: placeA!, rhs: placeB!))
    }

}
