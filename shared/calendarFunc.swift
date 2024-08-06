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

func getStandardDate(from date: Date) -> Date {
    let dateComponents =  Calendar.current.dateComponents([.year, .month,.day], from: date)
    
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    return calendar.date(from: dateComponents) ?? date
}

func getStandardDateOfYesterday() -> Date {
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

    let dateComponents =  Calendar.current.dateComponents([.year, .month,.day], from: yesterday)

    
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    return calendar.date(from: dateComponents) ?? yesterday
}

func getStandardDateOfNow() -> Date {
    let dateComponents =  Calendar.current.dateComponents([.year, .month,.day], from: Date())
    
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    return calendar.date(from: dateComponents) ?? Date()
}

func standardDateToLocalStartOfDay(std date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    // Extract year, month, and day components in UTC
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    
    // Set calendar to local time zone
    calendar.timeZone = TimeZone.current
    
    // Create a date from the components, now interpreted in the local time zone
    return calendar.date(from: dateComponents) ?? date
}

func standardDateToLocalStartOfDay(std date: Date?) -> Date? {
    if date == nil {return nil}
    else {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // Extract year, month, and day components in UTC
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date!)
        
        // Set calendar to local time zone
        calendar.timeZone = TimeZone.current
        
        // Create a date from the components, now interpreted in the local time zone
        return calendar.date(from: dateComponents)
    }
}


//func getYesterdayOf(_ date: Date) -> Date {
//    var calendar = Calendar.current
//    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//    let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
//    return calendar.startOfDay(for: yesterday)
//}

func getTomorrowOf(_ date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
    return calendar.startOfDay(for: tomorrow)
}


func convertToDate(from dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy/MM/dd"
//    formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing
    formatter.locale = Locale(identifier: "ko_KR") // Ensures consistent parsing
    return getStandardDate(from: formatter.date(from: dateString) ?? .now)
//    return getStartOfDate(date:formatter.date(from: dateString) ?? .now)
    
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


func dailyStreak(from dates: [Date], targetDate: Date) -> Int {
    // Ensure dates are sorted in ascending order
    let sortedDates = dates.sorted()
    
    // Create a Calendar instance
    let calendar = Calendar.current
    
    var streak = 0
    var currentDate = calendar.date(byAdding: .day, value: -1, to: targetDate) ?? targetDate
    
    // Iterate backward from the target date
    while sortedDates.contains(currentDate) {
        streak += 1
        if let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
            currentDate = previousDate
        } else {
            break
        }
    }
    
    return streak
}

func partitionByWeek(startDate: Date, endDate: Date) -> [[Date]] {
    var result:[[Date]] = [[Date]]()
    var currentWeek:[Date] = []
    var currentDate = startDate

    while currentDate <= endDate {
        let weekOfYear = Calendar.current.component(.weekOfYear, from: currentDate)
        let weekOfYearNextDay = Calendar.current.component(.weekOfYear, from: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)

        currentWeek.append(currentDate)

        if weekOfYear != weekOfYearNextDay {
            result.append(currentWeek)
            currentWeek = []
        }

        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }

    if !currentWeek.isEmpty {
        result.append(currentWeek)
    }

    return result
}




func containsFirstDateOfMonth(dates:[Date]) -> Bool {
    let startOfMonthIndex: Int? = dates.firstIndex(where: {$0.isStartOfMonth_local})
    if startOfMonthIndex != nil { return true }
    else { return false}
}

extension Date {
    var isStartOfMonth_local: Bool {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return components.day == 1
    }
    
    var isEndOfMonth_local: Bool {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: self)!
        return !Calendar.current.isDate(nextDay, equalTo: self, toGranularity: .month)
    }
    
    
    var isExpired_local: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Compare the components of the date up to the minute
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let inputDateComponents = calendar.dateComponents(components, from: self)
        let nowDateComponents = calendar.dateComponents(components, from: now)
        
        // Create dates truncated to the minute
        guard let inputDate = calendar.date(from: inputDateComponents),
              let nowDate = calendar.date(from: nowDateComponents) else {
            return false
        }
        
        return inputDate <= nowDate
    }
    
    var hhmmTimeString_local: String {
        // Get the current date and time
        
        // Create a DateFormatter
        let formatter = DateFormatter()
        
        // Set the locale to the current locale of the device
        formatter.locale = Locale.current
        
        // Set the time style to short (00:00)
        formatter.timeStyle = .short
        
        // Format the current date to a string
        let timeString = formatter.string(from: self)
        
        return timeString
    }
    
    var isStartOfMonth_std: Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return components.day == 1
    }
    
    var isEndOfMonth_std: Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let nextDay = calendar.date(byAdding: .day, value: 1, to: self)!
        return !Calendar.current.isDate(nextDay, equalTo: self, toGranularity: .month)
    }
    
    
    var isExpired_std: Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // Compare the components of the date up to the minute
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let inputDateComponents = calendar.dateComponents(components, from: self)
        let nowDateComponents = Calendar.current.dateComponents(components, from: Date())
        
        // Create dates truncated to the minute
        guard let inputDate = Calendar.current.date(from: inputDateComponents),
              let nowDate = Calendar.current.date(from: nowDateComponents) else {
            return false
        }
        
        return inputDate <= nowDate
    }
    
    
    
//    var hhmmTimeString_std: String {
//        // Get the current date and time
//        
//        // Create a DateFormatter
//        let formatter = DateFormatter()
//        
//        // Set the locale to the current locale of the device
//        formatter.locale = Locale(identifier: <#T##String#>)
//        
//        // Set the time style to short (00:00)
//        formatter.timeStyle = .short
//        
//        // Format the current date to a string
//        let timeString = formatter.string(from: self)
//        
//        return timeString
//    }
    func addingDays(_ value: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: value, to: self) ?? self
    }
    
    func addingHours(_ value: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: value, to: self) ?? self
    }
    
}




//func isDateExpired(date:Date) -> Bool {
//    let calendar = Calendar.current
//    let now = Date()
//    
//    // Compare the components of the date up to the minute
//    let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
//    let inputDateComponents = calendar.dateComponents(components, from: date)
//    let nowDateComponents = calendar.dateComponents(components, from: now)
//    
//    // Create dates truncated to the minute
//    guard let inputDate = calendar.date(from: inputDateComponents),
//          let nowDate = calendar.date(from: nowDateComponents) else {
//        return false
//    }
//    
//    return inputDate <= nowDate
//}
