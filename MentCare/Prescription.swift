//
//  Prescription.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import Foundation
import SwiftData

@Model
class Prescription {
    var id: UUID
    var drugName: String
    var dosageAmount: String
    var adminFrequency: String
    var cost: Double
    
    var consultation: Consultation?
    
    init(drugName: String, dosageAmount: String, adminFrequency: String, cost: Double) {
        self.id = UUID()
        self.drugName = drugName
        self.dosageAmount = dosageAmount
        self.adminFrequency = adminFrequency
        self.cost = cost
    }
}
