//
//  UserModel.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase

class NotifyUserModel {
    
    // Account ID
    var accountID: String
    // Name
    var name: NotifyNameModel
    // Location
    var location: CLLocation
    // Coordinate
    // UUID
    var uuid: NotifyUUIDModel
    // Is Notifying
    var isNotifying: Bool
    
    // Enums
    enum FRDKeys {
        static let AccountID = "Account ID"
        static let Name = "Name"
        static let FirstName = "First Name"
        static let LastName = "Last Name"
        static let Location = "Location"
        static let Coordinate = "Coordinate"
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
        static let UUID = "UUID"
        static let Users = "Users"
        static let UUIDVictim = "Victim UUID"
        static let UUIDPreviousVictim = "Previous Victim UUID"
        static let IsNotifying = "Is Notifying"
    }
    
    init(accountID: String = "", name: NotifyNameModel = NotifyNameModel(), location: CLLocation = CLLocation(), uuid: NotifyUUIDModel = NotifyUUIDModel(), isNotifying: Bool = false) {
        self.accountID = accountID
        self.name = name
        self.location = location
        self.uuid = uuid
        self.isNotifying = isNotifying
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: UUID(uuidString: self.uuid.uuidString)!, major: 1, minor: 1, identifier: name.getFullName())
    }
    
    func postAsUserOnFRD() {
        let name = [FRDKeys.FirstName: self.name.firstName, FRDKeys.LastName: self.name.lastName]
        let coordinate = [FRDKeys.Latitude: Int(self.location.coordinate.latitude), FRDKeys.Longitude: Int(self.location.coordinate.longitude)]
        let location = [FRDKeys.Coordinate: coordinate]
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues(
            [FRDKeys.AccountID: accountID,
             FRDKeys.Name: name,
             FRDKeys.Location: location,
             FRDKeys.IsNotifying: isNotifying,
             FRDKeys.UUID: uuid.uuidString,
             FRDKeys.UUIDVictim: uuid.uuidVictimString,
             FRDKeys.UUIDPreviousVictim: uuid.uuidPreviousVictimString
            ]
        )
    }
    
    // Public Updates
    
    func updateIsNotifying(isNotifying: Bool) {
        self.isNotifying = isNotifying
        updateSelfValue(key: FRDKeys.IsNotifying, value: isNotifying as Bool)
    }
    
    func updateLocationCoordinate(coordinate: CLLocationCoordinate2D) {
        let coordinatePost = [FRDKeys.Latitude: coordinate.latitude,
                              FRDKeys.Longitude: coordinate.longitude]
        updateSelfValue(key: "\(FRDKeys.Location)/\(FRDKeys.Coordinate)", value: coordinatePost)
    }
    
    func renewUUID() {
        updateUUID(uuid: UUID().uuidString)
    }
    
    func updateUUID(uuid: String) {
        self.uuid.uuidString = uuid
        updateSelfValue(key: FRDKeys.UUID, value: self.uuid.uuidString)
    }
    
    func updateVictimUUID(userList: [NotifyUserModel], victimUUIDString: String) {
        userList.forEach { (user) in
            updateValue(accountID: user.accountID, key: FRDKeys.UUIDVictim, value: victimUUIDString)
        }
    }
    
    func updatePreviousVictimUUID(previousUUID: String) {
        self.uuid.uuidPreviousVictimString = previousUUID
        updateSelfValue(key: FRDKeys.UUIDPreviousVictim, value: self.uuid.uuidPreviousVictimString)
    }
    
    // Private Updates
    
    private func updateSelfValue(key: String, value: Any) {
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues([key : value])
    }
    
    private func updateValue(accountID: String, key: String, value: Any) {
        Database.database().reference().child(FRDKeys.Users).child(accountID).updateChildValues([key : value])
    }
    
    // Equitable
    
    static func ==(user1: NotifyUserModel, user2: NotifyUserModel) -> Bool {
        return (user1.accountID == user2.accountID)
    }
    
    static func !=(user1: NotifyUserModel, user2: NotifyUserModel) -> Bool {
        return !(user1 == user2)
    }
    
}