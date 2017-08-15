//
//  NotificationController.swift
//  NotificationDemo WatchKit Extension
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

/// Primary Mode Notification Interface Controller
class PrimaryNotificationController: WKUserNotificationInterfaceController {
    /// Date formatter for displaying the notification date
    static let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        return df
    }()

    /// Notification body label
    @IBOutlet var bodyLabel: WKInterfaceLabel!
    /// Notification date label
    @IBOutlet var dateLabel: WKInterfaceLabel!
    /// Notification image view
    @IBOutlet var notificationImage: WKInterfaceImage!

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
		if #available(watchOS 4, *), !notification.request.content.attachments.isEmpty {
			// Not really #available, but limited to watchOS 4
			// Default interface gives us attachment support on watchOS 4
			completionHandler(.default)
		}
		
        self.bodyLabel.setText(notification.request.content.body)
        self.dateLabel.setText(PrimaryNotificationController.dateFormatter.string(from: notification.date))
        
        let userInfo = notification.request.content.userInfo
        guard let notificationIdentifier = userInfo[UserNotificationInfoKey.notificationAttachmentIdentifier.rawValue] else {
            completionHandler(.custom)
            return
        }
		
        var attachmentURLComponents = URLComponents()
        attachmentURLComponents.scheme = "https"
        attachmentURLComponents.host = "room45.co"
        attachmentURLComponents.path = "/\(notificationIdentifier)-Watch.jpg"
        
        guard let imageURL = attachmentURLComponents.url else {
            completionHandler(.custom)
            return
        }
        
        let attachmentDownloadSession = URLSession.shared.dataTask(with: imageURL) { (data: Data?, _, error: Error?) in
            defer {
                completionHandler(.custom)
            }
            
            guard let data = data else {
                print (error?.localizedDescription ?? "Unknown Error")
                return
            }
            
            if let image = UIImage(data: data) {
                self.notificationImage.setHidden(false)
                
                self.notificationImage.setImage(image)
            } else {
                self.notificationImage.setHidden(true)
            }
        }
        
        attachmentDownloadSession.resume()
    }
}
