//
//  CompetitionService.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 16/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

class CompetitionService {

    func fetchFriends() -> Observable<[Person]> {
        return Observable.create { observer in
            
            let restApi = SFRestAPI.sharedInstance()
            restApi.Promises
                .query(soql: "SELECT Distance__c, User__c, User__r.Name, id FROM Competition__c WHERE Calendar_Year__c = 2018 AND Calendar_Week__c = 32")
                .then {  request  in
                    restApi.Promises.send(request: request)
                }
                .done { response in
                    defer {
                        observer.on(.completed)
                    }
                    guard let dataRows = response.asJsonDictionary()["records"] as? [[String : Any]] else {
                        return
                    }
                    
                    let friends:[Person] = dataRows.map { row in
                        let user = row["User__r"] as? [String : Any]
                        let name = user?["Name"] as? String ?? ""
                        let distance = row["Distance__c"] as? Int ?? 0
                        return Person(name: name, distance: distance)
                    }
                    
                    observer.onNext(friends)
                }
                .catch { error in
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                    observer.onError(error)
                }
            
            return Disposables.create()
        }
    }
    
}
