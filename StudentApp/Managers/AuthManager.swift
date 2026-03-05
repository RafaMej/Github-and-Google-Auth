//
//  AuthManager.swift
//  StudentApp
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

class AuthManager: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var firebaseUser: User?
    @Published var authError: String?
    @Published var isLoadingGoogle: Bool = false
    @Published var isLoadingGitHub: Bool = false
    
    private let dataManager = DataManager.shared
    
    var isLoading: Bool { isLoadingGoogle || isLoadingGitHub }
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.firebaseUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - GOOGLE LOGIN
    
    func signInWithGoogle() {
        
        guard !isLoadingGoogle else { return }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            authError = "No se encontró el Client ID de Firebase."
            return
        }
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            authError = "No se pudo obtener el ViewController."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        isLoadingGoogle = true
        authError = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            
            DispatchQueue.main.async {
                
                self?.isLoadingGoogle = false
                
                if let error = error {
                    self?.authError = "Error Google: \(error.localizedDescription)"
                    return
                }
                
                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    self?.authError = "No se pudo obtener el token de Google."
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                
                self?.signInToFirebase(with: credential)
            }
        }
    }
    
    // MARK: - GITHUB LOGIN
    
    func signInWithGitHub() {
        
        guard !isLoadingGitHub else { return }
        
        isLoadingGitHub = true
        authError = nil
        
        Task { [weak self] in
            
            do {
                
                let authResult = try await GitHubSignInManager.shared.signIn()
                
                await MainActor.run {
                    self?.firebaseUser = authResult.user
                    self?.isAuthenticated = true
                    self?.dataManager.saveSession()
                    self?.isLoadingGitHub = false
                }
                
            } catch {
                
                await MainActor.run {
                    self?.isLoadingGitHub = false
                    self?.authError = "Error GitHub: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - FIREBASE LOGIN
    
    private func signInToFirebase(with credential: AuthCredential) {
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self?.authError = "Error Firebase: \(error.localizedDescription)"
                    return
                }
                
                self?.firebaseUser = authResult?.user
                self?.isAuthenticated = true
                self?.dataManager.saveSession()
                self?.authError = nil
            }
        }
    }
    
    // MARK: - SIGN OUT
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            firebaseUser = nil
            isAuthenticated = false
            isLoadingGoogle = false
            isLoadingGitHub = false
            
            dataManager.clearSession()
            
        } catch {
            authError = "Error al cerrar sesión: \(error.localizedDescription)"
        }
    }
}
