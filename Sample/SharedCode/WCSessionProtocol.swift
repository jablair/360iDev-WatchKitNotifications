//
//  WCSessionProtocol.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchConnectivity

/// Typealias for the `WCSession` `sendMessage` reply handler
typealias MessageReplyHandler = (([String: Any]) -> Void)
/// Typealis for the `WCSession` `snedMessageData` reply handler
typealias DataReplyHandler = ((Data) -> Void)
/// Typealias for the `WCSession` error handler
typealias ErrorHandler = ((Error) -> Void)


/// Protocol describing common `WCSession` methods.
/// Extracted to allow for mocking / testing
protocol WCSessionProtocol: class {
    static func isSupported() -> Bool
    
    weak var delegate: WCSessionDelegate? { get set }
    
    func activate()
    
    var activationState: WCSessionActivationState { get }
    
    var isReachable: Bool { get}
    
    func sendMessage(_ message: [String : Any], replyHandler: MessageReplyHandler?, errorHandler: ErrorHandler?)
    func sendMessageData(_ data: Data, replyHandler: ((Data) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?)
    
    #if os(iOS)
    var isPaired: Bool { get }
    
    var isWatchAppInstalled: Bool { get }
    #endif
}

// MARK: - WCSession conformance to the WCSessionProtocol
extension WCSession: WCSessionProtocol {  }
