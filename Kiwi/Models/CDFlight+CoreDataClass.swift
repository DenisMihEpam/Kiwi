//
//  CDFlight+CoreDataClass.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 13.12.2022.
//
//

import Foundation
import CoreData


public class CDFlight: NSManagedObject {
    init(from model: Flight) {
        self.id = model.id
        self.cityFrom = model.cityFrom
        self.cityTo = model.cityTo
        self.countryTo = model.countryTo.name
        self.created = Date()
        self.dTime = Date(timeIntervalSince1970: Double(model.dTime))
        self.distance = model.distance
        self.price = Int32(model.price)
        
    }
}
