//
//  Microphone.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestMicrophoneEnabled

import AVFoundation

@objc public class MicrophonePermissionDetails: NSObject, PermissionDetails {
    public let type: PermissionType = .microphone
    public var status: PermissionStatus {
        return PermissionScope().statusMicrophone()
    }
    override public var description: String {
        return "Microphone"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    /**
     Returns the current permission status for accessing the Microphone.

     - returns: Permission status for the requested type.
     */
    public func statusMicrophone() -> PermissionStatus {
        let recordPermission = AVAudioSession.sharedInstance().recordPermission()
        switch recordPermission {
        case AVAudioSessionRecordPermission.denied:
            return .unauthorized
        case AVAudioSessionRecordPermission.granted:
            return .authorized
        default:
            return .unknown
        }
    }

    /**
     Requests access to the Microphone, if necessary.
     */
    public func requestMicrophone() {
        let status = statusMicrophone()
        switch status {
        case .unknown:
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                self.detectAndCallback()
            })
        case .unauthorized:
            showDeniedAlert(.microphone)
        case .disabled:
            showDisabledAlert(.microphone)
        case .authorized:
            break
        }
    }

}

#endif
