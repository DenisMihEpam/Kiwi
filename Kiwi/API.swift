//
//  API.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import Foundation
import Combine
import UIKit

struct API {
    /// API Errors.
    enum Error: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        case addressUnreachable(URL)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Unexpected server response."
            case .addressUnreachable(let url): return "Server is unreachable. URL: \(url)"
            }
        }
    }
    
    /// API endpoints.
    enum EndPoint {
        case flightsURL
        case imageURL(Flight)
        
        var url: URL {
            switch self {
            case .flightsURL:
                return URL(string: "https://api.skypicker.com/flights?v=3&sort=popularity&asc=0&locale=en&daysInDestinationFrom=&daysInDestinationTo=&affilid=&children=0&infants=0&flyFrom=49.2-16.61-250km&to=anywhere&featureName=aggregateResults&typeFlight=oneway&one_per_date=0&oneforcity=1&wait_for_refresh=0&adults=1&limit=45&partner=skypicker&fly_from=prague_cz")!
            case .imageURL(let flight):
                let baseImageURL = URL(string: "https://images.kiwi.com/photos/600x330")!
                let imageName = "\(flight.cityTo.lowercased())_\(flight.countryTo.code.lowercased()).jpg"
                let imageURL = baseImageURL.appendingPathComponent(imageName)
                return imageURL
            }
        }
    }
    
    /// Maximum number of stories to fetch (reduce for lower API strain during development).
    var maxFlights = 5
    
    /// A shared JSON decoder to use in calls.
    private let decoder = JSONDecoder()
    
    private let apiQueue = DispatchQueue(label: "API",
                                         qos: .default,
                                         attributes: .concurrent)
    
    func urlSesion(url: URL) -> AnyPublisher<Data, URLError> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: apiQueue)
            .map(\.data)
            .eraseToAnyPublisher()
        
    }
    
    func flights() -> AnyPublisher<[Flight], Error> {
        let savedIDs = PersistenceController.shared.getSavedIDs()
        return urlSesion(url: EndPoint.flightsURL.url)
            .decode(type: Response.self, decoder: decoder)
            .mapError { error -> API.Error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(EndPoint.flightsURL.url)
                default:
                    return Error.invalidResponse
                }
            }
            .map{$0.data}
            .flatMap { entities -> AnyPublisher<Flight, Error> in
                Publishers.Sequence(sequence: entities).eraseToAnyPublisher()
            }
            .filter({ flight in
                !savedIDs.contains(flight.id)
            })
            .prefix(maxFlights)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func flightImage(flight: Flight) -> AnyPublisher<Data, Error> {
        return urlSesion(url: EndPoint.imageURL(flight).url)
            .mapError { error -> API.Error in
                return Error.addressUnreachable(EndPoint.imageURL(flight).url)
            }
            .eraseToAnyPublisher()
    }
    
}
