//
//  PatientPDFView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI

struct PatientPDFView: View {
    var patient: Patient
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("MentCare Clinical System")
                        .font(.system(size: 28, weight: .bold))
                    Text("Official Patient Report")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            Text("Report Generated: \(currentDate)")
                .font(.footnote)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Demographics & Identity")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 5)
                
                LabeledContent("Patient ID / TC", value: patient.patientID)
                LabeledContent("Personal Data", value: patient.demographicData)
                LabeledContent("Emergency Contact", value: patient.emergencyContact)
                LabeledContent("Assigned Clinic", value: patient.assignedClinic)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Security & Risk Assessment")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 5)
                
                HStack {
                    Text("Current Flag:")
                        .bold()
                    Text(patient.warningFlag)
                        .bold()
                        .foregroundColor(statusColor)
                }
            }
            .padding()
            .background(statusColor.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            Divider()

            HStack {
                Text("Confidential Medical Record")
                    .font(.caption)
                    .bold()
                Spacer()
                Text("Developed by Berkay Yaşar Turan")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(40)
        .frame(width: 595, height: 842) 
        .background(Color.white)
    }
    
    private var statusColor: Color {
        switch patient.warningFlag {
        case "Suicidal": return .red
        case "Aggressive": return .orange
        default: return .green
        }
    }
}
