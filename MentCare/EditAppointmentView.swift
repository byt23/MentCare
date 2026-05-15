//
//  EditAppointmentView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct EditAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var appointment: Appointment
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Edit Date & Time") {
                    DatePicker("", selection: $appointment.appointmentDate)
                        .datePickerStyle(.graphical)
                }
                
                Section("Session Notes") {
                    TextEditor(text: $appointment.notes)
                        .frame(height: 100)
                }
                
                Section("Status") {
                    Toggle("Mark as Completed", isOn: $appointment.isCompleted)
                        .tint(.green)
                }
            }
            .navigationTitle("Edit Session")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save & Close") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500) // Mac'te formun güzel görünmesi için
    }
}
