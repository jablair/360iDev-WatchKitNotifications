//
//  ExtensionDelegate.swift
//  NotificationDemo WatchKit Extension
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchKit
import UserNotifications

let CurrentModeKey = "CurrentMode"

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private(set) var connectivityManager: ConnectivityManager?
    private(set) var notificationProcessor: NotificationProcessor!

    func applicationDidFinishLaunching() {
        UserDefaults.standard.register(defaults: [CurrentModeKey: Mode.undefined.rawValue])
        
        self.connectivityManager = try? ConnectivityManager()
        self.connectivityManager?.sessionBehavior = WatchSessionBehavior()

        self.notificationProcessor = NotificationProcessor(connectivityManager: self.connectivityManager)
        self.notificationProcessor.registerNotifications()
        UNUserNotificationCenter.current().delegate = self.notificationProcessor

        
        
    }

    func applicationDidBecomeActive() {
        let replyHandler = { (response: [String: Any]) -> Void in
            print ("Received Mode Response")
            guard let receivedMode = Mode(messageRepresentation: response) else { return }
            UserDefaults.standard.set(receivedMode.rawValue, forKey:CurrentModeKey)
            
            DispatchQueue.main.async {
                guard let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController else { return }
                
                interfaceController.mode = receivedMode
            }
        }
        
        connectivityManager?.send(message: CommandMessage(command: .requestMode), queueIfNecessary: true, replyHandler: replyHandler) { (error: Error) in
            print ("Mode Request error \(error)")
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
}
