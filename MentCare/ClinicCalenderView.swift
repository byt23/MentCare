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
    @Query(sort: \Appointment.appointmentDate) private var allAppointments: [Appointment]
    
    @State private var selectedDate = Date()
    @State private var isShowingAdd = false
    @State private var editingAppointment: Appointment?
    
    var filteredAppointments: [Appointment] {
        allAppointments.filter { Calendar.current.isDate($0.appointmentDate, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        HSplitView {
            VStack(spacing: 20) {
                Text("Clinic Calendar")
                    .font(.title2).bold()
                    .padding(.top)
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .accentColor(.purple)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                    .cornerRadius(16)
                    .padding(.horizontal)
   
                VStack(alignment: .leading, spacing: 12) {
                    Label("\(allAppointments.count) Total Records", systemImage: "archivebox.fill")
                    Label("\(allAppointments.filter { !$0.isCompleted }.count) Pending Sessions", systemImage: "clock.badge.checkmark")
                        .foregroundColor(.orange)
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(minWidth: 320, maxWidth: 420)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedDate.formatted(date: .complete, time: .omitted))
                            .font(.title2).bold()
                        Text("\(filteredAppointments.count) appointments found")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Button(action: { isShowingAdd = true }) {
                        Label("New Appointment", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .controlSize(.large)
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                List {
                    if filteredAppointments.isEmpty {
                        ContentUnavailableView(
                            "Day Clear",
                            systemImage: "calendar.badge.plus",
                            description: Text("No sessions scheduled for this date.")
                        )
                    } else {
                        ForEach(filteredAppointments) { appt in
                            AppointmentRow(appointment: appt) {
                                editingAppointment = appt
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(appt)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 450)
        }
        .navigationTitle("Master Schedule")
        .sheet(isPresented: $isShowingAdd) {
            AddGeneralAppointmentView()
        }
        .sheet(item: $editingAppointment) { appt in
            EditAppointmentView(appointment: appt)
        }
    }
}


struct AppointmentRow: View {
    var appointment: Appointment
    var onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            
            Rectangle()
                .fill(appointment.isCompleted ? Color.gray : Color.purple)
                .frame(width: 5)
            
            HStack(spacing: 15) {
                
                VStack {
                    Text(appointment.appointmentDate.formatted(.dateTime.hour().minute()))
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(appointment.isCompleted ? .secondary : .primary)
                    
                    if appointment.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                .frame(width: 60)
                .padding(.vertical, 10)
                .background(appointment.isCompleted ? Color.gray.opacity(0.1) : Color.purple.opacity(0.1))
                .cornerRadius(10)
                
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(appointment.patient?.demographicData.components(separatedBy: " - ").first?.uppercased() ?? "NAME NOT SET")
                        .font(.headline)
                        .tracking(1)
                        .foregroundColor(appointment.isCompleted ? .secondary : .primary)
                    
                    
                    Text(appointment.patient?.patientID ?? "ID: Unknown")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    
                    Text(appointment.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .italic()
                }
                
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        .onTapGesture { onEdit() }
    }
}
