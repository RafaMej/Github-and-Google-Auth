//
//  HomeView.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    
    var onLogout: () -> Void
    var onDeleteAndLogout: () -> Void
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var animateCards = false
    
    var displayName: String {
        if let student = dataManager.student {
            return student.nombreCompleto
        } else if let firebaseUser = authManager.firebaseUser {
            return firebaseUser.displayName ?? firebaseUser.email ?? "Usuario"
        }
        return "Usuario"
    }
    
    var displayEmail: String {
        if let student = dataManager.student {
            return student.correo
        } else if let firebaseUser = authManager.firebaseUser {
            return firebaseUser.email ?? "—"
        }
        return "—"
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header
                    profileHeader
                    
                    VStack(spacing: 16) {
                        // Check if local student or Firebase user
                        if let student = dataManager.student {
                            // Show full student info
                            studentInfoCards(student: student)
                        } else if authManager.firebaseUser != nil {
                            // Firebase only user
                            firebaseUserCard
                        }
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("¿Deseas cerrar sesión? Tus datos se conservarán.")
        }
        .alert("Borrar Datos", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Borrar y Salir", role: .destructive) {
                onDeleteAndLogout()
            }
        } message: {
            Text("¿Estás seguro? Esta acción eliminará todos tus datos guardados y no se puede deshacer.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Profile Header
    var profileHeader: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AccentBlue"), Color("AccentPurple")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 90, height: 90)
                    
                    Text(String(displayName.prefix(2)).uppercased())
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text(displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(displayEmail)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                
                // Badge
                if authManager.firebaseUser != nil {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Verificado con Firebase")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Student Info Cards
    @ViewBuilder
    func studentInfoCards(student: Student) -> some View {
        // Academic Info
        InfoCard(
            title: "Información Académica",
            icon: "book.fill",
            color: Color("AccentBlue"),
            items: [
                InfoItem(label: "Matrícula", value: student.matricula, icon: "number"),
                InfoItem(label: "Facultad", value: student.facultad, icon: "building.columns"),
                InfoItem(label: "Semestre", value: "Semestre \(student.semestre)", icon: "calendar"),
            ]
        )
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        
        // Personal Info
        InfoCard(
            title: "Información Personal",
            icon: "person.fill",
            color: Color("AccentPurple"),
            items: [
                InfoItem(label: "Nombre Completo", value: student.nombreCompleto, icon: "person"),
                InfoItem(label: "Sexo", value: student.sexo, icon: "figure.stand"),
                InfoItem(label: "Correo", value: student.correo, icon: "envelope"),
            ]
        )
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: animateCards)
    }
    
    // MARK: - Firebase User Card
    var firebaseUserCard: some View {
        InfoCard(
            title: "Cuenta Vinculada",
            icon: "flame.fill",
            color: .orange,
            items: [
                InfoItem(label: "Nombre", value: authManager.firebaseUser?.displayName ?? "—", icon: "person"),
                InfoItem(label: "Correo", value: authManager.firebaseUser?.email ?? "—", icon: "envelope"),
                InfoItem(label: "UID", value: String((authManager.firebaseUser?.uid ?? "—").prefix(16)) + "...", icon: "key"),
            ]
        )
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
    }
    
    // MARK: - Action Buttons
    var actionButtons: some View {
        VStack(spacing: 12) {
            // Logout
            Button(action: { showLogoutAlert = true }) {
                HStack {
                    Image(systemName: "arrow.backward.circle.fill")
                        .font(.system(size: 18))
                    Text("Cerrar Sesión")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .foregroundColor(.primary)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
            }
            
            // Delete data
            Button(action: { showDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                    Text("Borrar Datos y Salir")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.08))
                .foregroundColor(.red)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: animateCards)
    }
}

// MARK: - Reusable Info Card
struct InfoItem {
    let label: String
    let value: String
    let icon: String
}

struct InfoCard: View {
    let title: String
    let icon: String
    let color: Color
    let items: [InfoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Spacer()
            }
            
            Divider()
            
            VStack(spacing: 14) {
                ForEach(items, id: \.label) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14))
                            .foregroundColor(color)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(item.value)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

#Preview {
    HomeView(onLogout: {}, onDeleteAndLogout: {})
        .environmentObject(DataManager.shared)
        .environmentObject(AuthManager())
}
