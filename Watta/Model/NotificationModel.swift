//
//  NotificationModel.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation
import UserNotifications

struct NotificationModel {
    static let instance = NotificationModel()
    func setupNotifications(){
        let notifId = "Notif1"
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) {  granted, error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized{
                center.getPendingNotificationRequests { requests in
                    let notificationExists = requests.contains{$0.identifier == notifId}
                    if notificationExists{return}
                    else {
                        let content = UNMutableNotificationContent()
                        content.title = "Watta up!"
                        content.body = "Stay Hydrated, Be sure to drink plenty of water 💫"
                        content.sound = .default
                        let calendar = Calendar.current
                        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                        dateComponents.hour = 8 // Start from 8 am
                        dateComponents.minute = 0
                        for i in 0..<12 {
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            
                            let request = UNNotificationRequest(identifier: "notification\(i)", content: content, trigger: trigger)
                            
                            center.add(request) { error in
                                if let error = error {
                                    print("Failed to schedule notification: \(error)")
                                } else {
                                    print("Notification scheduled for \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
                                }
                            }
                            
                            
                            // Increment dateComponents by 2 hours
                            dateComponents.hour? += 2
                        }
                    }
                }
            }
            else{
                return
            }
        }
        
    }
}
