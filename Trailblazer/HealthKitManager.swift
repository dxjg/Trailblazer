//
//  HealthKitManager.swift
//  Trailblazer
//
//  Created by David Gong on 2/2/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit
import os.log
import HealthKit

class HealthKitManager {
    
    // MARK: Properties
    
    let healthKitHealthStore: HKHealthStore = HKHealthStore()
    
    // MARK: Authorization Methods
    
    // Check authorization for sharing.
    func isAuthorized() -> Bool {
        if healthKitHealthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!) == .sharingAuthorized {
            return true
        } else {
            os_log("This devie is not authorized for sharing HealthKit data.")
            return false
        }
    }
    
    // Authorizes the application to share data.
    func authorizeHealthKit(completion: ((Bool, Error?) -> Void)?) {
        // Devices that do not provide HealthKit data have nothing to authorize.
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("HealthKit is unavailable on this device.")
        }
        
        // State the health data type(s) we want to write from HealthKit.
        guard let distanceWalkingRunningIdentifier = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else {
            fatalError("Unable to obtain HealthKit identifier for distanceWalkingRunning")
        }
        
        let healthDataToWrite: Set = [distanceWalkingRunningIdentifier]
        
        // Request authorization to read and/or write the specific data.
        healthKitHealthStore.requestAuthorization(toShare: healthDataToWrite, read: nil) {
            (authorized, error) -> Void in
            if let completion = completion {
                completion(authorized, error)
            }
        }
    }
    
    // MARK: Methods
    
    // Enter a new distance into the HealthKit store.
    func saveDistance(distance: Double, date: Date) {
        // Set the quantity type to the running/walking distance.
        let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        // Set the unit of measurement to miles.
        let distanceQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: distance)
        
        // Set the official Quantity Sample.
        let distance = HKQuantitySample(type: distanceType!, quantity: distanceQuantity, start: date, end: date)
        
        // Save the distance quantity sample to the HealthKit Store.
        healthKitHealthStore.save(distance, withCompletion: {
            (success, error) -> Void in
            if error != nil {
                os_log("An error occurred attempting to save a new distance.", log: OSLog.default, type: .debug)
            }
        })
    }
}
