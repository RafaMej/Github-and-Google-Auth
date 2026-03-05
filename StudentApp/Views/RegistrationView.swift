//
//  RegistrationView.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var dataManager: DataManager
    var onComplete: () -> Void
    
    @State private var nombre = ""
    @State private var apellido = ""
    @State private var matricula = ""
    @State private var facultad = Facultad.ingenieria.rawValue
    @State private var semestre = "1"
    @State private var sexo = Sexo.prefiero.rawValue
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var confirmarContrasena = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var currentStep = 1
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateIn = false
    @State private var screenWidth: CGFloat = 393
    
    let semestres = Array(1...12).map { "\($0)" }
    
    var body: some View {
        ZStack {
            // Background + capture width
            GeometryReader { geo in
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                    .onAppear { screenWidth = geo.size.width }
                    .onChange(of: geo.size.width) { _, w in screenWidth = w }
            }
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Progress
                progressBar
                
                // Form Steps
                ScrollView {
                    VStack(spacing: 24) {
                        if currentStep == 1 {
                            stepOneView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            stepTwoView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .animation(.spring(response: 0.4), value: currentStep)
                }
                
                // Navigation buttons
                bottomButtons
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
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
            
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Registro de Estudiante")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Paso \(currentStep) de 2")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 30)
        }
        .frame(height: 150)
    }
    
    // MARK: - Progress Bar
    var progressBar: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color("AccentBlue"))
                .frame(width: currentStep == 1 ? screenWidth / 2 : screenWidth)
                .animation(.spring(response: 0.4), value: currentStep)
        }
        .frame(height: 4)
        .background(Color.gray.opacity(0.2))
    }
    
    // MARK: - Step 1: Personal Info
    var stepOneView: some View {
        VStack(spacing: 16) {
            sectionHeader("Información Personal", icon: "person.fill")
            
            CustomTextField(label: "Nombre", placeholder: "Juan", text: $nombre, icon: "person")
            CustomTextField(label: "Apellido", placeholder: "García", text: $apellido, icon: "person.2")
            CustomTextField(label: "Matrícula", placeholder: "A12345678", text: $matricula, icon: "number")
            
            // Facultad picker
            VStack(alignment: .leading, spacing: 8) {
                Label("Facultad", systemImage: "building.columns")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Facultad", selection: $facultad) {
                    ForEach(Facultad.allCases, id: \.rawValue) { f in
                        Text(f.rawValue).tag(f.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Semestre picker
            VStack(alignment: .leading, spacing: 8) {
                Label("Semestre", systemImage: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Semestre", selection: $semestre) {
                    ForEach(semestres, id: \.self) { s in
                        Text("Semestre \(s)").tag(s)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Sexo
            VStack(alignment: .leading, spacing: 8) {
                Label("Sexo", systemImage: "figure.stand")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Sexo", selection: $sexo) {
                    ForEach(Sexo.allCases, id: \.rawValue) { s in
                        Text(s.rawValue).tag(s.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    // MARK: - Step 2: Account Info
    var stepTwoView: some View {
        VStack(spacing: 16) {
            sectionHeader("Datos de Acceso", icon: "lock.shield.fill")
            
            CustomTextField(
                label: "Correo Electrónico",
                placeholder: "correo@universidad.edu",
                text: $correo,
                icon: "envelope",
                keyboardType: .emailAddress
            )
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Label("Contraseña", systemImage: "lock")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    if showPassword {
                        TextField("Mínimo 6 caracteres", text: $contrasena)
                    } else {
                        SecureField("Mínimo 6 caracteres", text: $contrasena)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Confirm Password
            VStack(alignment: .leading, spacing: 8) {
                Label("Confirmar Contraseña", systemImage: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    if showConfirmPassword {
                        TextField("Repite tu contraseña", text: $confirmarContrasena)
                    } else {
                        SecureField("Repite tu contraseña", text: $confirmarContrasena)
                    }
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Password match indicator
            if !confirmarContrasena.isEmpty {
                HStack {
                    Image(systemName: contrasena == confirmarContrasena ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(contrasena == confirmarContrasena ? "Las contraseñas coinciden" : "Las contraseñas no coinciden")
                        .font(.caption)
                }
                .foregroundColor(contrasena == confirmarContrasena ? .green : .red)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Bottom Buttons
    var bottomButtons: some View {
        HStack(spacing: 16) {
            if currentStep == 2 {
                Button(action: {
                    withAnimation { currentStep = 1 }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Atrás")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(14)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            
            Button(action: {
                if currentStep == 1 {
                    if validateStep1() {
                        withAnimation { currentStep = 2 }
                    }
                } else {
                    if validateStep2() {
                        saveAndContinue()
                    }
                }
            }) {
                HStack {
                    Text(currentStep == 1 ? "Siguiente" : "Registrarme")
                    Image(systemName: currentStep == 1 ? "chevron.right" : "checkmark")
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Helpers
    func sectionHeader(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("AccentBlue"))
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Spacer()
        }
    }
    
    func validateStep1() -> Bool {
        if nombre.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa tu nombre."
            showError = true
            return false
        }
        if apellido.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa tu apellido."
            showError = true
            return false
        }
        if matricula.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa tu matrícula."
            showError = true
            return false
        }
        return true
    }
    
    func validateStep2() -> Bool {
        if correo.trimmingCharacters(in: .whitespaces).isEmpty || !correo.contains("@") {
            errorMessage = "Por favor ingresa un correo válido."
            showError = true
            return false
        }
        if contrasena.count < 6 {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            showError = true
            return false
        }
        if contrasena != confirmarContrasena {
            errorMessage = "Las contraseñas no coinciden."
            showError = true
            return false
        }
        return true
    }
    
    func saveAndContinue() {
        let student = Student(
            nombre: nombre,
            apellido: apellido,
            matricula: matricula,
            facultad: facultad,
            semestre: semestre,
            sexo: sexo,
            correo: correo,
            contrasena: contrasena
        )
        dataManager.saveStudent(student)
        dataManager.saveSession()
        onComplete()
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    RegistrationView(onComplete: {})
        .environmentObject(DataManager.shared)
}
