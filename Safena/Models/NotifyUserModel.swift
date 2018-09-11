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
    // UUID
    var uuid: NotifyUUIDModel
    // Is Notifying
    var isNotifying: Bool
    // Beacon Region
    lazy var beaconRegion = self.asBeaconRegion()
    
    init(accountID: String = "", name: NotifyNameModel = NotifyNameModel(), location: CLLocation = CLLocation(), uuid: NotifyUUIDModel = NotifyUUIDModel(), isNotifying: Bool = false) {
        self.accountID = accountID
        self.name = name
        self.location = location
        self.uuid = uuid
        self.isNotifying = isNotifying
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: UUID(uuidString: self.uuid.uuidString)!, major: 1, minor: 1, identifier: accountID)
    }
    
    func postAsUserOnFRD() {
        let name = [FRDKeys.FirstName: self.name.firstName, FRDKeys.LastName: self.name.lastName]
        let coordinate = [FRDKeys.Latitude: Int(self.location.coordinate.latitude), FRDKeys.Longitude: Int(self.location.coordinate.longitude)]
        let location = [FRDKeys.Coordinate: coordinate]
        let uuid = [FRDKeys.UUIDUser: self.uuid.uuidString,
                    FRDKeys.MonitoringBeacons: self.uuid.monitoringBeacons,
                    FRDKeys.RangingBeacons: self.uuid.rangingBeacons] as [String : Any]
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues(
            [FRDKeys.AccountID: accountID,
             FRDKeys.NotifyNameModel: name,
             FRDKeys.Location: location,
             FRDKeys.IsNotifying: isNotifying,
             FRDKeys.NotifyUUIDModel: uuid,
            ]
        )
    }
    
    // Public Updates
    
    func updateNearbyUsersMonitoringBeaconsWithUUID(uuid: String) {
        refUsers.observeSingleEvent(of: .value) { (snapshot) in
            for user in snapshot.children {
                let user1 = user as! DataSnapshot
                let user2 = user1.value as! [String:Any]
                let user3 = user2[FRDKeys.AccountID] as! String
                if (user3 != self.accountID) {
                    refUsers.child("\(user3)/\(FRDKeys.NotifyUUIDModel)/\(FRDKeys.MonitoringBeacons)").updateChildValues([String(uuid.hashValue):uuid])
                }
            }
        }
    }
    
    func updateMonitoringAndRangingUsers(user: NotifyUserModel) {
        updateMonitoringUsers(user: user)
        updateRangingUsers(user: user)
    }
    
    func updateMonitoringUsers(user: NotifyUserModel) {
        uuid.monitoringBeacons.updateValue(user.uuid.uuidString, forKey: user.uuid.uuidString.hashValue)
        updateSelfValue(key: FRDKeys.ToMonitoringBeacons, value: uuid.monitoringBeacons)
    }
    
    func updateRangingUsers(user: NotifyUserModel) {
        uuid.rangingBeacons.updateValue(user.uuid.uuidString, forKey: user.uuid.uuidString.hashValue)
        updateSelfValue(key: FRDKeys.ToRangingBeacons, value: uuid.rangingBeacons)
    }
    
    func updateIsNotifying(isNotifying: Bool) {
        self.isNotifying = isNotifying
        updateSelfValue(key: FRDKeys.IsNotifying, value: isNotifying as Bool)
    }
    
    func updateLocationCoordinate(coordinate: CLLocationCoordinate2D) {
        let coordinatePost = [FRDKeys.Latitude: coordinate.latitude,
                              FRDKeys.Longitude: coordinate.longitude]
        updateSelfValue(key: FRDKeys.ToCoordinate, value: coordinatePost)
    }
    
    func renewUUID() {
        updateUUID(uuid: UUID().uuidString)
    }
    
    func updateUUID(uuid: String) {
        self.uuid.uuidString = uuid
        updateSelfValue(key: FRDKeys.ToUUIDUser, value: self.uuid.uuidString)
    }
    
//    func updateVictimUUID(userList: [NotifyUserModel], victimUUIDString: String) {
//        userList.forEach { (user) in
//            updateValue(accountID: user.accountID, key: FRDKeys.ToUUIDVictim, value: victimUUIDString)
//        }
//    }
//
//    func updatePreviousVictimUUID(previousUUID: String) {
//        self.uuid.uuidPreviousVictimString = previousUUID
//        updateSelfValue(key: FRDKeys.ToUUIDPreviousVictim, value: self.uuid.uuidPreviousVictimString)
//    }
    
    // Private Updates
    
    private func updateSelfValue(key: String, value: Any) {
        updateValue(accountID: self.accountID, key: key, value: value)
    }
    
    private func updateValue(accountID: String, key: String, value: Any) {
        ref.child(FRDKeys.Users).child(accountID).updateChildValues([key : value])
    }
    
    // Equitable
    
    static func ==(user1: NotifyUserModel, user2: NotifyUserModel) -> Bool {
        return (user1.accountID == user2.accountID)
    }
    
    static func !=(user1: NotifyUserModel, user2: NotifyUserModel) -> Bool {
        return !(user1 == user2)
    }
    
}
