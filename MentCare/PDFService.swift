//
//  PDFService.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI

struct OfficialReportView: View {
    var patient: Patient
    var latestConsultation: Consultation?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("MENTCARE CLINICAL REPORT").font(.title2).bold()
                    Text("Patient Digital Summary").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Patient ID: \(patient.patientID)").font(.headline)
                Text("Demographics: \(patient.demographicData)")
                Text("Emergency Contact: \(patient.emergencyContact)")
                Text("Current Status: \(patient.warningFlag)").bold().foregroundColor(patient.warningFlag == "Normal" ? .black : .red)
            }
            
            Divider()
            
            Text("Latest Consultation Notes").font(.headline)
            Text(latestConsultation?.clinicalNotes ?? "No notes available.")
                .font(.body)
            
            Spacer()
            
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 5) {
                    Divider().frame(width: 200)
                    Text("Attending Physician Signature").font(.caption)
                    Text(latestConsultation?.signatureCode ?? "Authorized Clinician").bold()
                    Text(Date().formatted(date: .numeric, time: .shortened)).font(.caption2).foregroundColor(.secondary)
                }
            }
        }
        .padding(40)
        .frame(width: 595, height: 842)
        .background(Color.white)
    }
}
