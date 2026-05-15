//
//  MentCareApp.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MentCareApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
            .animation(.default, value: authManager.isAuthenticated)
            
        }
        // GÜNCELLEME: Appointment.self modelini listeye ekledik
        .modelContainer(for: [
            Patient.self,
            Appointment.self, // Eksik olan model buydu
            Prescription.self,
            Consultation.self,
            MedicalStaff.self
        ])
    }
}
