//
//  Reminders.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestRemindersEnabled

import EventKit

@objc public class RemindersPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .reminders
    public var status: PermissionStatus {
        return PermissionScope().statusReminders()
    }
    override public var description: String {
        return "Reminders"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    /**
     Returns the current permission status for accessing Reminders.

     - returns: Permission status for the requested type.
     */
    public func statusReminders() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
     Requests access to Reminders, if necessary.
     */
    public func requestReminders() {
        let status = statusReminders()
        switch status {
        case .unknown:
            EKEventStore().requestAccess(to: .reminder,
                                         completion: { granted, error in
                                            self.detectAndCallback()
            })
        case .unauthorized:
            self.showDeniedAlert(.reminders)
        default:
            break
        }
    }
}

#endif
