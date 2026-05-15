//
//  AddGeneralAppointmentView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct AddGeneralAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Patient.patientID) private var patients: [Patient]
    @State private var selectedPatient: Patient?
    @State private var appointmentDate = Date().addingTimeInterval(86400)
    @State private var notes = "Routine clinic visit."
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Patient") {
                    Picker("Patient", selection: $selectedPatient) {
                        Text("Select a patient...").tag(Patient?(nil))
                        ForEach(patients) { patient in
                            Text(patient.patientID).tag(Patient?(patient))
                        }
                    }
                }
                
                Section("Date & Time") {
                    DatePicker("", selection: $appointmentDate)
                        .datePickerStyle(.graphical)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let newAppt = Appointment(appointmentDate: appointmentDate, notes: notes)
                        newAppt.patient = selectedPatient
                        modelContext.insert(newAppt)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(selectedPatient == nil) 
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}
