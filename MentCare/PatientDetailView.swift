//
//  PatientDetailView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

#if canImport(AppKit)
import AppKit
#endif
import SwiftUI
import SwiftData

struct PatientDetailView: View {
    @Bindable var patient: Patient
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    
    @State private var isShowingAddConsultation = false
    @State private var selectedConsultationForPrescription: Consultation?
    @State private var isShowingAddAppointment = false
    
    var body: some View {
        Form {
            if patient.warningFlag == "Suicidal" || patient.warningFlag == "Aggressive" {
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("CRITICAL WARNING")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text("Patient status flagged as: \(patient.warningFlag)")
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Button("Clear") {
                            patient.warningFlag = "Normal"
                            saveAndSync()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Section(header: Text("Demographics")) {
                TextField("Patient ID", text: $patient.patientID)
                TextField("Demographics", text: $patient.demographicData)
                TextField("Emergency Contact", text: $patient.emergencyContact)
                TextField("Assigned Clinic", text: $patient.assignedClinic)
                
                Picker("Security Status", selection: $patient.warningFlag) {
                    Text("Normal").tag("Normal")
                    Text("Suicidal").tag("Suicidal")
                    Text("Aggressive").tag("Aggressive")
                }
            }

            // YENİ: Görsel Hasta Yolculuğu (Timeline) Bölümü
            Section(header: Text("Patient Journey")) {
                // 1. Yeni Randevu Butonu
                Button(action: { isShowingAddAppointment = true }) {
                    Label("Schedule Follow-up Appointment", systemImage: "calendar")
                        .foregroundColor(.blue)
                }
                
                // 2. YENİ ŞIK TİMELİNE BİLEŞENİ
                if let consultations = patient.consultations {
                    ConsultationTimelineView(consultations: consultations)
                        // Liste stili yerine kartların tam görünmesi için arka planı temizliyoruz
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                // 3. Yeni Not Butonu
                Button(action: { isShowingAddConsultation = true }) {
                    Label("Add New Consultation Note", systemImage: "plus.circle.fill")
                        .foregroundColor(.purple)
                }
            }
        }
        .navigationTitle("Profile: \(patient.patientID)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    saveAndSync()
                }) {
                    Label("Save & Sync", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    exportPDF()
                }) {
                    Label("Export PDF", systemImage: "doc.text.fill")
                }
            }
        }
        .sheet(isPresented: $isShowingAddConsultation) {
            AddConsultationView(patient: patient)
        }
        .sheet(item: $selectedConsultationForPrescription) { consultation in
            AddPrescriptionView(consultation: consultation)
        }
        .sheet(isPresented: $isShowingAddAppointment) {
            AddAppointmentView(patient: patient)
        }
    }
    
    @MainActor
    private func exportPDF() {
        let pdfView = PatientPDFView(patient: patient)
        let renderer = ImageRenderer(content: pdfView)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(patient.patientID)_Report.pdf")
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                print("❌ PDF çizim motoru başlatılamadı.")
                return
            }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        print("✅ PDF Başarıyla Oluşturuldu!")
        print("📁 Dosya Konumu: \(url.path)")
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        openURL(url)
        #endif
    }
    
    private func saveAndSync() {
        try? modelContext.save()
        SyncService().syncPatientsToCloud(patients: [patient])
    }
}
