//
//  MockPersistence.swift
//  KiwiTests
//
//  Created by Denis Mikhaylovskiy on 15.12.2022.
//

import Foundation
@testable import Kiwi

class MockPersistence: Persistence {
    var saveFlightsCalled = false
    var getSavedIDsCalled = false
    var getLastSavedDateCalled = false
    var deleteAllFlightsCalled = false
    var saveImageCalled = false
    
    func saveFlights(_ flights: [Kiwi.Flight]) {
        saveFlightsCalled = true
    }
    
    func getSavedIDs() -> [String] {
        getSavedIDsCalled = true
        return []
    }
    
    func getLastSavedDate() -> Date? {
        getLastSavedDateCalled = true
        return Date(timeIntervalSince1970: 1)
    }
    
    func deleteAllFlights() {
        deleteAllFlightsCalled = true
    }
    
    func saveImage(data: Data, flight: Kiwi.Flight) {
        saveImageCalled = true
    }
}
