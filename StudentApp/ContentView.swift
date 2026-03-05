//
//  ContentView.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var dataManager = DataManager.shared
    @State private var appState: AppState = .loading
    
    enum AppState {
        case loading
        case registration
        case login
        case home
    }
    
    var body: some View {
        Group {
            switch appState {
            case .loading:
                SplashView()
                    .onAppear { determineAppState() }
                    
            case .registration:
                RegistrationView(onComplete: {
                    appState = .home
                })
                .environmentObject(dataManager)
                
            case .login:
                LoginView(
                    onLoginSuccess: { appState = .home },
                    onRegisterNew: {
                        dataManager.deleteAllData()
                        appState = .registration
                    }
                )
                .environmentObject(dataManager)
                .environmentObject(authManager)
                
            case .home:
                HomeView(onLogout: {
                    dataManager.clearSession()
                    authManager.signOut()
                    appState = .login
                }, onDeleteAndLogout: {
                    dataManager.deleteAllData()
                    authManager.signOut()
                    appState = .registration
                })
                .environmentObject(dataManager)
                .environmentObject(authManager)
            }
        }
        // iOS 17+ two-parameter onChange
        .onChange(of: authManager.isAuthenticated) { _, authenticated in
            if authenticated {
                appState = .home
            }
        }
    }
    
    private func determineAppState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if !dataManager.isRegistered {
                appState = .registration
            } else if dataManager.isSessionActive() {
                appState = .home
            } else {
                appState = .login
            }
        }
    }
}
