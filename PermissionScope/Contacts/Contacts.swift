//
//  Contacts.swift
//  PermissionScope
//
//  Created by Alan Scarpa on 11/18/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

#if PermissionScopeRequestContactsEnabled

import AddressBook
import Contacts

@objc public class ContactsPermissionDetails: NSObject, PermissionDetails {
    public var type: PermissionType = .contacts
    public var status: PermissionStatus = PermissionScope().statusContacts()
    override public var description: String {
        return "Contacts"
    }
    public var prettyDescription: String {
        return description
    }
    public var isALocationType = false
}

extension PermissionScope {
    
    /**
     Returns the current permission status for accessing Contacts.

     - returns: Permission status for the requested type.
     */
    public func statusContacts() -> PermissionStatus {
        if #available(iOS 9.0, *) {
            let status = CNContactStore.authorizationStatus(for: .contacts)
            switch status {
            case .authorized:
                return .authorized
            case .restricted, .denied:
                return .unauthorized
            case .notDetermined:
                return .unknown
            }
        } else {
            // Fallback on earlier versions
            let status = ABAddressBookGetAuthorizationStatus()
            switch status {
            case .authorized:
                return .authorized
            case .restricted, .denied:
                return .unauthorized
            case .notDetermined:
                return .unknown
            }
        }
    }

    /**
     Requests access to Contacts, if necessary.
     */
    public func requestContacts() {
        let status = statusContacts()
        switch status {
        case .unknown:
            if #available(iOS 9.0, *) {
                CNContactStore().requestAccess(for: .contacts, completionHandler: {
                    success, error in
                    self.detectAndCallback()
                })
            } else {
                ABAddressBookRequestAccessWithCompletion(nil) { success, error in
                    self.detectAndCallback()
                }
            }
        case .unauthorized:
            self.showDeniedAlert(.contacts)
        default:
            break
        }
    }
}

#endif
