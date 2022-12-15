//
//  CDFlight+CoreDataProperties.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 13.12.2022.
//
//

import Foundation
import CoreData


extension CDFlight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFlight> {
        return NSFetchRequest<CDFlight>(entityName: "CDFlight")
    }

    @NSManaged public var cityFrom: String
    @NSManaged public var cityTo: String
    @NSManaged public var countryTo: String
    @NSManaged public var created: Date
    @NSManaged public var distance: Double
    @NSManaged public var dTime: Date
    @NSManaged public var id: String
    @NSManaged public var price: Int32
    @NSManaged public var image: Data?

}

extension CDFlight : Identifiable {

}
