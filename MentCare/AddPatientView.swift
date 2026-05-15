//
//  AddPatientView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct AddPatientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var tcNo = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var warningFlag = "Normal"
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Patient Identity") {
                    TextField("Full Name", text: $name)
                    TextField("TC / ID Number", text: $tcNo)
                }
                
                Section("Details") {
                    TextField("Age", text: $age)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                }
                
                Section("Medical Status & Safety") {
                    Picker("Condition", selection: $warningFlag) {
                        Text("Normal").tag("Normal")
                        Text("Suicidal").tag("Suicidal")
                        Text("Aggressive").tag("Aggressive")
                    }
                    .pickerStyle(.segmented)
                    
                    // İlk versiyonundaki önemli açıklama metni
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundColor(statusColor)
                        .padding(.top, 5)
                }
            }
            .navigationTitle("New Patient Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newPatient = Patient(
                            patientID: tcNo,
                            demographicData: "\(name) - \(age) Y - \(gender)",
                            emergencyContact: "None Provided",
                            assignedClinic: "Main Clinic",
                            warningFlag: warningFlag
                        )
                        modelContext.insert(newPatient)
                        dismiss()
                    }
                    .disabled(name.isEmpty || tcNo.isEmpty)
                }
            }
        }
    }
    
    private var statusDescription: String {
        switch warningFlag {
        case "Suicidal": return "Red Alert: High self-harm risk. Monitor closely."
        case "Aggressive": return "Orange Alert: Potential harm to staff. Exercise caution."
        default: return "Green Alert: Patient is currently stable."
        }
    }
    
    private var statusColor: Color {
        switch warningFlag {
        case "Suicidal": return .red
        case "Aggressive": return .orange
        default: return .secondary
        }
    }
}
