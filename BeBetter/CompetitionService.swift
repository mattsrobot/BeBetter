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
import HealthKit

class CompetitionService {
    
    fileprivate(set) var dataStore = Datastore.shared
    fileprivate(set) var calendarService = CompetitionCalendarService()
        
    func updateHealthDataRecord(category: Competition.Category, score: Int) {
            
        // Get the current competition week number/year.
        let yearNumber = calendarService.yearNumber
        let weekOfYearNumber = calendarService.weekOfYearNumber
    
        let restApi = SFRestAPI.sharedInstance()
        
        // Safely test if user logged in.
        let user: SFUserAccount? = restApi.user
        
        if user != nil {
            // Upsert (create/update) based on the Unique_Id a new Competition entry with the health record information.
            restApi.Promises.upsert(objectType: "Competition__c",
                                    externalIdField: "Unique_Id__c",
                                    externalId: "\(restApi.user.idData!.userId)\(weekOfYearNumber)\(yearNumber)",
                                    fieldList: ["Calendar_Year__c" : yearNumber,
                                                "Calendar_Week__c" : weekOfYearNumber,
                                                category.soqlField : score,
                                                "User__c" : restApi.user.idData!.userId])
                .then { request in
                    restApi.Promises.send(request: request)
                }
                .done { response in
                    SalesforceSwiftLogger.log(type(of:self), level: .debug, message:"Succes")
                }
                .catch { error in
                    SalesforceSwiftLogger.log(type(of:self), level: .debug, message:"Error: \(error)")
            }
        }
    }
    
    func fetchCompetitions() -> Observable<[Competition]> {
        
        // Get the current competition week number/year.
        let yearNumber = calendarService.yearNumber
        let weekOfYearNumber = calendarService.weekOfYearNumber
        
        // Fetch the latest health data and friend list for the current competition.
        let soqlQuery = "SELECT Distance__c, User__c, User__r.Name, User__r.FullPhotoURL, id FROM Competition__c WHERE Calendar_Year__c = \(yearNumber) AND Calendar_Week__c = \(weekOfYearNumber)"

        // Return an observable to async report the fetched Friends from Salesforce.
        return Observable.create { observer in

            let restApi = SFRestAPI.sharedInstance()
            
            // Safely test if user logged in
            let user: SFUserAccount? = restApi.user
            
            if user != nil {
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
                        guard let records = response.asJsonDictionary()["records"] as? [[String : Any]] else {
                            return
                        }
                        
                        // Map the JSON records to a competition array
                        let competitions = Competition.extract(records)
                        
                        // Tell observers of the fetched friends
                        observer.onNext(competitions)
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
