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
    
    // Orijinal değişkenler
    @State private var drugName = ""
    @State private var dosageAmount = ""
    @State private var adminFrequency = ""
    @State private var cost: Double = 0.0
    
    // Yapay Zeka ve Kontrol Değişkenleri
    @State private var interactionWarning: String? = nil
    @State private var dosageWarning: String? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Drug Name", text: $drugName)
                        .onChange(of: drugName) { _, newValue in
                            checkForInteractions(newDrug: newValue)
                            // İlaç adı değiştiğinde dozu da tekrar kontrol et
                            withAnimation {
                                dosageWarning = ClinicalDatabase.validateDosage(for: newValue, dosageString: dosageAmount)
                            }
                        }
                    
                    TextField("Dosage (e.g. 50mg)", text: $dosageAmount)
                        .onChange(of: dosageAmount) { _, newValue in
                            withAnimation {
                                dosageWarning = ClinicalDatabase.validateDosage(for: drugName, dosageString: newValue)
                            }
                        }
                    TextField("Frequency (e.g. Twice a day)", text: $adminFrequency)
                }
                
                // İlaç Etkileşim Uyarısı (Kırmızı)
                if let warning = interactionWarning {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                            Text(warning)
                                .font(.subheadline)
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .listRowBackground(Color.red)
                    }
                }
                
                // Doz Aşımı (Overdose) Uyarısı (Turuncu)
                if let warning = dosageWarning {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .font(.title)
                            Text(warning)
                                .font(.subheadline)
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .listRowBackground(Color.orange)
                    }
                }
                
                // Finansal Detaylar
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
                        newPrescription.consultation = consultation
                        modelContext.insert(newPrescription)
                        dismiss()
                    }
                    // KAYDET BUTONU KİLİDİ: İsim/Doz boşsa VEYA herhangi bir uyarı varsa kilitlenir
                    .disabled(drugName.isEmpty || dosageAmount.isEmpty || interactionWarning != nil || dosageWarning != nil)
                }
            }
        }
    }
    
    // Etkileşim Kontrol Fonksiyonu
    private func checkForInteractions(newDrug: String) {
        var currentDrugs: [String] = []
        
        if let existingPrescriptions = consultation.prescriptions {
            currentDrugs = existingPrescriptions.map { $0.drugName }
        }
        
        if !newDrug.isEmpty {
            currentDrugs.append(newDrug)
        }
        
        withAnimation {
            interactionWarning = InteractionService.checkInteractions(for: currentDrugs)
        }
    }
}
