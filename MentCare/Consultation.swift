//
//  Consultation.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import Foundation
import SwiftData

@Model
class Consultation {
    var id: UUID
    var consultationDate: Date
    var clinicalNotes: String
    var diagnosticCode: String
    var signatureCode: String
    var syncStatus: String
    
    var patient: Patient?
    var medicalStaff: MedicalStaff?
    
    @Relationship(deleteRule: .cascade, inverse: \Prescription.consultation)
    var prescriptions: [Prescription]?
    
    init(consultationDate: Date, clinicalNotes: String, diagnosticCode: String, signatureCode: String, syncStatus: String = "Pending") {
        self.id = UUID()
        self.consultationDate = consultationDate
        self.clinicalNotes = clinicalNotes
        self.diagnosticCode = diagnosticCode
        self.signatureCode = signatureCode
        self.syncStatus = syncStatus
    }
}
