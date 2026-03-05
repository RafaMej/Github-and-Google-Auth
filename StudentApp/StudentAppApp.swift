//
//  StudentAppApp.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import SwiftUI
import FirebaseCore

@main
struct StudentAppApp: App {

    // Connect AppDelegate so Firebase can handle OAuth URL callbacks
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
