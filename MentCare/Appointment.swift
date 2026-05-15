//
//  Appointment.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation
import SwiftData

@Model
final class Appointment {
    var id: UUID
    var appointmentDate: Date
    var notes: String
    var isCompleted: Bool
    var patient: Patient?
    
    init(appointmentDate: Date, notes: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.appointmentDate = appointmentDate
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
