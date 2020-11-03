//
//  HauptstadtApp.swift
//  Hauptstadt WatchKit Extension
//
//  Created by Felix on 10/26/20.
//

import SwiftUI

@main
struct HauptstadtApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
