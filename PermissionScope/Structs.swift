//
//  Structs.swift
//  PermissionScope
//
//  Created by Nick O'Neill on 8/21/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

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

    var details: PermissionDetails? {
        #if PermissionScopeRequestContactsEnabled
            if self == .contacts {
                return ContactsPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestLocationEnabled
            if self == .locationAlways {
                return LocationAlwaysPermissionDetails()
            } else if self == .locationInUse {
                return LocationWhileInUsePermissionDetails()
            }
        #endif
        #if PermissionScopeRequestNotificationsEnabled
            if self == .notifications {
                return NotificationsPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestMicrophoneEnabled
            if self == .microphone {
                return MicrophonePermissionDetails()
            }
        #endif
        #if PermissionScopeRequestCameraEnabled
            if self == .camera {
                return CameraPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestPhotoLibraryEnabled
            if self == .photos {
                return PhotosPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestRemindersEnabled
            if self == .reminders {
                return RemindersPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestEventsEnabled
            if self == .events {
                return EventsPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestBluetoothEnabled
            if self == .bluetooth {
                return BluetoothPermissionDetails()
            }
        #endif
        #if PermissionScopeRequestMotionEnabled
            if self == .motion {
                return MotionPermissionDetails()
            }
        #endif
        return nil
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
