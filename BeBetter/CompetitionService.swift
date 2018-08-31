//
//  CompetitionService.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 16/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

class CompetitionService {
    
    /// The calendar we use for the competition data.
    var calendar: Calendar {
        return Calendar(identifier: .iso8601)
    }
    
    /// The current week number for the competition data to use.
    var yearNumber: Int {
        return calendar.component(.year, from: Date())
    }
    
    /// The current year number for the competition data to use.
    var weekOfYearNumber: Int {
        return calendar.component(.weekOfYear, from: Date())
    }
    
    /// The first day of the calendar week date.
    var firstDayOfWeekDate: Date {
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                           from: Date()))!
    }
    
    func updateHealthDataRecord(distanceInMeters: Int) {
    
        // Get the current competition week number/year.
        let yearNumber = self.yearNumber
        let weekOfYearNumber = self.weekOfYearNumber
    
        let restApi = SFRestAPI.sharedInstance()
    
        // Safely test if user logged in.
        if restApi.user != nil {
            // Upsert (create/update) based on the Unique_Id a new Competition entry with the health record information.
            restApi.Promises.upsert(objectType: "Competition__c",
                                    externalIdField: "Unique_Id__c",
                                    externalId: "\(restApi.user.idData!.userId)+\(weekOfYearNumber)+\(yearNumber)",
                                    fieldList: ["Calendar_Year__c" : yearNumber,
                                                "Calendar_Week__c" : weekOfYearNumber,
                                                "Distance__c" : distanceInMeters,
                                                "User__c" : restApi.user.idData!.userId])
                .then { request in
                    restApi.Promises.send(request: request)
                }
                .done { response in
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Succes")
                }
                .catch { error in
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
            }
        }
    }
    
    func fetchFriends() -> Observable<[Person]> {
        
        // Get the current competition week number/year.
        let yearNumber = self.yearNumber
        let weekOfYearNumber = self.weekOfYearNumber
        
        // Fetch the latest health data and friend list for the current competition.
        let soqlQuery = "SELECT Distance__c, User__c, User__r.Name, id FROM Competition__c WHERE Calendar_Year__c = \(yearNumber) AND Calendar_Week__c = \(weekOfYearNumber)"

        // Return an observable to async report the fetched Friends from Salesforce.
        return Observable.create { observer in

            let restApi = SFRestAPI.sharedInstance()
            
            // Safely test if user logged in
            if restApi.user != nil {
                restApi.Promises
                    .query(soql: soqlQuery)
                    .then { request  in
                        restApi.Promises.send(request: request)
                    }
                    .done { response in
                        
                        // Tell subscribers (when we've finished) the data has finished loading.
                        defer {
                            observer.on(.completed)
                        }
                        
                        // Get the response JSON
                        guard let dataRows = response.asJsonDictionary()["records"] as? [[String : Any]] else {
                            return
                        }
                        
                        // Map the JSON to a Person object
                        let friends:[Person] = dataRows.map { row in
                            let user = row["User__r"] as? [String : Any]
                            let name = user?["Name"] as? String ?? ""
                            let distance = row["Distance__c"] as? Int ?? 0
                            return Person(name: name, distance: distance)
                        }
                        
                        // Tell observers of the fetched friends
                        observer.onNext(friends)
                    }
                    .catch { error in
                        SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                        observer.onError(error)
                        observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
}
