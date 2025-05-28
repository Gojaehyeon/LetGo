//
//  LetGoApp.swift
//  LetGo
//
//  Created by Gojaehyun on 5/21/25.
//

import SwiftUI
import CoreData

@main
struct LetGoApp: App {
    init() {
        // Force light mode
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
