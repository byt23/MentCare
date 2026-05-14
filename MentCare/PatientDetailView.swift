//
//  PatientDetailView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct PatientDetailView: View {
    @Bindable var patient: Patient
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowingAddConsultation = false
    @State private var selectedConsultationForPrescription: Consultation?
    
    var body: some View {
        Form {
            // Kritik Uyarı Bölümü
            if patient.warningFlag == "Suicidal" || patient.warningFlag == "Aggressive" {
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("CRITICAL WARNING")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text("Patient status flagged as: \(patient.warningFlag)")
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Button("Clear") {
                            patient.warningFlag = "Normal"
                            saveAndSync()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            // Demografik Bilgiler (Düzenlenebilir)
            Section(header: Text("Demographics")) {
                TextField("Patient ID", text: $patient.patientID)
                TextField("Demographics", text: $patient.demographicData)
                TextField("Emergency Contact", text: $patient.emergencyContact)
                TextField("Assigned Clinic", text: $patient.assignedClinic)
                
                Picker("Security Status", selection: $patient.warningFlag) {
                    Text("Normal").tag("Normal")
                    Text("Suicidal").tag("Suicidal")
                    Text("Aggressive").tag("Aggressive")
                }
            }
            
            // Konsültasyon Geçmişi
            Section(header: Text("Consultation History")) {
                if let consultations = patient.consultations, !consultations.isEmpty {
                    ForEach(consultations) { consultation in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(consultation.consultationDate, style: .date)
                                    .font(.headline)
                                Spacer()
                                Text("Code: \(consultation.diagnosticCode)")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            Text(consultation.clinicalNotes)
                                .font(.subheadline)
                                .lineLimit(3)
                            
                            Button(action: {
                                selectedConsultationForPrescription = consultation
                            }) {
                                Label("Add Prescription", systemImage: "pills")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No consultations on record.")
                        .foregroundColor(.secondary)
                }
                
                Button(action: { isShowingAddConsultation = true }) {
                    Label("Add New Consultation Note", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Profile: \(patient.patientID)")
        .toolbar {
            Button("Save & Sync") {
                saveAndSync()
            }
        }
        .sheet(isPresented: $isShowingAddConsultation) {
            AddConsultationView(patient: patient)
        }
        .sheet(item: $selectedConsultationForPrescription) { consultation in
            AddPrescriptionView(consultation: consultation)
        }
    }
    
    // Değişiklikleri hem yerel SwiftData'ya hem Firebase'e gönderir
    private func saveAndSync() {
        try? modelContext.save()
        // Tekil güncellemeyi tetiklemek için SyncService'i çağırıyoruz
        SyncService().syncPatientsToCloud(patients: [patient])
    }
}
