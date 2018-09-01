//
//  HealthMonitor.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 17/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import HealthKit

class HealthMonitor {
    
    /// The service class the health monitor uses to update Salesforce with the new data
    private(set) var competitionService = CompetitionService()
    
    /// The types of data we're interested in observing.
    fileprivate var readableTypes: Set<HKSampleType> {
        return [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!]
        
        // TODO
        
//        return [HKWorkoutType.workoutType(),
//                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
//                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
//                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
//                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
    }

    /// Sets up everything required to gather information from HealthKit.
    func activate() {
        
        // Abort early if health data is not available
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let healthStore = HKHealthStore()
        
        // Request authorization from user (shows apple popup to turn on HK categories)
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { [weak self] success , _ in
            
            guard success, let `self` = self else {
                return
            }
            
            // Setup HK observers to monitor changes
            self.observe(healthStore)
            
            // Enable background delivery of data (requires background mode support)
            self.enableBackgroundDelivery(healthStore)
        }
    }
    
    /// Observes the HealthStore for changes in the types we're interested in, e.g, step count, running distance
    ///
    /// - Parameter healthStore: the healthstore from HealthKit
    fileprivate func observe(_ healthStore: HKHealthStore) {
        
        // The earliest date HealthKit allows samples to be recorded from.
        let earliestPermittedSampleDate = healthStore.earliestPermittedSampleDate()
        
        // The beginning of the calendar week, or the permitted date from healthKit (if HealthKit is later, choose this).
        let startDate = earliestPermittedSampleDate > competitionService.firstDayOfWeekDate ? earliestPermittedSampleDate : competitionService.firstDayOfWeekDate
        
        // The query predicate to only use samples for this date range.
        let sampleDataPredicate = HKQuery.predicateForSamples(withStart: startDate,
                                                              end: Date(),
                                                              options: [])
        
        // Enumerate each type, and setup an anchoredObjectQuery, which enables delivery of sample updates for each type.
        for type in readableTypes {
            
            var anchor: HKQueryAnchor? = nil
            
            // Create the query.
            let query = HKAnchoredObjectQuery(type: type,
                                              predicate: sampleDataPredicate,
                                              anchor: anchor,
                                              limit: HKObjectQueryNoLimit)
            { (query, samplesOrNil, _, newAnchor, _) in
                
                guard let samples = samplesOrNil else {
                    return
                }
                
                anchor = newAnchor
                
                if let quantitySamples = samples as? [HKQuantitySample] {
                    let totalDistance = quantitySamples.map({$0.quantity.doubleValue(for: HKUnit.meter())}).reduce(1, +)
                    self.competitionService.updateHealthDataRecord(distanceInMeters: Int(totalDistance))
                }
            }
            
            query.updateHandler = { (query, samplesOrNil, _, newAnchor, _) in
                
                guard let samples = samplesOrNil else {
                    return
                }
                
                anchor = newAnchor
                
                if let quantitySamples = samples as? [HKQuantitySample] {
                    let totalDistance = quantitySamples.map({$0.quantity.doubleValue(for: HKUnit.meter())}).reduce(1, +)
                    self.competitionService.updateHealthDataRecord(distanceInMeters: Int(totalDistance))
                }
            }
            
            // Run the query.
            healthStore.execute(query)
        }
    }
    
    /// Enables background updates for the types we're interested, iOS will wake app up when possible, and this triggers our object queries later.
    ///
    /// - Parameter healthStore: the healthstore from HealthKit
    fileprivate func enableBackgroundDelivery(_ healthStore: HKHealthStore) {
        for type in readableTypes {
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: { (success, _) in
                debugPrint("enabled background delivery \(success) for \(type)")
            })
        }
    }

}
