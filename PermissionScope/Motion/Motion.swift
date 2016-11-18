//
//  Motion.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/18/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

import Foundation
import CoreMotion

extension PermissionScope {
    // MARK: Core Motion Activity

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
    func triggerMotionStatusUpdate() {
        let tmpMotionPermissionStatus = motionPermissionStatus
        defaults.set(true, forKey: Constants.NSUserDefaultsKeys.requestedMotion)
        defaults.synchronize()

        let today = Date()
        motionManager.queryActivityStarting(from: today,
                                            to: today,
                                            to: .main) { activities, error in
                                                if let error = error , error._code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                                                    self.motionPermissionStatus = .unauthorized
                                                } else {
                                                    self.motionPermissionStatus = .authorized
                                                }

                                                self.motionManager.stopActivityUpdates()
                                                if tmpMotionPermissionStatus != self.motionPermissionStatus {
                                                    self.waitingForMotion = false
                                                    self.detectAndCallback()
                                                }
        }

        askedMotion = true
        waitingForMotion = true
    }

    /// Returns whether Bluetooth access was asked before or not.
    var askedMotion:Bool {
        get {
            return defaults.bool(forKey: Constants.NSUserDefaultsKeys.requestedMotion)
        }
        set {
            defaults.set(newValue, forKey: Constants.NSUserDefaultsKeys.requestedMotion)
            defaults.synchronize()
        }
    }
}
