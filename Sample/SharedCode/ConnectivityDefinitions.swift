//
//  ConnectivityDefinitions.swift
//  NotificationDemo
//
//  Created by Eric Blair on 1/6/17.
//  Copyright © 2017 Martiancraft. All rights reserved.
//

import Foundation

/// Enum describing the supported modes handled by the application
///
/// - undefined: Mode not configured
/// - primary: Configured as primary device
/// - secondary: Configured as secondary device
enum Mode: String, Messageable {
    /// Mode not configured
    case undefined
    /// Configured as primary device
    case primary
    /// Configured as secondary device
    case secondary

    /// Mode key in the message
    private static let ModeKey = "mode"
    
    init?(messageRepresentation: [String: Any]) {
        guard
            let rawRepresentationMode = messageRepresentation[Mode.ModeKey] as? String,
            let representationMode = Mode(rawValue: rawRepresentationMode)
            else {
                return nil
        }
        self = representationMode
    }
    
    func messageRepresentation() -> [String: Any] {
        return [Mode.ModeKey: self.rawValue]
    }
}

/// Protocol that describes Command messages
protocol Commandable: Messageable {
    
    /// The command type
    var command: CommandKey { get }
    
}

/// Command key in a `Commandable` `messageRepresentation` dictionary
let CommandTypeKey = "Command"

/// Generic command message with no payload
struct CommandMessage: Commandable {
    let command: CommandKey
    
    /// Initializes a generic command message
    ///
    /// - Parameter command: The command type
    init(command: CommandKey) {
        self.command = command
    }
    
    init?(messageRepresentation: [String : Any]) {
        guard
            let rawCommand = messageRepresentation[CommandTypeKey] as? String,
            let command = CommandKey(rawValue: rawCommand)
            else {
                return nil
        }
        
        self.init(command: command)
    }
    
    func messageRepresentation() -> [String : Any] {
        return [CommandTypeKey: self.command.rawValue]
    }
}

/// Command message for clearing a notificaiton 
struct ClearNotificationCommand: Commandable {
    /// Identifier key in the message
    private static let identifierKey = "IdentifierKey"
    
    let command: CommandKey = .clearNotification
    
    /// Notification request identifier
    let identifier: String
    
    /// Initialize a clear notification command for the specific notification request identifier
    ///
    /// - Parameter identifier: The notification request identifier to clear
    init(identifier: String) {
        self.identifier = identifier
    }
    
    init?(messageRepresentation: [String: Any]) {
        guard
            let rawCommand = messageRepresentation[CommandTypeKey] as? String,
            CommandKey(rawValue: rawCommand) == self.command,
            let identifier = messageRepresentation[ClearNotificationCommand.identifierKey] as? String
            else {
                return nil
        }
        
        self.identifier = identifier
    }
    
    func messageRepresentation() -> [String : Any] {
        return [CommandTypeKey: self.command.rawValue, ClearNotificationCommand.identifierKey: self.identifier]
    }
}

/// Types of commands supported via WCSession communication
///
/// - requestMode: Request mode from iOS app command
/// - clearNotification: Remove given notification from receiver's notification center
enum CommandKey: String {
    /// Request mode from iOS app command
    case requestMode
    /// Remove given notification from receiver's notification center
    case clearNotification
}
