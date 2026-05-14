//
//  AddPrescriptionView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct AddPrescriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var consultation: Consultation
    
    @State private var drugName = ""
    @State private var dosageAmount = ""
    @State private var adminFrequency = ""
    @State private var cost: Double = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Drug Name", text: $drugName)
                    TextField("Dosage (e.g. 50mg)", text: $dosageAmount)
                    TextField("Frequency (e.g. Twice a day)", text: $adminFrequency)
                }
                
                Section(header: Text("Financials")) {
                    HStack {
                        Text("$")
                        #if os(iOS)
                        TextField("Estimated Cost", value: $cost, format: .number)
                            .keyboardType(.decimalPad)
                        #else
                        TextField("Estimated Cost", value: $cost, format: .number)
                        #endif
                    }
                }
            }
            .navigationTitle("Prescribe Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newPrescription = Prescription(
                            drugName: drugName,
                            dosageAmount: dosageAmount,
                            adminFrequency: adminFrequency,
                            cost: cost
                        )
                        newPrescription.consultation = consultation // Konsültasyona bağlıyoruz
                        modelContext.insert(newPrescription)
                        dismiss()
                    }
                    .disabled(drugName.isEmpty || dosageAmount.isEmpty)
                }
            }
        }
    }
}
