//
//  SyncService.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation
import FirebaseFirestore
import SwiftData
import Combine

struct SyncService {
    private let db = Firestore.firestore()
    
    @MainActor
    func syncPatientsToCloud(patients: [Patient]) {
        for patient in patients {
            let patientData: [String: Any] = [
                "patientID": patient.patientID,
                "demographicData": patient.demographicData,
                "emergencyContact": patient.emergencyContact,
                "warningFlag": patient.warningFlag,
                "lastUpdated": FieldValue.serverTimestamp()
            ]
            
            // Veriyi Firestore'a ID bazlı gönderir
            db.collection("patients").document(patient.patientID).setData(patientData) { error in
                if let error = error {
                    print("❌ Senkronizasyon Hatası: \(error.localizedDescription)")
                } else {
                    print("✅ \(patient.patientID) başarıyla buluta yedeklendi.")
                }
            }
        }
    }
}
