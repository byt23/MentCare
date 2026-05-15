//
//  PatientListView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

struct PatientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Patient.patientID) private var patients: [Patient]
    @State private var isShowingSheet = false
    
    // YENİ: Arama ve Filtreleme için State Değişkenleri
    @State private var searchText = ""
    @State private var selectedFilter = "All" // Seçenekler: "All", "Normal", "Suicidal", "Aggressive"
    
    // YENİ: Arama ve filtrelemeyi aynı anda uygulayan akıllı liste
    var filteredPatients: [Patient] {
        patients.filter { patient in
            // 1. Arama Çubuğu Kontrolü (İsim veya ID'de geçiyorsa)
            let matchesSearch = searchText.isEmpty ||
                                patient.demographicData.localizedCaseInsensitiveContains(searchText) ||
                                patient.patientID.localizedCaseInsensitiveContains(searchText)
            
            // 2. Kategori Filtresi Kontrolü
            let matchesFilter = selectedFilter == "All" || patient.warningFlag == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // YENİ: Hızlı Filtreleme Butonları
                Picker("Filter Status", selection: $selectedFilter) {
                    Text("All Patients").tag("All")
                    Text("Normal").tag("Normal")
                    Text("Suicidal").tag("Suicidal")
                    Text("Aggressive").tag("Aggressive")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 5)
                
                List {
                    // YENİ: Artık 'patients' yerine 'filteredPatients' kullanıyoruz
                    ForEach(filteredPatients) { patient in
                        NavigationLink(destination: PatientDetailView(patient: patient)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(patient.demographicData.components(separatedBy: " - ").first ?? "Unknown")
                                        .font(.headline)
                                    Text("ID: \(patient.patientID)")
                                        .font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                statusIcon(for: patient.warningFlag)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteSinglePatient(patient)
                            } label: {
                                Label("Delete Patient", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deletePatients)
                }
            }
            .navigationTitle("Records")
            // YENİ: SwiftUI'ın yerleşik arama çubuğu
            .searchable(text: $searchText, prompt: "Search by Name or TC/ID")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                AddPatientView()
            }
            .onChange(of: patients) { _, newPatients in
                SyncService().syncPatientsToCloud(patients: newPatients)
            }
        }
    }
    
    private func statusIcon(for flag: String) -> some View {
        Group {
            if flag == "Suicidal" {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            } else if flag == "Aggressive" {
                Image(systemName: "hand.raised.fill").foregroundColor(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            }
        }
    }
    
    private func deletePatients(offsets: IndexSet) {
        for index in offsets {
            // KRİTİK DÜZELTME: Doğru öğeyi silmek için filteredPatients kullanıyoruz
            let patientToDelete = filteredPatients[index]
            modelContext.delete(patientToDelete)
        }
        try? modelContext.save()
    }
    
    private func deleteSinglePatient(_ patient: Patient) {
        modelContext.delete(patient)
        try? modelContext.save()
    }
}
