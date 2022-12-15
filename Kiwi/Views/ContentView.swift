//
//  ContentView.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDFlight.created, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CDFlight>
    @ObservedObject var contentManager: ContentManager
    
    init(contentManager: ContentManager){
        self.contentManager = contentManager
    }
    
    var body: some View {
        UpdatingView(isShowing: $contentManager.uppdating) {
            TabView {
                ForEach(items) { item in
                    PageView(flight: item)
                }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .alert(item: $contentManager.error) { error in
                      Alert(
                        title: Text("Network error"),
                        message: Text(error.localizedDescription),
                        dismissButton: .cancel()
                      )
                    }
        }
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(contentManager: ContentManager()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
