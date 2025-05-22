//
//  LetGoApp.swift
//  LetGo
//
//  Created by Gojaehyun on 5/21/25.
//

import SwiftUI

@main
struct LetGoApp: App {
    init() {
        // Force light mode
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
