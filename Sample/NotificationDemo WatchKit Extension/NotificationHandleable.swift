//
//  NotificationHandleable.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/19/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UserNotifications

/// Protocol for direct handling of notifications
protocol NotificationHandleable {
    /// Indicates whether the receiver can handle a notification in its current state
    ///
    /// - Parameters:
    ///   - notification: The notification to be handled
    ///   - response: The response associated with the notification
    /// - Returns: `true` if the notification can be handled, otherwise `false`.
    func canHandle(notification: UNNotification, with response: UNNotificationResponse?) -> Bool
    
    /// Handles a notification by the receiver
    ///
    /// - Parameters:
    ///   - notification: The notification to be handled
    ///   - response: The response associated with the notification
    func handle(notification: UNNotification, with response: UNNotificationResponse?)
}

extension NotificationHandleable {
    func canHandle(notification: UNNotification, with response: UNNotificationResponse?) -> Bool {
        return false
    }
    
    func handle(notification: UNNotification, with response: UNNotificationResponse?) { }
}
