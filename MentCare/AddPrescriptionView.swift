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
    
    // Senin orijinal değişkenlerin
    @State private var drugName = ""
    @State private var dosageAmount = ""
    @State private var adminFrequency = ""
    @State private var cost: Double = 0.0
    
    // YENİ: Etkileşim uyarısını tutacak değişken
    @State private var interactionWarning: String? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Drug Name", text: $drugName)
                        // YENİ: İlaç adı her değiştiğinde AI kontrolünü tetikler
                        .onChange(of: drugName) { _, newValue in
                            checkForInteractions(newDrug: newValue)
                        }
                    
                    TextField("Dosage (e.g. 50mg)", text: $dosageAmount)
                    TextField("Frequency (e.g. Twice a day)", text: $adminFrequency)
                }
                
                // YENİ: Akıllı Etkileşim Uyarısı (Sadece çakışma varsa görünür)
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
                        .listRowBackground(Color.red) // Bölümün arka planını kırmızı yapar
                    }
                }
                
                // Senin orijinal finansal detayların
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
                    // YENİ: İlaç adı boşsa VEYA tehlikeli bir etkileşim varsa kaydetmeyi engelle
                    .disabled(drugName.isEmpty || dosageAmount.isEmpty || interactionWarning != nil)
                }
            }
        }
    }
    
    // YENİ: Girilen ilacın, konsültasyondaki diğer ilaçlarla çakışıp çakışmadığını kontrol eder
    private func checkForInteractions(newDrug: String) {
        // Konsültasyona daha önce eklenmiş reçeteler varsa onların isimlerini alıyoruz
        // (Eğer Consultation modelinde 'prescriptions' dizisi yoksa, sadece yeni girilen ilacı kontrol eder)
        var currentDrugs: [String] = []
        
        // SwiftData ilişkisinden dolayı consultation.prescriptions adında bir diziye sahip olduğunu varsayıyoruz
        // Eğer modelinde bu dizinin adı farklıysa (örneğin 'medications'), aşağıyı ona göre güncelleyebilirsin.
        if let existingPrescriptions = consultation.prescriptions {
            currentDrugs = existingPrescriptions.map { $0.drugName }
        }
        
        // Yeni yazılan ilacı da listeye ekliyoruz
        if !newDrug.isEmpty {
            currentDrugs.append(newDrug)
        }
        
        // InteractionService'e gönderip sonucu alıyoruz
        withAnimation {
            interactionWarning = InteractionService.checkInteractions(for: currentDrugs)
        }
    }
}
