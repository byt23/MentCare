//
//  ClinicCalendarView.swift
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
                    .padding(.bottom, 10)
                
                Divider()
                
                appointmentMainList
            }
            .background(Color.customWindowBackground)
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
        VStack(spacing: 15) {
            #if os(macOS)
            Text("Clinic Calendar")
                .font(.title2).bold()
                .padding(.top)
            #endif
            
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .accentColor(.purple)
                .padding(10)
                .background(Color.customControlBackground.opacity(0.6))
                .cornerRadius(20)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                miniStat(title: "Total", count: allAppointments.count, color: .blue)
                miniStat(title: "Pending", count: allAppointments.filter {!$0.isCompleted}.count, color: .orange)
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
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                    Text("\(filteredAppointments.count) sessions found")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: { isShowingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            List {
                if filteredAppointments.isEmpty {
                    VStack(spacing: 15) {
                        Spacer().frame(height: 40)
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.quaternary)
                        Text("No Sessions Scheduled")
                            .font(.subheadline).bold()
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredAppointments) { appt in
                        AppointmentRow(appointment: appt) {
                            editingAppointment = appt
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            #if os(iOS)
            .padding(.bottom, 80)
            #endif
        }
    }
    
    private func miniStat(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).font(.caption).foregroundColor(.secondary)
            Text("\(count)").font(.caption).bold()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.customControlBackground)
        .cornerRadius(20)
    }
}


struct AppointmentRow: View {
    var appointment: Appointment
    var onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(appointment.isCompleted ? Color.gray : Color.purple)
                .frame(width: 4)
            
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
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        .onTapGesture { onEdit() }
    }
}
