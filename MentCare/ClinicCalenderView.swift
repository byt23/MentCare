//
//  ClinicCalenderView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData

struct ClinicCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    // Tüm randevuları en yakından en uzağa doğru sıralı çeker
    @Query(sort: \Appointment.appointmentDate) private var allAppointments: [Appointment]
    
    // Sadece gelecekteki randevuları filtrelemek için
    var upcomingAppointments: [Appointment] {
        allAppointments.filter { $0.appointmentDate >= Date() }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if upcomingAppointments.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Appointments",
                        systemImage: "calendar.badge.minus",
                        description: Text("The clinic schedule is clear.")
                    )
                } else {
                    ForEach(upcomingAppointments) { appointment in
                        HStack(spacing: 15) {
                            // Sol Taraf: Takvim İkonu ve Saat
                            VStack {
                                Text(appointment.appointmentDate.formatted(.dateTime.month().day()))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.blue)
                                Text(appointment.appointmentDate.formatted(.dateTime.hour().minute()))
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Sağ Taraf: Hasta Bilgisi ve Notlar
                            VStack(alignment: .leading, spacing: 5) {
                                Text(appointment.patient?.demographicData.components(separatedBy: " - ").first ?? "Unknown Patient")
                                    .font(.title3)
                                    .bold()
                                
                                Text(appointment.notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAppointment(appointment)
                            } label: {
                                Label("Cancel", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Clinic Schedule")
            .overlay(alignment: .bottomTrailing) {
                // Toplam randevu sayısını gösteren mini widget
                if !upcomingAppointments.isEmpty {
                    Text("\(upcomingAppointments.count) Appointments")
                        .font(.caption).bold()
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding()
                }
            }
        }
    }
    
    private func deleteAppointment(_ appointment: Appointment) {
        modelContext.delete(appointment)
        try? modelContext.save()
    }
}
