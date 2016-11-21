//
//  Motion.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestMotionEnabled

import CoreMotion

class Motion: PermissionScope {
    lazy var motionManager:CMMotionActivityManager = {
        return CMMotionActivityManager()
    }()
}

@objc public class MotionPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .motion
    public var status: PermissionStatus {
        return PermissionScope().statusMotion()
    }
    override public var description: String {
        return "Motion"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
    @objc public func triggerStatusUpdate() {
        if PermissionScope().askedMotion {
            PermissionScope().triggerMotionStatusUpdate()
        }
    }
}

extension PermissionScope {

    /**
     Returns the current permission status for accessing Core Motion Activity.

     - returns: Permission status for the requested type.
     */
    public func statusMotion() -> PermissionStatus {
        if askedMotion {
            triggerMotionStatusUpdate()
        }
        return motionPermissionStatus
    }

    /**
     Requests access to Core Motion Activity, if necessary.
     */
    public func requestMotion() {
        let status = statusMotion()
        switch status {
        case .unauthorized:
            showDeniedAlert(.motion)
        case .unknown:
            triggerMotionStatusUpdate()
        default:
            break
        }
    }

    /**
     Prompts motionManager to request a status update. If permission is not already granted the user will be prompted with the system's permission dialog.
     */
    fileprivate func triggerMotionStatusUpdate() {
        let tmpMotionPermissionStatus = motionPermissionStatus
        defaults.set(true, forKey: Constants.NSUserDefaultsKeys.requestedMotion)
        defaults.synchronize()

        let today = Date()
        Motion().motionManager.queryActivityStarting(from: today,
                                            to: today,
                                            to: .main) { activities, error in
                                                if let error = error , error._code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                                                    self.motionPermissionStatus = .unauthorized
                                                } else {
                                                    self.motionPermissionStatus = .authorized
                                                }

                                                Motion().motionManager.stopActivityUpdates()
                                                if tmpMotionPermissionStatus != self.motionPermissionStatus {
                                                    self.waitingForMotion = false
                                                    self.detectAndCallback()
                                                }
        }

        askedMotion = true
        waitingForMotion = true
    }
    
    /// Returns whether Bluetooth access was asked before or not.
    fileprivate var askedMotion:Bool {
        get {
            return defaults.bool(forKey: Constants.NSUserDefaultsKeys.requestedMotion)
        }
        set {
            defaults.set(newValue, forKey: Constants.NSUserDefaultsKeys.requestedMotion)
            defaults.synchronize()
        }
    }
}

#endif
