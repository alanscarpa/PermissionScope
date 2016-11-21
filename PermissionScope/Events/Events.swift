//
//  Events.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestEventsEnabled

import EventKit

@objc public class EventsPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .events
    public var status: PermissionStatus {
        return PermissionScope().statusEvents()
    }
    override public var description: String {
        return "Events"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    /**
     Returns the current permission status for accessing Events.

     - returns: Permission status for the requested type.
     */
    public func statusEvents() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
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
     Requests access to Events, if necessary.
     */
    public func requestEvents() {
        let status = statusEvents()
        switch status {
        case .unknown:
            EKEventStore().requestAccess(to: .event,
                                         completion: { granted, error in
                                            self.detectAndCallback()
            })
        case .unauthorized:
            self.showDeniedAlert(.events)
        default:
            break
        }
    }
}

#endif
