//
//  Location.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestLocationEnabled

import CoreLocation

class Location: PermissionScope {
    static let sharedInstance = Location()

    lazy var locationManager:CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()
}

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

extension PermissionScope: CLLocationManagerDelegate {
    /**
     Returns the current permission status for accessing LocationAlways.

     - returns: Permission status for the requested type.
     */

    public func statusLocationAlways() -> PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .disabled }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .authorizedWhenInUse:
            // Curious why this happens? Details on upgrading from WhenInUse to Always:
            // [Check this issue](https://github.com/nickoneill/PermissionScope/issues/24)
            if defaults.bool(forKey: Constants.NSUserDefaultsKeys.requestedInUseToAlwaysUpgrade) {
                return .unauthorized
            } else {
                return .unknown
            }
        case .notDetermined:
            return .unknown
        }
    }

    /**
     Requests access to LocationAlways, if necessary.
     */
    public func requestLocationAlways() {
        let hasAlwaysKey:Bool = !Bundle.main
            .object(forInfoDictionaryKey: Constants.InfoPlistKeys.locationAlways).isNil
        assert(hasAlwaysKey, Constants.InfoPlistKeys.locationAlways + " not found in Info.plist.")

        let status = statusLocationAlways()
        switch status {
        case .unknown:
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                defaults.set(true, forKey: Constants.NSUserDefaultsKeys.requestedInUseToAlwaysUpgrade)
                defaults.synchronize()
            }
            Location.sharedInstance.locationManager.requestAlwaysAuthorization()
        case .unauthorized:
            self.showDeniedAlert(.locationAlways)
        case .disabled:
            self.showDisabledAlert(.locationInUse)
        default:
            break
        }
    }

    /**
     Returns the current permission status for accessing LocationWhileInUse.

     - returns: Permission status for the requested type.
     */
    public func statusLocationInUse() -> PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .disabled }

        let status = CLLocationManager.authorizationStatus()
        // if you're already "always" authorized, then you don't need in use
        // but the user can still demote you! So I still use them separately.
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
     Requests access to LocationWhileInUse, if necessary.
     */
    public func requestLocationInUse() {
        let hasWhenInUseKey :Bool = !Bundle.main
            .object(forInfoDictionaryKey: Constants.InfoPlistKeys.locationWhenInUse).isNil
        assert(hasWhenInUseKey, Constants.InfoPlistKeys.locationWhenInUse + " not found in Info.plist.")

        let status = statusLocationInUse()
        switch status {
        case .unknown:
            Location.sharedInstance.locationManager.requestWhenInUseAuthorization()
        case .unauthorized:
            self.showDeniedAlert(.locationInUse)
        case .disabled:
            self.showDisabledAlert(.locationInUse)
        default:
            break
        }
    }

    // MARK: Location delegate

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        detectAndCallback()
    }
}

#endif
