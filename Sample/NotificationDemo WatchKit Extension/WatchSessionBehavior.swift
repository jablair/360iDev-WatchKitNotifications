//
//  WatchSessionBehavior.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/9/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchKit

/// Implements Connectivity Manager behaviors for Watch extension
class WatchSessionBehavior: ConnectivityBehavior {
    func didReceive(message: [String: Any], replyHandler: MessageReplyHandler?) {
        if let receivedMode = Mode(messageRepresentation: message) {
            guard let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController else { return }
            UserDefaults.standard.set(receivedMode.rawValue, forKey:CurrentModeKey)
            
            DispatchQueue.main.async {
                
                interfaceController.mode = receivedMode
            }
        }
    }
}
