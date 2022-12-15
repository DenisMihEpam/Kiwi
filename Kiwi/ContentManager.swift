//
//  ContentManager.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 13.12.2022.
//

import Foundation
import Combine

class ContentManager: ObservableObject {
    private var subscriptions = [AnyCancellable]()
    var api: Networking
    var persistenceController: Persistence
    @Published var uppdating: Bool = false
    @Published var error: APIError? = nil
    
    private lazy var needUpdates: Bool = {
        guard let contentDate =  persistenceController.getLastSavedDate() else { return true}
        return !Calendar.current.isDate(contentDate, inSameDayAs: Date())
    }()
    
    init(api: Networking, persistenceController: Persistence) {
        self.api = api
        self.persistenceController = persistenceController
    }
    
    
    func checkUpdates() {
        if needUpdates {
            uppdating = true
            api.flights()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                      self.error = error
                        self.uppdating = false
                    }
                },
                      receiveValue: {[weak self] in
                    guard let self = self else { return }
                    self.persistenceController.deleteAllFlights()
                    self.persistenceController.saveFlights($0)
                    self.uppdating = false
                    self.downloadImages(for: $0)
                })
                .store(in: &subscriptions)
        }
    }
    
    private func downloadImages(for flights: [Flight]) {
        flights.forEach { flight in
            api.flightImage(flight: flight)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: {[weak self] in
                    self?.persistenceController.saveImage(data: $0, flight: flight)
                })
                .store(in: &subscriptions)
        }
    }
}
