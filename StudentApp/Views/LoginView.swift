//
//  LoginView.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    
    var onLoginSuccess: () -> Void
    var onRegisterNew: () -> Void
    
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var shake = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header illustration
                    headerView
                    
                    // Form card
                    loginCard
                    
                    // Social login
                    socialLoginSection
                    
                    // Register link
                    registerLink
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Error de acceso", isPresented: $showError) {
            Button("Intentar de nuevo") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Error de autenticación", isPresented: Binding(
            get: { authManager.authError != nil },
            set: { if !$0 { authManager.authError = nil } }
        )) {
            Button("OK") { authManager.authError = nil }
        } message: {
            Text(authManager.authError ?? "")
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AccentBlue"), Color("AccentPurple")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 8)
                
                Text("EduApp")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Inicia sesión para continuar")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Login Card
    var loginCard: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Text("Acceso")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundColor(Color("AccentBlue"))
            }
            
            Divider()
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Label("Correo Electrónico", systemImage: "envelope")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("tu@correo.com", text: $correo)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Label("Contraseña", systemImage: "lock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    if showPassword {
                        TextField("Tu contraseña", text: $contrasena)
                    } else {
                        SecureField("Tu contraseña", text: $contrasena)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            // Login Button
            Button(action: attemptLogin) {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Iniciar Sesión")
                                .fontWeight(.bold)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color("AccentBlue"), Color("AccentPurple")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .font(.system(size: 16, weight: .semibold))
                .shadow(color: Color("AccentBlue").opacity(0.3), radius: 8, y: 4)
            }
            .offset(x: shake ? -8 : 0)
            .animation(shake ? Animation.default.repeatCount(4, autoreverses: true).speed(6) : .default, value: shake)
            .disabled(isLoading)
        }
        .padding(24)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 15, y: 5)
        .padding(.horizontal, 20)
        .offset(y: -20)
    }
    
    // MARK: - Social Login
    var socialLoginSection: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                Text("O continúa con")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize()
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                // Google Button
                Button(action: {
                    authManager.signInWithGoogle()
                }) {
                    HStack(spacing: 10) {
                        if authManager.isLoadingGoogle {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "globe")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                            Text("Google")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                }
                .disabled(authManager.isLoading)
                
                // GitHub Button
                Button(action: {
                    authManager.signInWithGitHub()
                }) {
                    HStack(spacing: 10) {
                        if authManager.isLoadingGitHub {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("GitHub")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                }
                .disabled(authManager.isLoading)
            }
            .padding(.horizontal, 20)
        }
        .offset(y: -10)
    }
    
    // MARK: - Register Link
    var registerLink: some View {
        Button(action: onRegisterNew) {
            HStack {
                Text("¿Datos incorrectos?")
                    .foregroundColor(.secondary)
                Text("Registrar nueva cuenta")
                    .foregroundColor(Color("AccentBlue"))
                    .fontWeight(.semibold)
            }
            .font(.system(size: 14))
        }
    }
    
    // MARK: - Login Logic
    func attemptLogin() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            if dataManager.validateLogin(correo: correo, contrasena: contrasena) {
                dataManager.saveSession()
                onLoginSuccess()
            } else {
                errorMessage = "Correo o contraseña incorrectos. Por favor inténtalo de nuevo."
                showError = true
                shake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    shake = false
                }
            }
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: {}, onRegisterNew: {})
        .environmentObject(DataManager.shared)
        .environmentObject(AuthManager())
}
