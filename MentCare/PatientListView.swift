//
//  PatientListView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct PatientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Patient.patientID) private var patients: [Patient]
    @State private var isShowingSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(patients) { patient in
                    NavigationLink(destination: PatientDetailView(patient: patient)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(patient.demographicData.components(separatedBy: " - ").first ?? "Unknown")
                                    .font(.headline)
                                Text("ID: \(patient.patientID)")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // Durum İkonları
                            statusIcon(for: patient.warningFlag)
                        }
                    }
                    // SAĞ TIK MENÜSÜ (Mac için harika)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteSinglePatient(patient)
                        } label: {
                            Label("Delete Patient", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: deletePatients) // KAYDIRARAK SİLME
            }
            .navigationTitle("Records")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                AddPatientView()
            }
            .onChange(of: patients) { _, newPatients in
                SyncService().syncPatientsToCloud(patients: newPatients)
            }
        }
    }
    
    private func statusIcon(for flag: String) -> some View {
        Group {
            if flag == "Suicidal" {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            } else if flag == "Aggressive" {
                Image(systemName: "hand.raised.fill").foregroundColor(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            }
        }
    }
    
    private func deletePatients(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(patients[index])
        }
    }
    
    private func deleteSinglePatient(_ patient: Patient) {
        modelContext.delete(patient)
        try? modelContext.save()
    }
}
