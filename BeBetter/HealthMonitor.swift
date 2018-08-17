//
//  HealthMonitor.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 17/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import HealthKit

class HealthMonitor {

    func activate() {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let healthStore = HKHealthStore()
        
        let readableTypes: Set<HKSampleType> = [HKWorkoutType.workoutType(),
                                                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                                                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                                                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success , _ in
            guard success else {
                return
            }
            for type in readableTypes {
                healthStore.enableBackgroundDelivery(for: type, frequency: .hourly, withCompletion: { (success, _) in
                    print("enabled background delivery \(success)")
                })
            }
        }
    }
    
    func observe() {
        
    }

}
