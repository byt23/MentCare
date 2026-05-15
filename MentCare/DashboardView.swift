//
//  DashboardView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var allPatients: [Patient]
    @Query private var allAppointments: [Appointment]
    @Query private var allConsultations: [Consultation]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Clinical Overview")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    summaryCard(title: "Active Patients", count: allPatients.count, icon: "person.2.fill", color: .blue)
                    summaryCard(title: "Critical Alerts", count: allPatients.filter { $0.warningFlag != "Normal" }.count, icon: "exclamationmark.triangle.fill", color: .red)
                }
                .padding(.horizontal)
                VStack(alignment: .leading) {
                    Text("Risk Distribution")
                        .font(.headline).padding(.bottom, 5)
                    Chart {
                        ForEach(riskData, id: \.type) { data in
                            SectorMark(
                                angle: .value("Count", data.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Type", data.type))
                            .cornerRadius(5)
                        }
                    }
                    .frame(height: 200)
                }
                .padding()
                .background(Color.customControlBackground.opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal)
                VStack(alignment: .leading) {
                    Text("Weekly Appointment Load")
                        .font(.headline).padding(.bottom, 5)
                    Chart {
                        ForEach(weeklyData) { data in
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Appointments", data.count)
                            )
                            .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .bottom, endPoint: .top))
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)
                }
                .padding()
                .background(Color.customControlBackground.opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    

    
    private func summaryCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).foregroundColor(color).font(.title2)
            Text("\(count)").font(.title).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.customControlBackground)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    var riskData: [(type: String, count: Int)] {
        let normal = allPatients.filter { $0.warningFlag == "Normal" }.count
        let critical = allPatients.filter { $0.warningFlag != "Normal" }.count
        return [("Stable", normal), ("At Risk", critical)]
    }
    
    var weeklyData: [WeeklyAppointment] {
        return [
            WeeklyAppointment(day: "Mon", count: 3),
            WeeklyAppointment(day: "Tue", count: 5),
            WeeklyAppointment(day: "Wed", count: 2),
            WeeklyAppointment(day: "Thu", count: 8),
            WeeklyAppointment(day: "Fri", count: 4)
        ]
    }
}

struct WeeklyAppointment: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
}
