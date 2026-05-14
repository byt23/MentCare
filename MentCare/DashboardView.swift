//
//  DashboardView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    // SwiftData'dan acil durum uyarısı olan hastaları çekiyoruz
    @Query(filter: #Predicate<Patient> { $0.warningFlag != "Normal" })
    private var highRiskPatients: [Patient]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome to MentCare")
                        .font(.largeTitle)
                        .bold()
                    
                    // Eğer riskli hasta varsa kırmızı uyarı kartı göster
                    if !highRiskPatients.isEmpty {
                        VStack(alignment: .leading) {
                            Label("Critical Action Required", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("You have \(highRiskPatients.count) patient(s) with active risk flags.")
                                .foregroundColor(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    } else {
                        Text("No active critical warnings today.")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}
