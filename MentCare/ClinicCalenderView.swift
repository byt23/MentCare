//
//  ClinicCalenderView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import SwiftData


extension Color {
    static var customControlBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    static var customWindowBackground: Color {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }
}

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
        Group {
            #if os(macOS)
            HSplitView {
                calendarSidebar
                appointmentMainList
            }
            #else
            VStack(spacing: 0) {
                calendarSidebar
                    .frame(maxHeight: 400)
                Divider()
                appointmentMainList
            }
            #endif
        }
        .navigationTitle("Schedule")
        .sheet(isPresented: $isShowingAdd) {
            AddGeneralAppointmentView()
        }
        .sheet(item: $editingAppointment) { appt in
            EditAppointmentView(appointment: appt)
        }
    }
    
    private var calendarSidebar: some View {
        VStack(spacing: 20) {
            Text("Clinic Calendar")
                .font(.title2).bold()
                .padding(.top)
            
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .accentColor(.purple)
                .padding()
                .background(Color.customControlBackground.opacity(0.6))
                .cornerRadius(16)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                statBox(title: "Total", count: allAppointments.count, icon: "archivebox.fill", color: .blue)
                statBox(title: "Pending", count: allAppointments.filter {!$0.isCompleted}.count, icon: "clock.fill", color: .orange)
            }
            .padding(.horizontal)
            
            #if os(macOS)
            Spacer()
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 320, maxWidth: 420)
        #endif
    }
    
    private var appointmentMainList: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                    Text("\(filteredAppointments.count) appointments found")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: { isShowingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.customWindowBackground)
            
            Divider()
            
            List {
                if filteredAppointments.isEmpty {
                    ContentUnavailableView("No Sessions", systemImage: "calendar.badge.plus")
                } else {
                    ForEach(filteredAppointments) { appt in
                        AppointmentRow(appointment: appt) {
                            editingAppointment = appt
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private func statBox(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            Image(systemName: icon).foregroundColor(color)
            Text("\(count)").font(.headline).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.customControlBackground.opacity(0.5))
        .cornerRadius(12)
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
                    if appointment.isCompleted {
                        Image(systemName: "checkmark.seal.fill").foregroundColor(.green).font(.caption)
                    }
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.patient?.demographicData.components(separatedBy: " - ").first?.uppercased() ?? "NAME NOT SET")
                        .font(.headline)
                        .tracking(1)
                    Text(appointment.patient?.patientID ?? "ID: Unknown")
                        .font(.system(.caption, design: .monospaced)).foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "ellipsis.circle.fill").font(.title2).foregroundColor(.purple.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color.customControlBackground)
        .cornerRadius(12)
        .onTapGesture { onEdit() }
    }
}
