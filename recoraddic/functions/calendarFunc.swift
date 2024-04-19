//
//  calendarFunc.swift
//  recoraddic
//
//  Created by 김지호 on 11/8/23.
//


import Foundation

let dueTime:Int = 10 // 10AM

//func getDateOfNow() -> Date {
//    let now = Date()
//    var calendar = Calendar.current
//    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//    let hour = calendar.component(.hour, from: now)
//    
//    if hour >= recoraddic.dueTime {
////        print("\(hour)hours passed, so today")
////        print(calendar.startOfDay(for: now))
//        return calendar.startOfDay(for: now)
//    } else {
////        print("\(hour)hours passed, so yesterday")
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
////        print(calendar.startOfDay(for: yesterday))
//        return calendar.startOfDay(for: yesterday)
//    }
//}
func getStartDateOfNow() -> Date {
    let now = Date()
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    
    return calendar.startOfDay(for: now)
}

func getStartDateOfYesterday() -> Date {
    let now = Date()
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
    
    return calendar.startOfDay(for: yesterday)
}

func getYesterdayOf(_ date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
    return calendar.startOfDay(for: yesterday)
}

func getTomorrowOf(_ date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
    return calendar.startOfDay(for: tomorrow)
}


//func getDateOfYesterDay() -> Date {
//    let now = Date()
//    var calendar = Calendar.current
//    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//    let hour = calendar.component(.hour, from: now)
//    
//    if hour >= recoraddic.dueTime {
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        return calendar.startOfDay(for: yesterday)
//    } else {
//        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
//        return calendar.startOfDay(for: twoDaysAgo)
//    }
//}



func getStartOfDate(date:Date) -> Date {
    let calendar = Calendar.current
    return calendar.startOfDay(for: date)
}



func calculateDaysBetweenTwoDates(from: Date, to: Date) -> Int {
    let currentCalendar = Calendar.current
    guard let startDay = currentCalendar.ordinality(of: .day, in: .era, for: from) else { return 0 }
    guard let endDay = currentCalendar.ordinality(of: .day, in: .era, for: to) else { return 0 }
    return endDay - startDay
}



func getDateList(from startDate: Date, to endDate: Date) -> [Date] {
    var dates: [Date] = []
    let calendar = Calendar.current
    var currentDate = startDate

    while currentDate <= endDate {
        dates.append(calendar.startOfDay(for: currentDate))
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    }

    return dates
}

func yymmFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YY/MM"
    return formatter.string(from: date)
}


func mmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "MM/dd"
    return formatter.string(from: date)
}

func ddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "dd"
    return formatter.string(from: date)
}

func yymmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YY/MM/dd"
    return formatter.string(from: date)
}

func yyyymmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.string(from: date)
}


func kor_yyyymmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy/MM/dd"
    
    let yyyymmddList = formatter.string(from: date).split(separator: "/").map({$0})
    
    
    
    return "\(yyyymmddList[0])년 \(yyyymmddList[1])월 \(yyyymmddList[2])일"
}
func kor_mmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy/MM/dd"
    
    let yyyymmddList = formatter.string(from: date).split(separator: "/").map({$0})
    
    
    
    return "\(yyyymmddList[1])월 \(yyyymmddList[2])일"
}


func eeeemmddFormatOf(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "EEEE MM/dd"
    return formatter.string(from: date)
}

func nDates(from date :Date, n:Int) -> [Date] {
    var dates:[Date] = [date]
    var dateComponents = DateComponents()
    dateComponents.day = 1
    let calendar = Calendar.current
    for _ in 1...200 {
        let nextDay = calendar.date(byAdding: dateComponents, to: dates.last!)

        dates.append(nextDay!)
    }
    print("dates:\(dates)")

    return dates
    
}

extension Date {
    var isStartOfMonth: Bool {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return components.day == 1
    }
    
    var isEndOfMonth: Bool {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: self)!
        return !Calendar.current.isDate(nextDay, equalTo: self, toGranularity: .month)
    }
}
