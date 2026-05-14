//
//  EditPatientView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct EditPatientView: View {
    @Bindable var patient: Patient
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Update Information") {
                    TextField("Demographic Data", text: $patient.demographicData)
                    TextField("Emergency Contact", text: $patient.emergencyContact)
                }
                
                Section("Security Status") {
                    Picker("Condition", selection: $patient.warningFlag) {
                        Text("Normal").tag("Normal")
                        Text("Suicidal").tag("Suicidal")
                        Text("Aggressive").tag("Aggressive")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Patient")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
