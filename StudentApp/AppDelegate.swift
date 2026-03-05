//
//  AppDelegate.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 05/03/26.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // Handle OAuth callback URLs (required for GitHub and Google Sign-In)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("🔗 AppDelegate open URL: \(url)")

        // Let Google Sign-In handle its callback
        if GIDSignIn.sharedInstance.handle(url) {
            print("✅ Google handled URL")
            return true
        }

        // Let Firebase Auth handle GitHub and other OAuth callbacks
        if Auth.auth().canHandle(url) {
            print("✅ Firebase handled URL")
            return true
        }

        return false
    }

    // Handle Universal Links (needed for some Firebase flows)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
}
