//
//  Datamanager.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    private let studentKey = "saved_student"
    private let isRegisteredKey = "is_registered"
    
    @Published var student: Student?
    @Published var isRegistered: Bool = false
    
    init() {
        loadData()
    }
    
    // MARK: - Save
    func saveStudent(_ student: Student) {
        do {
            let encoded = try JSONEncoder().encode(student)
            UserDefaults.standard.set(encoded, forKey: studentKey)
            UserDefaults.standard.set(true, forKey: isRegisteredKey)
            self.student = student
            self.isRegistered = true
        } catch {
            print("Error saving student: \(error)")
        }
    }
    
    // MARK: - Load
    func loadData() {
        isRegistered = UserDefaults.standard.bool(forKey: isRegisteredKey)
        
        if let data = UserDefaults.standard.data(forKey: studentKey) {
            do {
                let decoded = try JSONDecoder().decode(Student.self, from: data)
                self.student = decoded
            } catch {
                print("Error loading student: \(error)")
            }
        }
    }
    
    // MARK: - Delete (Logout + clear)
    func deleteAllData() {
        UserDefaults.standard.removeObject(forKey: studentKey)
        UserDefaults.standard.removeObject(forKey: isRegisteredKey)
        UserDefaults.standard.removeObject(forKey: "is_logged_in")
        self.student = nil
        self.isRegistered = false
    }
    
    // MARK: - Session
    func saveSession() {
        UserDefaults.standard.set(true, forKey: "is_logged_in")
    }
    
    func clearSession() {
        UserDefaults.standard.set(false, forKey: "is_logged_in")
    }
    
    func isSessionActive() -> Bool {
        return UserDefaults.standard.bool(forKey: "is_logged_in")
    }
    
    // MARK: - Validate login
    func validateLogin(correo: String, contrasena: String) -> Bool {
        guard let student = student else { return false }
        return student.correo.lowercased() == correo.lowercased() && student.contrasena == contrasena
    }
}
