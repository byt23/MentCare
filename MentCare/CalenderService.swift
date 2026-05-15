//
//  CalenderService.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation
import EventKit

class CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    // Sadece takvime randevu ekleme yetkisi istiyoruz (iOS 17 / macOS 14 ve üzeri için en güvenlisi)
    func addAppointment(for patientName: String, date: Date, notes: String, completion: @escaping (Bool) -> Void) {
        eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
            guard granted, error == nil else {
                print("❌ Takvim erişimi reddedildi veya hata oluştu: \(String(describing: error))")
                completion(false)
                return
            }
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = "MentCare: \(patientName) - Follow-up"
            event.startDate = date
            event.endDate = date.addingTimeInterval(60 * 60) // Standart 1 saatlik seans
            event.notes = notes
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                print("✅ Randevu Mac Takvimine başarıyla işlendi!")
                completion(true)
            } catch {
                print("❌ Randevu kaydedilemedi: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
