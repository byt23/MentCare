//
//  AddAppointmentView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var patient: Patient
    
    @State private var appointmentDate = Date().addingTimeInterval(86400)
    @State private var appointmentNotes = "Routine follow-up session."
    @State private var isSuccess = false
    
    var patientName: String {
        patient.demographicData.components(separatedBy: " - ").first ?? "Patient"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 38, weight: .light))
                                .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                        }
                        
                        Text("Schedule Follow-up")
                            .font(.title2).bold()
                        Text(patientName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Select Date & Time", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker("", selection: $appointmentDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Session Notes", systemImage: "note.text")
                            .font(.headline)
                        
                        TextEditor(text: $appointmentNotes)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    Button(action: saveToInternalDatabase) {
                        HStack {
                            Spacer()
                            Image(systemName: isSuccess ? "checkmark.seal.fill" : "calendar.badge.plus")
                                .font(.title3)
                            Text(isSuccess ? "Saved to Clinic System" : "Confirm Appointment")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .background(
                            isSuccess ?
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(18)
                        .shadow(color: (isSuccess ? Color.green : Color.blue).opacity(0.4), radius: 12, y: 6)
                        .scaleEffect(isSuccess ? 1.05 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isSuccess)
                    }
                    .padding(.horizontal)
                    .disabled(isSuccess)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    private func saveToInternalDatabase() {
        let newAppointment = Appointment(appointmentDate: appointmentDate, notes: appointmentNotes)
        newAppointment.patient = patient
        
        modelContext.insert(newAppointment)
        try? modelContext.save()
        SyncService().syncPatientsToCloud(patients: [patient])
        
        withAnimation {
            isSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
