//
//  UserNotificationCategory.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/9/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UserNotifications

/// Notification categories supported by the application
///
/// - primaryMode: Notifications handled by devices configured as primary
/// - secondaryMode: Notification handled by devices configured as secondary
/// - repeating: Repeating notification category that supports a dismissal action
enum UserNotificationCategory: String {
    /// Notifications handled by devices configured as primary
    case primaryMode
    /// Notification handled by device configured as secondary
    case secondaryMode
    /// Repeating notification category that supports a dismissal action
    case repeating
}

/// Notification actions supported by the application
///
/// - call: Action that should trigger a phone call
/// - modal: Action that displays notification info in a modal
enum UserNotificationAction: String {
    /// Action that should trigger a phone call
    case call
    /// Action that displays notification info in a modal
    case modal
	/// Action that offers text input options
	case textInput
	/// Action that runs in the background
	case background
}

/// Keys used for `UNNotificationContent userInfo` entries
///
/// - notificationAttachmentIdentifier: Key for the attachment identifier. Value is a string.
enum UserNotificationInfoKey: String {
    /// Key for the attachment identifier. Value is a string.
    case notificationAttachmentIdentifier
}
