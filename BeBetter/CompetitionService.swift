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
        
        let restApi = SFRestAPI.sharedInstance()

        var updatedCompetitions = dataStore.competitions.value
    
        for (index, competition) in updatedCompetitions.enumerated() {
            var particpants = competition.participants
            if competition.name == category.localizedName {
                var maxScore = competition.participants
                    .filter({ $0.person.name != restApi.user.fullName })
                    .map({ $0.score })
                    .sorted()
                    .last ?? 1
                maxScore = max(score, maxScore)
                for (index, participant) in competition.participants.enumerated() {
                    let updatedScore = participant.person.name == restApi.user.fullName ? score : participant.score
                    particpants[index] = CompetitionParticipant(person: participant.person, score: updatedScore, rank: CGFloat(updatedScore)/CGFloat(maxScore))
                }
                updatedCompetitions[index] = Competition(name: competition.name, participants: particpants)
            }
        }
        
        if dataStore.competitions.value != updatedCompetitions {
            dataStore.competitions.accept(updatedCompetitions)
        }
        
        // Get the current competition week number/year.
        let yearNumber = calendarService.yearNumber
        let weekOfYearNumber = calendarService.weekOfYearNumber
    
        
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
    
    @discardableResult func fetchCompetitions() -> Observable<Bool> {
        
        // Get the current competition week number/year.
        let yearNumber = calendarService.yearNumber
        let weekOfYearNumber = calendarService.weekOfYearNumber
        
        /// Get the list of supported competition fields
        let competitionFields = Competition.Category.all.map({ $0.soqlField }).joined(separator: ",")
        
        // Fetch the latest health data and friend list for the current competition.
        let soqlQuery = "SELECT \(competitionFields), User__c, User__r.Name, User__r.FullPhotoURL, id FROM Competition__c WHERE Calendar_Year__c = \(yearNumber) AND Calendar_Week__c = \(weekOfYearNumber)"

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
                        
                        if self.dataStore.competitions.value != competitions {
                            self.dataStore.competitions.accept(competitions)
                        }
                        
                        // Tell observers of the fetched friends
                        observer.onNext(true)
                    }
                    .catch { error in
                        SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                        observer.onNext(false)
                        observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchProfileImage(photoURL: URL, replyHandler: @escaping (UIImage) -> ()) {
        
        if let cachedImage = SimpleCache.shared.images[photoURL.absoluteString] {
            replyHandler(cachedImage)
            return
        }
        
        let restApi = SFRestAPI.sharedInstance()
        
        let request = SFRestRequest(method: .GET,
                                    path: photoURL.path,
                                    queryParams: nil)
        
        request.baseURL = "https://\(photoURL.host!)"
        request.endpoint = ""
        
        restApi.send(request, fail: { (error, _) in
            DispatchQueue.main.async {
                replyHandler(SFSDKResourceUtils.imageNamed("profile-placeholder"))
            }
        }) { (data, _) in
            guard let imageData = data as? Data else {
                return
            }
            DispatchQueue.main.async {
                guard let image = UIImage(data: imageData, scale: UIScreen.main.scale) else {
                    return
                }
                replyHandler(image)
                SimpleCache.shared.images[photoURL.absoluteString] = image
            }
        }
    }
    
}
