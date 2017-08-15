//
//  NotificationProcessor.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/9/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UIKit
import UserNotifications

/// Handles the notification registation and response processing responsibilities for the iOS application.
class NotificationProcessor: NSObject {
    /// Registers for known notification categories and actions and requests remote notification authorization
	func registerNotifications() {
		let callAction = UNNotificationAction(
			identifier: UserNotificationAction.call.rawValue,
			title: NSLocalizedString("Call", comment: "Call notification title"),
			options: .foreground)
		
		let modalAction = UNNotificationAction(
			identifier: UserNotificationAction.modal.rawValue,
			title: NSLocalizedString("Modal", comment: "Modal notification title"),
			options: .foreground)
		
		let backgroundAction = UNNotificationAction(
			identifier: UserNotificationAction.background.rawValue,
			title: NSLocalizedString("Background", comment: "Background notification title"),
			options: [])
		
		let primaryCategory = UNNotificationCategory(
			identifier: UserNotificationCategory.primaryMode.rawValue,
			actions: [callAction, modalAction, backgroundAction],
			intentIdentifiers: [],
			options: [])
		
		let secondaryCategory = UNNotificationCategory(
			identifier: UserNotificationCategory.secondaryMode.rawValue,
			actions: [],
			intentIdentifiers: [],
			options: [])
		
		let repeatingCategory = UNNotificationCategory(
			identifier: UserNotificationCategory.repeating.rawValue,
			actions: [],
			intentIdentifiers: [],
			options: .customDismissAction)
		
		let categories: Set<UNNotificationCategory> = [primaryCategory, secondaryCategory, repeatingCategory]
		UNUserNotificationCenter.current().setNotificationCategories(categories)
		
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { registered, _ in
			guard registered else {
				print ("Failed to request notification authorization")
				return
			}
			
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
        }
    }
}

extension NotificationProcessor: UNUserNotificationCenterDelegate {
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let presentationOptions: UNNotificationPresentationOptions
        if UserNotificationCategory(rawValue: notification.request.content.categoryIdentifier) == .repeating {
            presentationOptions = [.sound, .alert]
        } else {
            presentationOptions = []
        }

        // Don't display notifications that are received while the applicaiton is active
        completionHandler(presentationOptions)
    }
    
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == UserNotificationCategory.repeating.rawValue && response.actionIdentifier == UNNotificationDismissActionIdentifier {
            
            self.clearRepeatingNotifications()
            
            print("Cancelling repeating notification")
            
        }
        
        completionHandler()
    }
}
