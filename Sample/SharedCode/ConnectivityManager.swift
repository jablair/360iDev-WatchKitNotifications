//
//  ConnectivityManager.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/5/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import WatchConnectivity


/// Central class for managing shared WatchConnectivity communication between iOS and watchOS apps
class ConnectivityManager: NSObject {
    
    /// Errors thrown by the `ConnectivityManager`
    ///
    /// - WCSessionUnsupported: The current device does not support `WCSession`.
    enum ConnectivityError: Error {
        /// The current device does not support `WCSession`
        case WCSessionUnsupported
    }
    
    /// The app watch connectivity session
    fileprivate let session: WCSessionProtocol
    /// Queued interfactive message requests received while the seesion was inactive
    fileprivate var pendingMessages: [PendingMessage] = []
    
    /// Instance-specific behaviors for the customizing the behavior of the connectivity manager.
    var sessionBehavior: ConnectivityBehavior? = nil
    
    /// Initializes a ConnectivityManager instance with a watch communication session.
    ///
    /// - Parameter session: The watch communication session. Defaults to `WCSession.default()`.
    /// - Throws: `ConnectivityError.WCSessionUnsupported`
    init(session: WCSessionProtocol = WCSession.default()) throws {
        guard type(of: session).isSupported() else {
            throw ConnectivityError.WCSessionUnsupported
        }

        self.session = session
        
        super.init()
        
        self.session.delegate = self
        self.session.activate()
    }
    
    /// Sends an interactive message to the paired device, optionally queuing the message if the connection is inactive
    ///
    /// - Parameters:
    ///   - message: The message to send to the paired device
    ///   - queueIfNecessary: Indicates if the message should be queued if the connecting is inactive. Optional, defaults to `false`.
    ///   - replyHandler: The message reply handler, if any. Optional.
    ///   - errorHandler: The error reply handler, if any. Optional.
    func send(message: Messageable, queueIfNecessary: Bool = false, replyHandler: MessageReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.send(message: message.messageRepresentation(), queueIfNecessary: queueIfNecessary, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    /// Sends an interactive message to the paired device, optionally queuing the message if the connection is inactive
    ///
    /// - Parameters:
    ///   - message: The message to send to the paired device.
    ///   - queueIfNecessary: Indicates if the message should be queued if the connecting is inactive. Optional, defaults to `false`.
    ///   - replyHandler: The message reply handler, if any. Optional.
    ///   - errorHandler: The error reply handler, if any. Optional.
    func send(message: [String: Any], queueIfNecessary: Bool = false, replyHandler: MessageReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
        guard self.session.activationState == .activated else {
            if queueIfNecessary {
                self.pendingMessages.append(PendingMessage(message: message, messageReplyHandler: replyHandler, errorHandler: errorHandler))
            }
            
            return
        }
        
        let shouldSend = self.sessionBehavior?.shouldSend(with: self.session) ?? true
        guard self.session.isReachable, shouldSend else {
            print("Session is not in a sendable state. Dropping message.")
            return
        }
        
        self.session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }

    /// Structure for wrapping queued messages
    fileprivate struct PendingMessage {
        /// The message dictionary, for standard messages
        let message: [String: Any]?
        /// The message data, for data messages
        let data: Data?
        /// The message reply handler, if any
        let messageReplyHandler: MessageReplyHandler?
        /// The message data reply handler, if any
        let dataReplyHandler: DataReplyHandler?
        /// The message error handler, if any
        let errorHandler: ErrorHandler?
        
        /// Fully initializes a `PendingMessage` instance
        ///
        /// - Parameters:
        ///   - message: The message contents, for standard messages
        ///   - data: The data content, for data messages
        ///   - messageReplyHandler: The standard message reply handler, if any
        ///   - dataReplyHandler: The data message reply handler, if any
        ///   - errorHandler: The error handler, if any
        private init(message: [String: Any]?, data: Data?, messageReplyHandler: MessageReplyHandler? = nil, dataReplyHandler: DataReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
            self.message = message
            self.data = data
            self.messageReplyHandler = messageReplyHandler
            self.dataReplyHandler = dataReplyHandler
            self.errorHandler = errorHandler
        }
        
        /// Convenience initializer for pending standard messages
        ///
        /// - Parameters:
        ///   - message: The message content
        ///   - messageReplyHandler: The message reply handler, if any
        ///   - errorHandler: The message error handler, if any
        init(message: [String: Any], messageReplyHandler: MessageReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
            self.init(message: message, data: nil, messageReplyHandler: messageReplyHandler, errorHandler: errorHandler)
        }
        
        /// Convenience initializer for pending data messages
        ///
        /// - Parameters:
        ///   - data: The data content
        ///   - dataReplyHandler: The data message reply handler, if any
        ///   - errorHandler: The data message error handler, if any
        init(data: Data, dataReplyHandler: DataReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
            self.init(message: nil, data: data, dataReplyHandler: dataReplyHandler, errorHandler: errorHandler)
        }
    }
}

// MARK: - WCSessionDelegate Implementation
extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            self.pendingMessages.forEach {
                if let message = $0.message {
                    self.send(message: message, replyHandler: $0.messageReplyHandler, errorHandler: $0.errorHandler)
                }
            }
            
            self.pendingMessages.removeAll()
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.sessionBehavior?.didReceive(message: message, replyHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        self.sessionBehavior?.didReceive(message: message, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        self.sessionBehavior?.didReceive(messageData: messageData)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        self.sessionBehavior?.didReceive(messageData: messageData, replyHandler: replyHandler)
    }
}

/// Protocol defining the methods needed to procerss received `WCSession` messages
protocol ConnectivityBehavior {
    /// Called before `ConnectivityManager` sends a message to the paired device.
    /// Messages that should not be sent are not queued.
    ///
    /// This method assumes that the `activationState` of `session` is `actived`.
    ///
    /// - Parameter session: The WCSession used in communicating with the paired device.
    /// - Returns: `true` if the message should be sent, otherwise `false`.
    func shouldSend(with session: WCSessionProtocol) -> Bool
    
    /// Called when `ConnectivityManager` receives an immediate `WCSession` message
    ///
    /// - Parameters:
    ///   - message: The message content
    ///   - replyHandler: The reply handler, if any
    func didReceive(message: [String: Any], replyHandler: MessageReplyHandler?)
    
    /// Called when `ConnectivityManager` receives an immediate `WCSession` data message
    ///
    /// - Parameters:
    ///   - messageData: The message data
    ///   - replyHandler: The reply handler, if any
    func didReceive(messageData: Data, replyHandler: DataReplyHandler?)
}

extension ConnectivityBehavior {
    func shouldSend(with session: WCSessionProtocol) -> Bool {
        return true
    }
    
    func didReceive(message: [String: Any], replyHandler: MessageReplyHandler? = nil) {
		assertionFailure("Default Message Reply Handler for payload \(message) with replyHandler \(String(describing:replyHandler))")
    }
    
    func didReceive(messageData: Data, replyHandler: DataReplyHandler? = nil) {
        assertionFailure("Default Data Message Reply Handler with replyHandler \(String(describing:replyHandler))")
    }
}

/// Protocol defining methods needed for serializing and deserializing WCSession messages from strongly-typed sources
protocol Messageable {
    /// Initializes a `Messagable` instance from a `WCSession` message representation
    ///
    /// - Parameter messageRepresentation: The WCSession message representation
    init?(messageRepresentation: [String: Any])
    
    /// Generates a `WCSession` message representation
    ///
    /// - Returns: The `WCSession` message representation
    func messageRepresentation() -> [String: Any]
}
