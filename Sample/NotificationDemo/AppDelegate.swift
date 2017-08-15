//
//  AppDelegate.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import UIKit
import UserNotifications

let CurrentModeKey = "CurrentMode"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationProcessor: NotificationProcessor!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: [CurrentModeKey: Mode.undefined.rawValue])

        self.notificationProcessor = NotificationProcessor()
        self.notificationProcessor.registerNotifications()
        UNUserNotificationCenter.current().delegate = self.notificationProcessor

        do {
            let connectivityManager = try ConnectivityManager()
            connectivityManager.sessionBehavior = PhoneSessionBehavior()
            
            if let mainViewController = self.window?.rootViewController as? ViewController {
                mainViewController.connectivityManager = connectivityManager
                mainViewController.notificationProcessor = self.notificationProcessor
            }
        } catch {
            print("Failed to configure connectivity manager - \(error)")
        }
        
        
        return true
    
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // In the real world, we'd probably push this up to a server somewhere. For now, log the device token and use something like 
        // Pusher (https://github.com/noodlewerk/NWPusher) to simulate notifications
        let tokenString = deviceToken.withUnsafeBytes { (tokenChars: UnsafePointer<CChar>) -> String in
            var tokenString = ""
            
            for i in 0..<deviceToken.count {
                tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
            }
            
            return tokenString
        }
        
        print("Device Token:", tokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error \(error)")
    }
    
}

