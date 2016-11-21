//
//  Structs.swift
//  PermissionScope
//
//  Created by Nick O'Neill on 8/21/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

struct PermissionTypeDetails: CustomStringConvertible {
    var description: String
    var prettyDescription: String
    var status: PermissionStatus
    var isALocationType: Bool

    init(description: String = "", prettyDescription: String? = nil, isALocationType: Bool = false, status: PermissionStatus = .unknown) {
        self.description = description
        self.prettyDescription = prettyDescription == nil ? description : prettyDescription!
        self.isALocationType = isALocationType
        self.status = status
    }
}

/// Permissions currently supportes by PermissionScope
@objc public enum PermissionType: Int {
    #if PermissionScopeRequestContactsEnabled
    case contacts
    #endif
    #if PermissionScopeRequestLocationEnabled
    case locationAlways
    case locationInUse
    #endif
    #if PermissionScopeRequestNotificationsEnabled
    case notifications
    #endif
    #if PermissionScopeRequestMicrophoneEnabled
    case microphone
    #endif
    #if PermissionScopeRequestCameraEnabled
    case camera
    #endif
    #if PermissionScopeRequestPhotoLibraryEnabled
    case photos
    #endif
    #if PermissionScopeRequestRemindersEnabled
    case reminders
    #endif
    #if PermissionScopeRequestEventsEnabled
    case events
    #endif
    #if PermissionScopeRequestBluetoothEnabled
    case bluetooth
    #endif
    #if PermissionScopeRequestMotionEnabled
    case motion
    #endif

    var details: PermissionTypeDetails {
        #if PermissionScopeRequestContactsEnabled
            if self == .contacts {
                return PermissionTypeDetails(description: "Contacts", status: PermissionScope().statusContacts())
            }
        #endif
        #if PermissionScopeRequestLocationEnabled
            if self == .locationAlways {
                return PermissionTypeDetails(description: "LocationAlways", prettyDescription: "Location", isALocationType: true, status: PermissionScope().statusLocationAlways())
            }else if self == .locationInUse {
                return PermissionTypeDetails(description: "LocationInUse", prettyDescription: "Location", isALocationType: true, status: PermissionScope().statusLocationInUse())
            }
        #endif
        #if PermissionScopeRequestNotificationsEnabled
            if self == .notifications {
                return PermissionTypeDetails(description: "Notifications", status: PermissionScope().statusNotifications())
            }
        #endif
        #if PermissionScopeRequestMicrophoneEnabled
            if self == .microphone {
                return PermissionTypeDetails(description: "Microphone", status: PermissionScope().statusMicrophone())
            }
        #endif
        #if PermissionScopeRequestCameraEnabled
            if self == .camera {
                return PermissionTypeDetails(description: "Camera", status: PermissionScope().statusCamera())
            }
        #endif
        #if PermissionScopeRequestPhotoLibraryEnabled
            if self == .photos {
                return PermissionTypeDetails(description: "Photos", status: PermissionScope().statusPhotos())
            }
        #endif
        #if PermissionScopeRequestRemindersEnabled
            if self == .reminders {
                return PermissionTypeDetails(description: "Reminders", status: PermissionScope().statusReminders())
            }
        #endif
        #if PermissionScopeRequestEventsEnabled
            if self == .events {
                return PermissionTypeDetails(description: "Events", status: PermissionScope().statusEvents())
            }
        #endif
        #if PermissionScopeRequestBluetoothEnabled
            if self == .bluetooth {
                return PermissionTypeDetails(description: "Bluetooth", status: PermissionScope().statusBluetooth())
            }
        #endif
        #if PermissionScopeRequestMotionEnabled
            if self == .motion {
                return PermissionTypeDetails(description: "Motion", status: PermissionScope().statusMotion())
            }
        #endif
        return PermissionTypeDetails()
    }
    
    static var allValues: [PermissionType] {
        var values = [PermissionType]()
        for permission in iterateEnum(PermissionType.self) {
            guard let permissionType = PermissionType(rawValue: permission.rawValue) else { continue }
            values.append(permissionType)
        }
        return values
    }
}

/// Possible statuses for a permission.
@objc public enum PermissionStatus: Int, CustomStringConvertible {
    case authorized, unauthorized, unknown, disabled
    
    public var description: String {
        switch self {
        case .authorized:   return "Authorized"
        case .unauthorized: return "Unauthorized"
        case .unknown:      return "Unknown"
        case .disabled:     return "Disabled" // System-level
        }
    }
}

/// Result for a permission status request.
@objc public class PermissionResult: NSObject {
    public let type: PermissionType
    public let status: PermissionStatus
    
    internal init(type:PermissionType, status:PermissionStatus) {
        self.type   = type
        self.status = status
    }
    
    override public var description: String {
        return "\(type) \(status)"
    }
}

/* Used to iterate through available PermissionType based on permissions in use.  Taken from http://stackoverflow.com/a/28341290/3880396 */
func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
