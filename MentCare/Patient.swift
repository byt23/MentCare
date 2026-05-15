//
//  Patient.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import Foundation
import SwiftData

@Model
class Patient {
    @Attribute(.unique) var patientID: String
    var demographicData: String
    var emergencyContact: String
    var assignedClinic: String
    var warningFlag: String
    
    @Relationship(deleteRule: .cascade) var appointments: [Appointment]? = []
    var consultations: [Consultation]?
    
    init(patientID: String, demographicData: String, emergencyContact: String, assignedClinic: String, warningFlag: String = "Normal") {
        self.patientID = patientID
        self.demographicData = demographicData
        self.emergencyContact = emergencyContact
        self.assignedClinic = assignedClinic
        self.warningFlag = warningFlag
    }
}
