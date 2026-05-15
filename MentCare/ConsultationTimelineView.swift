//
//  ConsultationTimelineView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import SwiftUI

struct ConsultationTimelineView: View {
    var consultations: [Consultation]

    var sortedConsultations: [Consultation] {
        consultations.sorted { $0.consultationDate > $1.consultationDate }
    }

    private var platformBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if sortedConsultations.isEmpty {
                Text("No medical history on record.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(sortedConsultations.enumerated()), id: \.element.id) { index, consultation in
                    HStack(alignment: .top, spacing: 15) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                                .frame(width: 14, height: 14)
                                .shadow(color: .blue.opacity(0.4), radius: 4, x: 0, y: 2)
                                .padding(.top, 4)
                            
                            if index != sortedConsultations.count - 1 {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 2)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(consultation.consultationDate, style: .date)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(consultation.diagnosticCode)
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .cornerRadius(8)
                            }
                            
                            Text(consultation.clinicalNotes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                            
                            if let prescriptions = consultation.prescriptions, !prescriptions.isEmpty {
                                Divider().padding(.vertical, 4)
                                HStack {
                                    Image(systemName: "pills.fill")
                                        .foregroundColor(.green)
                                    Text(prescriptions.map { $0.drugName }.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .bold()
                                }
                            }
                        }
                        .padding()
                        .background(platformBackground) 
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}
