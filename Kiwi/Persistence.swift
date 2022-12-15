//
//  Persistence.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        return result
    }()

    let container: NSPersistentContainer
    var moc: NSManagedObjectContext

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Kiwi")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        moc = container.viewContext
    }
    
    func saveFlights(_ flights: [Flight]) {
        flights.forEach { model in
            let newItem = CDFlight(context: moc)
            newItem.id = model.id
            newItem.cityFrom = model.cityFrom
            newItem.cityTo = model.cityTo
            newItem.countryTo = model.countryTo.name
            newItem.created = Date()
            newItem.dTime = Date(timeIntervalSince1970: Double(model.dTime))
            newItem.distance = model.distance
            newItem.price = Int32(model.price)
        }
        do {
            try? moc.save()
        } catch {
            print("Error: Unable save flights to database")
        }
    }
    func getSavedIDs() -> [String] {
        let fetchRequest = NSFetchRequest<CDFlight>(entityName: "CDFlight")
        do {
            let flights = try moc.fetch(fetchRequest)
            return flights.compactMap {$0.id}
        } catch {
            return []
        }
    }
    func getLastSavedDate() -> Date? {
        let fetchRequest = NSFetchRequest<CDFlight>(entityName: "CDFlight")
        do {
            let flights = try moc.fetch(fetchRequest)
            return flights.compactMap {$0.created}.max()
        } catch {
            return nil
        }
    }
    func deleteAllFlights() {
            let fetchRequest = NSFetchRequest<CDFlight>(entityName: "CDFlight")
            do {
                let flights = try moc.fetch(fetchRequest)
                flights.forEach {moc.delete($0)}
                try moc.save()
            } catch {
                print("Error: can't remove flights from database")
            }
    }
    func saveImage(data: Data, flight: Flight) {
        let fetchRequest = NSFetchRequest<CDFlight>(entityName: "CDFlight")
        let predicate = NSPredicate(format: "id = %@", flight.id)
        fetchRequest.predicate = predicate
        do {
            if let flightObject = try moc.fetch(fetchRequest).first {
                flightObject.image = data
                try moc.save()
            }
                
        } catch {
            print("Error: can't save image for flight \(flight.id)")
        }
    }
}
