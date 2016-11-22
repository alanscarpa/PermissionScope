//
//  Notifications.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestNotificationsEnabled

@objc public class NotificationsPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .notifications
    public var status: PermissionStatus {
        return PermissionScope().statusNotifications()
    }
    override public var description: String {
        return "Notifications"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
    public let notificationCategories: Set<UIUserNotificationCategory>?

    public init(notificationCategories: Set<UIUserNotificationCategory>? = nil) {
        self.notificationCategories = notificationCategories
    }
}

extension PermissionScope {
    
    /**
     Returns the current permission status for accessing Notifications.

     - returns: Permission status for the requested type.
     */

    public func statusNotifications() -> PermissionStatus {
        let settings = UIApplication.shared.currentUserNotificationSettings
        if let settingTypes = settings?.types , settingTypes != UIUserNotificationType() {
            return .authorized
        } else {
            if defaults.bool(forKey: Constants.NSUserDefaultsKeys.requestedNotifications) {
                return .unauthorized
            } else {
                return .unknown
            }
        }
    }

    /**
     To simulate the denied status for a notifications permission,
     we track when the permission has been asked for and then detect
     when the app becomes active again. If the permission is not granted
     immediately after becoming active, the user has cancelled or denied
     the request.

     This function is called when we want to show the notifications
     alert, kicking off the entire process.
     */
    func showingNotificationPermission() {
        let notifCenter = NotificationCenter.default

        notifCenter
            .removeObserver(self,
                            name: NSNotification.Name.UIApplicationWillResignActive,
                            object: nil)
        notifCenter
            .addObserver(self,
                         selector: #selector(finishedShowingNotificationPermission),
                         name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        notificationTimer?.invalidate()
    }

    /**
     This function is triggered when the app becomes 'active' again after
     showing the notification permission dialog.

     See `showingNotificationPermission` for a more detailed description
     of the entire process.
     */
    func finishedShowingNotificationPermission () {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationWillResignActive,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                  object: nil)

        notificationTimer?.invalidate()

        defaults.set(true, forKey: Constants.NSUserDefaultsKeys.requestedNotifications)
        defaults.synchronize()

        // callback after a short delay, otherwise notifications don't report proper auth
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(100),
            execute: {
                self.getResultsForConfig { results in
                    guard let notificationResult = results.first(where: { $0.type == .notifications })
                        else { return }
                    if notificationResult.status == .unknown {
                        self.showDeniedAlert(notificationResult.type)
                    } else {
                        self.detectAndCallback()
                    }
                }
        })
    }

    /**
     Requests access to User Notifications, if necessary.
     */
    public func requestNotifications() {
        let status = statusNotifications()
        switch status {
        case .unknown:
            let notificationsPermission = self.configuredPermissions
                .first { $0 is NotificationsPermissionDetails } as? NotificationsPermissionDetails
            let notificationsPermissionSet = notificationsPermission?.notificationCategories

            NotificationCenter.default.addObserver(self, selector: #selector(showingNotificationPermission), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)

            notificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(finishedShowingNotificationPermission), userInfo: nil, repeats: false)

            UIApplication.shared.registerUserNotificationSettings(
                UIUserNotificationSettings(types: [.alert, .sound, .badge],
                                           categories: notificationsPermissionSet)
            )
        case .unauthorized:
            showDeniedAlert(.notifications)
        case .disabled:
            showDisabledAlert(.notifications)
        case .authorized:
            detectAndCallback()
        }
    }
}

#endif
