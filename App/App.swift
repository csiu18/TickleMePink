//
//  App.swift
//  App
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI

@main
struct AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
