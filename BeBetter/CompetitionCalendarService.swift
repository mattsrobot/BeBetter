//
//  CompetitionCalendarService.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 7/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

class CompetitionCalendarService {

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
    
}
