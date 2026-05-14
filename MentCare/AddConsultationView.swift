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
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Clinical Details")) {
                    TextField("Diagnostic Code (e.g. ICD-10)", text: $diagnosticCode)
                    
                    VStack(alignment: .leading) {
                        Text("Clinical Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $clinicalNotes)
                            .frame(minHeight: 120)
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
                        newConsultation.patient = patient // Hastaya bağlıyoruz
                        modelContext.insert(newConsultation)
                        dismiss()
                    }
                    // Veri Doğrulama (Data Validation): İmza veya Teşhis kodu boşsa kayıt yapılamaz
                    .disabled(signatureCode.isEmpty || diagnosticCode.isEmpty)
                }
            }
        }
    }
}
