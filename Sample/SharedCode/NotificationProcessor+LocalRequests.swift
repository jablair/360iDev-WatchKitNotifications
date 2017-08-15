//
//  NotificationProcessor+LocalRequests.swift
//  NotificationDemo
//
//  Created by Eric Blair on 2/13/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UserNotifications

// MARK: - Repeating notification support for both iOS and watchOS apps

extension NotificationProcessor {
    private var repeatingIdentifer: String {
        return "notificationDemo-repeating-identifier"
    }
    
    func addRepeatingNotificationTriggers() {
        let entryTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0, repeats: true)
        let entryContent = UNMutableNotificationContent()
        entryContent.title = NSLocalizedString("Repeating Notification", comment: "Repeating Notification Title")
        entryContent.body = NSLocalizedString("This is the notification that never ends", comment: "Repeating Notification Body")
        entryContent.categoryIdentifier = UserNotificationCategory.repeating.rawValue
        
        let entryRequest = UNNotificationRequest(identifier: self.repeatingIdentifer, content: entryContent, trigger: entryTrigger)
        
        UNUserNotificationCenter.current().add(entryRequest) { (error: Error?) in
            guard let error = error else { return }
            print ("Error adding entry notification: \(error)")
        }
    }
    
    func clearRepeatingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.repeatingIdentifer])
    }
}
