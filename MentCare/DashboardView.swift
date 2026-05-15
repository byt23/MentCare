//
//  DashboardView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    @Query private var patients: [Patient]
    @Query private var appointments: [Appointment]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Clinical Insights")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Risk Distribution").font(.headline)
                        Chart(riskData, id: \.type) { data in
                            SectorMark(
                                angle: .value("Count", data.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Type", data.type))
                            .annotation(position: .overlay) {
                                Text("\(data.count)").font(.caption).bold().foregroundColor(.white)
                            }
                        }
                        .frame(height: 220)
                        .chartForegroundStyleScale([
                            "Normal": .green, "Suicidal": .red, "Aggressive": .orange
                        ])
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    VStack(alignment: .leading) {
                        Text("Daily Schedule").font(.headline)
                        Chart(appointmentTrends, id: \.day) { data in
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Appointments", data.count)
                            )
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .bottom, endPoint: .top))
                            .cornerRadius(5)
                        }
                        .frame(height: 220)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                
                // Özet Kartları
                HStack(spacing: 20) {
                    summaryCard(title: "Total Patients", count: patients.count, icon: "person.2.fill", color: .blue)
                    summaryCard(title: "Critical Cases", count: patients.filter { $0.warningFlag != "Normal" }.count, icon: "exclamationmark.shield.fill", color: .red)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
    
    private var riskData: [(type: String, count: Int)] {
        let normal = patients.filter { $0.warningFlag == "Normal" }.count
        let suicidal = patients.filter { $0.warningFlag == "Suicidal" }.count
        let aggressive = patients.filter { $0.warningFlag == "Aggressive" }.count
        return [("Normal", normal), ("Suicidal", suicidal), ("Aggressive", aggressive)]
    }
    
    private var appointmentTrends: [(day: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return (0..<7).map { i in
            let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
            let count = appointments.filter { Calendar.current.isDate($0.appointmentDate, inSameDayAs: date) }.count
            return (formatter.string(from: date), count)
        }
    }
    
    private func summaryCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.subheadline).foregroundColor(.secondary)
            }
            Text("\(count)").font(.system(size: 44, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
