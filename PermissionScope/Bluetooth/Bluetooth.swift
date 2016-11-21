//
//  Bluetooth.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/21/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//


#if PermissionScopeRequestBluetoothEnabled

import CoreBluetooth

class Bluetooth: PermissionScope {
    static let sharedInstance = Bluetooth()

    lazy var bluetoothManager:CBPeripheralManager = {
        return CBPeripheralManager(delegate: self, queue: nil, options:[CBPeripheralManagerOptionShowPowerAlertKey: false])
    }()
}

@objc public class BluetoothPermission: NSObject, Permission {
    public let type: PermissionType = .bluetooth
    public var status: PermissionStatus {
        return PermissionScope().statusBluetooth()
    }
    @objc public func triggerStatusUpdate() {
        if PermissionScope().askedBluetooth {
            PermissionScope().triggerBluetoothStatusUpdate()
        }
    }
}

extension PermissionScope: CBPeripheralManagerDelegate {

    /**
     Start and immediately stop bluetooth advertising to trigger
     its permission dialog.
     */
    internal func triggerBluetoothStatusUpdate() {
        if !waitingForBluetooth && Bluetooth.sharedInstance.bluetoothManager.state == .unknown {
            Bluetooth.sharedInstance.bluetoothManager.startAdvertising(nil)
            Bluetooth.sharedInstance.bluetoothManager.stopAdvertising()
            askedBluetooth = true
            waitingForBluetooth = true
        }
    }

    // MARK: Bluetooth delegate

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        waitingForBluetooth = false
        detectAndCallback()
    }

    /// Returns whether Bluetooth access was asked before or not.
    internal var askedBluetooth:Bool {
        get {
            return defaults.bool(forKey: Constants.NSUserDefaultsKeys.requestedBluetooth)
        }
        set {
            defaults.set(newValue, forKey: Constants.NSUserDefaultsKeys.requestedBluetooth)
            defaults.synchronize()
        }
    }

    /**
     Returns the current permission status for accessing Bluetooth.

     - returns: Permission status for the requested type.
     */
    public func statusBluetooth() -> PermissionStatus {
        // if already asked for bluetooth before, do a request to get status, else wait for user to request
        if askedBluetooth{
            triggerBluetoothStatusUpdate()
        } else {
            return .unknown
        }

        let state = (Bluetooth.sharedInstance.bluetoothManager.state, CBPeripheralManager.authorizationStatus())
        switch state {
        case (.unsupported, _), (.poweredOff, _), (_, .restricted):
            return .disabled
        case (.unauthorized, _), (_, .denied):
            return .unauthorized
        case (.poweredOn, .authorized):
            return .authorized
        default:
            return .unknown
        }

    }

    /**
     Requests access to Bluetooth, if necessary.
     */
    public func requestBluetooth() {
        let status = statusBluetooth()
        switch status {
        case .disabled:
            showDisabledAlert(.bluetooth)
        case .unauthorized:
            showDeniedAlert(.bluetooth)
        case .unknown:
            triggerBluetoothStatusUpdate()
        default:
            break
        }
        
    }
}

#endif
