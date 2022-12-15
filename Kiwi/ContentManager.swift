//
//  ContentManager.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 13.12.2022.
//

import Foundation
import Combine

protocol ContentManaging: ObservableObject {
    var uppdating: Bool {get}
    var error: API.Error? {get}
    func checkUpdates()
}

class ContentManager: ContentManaging {
    private var subscriptions = [AnyCancellable]()
    @Published var uppdating: Bool
    @Published var error: API.Error? = nil
    
    private var needUpdates: Bool = {
        guard let contentDate =  PersistenceController.shared.getLastSavedDate() else { return true}
        return !Calendar.current.isDate(contentDate, inSameDayAs: Date())
    }()
    
    init() {
        self.uppdating = needUpdates
        checkUpdates()
    }
    
    
    func checkUpdates() {
        if needUpdates {
            API().flights()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                      self.error = error
                        self.uppdating = false
                    }
                },
                      receiveValue: {[weak self] in
                    PersistenceController.shared.deleteAllFlights()
                    PersistenceController.shared.saveFlights($0)
                    self?.uppdating = false
                    self?.downloadImages(for: $0)
                })
                .store(in: &subscriptions)
        }
    }
    
    private func downloadImages(for flights: [Flight]) {
        flights.forEach { flight in
            API().flightImage(flight: flight)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: {
                    PersistenceController.shared.saveImage(data: $0, flight: flight)
                })
                .store(in: &subscriptions)
        }
    }
}
