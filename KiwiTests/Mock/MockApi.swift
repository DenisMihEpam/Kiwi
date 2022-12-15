//
//  MockApi.swift
//  KiwiTests
//
//  Created by Denis Mikhaylovskiy on 15.12.2022.
//

import Foundation
import Combine
import UIKit
@testable import Kiwi

class MockApi : Networking {
    let flight = Flight(id: "1", cityFrom: "Prague", cityTo: "Milan", countryTo: Country(code: "It", name: "Italy"), dTime: 1673169600, distance: 100, price: 100)
    
    func flights() -> AnyPublisher<[Kiwi.Flight], Kiwi.APIError> {
        let flights = [flight]
        return flights
            .publisher
            .collect()
            .mapError { error -> APIError in
                return APIError.addressUnreachable(URL(string: "https:google.com")!)
            }
            .print()
            .eraseToAnyPublisher()
    }

    func flightImage(flight: Kiwi.Flight) -> AnyPublisher<Data, Kiwi.APIError> {
        let data = UIImage(named: "placeholder")!.jpegData(compressionQuality: 1)!
        return [data]
            .publisher
            .mapError { error -> APIError in
                return APIError.addressUnreachable(URL(string: "https:google.com")!)
            }
            .print()
            .eraseToAnyPublisher()
    }
    
    
}
