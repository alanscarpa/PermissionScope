//
//  Permissions.swift
//  PermissionScope
//
//  Created by Nick O'Neill on 8/25/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

/**
*  Protocol for permission configurations.
*/
@objc public protocol Permission {
    /// Permission type
    var type: PermissionType { get }
    var status: PermissionStatus { get }
}

#if PermissionScopeRequestNotificationsEnabled
@objc public class NotificationsPermission: NSObject, Permission {
    public let type: PermissionType = .notifications
    public var status: PermissionStatus {
        return PermissionScope().statusNotifications()
    }
    public let notificationCategories: Set<UIUserNotificationCategory>?
    
    public init(notificationCategories: Set<UIUserNotificationCategory>? = nil) {
        self.notificationCategories = notificationCategories
    }
}
#endif

#if PermissionScopeRequestLocationEnabled
@objc public class LocationWhileInUsePermission: NSObject, Permission {
    public let type: PermissionType = .locationInUse
    public var status: PermissionStatus {
        return PermissionScope().statusLocationInUse()
    }
}

@objc public class LocationAlwaysPermission: NSObject, Permission {
    public let type: PermissionType = .locationAlways
    public var status: PermissionStatus {
        return PermissionScope().statusLocationAlways()
    }
}
#endif

public typealias requestPermissionUnknownResult = () -> Void
public typealias requestPermissionShowAlert     = (PermissionType) -> Void

#if PermissionScopeRequestEventsEnabled
@objc public class EventsPermission: NSObject, Permission {
    public let type: PermissionType = .events
    public var status: PermissionStatus {
        return PermissionScope().statusEvents()
    }
}
#endif

#if PermissionScopeRequestMicrophoneEnabled
@objc public class MicrophonePermission: NSObject, Permission {
    public let type: PermissionType = .microphone
    public var status: PermissionStatus {
        return PermissionScope().statusMicrophone()
    }
}
#endif

#if PermissionScopeRequestCameraEnabled
@objc public class CameraPermission: NSObject, Permission {
    public let type: PermissionType = .camera
    public var status: PermissionStatus {
        return PermissionScope().statusCamera()
    }
}
#endif

#if PermissionScopeRequestPhotoLibraryEnabled
@objc public class PhotosPermission: NSObject, Permission {
    public let type: PermissionType = .photos
    public var status: PermissionStatus {
        return PermissionScope().statusPhotos()
    }
}
#endif

#if PermissionScopeRequestRemindersEnabled
@objc public class RemindersPermission: NSObject, Permission {
    public let type: PermissionType = .reminders
    public var status: PermissionStatus {
        return PermissionScope().statusReminders()
    }
}
#endif

#if PermissionScopeRequestBluetoothEnabled
@objc public class BluetoothPermission: NSObject, Permission {
    public let type: PermissionType = .bluetooth
    public var status: PermissionStatus {
        return PermissionScope().statusBluetooth()
    }
}
#endif

#if PermissionScopeRequestMotionEnabled
@objc public class MotionPermission: NSObject, Permission {
    public let type: PermissionType = .motion
    public var status: PermissionStatus {
        return PermissionScope().statusMotion()
    }
}
#endif
