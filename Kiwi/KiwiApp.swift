//
//  KiwiApp.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import SwiftUI

@main
struct KiwiApp: App {
    let persistenceController = PersistenceController.shared
    let contentManager = ContentManager()
    var body: some Scene {
        WindowGroup {
            ContentView(contentManager: contentManager)
                .environment(\.managedObjectContext, persistenceController.moc)        }
    }
}
