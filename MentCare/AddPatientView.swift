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
    
    // State değişkenleri - Tüm özellikler korundu
    @State private var name = ""
    @State private var tcNo = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var warningFlag = "Normal"
    
    var body: some View {
        NavigationStack {
            Form {
                // Kimlik Bölümü
                Section("Patient Identity") {
                    TextField("Full Name", text: $name)
                    TextField("TC / ID Number", text: $tcNo)
                }
                
                // Detaylar Bölümü
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
                
                // Tıbbi Durum ve Güvenlik (Segmented Picker + Dinamik Açıklama)
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
    
    // İlk versiyonundaki mantığı daha da geliştirerek korudum
    private var statusDescription: String {
        switch warningFlag {
        case "Suicidal": return "Red Alert: High self-harm risk. Monitor closely."
        case "Aggressive": return "Orange Alert: Potential harm to staff. Exercise caution."
        default: return "Green Alert: Patient is currently stable."
        }
    }
    
    // Açıklama metnine dinamik renk ekledim (Görsel uyarı için)
    private var statusColor: Color {
        switch warningFlag {
        case "Suicidal": return .red
        case "Aggressive": return .orange
        default: return .secondary
        }
    }
}
