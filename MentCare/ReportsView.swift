//
//  ReportsView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI
import Charts
import SwiftData

struct ReportsView: View {
    @Query private var patients: [Patient]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        ReportTile(title: "Stable", count: patients.filter{$0.warningFlag == "Normal"}.count, color: .green)
                        ReportTile(title: "Suicidal", count: patients.filter{$0.warningFlag == "Suicidal"}.count, color: .red)
                        ReportTile(title: "Aggressive", count: patients.filter{$0.warningFlag == "Aggressive"}.count, color: .orange)
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text("Security Risk Distribution").font(.headline).padding([.leading, .top])
                        
                        Chart {
                            ForEach(patients) { patient in
                                BarMark(
                                    x: .value("ID", patient.patientID),
                                    y: .value("Count", 1)
                                )
                                .foregroundStyle(by: .value("Status", patient.warningFlag))
                            }
                        }
                        .chartForegroundStyleScale([
                            "Normal": .green,
                            "Suicidal": .red,
                            "Aggressive": .orange
                        ])
                        .frame(height: 250)
                        .padding()
                    }
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(15)
                    .padding()
                }
            }
            .navigationTitle("Clinical Analytics")
        }
    }
}

struct ReportTile: View {
    let title: String
    let count: Int
    let color: Color
    var body: some View {
        VStack {
            Text(title).font(.caption2).bold().foregroundColor(color)
            Text("\(count)").font(.title2).bold()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
