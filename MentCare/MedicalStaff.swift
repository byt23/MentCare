//
//  MedicalStaff.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import Foundation
import SwiftData

@Model
class MedicalStaff {
    @Attribute(.unique) var staffID: String
    var role: String
    var passwordHash: String
    var biometricPIN: String
    
    @Relationship(deleteRule: .nullify, inverse: \Consultation.medicalStaff)
    var consultations: [Consultation]?
    
    init(staffID: String, role: String, passwordHash: String, biometricPIN: String) {
        self.staffID = staffID
        self.role = role
        self.passwordHash = passwordHash
        self.biometricPIN = biometricPIN
    }
}
