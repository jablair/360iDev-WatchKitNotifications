//
//  DetailInterfaceController.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/9/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

/// Interface controller for showing the details of a notification in the primary application mode
class DetailInterfaceController: WKInterfaceController {
    /// Storyboard identifier for the Detail Interface Controller
    static let identifer = "DetailInterfaceController"

    /// Notification description label
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    /// Notification date label
    @IBOutlet var detailLabel: WKInterfaceLabel!
    
    /// Date formatter for notification date label
    static let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        return df
    }()

    /// The primary mode notification to display
    private var primaryDisplayNotification: NotificationInfo? = nil {
        didSet {
            self.configureUI()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.primaryDisplayNotification = context as? NotificationInfo
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    /// Configured the UI for displaying the notification, if any
    private func configureUI() {
		if let notification = self.primaryDisplayNotification?.notification {
			descriptionLabel.setText("Notification Processed")
			if let response = self.primaryDisplayNotification?.response as? UNTextInputNotificationResponse {
				detailLabel.setText(response.userText)
			} else {
				detailLabel.setText(DetailInterfaceController.dateFormatter.string(from: notification.date))
			}
			detailLabel.setHidden(false)
        } else {
            descriptionLabel.setText("No Notification")
            detailLabel.setHidden(true)
        }
        
    }

}
