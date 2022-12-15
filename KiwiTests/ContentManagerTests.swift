//
//  KiwiTests.swift
//  KiwiTests
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import XCTest
@testable import Kiwi

final class KiwiTests: XCTestCase {
    var sut: ContentManager!
    var mockPersistence: MockPersistence!
    
    override func setUpWithError() throws {
        let mockApi = MockApi()
        mockPersistence = MockPersistence()
        sut = ContentManager(api: mockApi, persistenceController: mockPersistence)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_checkUpdates() throws {
        XCTAssertFalse(mockPersistence.saveFlightsCalled)
        XCTAssertFalse(mockPersistence.deleteAllFlightsCalled)
        XCTAssertFalse(mockPersistence.saveImageCalled)
        sut.checkUpdates()
        let expectation = expectation(description: "contentManager")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[self] in
            XCTAssertTrue(self.mockPersistence.saveFlightsCalled)
            XCTAssertTrue(self.mockPersistence.deleteAllFlightsCalled)
            XCTAssertTrue(self.mockPersistence.saveImageCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6)
    }

}
