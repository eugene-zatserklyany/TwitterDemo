//
//  String+formatDate.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/10/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import Foundation

extension String {
    
    static func formatTweetDate(dateString: String) -> String {
        let date: Date = formatOriginalDate(dateString: dateString)
        let timeDelta = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: Date())
        
        guard
            let day = timeDelta.day,
            let hour = timeDelta.hour,
            let minute = timeDelta.minute
            else {
                return ""
        }
        
        if day < 1 {
            if hour < 1 {
                if minute < 1 {
                    return "A moment ago"
                } else {
                    return String(minute) + "min"
                }
            } else {
                return String(hour) + "h"
            }
        } else if day > 6 {
            return formatDate(date: date)
        } else {
            return String(day) + "d"
        }
    }

    static func formatUserDate(dateString: String) -> String {
        let date: Date = formatOriginalDate(dateString: dateString)
        return formatDate(date: date, isShort: false)
    }
    
    static private func formatOriginalDate(dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"

        if let date = formatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
    
    static private func formatDate(date: Date, isShort: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = isShort ? "M/d/yy" : "MMMM yyyy"
        return formatter.string(from: date)
    }

    static func likesCount(_ count: Int) -> String {
        if count > 999999 {
            return "\(count / 1000000)M"
        } else if count > 999 {
            return "\(count / 1000)K"
        }
        return String(count)
    }
}
