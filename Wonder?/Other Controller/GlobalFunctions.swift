//
//  GlobalFunctions.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/18/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

/// This date formatter is for the Movie showtime url
func returnFormattedDateString(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let strDate = dateFormatter.string(from: date)
    return strDate
    
}

/// This is for the Movie Label
func returnFormattedDateForMovieLabel(string: String) -> Date? {

    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "yyyy-MM-dd"

    let dateFromString: Date = dateFormatter.date(from: string)!

    return dateFromString
}

/// This is the second function that must be used to display the release date correctely
func returnFormattedDateFrom2(date: Date) -> String? {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    
    let stringFromDate = dateFormatter.string(from: date)
    
    return stringFromDate
}

