//
//  Permissions.swift
//  PermissionScope
//
//  Created by Nick O'Neill on 8/25/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

/**
*  Protocol for permission configurations.
*/
@objc public protocol PermissionDetails {
    /// Permission type
    var type: PermissionType { get }
    var status: PermissionStatus { get }
    var description: String { get }
    var prettyDescription: String { get }
    var isALocationType: Bool { get }
    @objc optional func triggerStatusUpdate()
}

public typealias requestPermissionUnknownResult = () -> Void
public typealias requestPermissionShowAlert     = (PermissionType) -> Void
