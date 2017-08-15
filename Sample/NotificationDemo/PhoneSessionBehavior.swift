//
//  PhoneSessionBehavior.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/6/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import Foundation
import UserNotifications

/// Implements Connectivity Manager behaviors for iPhone application
class PhoneSessionBehavior: ConnectivityBehavior {
    func shouldSend(with session: WCSessionProtocol) -> Bool {
        return session.isPaired && session.isWatchAppInstalled
    }
    
    func didReceive(message: [String: Any], replyHandler: MessageReplyHandler? = nil) {
        guard     
            let rawCommand = message[CommandTypeKey] as? String,
            let command = CommandKey(rawValue: rawCommand) else {
            assertionFailure("Non-Command payload received \(message)")
            return
        }
        
        switch command {
        case .requestMode:
            let currentMode: Mode
            
            if let storedModeString = UserDefaults.standard.string(forKey: CurrentModeKey),
                let storedMode = Mode(rawValue: storedModeString) {
                currentMode = storedMode
            } else {
                currentMode = .undefined
            }
            
            replyHandler?(currentMode.messageRepresentation())
        case .clearNotification:
            guard let clearNotification = ClearNotificationCommand(messageRepresentation: message) else { return }

            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [clearNotification.identifier])
//        default:
//            assertionFailure("Unsupported message command \(command)")
//            break
        }
    }
}
