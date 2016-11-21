//
//  PhotoLibrary.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestPhotoLibraryEnabled

import Photos

@objc public class PhotosPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .photos
    public var status: PermissionStatus {
        return PermissionScope().statusPhotos()
    }
    override public var description: String {
        return "Photos"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    /**
     Returns the current permission status for accessing Photos.

     - returns: Permission status for the requested type.
     */
    public func statusPhotos() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
     Requests access to Photos, if necessary.
     */
    public func requestPhotos() {
        let status = statusPhotos()
        switch status {
        case .unknown:
            PHPhotoLibrary.requestAuthorization({ status in
                self.detectAndCallback()
            })
        case .unauthorized:
            self.showDeniedAlert(.photos)
        case .disabled:
            showDisabledAlert(.photos)
        case .authorized:
            break
        }
    }
}

#endif
