//
//  NotificationManager.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted { print("🔔 Notifications Authorized") }
        }
    }
    
    func scheduleAppointmentReminder(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "Patient session starts in 15 minutes."
        content.sound = .default
        
        // Randevudan 15 dakika öncesine ayarla
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -15, to: appointment.appointmentDate)!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: appointment.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
