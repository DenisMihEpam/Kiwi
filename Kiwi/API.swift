//
//  API.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import Foundation
import Combine
import UIKit

protocol Networking {
    func flights() -> AnyPublisher<[Flight], APIError>
    func flightImage(flight: Flight) -> AnyPublisher<Data, APIError>
}

enum APIError: LocalizedError, Identifiable {
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

struct API: Networking {
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
    
    var maxFlights = 5
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
    
    func flights() -> AnyPublisher<[Flight], APIError> {
        let savedIDs = PersistenceController.shared.getSavedIDs()
        return urlSesion(url: EndPoint.flightsURL.url)
            .decode(type: Response.self, decoder: decoder)
            .mapError { error -> APIError in
                switch error {
                case is URLError:
                    return APIError.addressUnreachable(EndPoint.flightsURL.url)
                default:
                    return APIError.invalidResponse
                }
            }
            .map{$0.data}
            .flatMap { entities -> AnyPublisher<Flight, APIError> in
                Publishers.Sequence(sequence: entities).eraseToAnyPublisher()
            }
            .filter({ flight in
                !savedIDs.contains(flight.id)
            })
            .prefix(maxFlights)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func flightImage(flight: Flight) -> AnyPublisher<Data, APIError> {
        return urlSesion(url: EndPoint.imageURL(flight).url)
            .mapError { error -> APIError in
                return APIError.addressUnreachable(EndPoint.imageURL(flight).url)
            }
            .eraseToAnyPublisher()
    }
    
}
