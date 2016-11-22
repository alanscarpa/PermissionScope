//
//  Camera.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestCameraEnabled

import AVFoundation

@objc public class CameraPermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .camera
    public var status: PermissionStatus {
        return PermissionScope().statusCamera()
    }
    override public var description: String {
        return "Camera"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    
    /**
     Returns the current permission status for accessing the Camera.

     - returns: Permission status for the requested type.
     */
    public func statusCamera() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
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
     Requests access to the Camera, if necessary.
     */
    public func requestCamera() {
        let status = statusCamera()
        switch status {
        case .unknown:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { granted in
                                            self.detectAndCallback()
            })
        case .unauthorized:
            showDeniedAlert(.camera)
        case .disabled:
            showDisabledAlert(.camera)
        case .authorized:
            break
        }
    }
}

#endif

