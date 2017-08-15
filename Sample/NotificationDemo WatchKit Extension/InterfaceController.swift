//
//  InterfaceController.swift
//  NotificationDemo WatchKit Extension
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

/// Main UI Interface Controller for watch application
class InterfaceController: WKInterfaceController {
    /// Storyboard identifier for the interface
    static let identifer = "InterfaceController"

    /// Date formatter for displaying notification date
    static let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        return df
    }()
    
    /// Configured device mode
    var mode: Mode = .undefined {
        didSet {
            self.setTitle(mode.rawValue)
            self.configureInterface()

            self.processPendingNotification()
        }
    }
    
    /// Notification, if any, that should be processed after the UI is displayed
    private var pendingNotificationInfo: NotificationInfo?
    
    /// Interface group containing the default / first run device UI
    @IBOutlet private var undefinedInterfaceGroup: WKInterfaceGroup!
    /// Interface group containing the primary device UI
    @IBOutlet private var primaryInterfaceGroup: WKInterfaceGroup!
    /// Interface group containing the secondary device UI
    @IBOutlet private var secondaryInterfaceGroup: WKInterfaceGroup!
    /// Secondary device UI notification received label
    @IBOutlet private var notificationReceivedLabel: WKInterfaceLabel!
    /// Secondary device UI notification date received label
    @IBOutlet private var notificationReceivedDateLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let rawMode = UserDefaults.standard.string(forKey: CurrentModeKey), let mode = Mode(rawValue: rawMode) {
            self.mode = mode
        }
        
        self.pendingNotificationInfo = context as? NotificationInfo
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.configureInterface()
    }
    
    override func didAppear() {
        super.didAppear()
        
        self.processPendingNotification()
    }
    
    /// Adds a request for a primary local notification with a 10 second delay
    @IBAction func requestLocalNotification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Local Notification", comment: "Local Notification Title")
        content.body = NSLocalizedString("Notification Body", comment: "Local Notification Body")
        content.categoryIdentifier = UserNotificationCategory.primaryMode.rawValue
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Adds a request for a repeating notification each minute
    @IBAction func requestRepeatingNotification() {
        (WKExtension.shared().delegate as? ExtensionDelegate)?.notificationProcessor.addRepeatingNotificationTriggers()
    }
    
    /// Handles the processing of notifications that required the fixed / initial UI state
    private func processPendingNotification() {
        guard
            let notificationInfo = self.pendingNotificationInfo,
            let category = UserNotificationCategory(rawValue: notificationInfo.notification.request.content.categoryIdentifier),
            self.mode != .undefined else {
                return
        }
        
        switch mode {
        case .primary where category == .primaryMode:
            guard notificationInfo.action != .call else {
                break
            }

            if notificationInfo.action == .modal || notificationInfo.action == .textInput {
                self.displayModal(notificationInfo: notificationInfo)
            } else {
                self.pushController(withName: DetailInterfaceController.identifer, context: notificationInfo)
            }
        
        default:
			break
        }
        
        self.pendingNotificationInfo = nil
    }
    
    /// Helper method for displaying a modal notification detail interface
    ///
    /// - Parameter notification: The notification to display
	fileprivate func displayModal(notificationInfo: NotificationInfo) {
        self.dismiss()
        self.presentController(withName: DetailInterfaceController.identifer, context: notificationInfo)
    }
    
    /// Confgires the UI based on the current mode and notification state
    ///
    /// - Parameter notification: The notification, if any, to use in populating the UI
    fileprivate func configureInterface(with notification: UNNotification? = nil) {
        guard self.pendingNotificationInfo == nil else {
            // Hide the UI when processing a pending notification to avoid a flash of content
            self.undefinedInterfaceGroup.setHidden(true)
            self.primaryInterfaceGroup.setHidden(true)
            self.secondaryInterfaceGroup.setHidden(true)
            
            return
        }
        
        switch self.mode {
        case .undefined:
            self.undefinedInterfaceGroup.setHidden(false)
            self.primaryInterfaceGroup.setHidden(true)
            self.secondaryInterfaceGroup.setHidden(true)
        case .primary:
            self.undefinedInterfaceGroup.setHidden(true)
            self.primaryInterfaceGroup.setHidden(false)
            self.secondaryInterfaceGroup.setHidden(true)
        case .secondary:
            self.undefinedInterfaceGroup.setHidden(true)
            self.primaryInterfaceGroup.setHidden(true)
            self.secondaryInterfaceGroup.setHidden(false)
            
            if let notification = notification {
                self.notificationReceivedLabel.setHidden(false)
                self.notificationReceivedDateLabel.setHidden(false)
                self.notificationReceivedDateLabel.setText(InterfaceController.dateFormatter.string(from: notification.date))
            }
        }

    }

}

extension InterfaceController: NotificationHandleable {
    func canHandle(notification: UNNotification, with response: UNNotificationResponse?) -> Bool {
        guard let category = UserNotificationCategory(rawValue: notification.request.content.categoryIdentifier) else { return false }
		
		let action = response.flatMap { UserNotificationAction(rawValue:  $0.actionIdentifier) }
		
        switch self.mode {
        case .primary where category == .primaryMode && (action == .modal || action == .textInput),
             .secondary where category == .secondaryMode:
            return true
        default:
            return false
        }
    }
    
    func handle(notification: UNNotification, with response: UNNotificationResponse? = nil) {
        guard let category = UserNotificationCategory(rawValue: notification.request.content.categoryIdentifier) else { return }

		let action = response.flatMap { UserNotificationAction(rawValue:  $0.actionIdentifier) }

        switch self.mode {
        case .primary where category == .primaryMode && (action == .modal || action == .textInput):
            self.displayModal(notificationInfo: NotificationInfo(notification: notification, response: response))
        case .secondary where category == .secondaryMode:
            self.configureInterface(with: notification)
        default:
            print ("No handle-able notifications for combination of mode = \(self.mode), category = \(notification.request.content.categoryIdentifier), action = \(action?.rawValue ?? "none")")
        }
    }
}
