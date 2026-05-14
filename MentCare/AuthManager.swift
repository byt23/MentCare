//
//  AuthManager.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserRole = ""
    @Published var currentStaffID = "" // Hata aldığın değişken burada
    
    init() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            self.currentStaffID = user.email ?? ""
            self.currentUserRole = (user.email?.contains("admin") ?? false) ? "Manager" : "Doctor"
        }
    }
    
    func login(email: String, pin: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pin) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.currentStaffID = email
                self.currentUserRole = email.contains("admin") ? "Manager" : "Doctor"
                self.isAuthenticated = true
                completion(true, nil)
            }
        }
    }
    
    // Hata aldığın fonksiyon burada
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUserRole = ""
                self.currentStaffID = ""
            }
        } catch {
            print("Çıkış hatası: \(error.localizedDescription)")
        }
    }
}
