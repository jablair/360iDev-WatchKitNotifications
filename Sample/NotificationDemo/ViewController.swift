//
//  ViewController.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UIKit
import UserNotifications

/// Primary view controller for the iOS application
class ViewController: UIViewController {
    /// The configured application mode for this app instance
    private var currentMode: Mode = .undefined {
        didSet {
            self.configureUI()
            self.connectivityManager?.send(message: currentMode, queueIfNecessary: true, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /// Connectivity manager for communicating with a paired watch appliction
    var connectivityManager: ConnectivityManager?
    
    /// Notification Processor for managing repeating notifications
    var notificationProcessor: NotificationProcessor?
    
    /// Displays the current configuration status of the application
    @IBOutlet var statusLabel: UILabel!
    /// Button for transitioning to the default / first run application mode
    @IBOutlet var defaultMode: UIButton!
    /// Button for transitioning to the primary device application mode
    @IBOutlet var primaryMode: UIButton!
    /// Button for transitioning to the secondary device application mode
    @IBOutlet var secondaryMode: UIButton!

    /// Button for sending a `primaryMode` local notification with an attachment
    @IBOutlet var knownNotificationButton: UIButton!
    
    /// Button for sending an non-handled local notification category with an attachment
    @IBOutlet var unknownNotificationButton: UIButton!
    
    /// Button for registering a repeating notification trigger
    @IBOutlet var repeatingNotificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rawStoredMode = UserDefaults.standard.string(forKey: CurrentModeKey) {
            self.currentMode = Mode(rawValue: rawStoredMode) ?? .undefined
        }
        
        self.configureUI()
    }
    
    /// Configures the application in default / first run mode
    ///
    /// - Parameter sender: The object that sent the message
    @IBAction func configureUndefinedMode(_ sender: Any) {
        self.currentMode = .undefined
        UserDefaults.standard.set(self.currentMode.rawValue, forKey: CurrentModeKey)
    }
    
    /// Configures the applicating in primary device mode
    ///
    /// - Parameter sender: The object that sent the message
    @IBAction func configurePrimaryMode(_ sender: Any) {
        self.currentMode = .primary
        UserDefaults.standard.set(self.currentMode.rawValue, forKey: CurrentModeKey)    }

    /// Configures the application in secondary device mode.
    ///
    /// - Parameter sender: The object that sent the message
    @IBAction func configureSecondaryMode(_ sender: Any) {
        self.currentMode = .secondary
        UserDefaults.standard.set(self.currentMode.rawValue, forKey: CurrentModeKey)
    }
    
    @IBAction func sendKnownNotification(_ sender: Any) {
        self.sendNotification(with: UserNotificationCategory.primaryMode.rawValue)
    }
    
    @IBAction func sendUnknownNotification(_ sender: Any) {
        self.sendNotification(with: "UnhandledNotificationCategory")
    }
    
    @IBAction func sendRepeatingNotification(_ sender: Any) {
        self.notificationProcessor?.addRepeatingNotificationTriggers()
    }
    
    private func sendNotification(with categoryIdentifier: String) {
        let attachmentURL = Bundle.main.url(forResource: "GeneralOrgana", withExtension: "jpg")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Local Notification", comment: "Local Notification Title")
        content.body = NSLocalizedString("Notification Body", comment: "Local Notification Body")
        content.categoryIdentifier = categoryIdentifier
        
        do {
            if let attachment = try attachmentURL.map({ return try UNNotificationAttachment(identifier: "", url: $0, options: nil) }) {
                content.attachments = [attachment]
                
                // This isn't really required for on-phone local notifications. However, we need some way to communicate the notification data to the watch, since
                // the URL on the attachment will be security-scoped to the phone and not available on the watch.
                // I experimented a bit with using a WCSession request in the PrimaryNotificationController, but I wasn't getting back a response soon enough
                content.userInfo[UserNotificationInfoKey.notificationAttachmentIdentifier.rawValue] = attachment.url.deletingPathExtension().lastPathComponent
            }
        } catch {
            print ("Failed to create attachment with error \(error)")
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)

    }
    
    /// Configures the UI based on the current device mode
    private func configureUI() {
        self.statusLabel.text = self.currentMode.title
        
        switch self.currentMode {
        case .undefined:
            self.defaultMode.isHidden = true
            self.primaryMode.isHidden = false
            self.secondaryMode.isHidden = false
            self.knownNotificationButton.isHidden = true
            self.unknownNotificationButton.isHidden = true
        case .primary, .secondary:
            self.defaultMode.isHidden = false
            self.primaryMode.isHidden = true
            self.secondaryMode.isHidden = true
            self.knownNotificationButton.isHidden = self.currentMode == .secondary
            self.unknownNotificationButton.isHidden = self.currentMode == .secondary
        }
    }
}

extension Mode {
    /// UI display string for the various device modes
    var title: String {
        switch self {
        case .undefined:
            return NSLocalizedString("Not Configured", comment:"Not Configured device mode title")
        case .primary:
            return NSLocalizedString("Primary Device", comment:"Primary device mode title")
        case .secondary:
            return NSLocalizedString("Secondary Device", comment:"Secondary device mode title")
        }
    }
}
