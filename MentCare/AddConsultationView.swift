//
//  AddConsultationView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct AddConsultationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var patient: Patient
    
    @State private var clinicalNotes = ""
    @State private var diagnosticCode = ""
    @State private var signatureCode = ""
    @State private var suggestedFlag = "Normal"
    @State private var isAIAnalyzed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Clinical Details")) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Search Diagnostic Code or Name...", text: $diagnosticCode)
                            .textFieldStyle(.roundedBorder)

                        let searchResults = ClinicalDatabase.searchICD10(query: diagnosticCode)
                        
                        if !searchResults.isEmpty && !ClinicalDatabase.icd10Codes.keys.contains(diagnosticCode) {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    ForEach(searchResults.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        Button(action: {
                                            diagnosticCode = key
                                        }) {
                                            HStack {
                                                Text(key).bold()
                                                Text("- \(value)").foregroundColor(.secondary)
                                                Spacer()
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                        }
                                        .buttonStyle(.plain)
                                        Divider()
                                    }
                                }
                                .background(platformBackgroundColor)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            }
                            .frame(maxHeight: 150)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack(alignment: .leading) {
                        Text("Clinical Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $clinicalNotes)
                            .frame(minHeight: 120)
                        
                        Button(action: runAIAnalysis) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("AI Risk Analysis")
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(clinicalNotes.isEmpty ? Color.gray : Color.purple)
                            .cornerRadius(10)
                        }
                        .disabled(clinicalNotes.isEmpty)
                        .padding(.top, 5)
                    }
                }

                if isAIAnalyzed {
                    Section("AI Assessment") {
                        HStack {
                            Text("Suggested Risk Level:")
                            Spacer()
                            Text(suggestedFlag)
                                .bold()
                                .foregroundColor(statusColor)
                        }
                        
                        if suggestedFlag != "Normal" {
                            Button("Apply Flag to Patient Profile") {
                                patient.warningFlag = suggestedFlag
                                try? modelContext.save()
                            }
                            .buttonStyle(.bordered)
                            .tint(statusColor)
                        }
                    }
                }
                
                Section(header: Text("Authentication")) {
                #if os(iOS)
                    TextField("Doctor Signature Code", text: $signatureCode)
                        .textInputAutocapitalization(.characters)
                #else
                    TextField("Doctor Signature Code", text: $signatureCode)
                #endif
                }
            }
            .navigationTitle("New Consultation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newConsultation = Consultation(
                            consultationDate: Date(),
                            clinicalNotes: clinicalNotes,
                            diagnosticCode: diagnosticCode,
                            signatureCode: signatureCode
                        )
                        newConsultation.patient = patient
                        modelContext.insert(newConsultation)
                        SyncService().syncPatientsToCloud(patients: [patient])
                        dismiss()
                    }
                    .disabled(signatureCode.isEmpty || diagnosticCode.isEmpty)
                }
            }
        }
    }
    
    private var platformBackgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    private func runAIAnalysis() {
        withAnimation {
            suggestedFlag = AIService.analyzeRisk(from: clinicalNotes)
            isAIAnalyzed = true
        }
    }

    private var statusColor: Color {
        switch suggestedFlag {
        case "Suicidal": return .red
        case "Aggressive": return .orange
        default: return .green
        }
    }
}
