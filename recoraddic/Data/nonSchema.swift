//
//  nonSchema.swift
//  recoraddic
//
//  Created by 김지호 on 11/19/24.
//

import Foundation
import SwiftData
import SwiftUI
// use @observable after update to swift 5.9


final class RecordInterval {
    static let everyDay = 0
    static let onceInNdays = 1
    static let chooseInCalander = 2
    
    init() {
    }
}

final class DefaultPurpose {
    
    
    // 개인지향
    static let atr = "attractiveness" // 외모, 매력 (atr)
    static let inq = "inquisitiveness" // 지식, 탐구 (inq)
    static let ent = "entertainmentAndFun" // 즐거움 (ent)
    static let hlt = "personalHealth" // 건강 (hlt)
    static let ftr = "myFuture" // 개인적인 미래 (ftr)
    static let ach = "selfAchievement"
    static let rts = "relationship"
    static let cmp = "competitiveness"

    // 타인지향
    static let lov = "love" // 사랑하는, 소중한 사람 (sgn)
    static let fml = "family" // 가족 (fml)
    static let cmn = "community" // 공동체 (cmn)
    static let alt = "alturism" // 이타심 (alt)
    static let wrl = "world"  // 인류의 미래 (wrl)
    
    
    
    static func inKorean(_ input: String) -> String {
        if input == DefaultPurpose.atr {
            return "매력"
        }
        else if input == DefaultPurpose.inq {
            return "탐구심"
        }
        else if input == DefaultPurpose.ent {
            return "즐거움"
        }
        else if input == DefaultPurpose.hlt {
            return "건강"
        }
        else if input == DefaultPurpose.ftr {
            return "미래"
        }
        else if input == DefaultPurpose.ach {
            return "성취감"
        }
        else if input  == DefaultPurpose.rts {
            return "인간관계"
        }
        else if input == DefaultPurpose.cmp {
            return "경쟁심"
        }
        
        
        else if input == DefaultPurpose.lov {
            return "사랑"
        }
        else if input == DefaultPurpose.fml {
            return "가족"
        }
        else if input == DefaultPurpose.cmn {
            return "공동체"
        }
        else if input == DefaultPurpose.alt {
            return "이타심"
        }
        else if input == DefaultPurpose.wrl {
            return "세상"
        }
        else {
            return "에러: KORPURP"
        }
        
    }
    
    
}

final class QuestRepresentingData {
    
    static let cumulativeData = 0
    static let recentMontlyData = 1
    static let recentYearlyData = 2
    
    init() {}
    
    static func titleOf(representingData:Int) -> String {
        if representingData == QuestRepresentingData.cumulativeData {
            return "누적:"
        }
        
        else if representingData == QuestRepresentingData.recentMontlyData {
            return "최근 30일:"
        }
        else {
            return "titleOfRepresentingData: Error"
        }
    }
    
}


final class DailyTextType {
    // 소감 / 감정 / 다짐 / 피드백 / 즐거웠던 일 / 인상깊었던 일 / 기억하고 싶은 일

    static let inShort = "inShort" // 한줄평 (-) : 오늘 하루를 최대한 간략하고 위트있게 표현해보세요!
    static let diary = "diary" // 오늘 있었던 특별했던, 또는 중요했던, 잊고 싶지 않은 일을 상세히 기록하세요!
    
    init() {
    }
}


extension DailyQuest {
    func dataForDataRepresentation() -> (Int, Int, String?) {
        return (data, dataType, customDataTypeNotation)
    }
    
    func getName() -> String {
        if let subName = self.questSubName {
            return subName
        } else {
            return self.questName
        }
    }
}

extension DailyRecordSet {
    func getIntegratedDailyRecordColor(colorScheme:ColorScheme) -> Color {
        if self.dailyRecordThemeName == "StoneTower" {
            return TowerView.getIntegratedDailyRecordColor(
                index: dailyRecordColorIndex,
                colorScheme: colorScheme
            )
        }
        else {
            return TowerView.getIntegratedDailyRecordColor(
                index: dailyRecordColorIndex,
                colorScheme: colorScheme
            )
        }
    }
    
    
    
    func getTerm_string() -> String {
        if self.end != nil {
            return "\(yymmddFormatOf(self.start)) ~ \(yymmddFormatOf(self.end!))"
        }
        else {
            return "\(yymmddFormatOf(self.start)) ~ "
        }
    }
    
    
    
    func updateDailyRecordsMomentum() -> Void { // modify absence and streak
        if let dailyRecords = self.dailyRecords {
            let dates = dailyRecords.filter({$0.hasContent}).compactMap({$0.date}).sorted()
            for dailyRecord in dailyRecords {
                if let date = dailyRecord.date {
                    let dates_beforeDate:[Date] = dates.filter({$0 < date})
                    if let nearestDate:Date = dates_beforeDate.last {
                        dailyRecord.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
                        if dailyRecord.absence == 0 {
                            dailyRecord.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
                        } else {
                            dailyRecord.streak = 0
                        }
                    } else { // first dailyRecord in drs
                        dailyRecord.absence = 0
                        dailyRecord.streak = 0
                    }
                }
            }
        }
    }
    
    func getLocalStart() -> Date {
        let date = self.start
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        // Extract year, month, and day components in UTC
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        // Set calendar to local time zone
        calendar.timeZone = TimeZone.current
        // Create a date from the components, now interpreted in the local time zone
        return calendar.date(from: dateComponents) ?? date
        
        
    }
    func getLocalEnd() -> Date? {
        if let date = self.end {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
            // Extract year, month, and day components in UTC
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            // Set calendar to local time zone
            calendar.timeZone = TimeZone.current
            // Create a date from the components, now interpreted in the local time zone
            return calendar.date(from: dateComponents) ?? date
        } else {
            return nil
        }
        
    }
    
    
    func visibleDailyRecords(hiddenQuestNames:Set<String>, showHiddenQuests:Bool) -> [DailyRecord] {
        let dailyRecords_filtered = self.dailyRecords!
            .filter({$0.hasContent && $0.date != nil})
            .filter({($0.getLocalDate() ?? getStartDateOfNow()) < .now })
        if showHiddenQuests {
            return dailyRecords_filtered
                .sorted(by: {
                    if let date0 = $0.date, let date1 = $1.date {
                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
                    } else if $0.date == nil {
                        return false  // Places items with nil date after those with a non-nil date
                    } else {
                        return true  // Ensures $0 with a date is before $1 with nil
                    }
                })
        } else {
            return dailyRecords_filtered
                .filter({
                    $0.hasTodoOrDiary ||
                    !Set($0.dailyQuestList!.filter({$0.data != 0}).map{$0.questName}).subtracting(hiddenQuestNames).isEmpty
                })
                .sorted(by:{
                    if let date0 = $0.date, let date1 = $1.date {
                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
                    } else if $0.date == nil {
                        return false  // Places items with nil date after those with a non-nil date
                    } else {
                        return true  // Ensures $0 with a date is before $1 with nil
                    }
                }
                )
        }
    }
    
    
    //    func increaseStreak(from date:Date) {
    //        if let dailyRecords = self.dailyRecords {
    //            for dailyRecord in dailyRecords {
    //
    //
    //            }
    //        }
    //
    //        if let dates = dailyRecordSet.dailyRecords?.filter({$0.recordedAmount > 0}).map({ $0.date }) {
    //            if let date = self.date {
    //                let dates_beforeDate:[Date] = dates.compactMap({$0}).filter({$0 < date})
    //                if let nearestDate:Date = dates_beforeDate.sorted().last {
    //                    self.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
    //                    if self.absence == 0 {
    //                        self.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
    //                    } else {
    //                        self.streak = 0
    //                    }
    //                }
    //            }
    //        }
    //    }
    //    func decreaseStreak(from:Date) {
    //
    //    }
}

extension DailyRecord {
    func updateRecordedMinutes() -> Void {
        if let dailyQuestList = self.dailyQuestList {
            self.recordedMinutes = sumIntArray(dailyQuestList.filter({dataTypeFrom($0.dataType) == DataType.hour}).map({$0.data}))
        }
    }
    
    func updateExternalFactors() -> Void {
        if let dailyRecordSet = self.dailyRecordSet {
            if let dates = dailyRecordSet.dailyRecords?.filter({$0.hasContent}).map({ $0.date }) {
                if let date = self.date {
                    let dates_beforeDate:[Date] = dates.compactMap({$0}).filter({$0 < date})
                    if let nearestDate:Date = dates_beforeDate.sorted().last {
                        self.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
                        if self.absence == 0 {
                            self.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
                        } else {
                            self.streak = 0
                        }
                    }
                }
            }
        }
    }
    
    func getLocalDate() -> Date? {
        if let date = self.date {
            //            print("convert \(date) into")
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
            // Extract year, month, and day components in UTC
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            // Set calendar to local time zone
            calendar.timeZone = TimeZone.current
            // Create a date from the components, now interpreted in the local time zone
            //            print("\(calendar.date(from: dateComponents))")
            
            return calendar.date(from: dateComponents) ?? date
        } else {
            
            return nil
        }
        
    }
}

extension Quest {
    
    func isVisible() -> Bool {
        return !isArchived && !isHidden && !inTrashCan
    }
    
    func getName() -> String {
        if let subName = self.subName {
            return subName
        } else {
            return self.name
        }
    }
    
    func getCumulative(from start:Date, to end:Date?) -> Int {
        return self.dailyData.filter({$0.key >= start && $0.key <= (end ?? $0.key)}).values.reduce(0,+)
    }
    func getCount(from start:Date, to end:Date?) -> Int {
        return self.dailyData.keys.filter({$0 >= start && $0 <= (end ?? $0) }).count
    }
    
    func cumulative() -> Int {
        return sumIntArray(Array(self.dailyData.values)) + self.pastCumulatve
    }
    
    func updateTier() -> Void {
        
//        if self.tier == 40 { return }
        var cumulative = dataType == DataType.custom.rawValue ? self.dailyData.count : cumulative()
        if dataType == DataType.hour.rawValue {
            for i in 0...40 {
                let minus: Int = {
                    switch i {
                    case 0...9:
                        return 60 // 1시간
                    case 10...14:
                        return 360 // 6시간
                    case 15...19:
                        return 720 // 12시간
                    case 20...24:
                        return 3600 // 60시간
                    case 25...29:
                        return 7200 // 120시간
                    case 30...34:
                        return 36000 // 600시간
                    case 35...39:
                        return 72000 // 1200시간
                    default:
                        return 9999999
                    }
                }()
                
                if cumulative-minus < 0 || i == 40 {
                    self.tier = i
                    break
                }
                else {
                    cumulative -= minus
                }
            }
        }
        else {
            for i in 0...40 {
                let minus: Int = {
                    switch i {
                    case 0...9:
                        return 1
                    case 10...14:
                        return 6
                    case 15...19:
                        return 12
                    case 20...24:
                        return 60
                    case 25...29:
                        return 120
                    case 30...34:
                        return 600
                    case 35...39:
                        return 1200
                    default:
                        return -9999999
                    }
                }()
                
                if cumulative-minus < 0 || i == 40 {
                    self.tier = i
                    break
                }
                else {
                    cumulative -= minus
                }
            }
        }
    }
    
    func getNextTierCondition() -> Int {
        // 0~4 -> 5
        // 5~9 -> 10
        let returnValue: Int = {
            switch self.tier/5 {
            case 0: return 5
            case 1: return 10
            case 2: return 40
            case 3: return 100
            case 4: return 400
            case 5: return 1000
            case 6: return 4000
            case 7: return 10000
            default: return 0
            }
        }()
        
        if self.dataType == DataType.hour.rawValue {
            return returnValue*60
        }
        else {
            return returnValue
        }

        
    }

    func representingDataToString() -> String {
//        let calendar = Calendar.current
        
//        let currentDate = (dailyData.isEmpty || dailyData.keys.contains(getStandardDateOfNow())) ? getStartDateOfNow() : calendar.date(byAdding: .day, value: -1, to: getStartDateOfNow())!
        // 오늘기록완료시(get d -> 마지막기록날짜 / 기록완료 안했을 시: 전날
        
        if representingData == QuestRepresentingData.cumulativeData {
            return "누적 \(DataType.string_fullRepresentableNotation(data: cumulative(), dataType: dataTypeFrom(dataType), customDataTypeNotation: self.customDataTypeNotation))"
        }
        
        // not used
//        else if representingData == QuestRepresentingData.recentMontlyData {
//
//            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: currentDate)!
//
//            let recentData = dailyData.filter { (key: Date, value: Int) -> Bool in
//                return key >= thirtyDaysAgo
//            }
//
//            let actualTerm:Int = {
//                if recentData.isEmpty {
//                    return 1
//                }
//                else {
//                    if recentData.keys.sorted().first! != currentDate {
//                        return calculateDaysBetweenTwoDates(from: recentData.keys.sorted().first!, to: currentDate) + 1
//                    }
//                    else {
//                        return 1
//                    }
//                }
//            }()
//
//
//            let numberOfDoneDates: Int = recentData.isEmpty ? 1 : recentData.count
//
//            let averageTermOfQuest: Float = recentData.isEmpty ? 0.0 : Float(actualTerm) / Float(numberOfDoneDates)
//
//            let averageValueOfQuest: Float = Float(sumIntArray(Array(recentData.values))) / Float(numberOfDoneDates)
//
//            return "\(String(format:"%.1f",averageTermOfQuest)) 일마다 \(String(format:"%.1f",DataType.float_unitDataToRepresentableData(data:Int(averageValueOfQuest*10), dataType: self.dataType)/10.0 ) )\(DataType.unitNotationOf(dataType: self.dataType, customDataTypeNotation: customDataTypeNotation))"
//
//        }
        
        else {
            return "questRepresentOptionError"
        }
        
    }
    
    func updateMomentumLevel() -> Void {
        self.momentumLevel = returnMomentumLevel()
    }
//    func returnMomentumLevel() -> Int {
//        // 1. special
//
//        let datesRecorded:[Date] = self.dailyData.keys.filter({self.dailyData[$0] ?? 0 > 0})
//        let boolArray60days:[Bool] = generateBoolArray(from:datesRecorded)
//        let (days, percentage) = getRecentPercentage(from:boolArray60days)
//
//        if days == 0 { return 0 }
//
//        let fire:Int = {
//            switch percentage {
//            case 1.0...: return 4
//            case 0.75..<1.0: return 3
//            case 0.5..<0.75: return 2
//            case 0.25..<0.5: return 1
//            case 0.01..<0.5: return 0
//            default: return 0
//            }
//        }()
//
//        let size:Int = {
//            switch days {
//            case 60...: return 5
//            case 30..<60: return 4
//            case 20..<30: return 3
//            case 10..<20: return 2
//            case 5..<10: return 1
//            default: return 0
//            }
//        }()
//
//
//        return 1 + fire*6 + size
//
//
//
//
//    }

    func returnMomentumLevel() -> Int {

        if self.dailyData.count == 0 {
            return 0
        }
        
        let latestRecordDate: Date = self.dailyData.sorted { element1, element2 in
            element1.key < element2.key
        }.last!.key
        
        let today: Date = getStandardDateOfNow()
        let todayOrYesterday = latestRecordDate == today ? today : getStandardDateOfYesterday()
        
        let unactivatedPeriod: Int = calculateDaysBetweenTwoDates(from:latestRecordDate, to: today)
        
//        if self.name == "시간퀘스트" {
//            print(unactivatedPeriod)
//            print(self.dailyData)
//            let baseDate = Calendar.current.date(byAdding: .day, value: -3, to: todayOrYesterday)!
//            print(baseDate)
//            for key in self.dailyData.keys {
//                print(calculateDaysBetweenTwoDates(from: baseDate, to: key) > 0)
//            }
//            let numberOfRecordedDates:Int = self.dailyData.filter({ element in
//                calculateDaysBetweenTwoDates(from: baseDate, to: element.key) > 0
//            }).count
//            print(numberOfRecordedDates)
//            print(checkMomentumLevel(ratio: 0.33, termLength: 3, today: todayOrYesterday))
//        }
        
        if unactivatedPeriod <= 1 { // try finding if there's special(extreme high) momentumLevel
            if checkMomentumLevel(ratio: 1.0, termLength: 60, today: todayOrYesterday) {
                return 25
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 30, today: todayOrYesterday) {
                return 24
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 20, today: todayOrYesterday) {
                return 23
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 10, today: todayOrYesterday) {
                return 22
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 5, today: todayOrYesterday) {
                return 21
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 3, today: todayOrYesterday) {
                return 20
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 1, today: todayOrYesterday) {
                return 19
            }
        }
        if unactivatedPeriod <= 5 {
            if checkMomentumLevel(ratio: 0.66, termLength: 60, today: todayOrYesterday) {
                return 18
            }
            else if checkMomentumLevel(ratio: 0.66, termLength: 30, today: todayOrYesterday) {
                return 17
            }
            else if checkMomentumLevel(ratio: 0.66, termLength: 20, today: todayOrYesterday) {
                return 16
            }
            else if checkMomentumLevel(ratio: 0.66, termLength: 10, today: todayOrYesterday) {
                return 15
            }
            else if checkMomentumLevel(ratio: 0.66, termLength: 5, today: todayOrYesterday) {
                return 14
            }
            else if checkMomentumLevel(ratio: 0.66, termLength: 3, today: todayOrYesterday) {
                return 13
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 60, today: todayOrYesterday) {
                return 12
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 30, today: todayOrYesterday) {
                return 11
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 20, today: todayOrYesterday) {
                return 10
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 10, today: todayOrYesterday) {
                return 9
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 5, today: todayOrYesterday) {
                return 8
            }
            else if checkMomentumLevel(ratio: 0.33, termLength: 3, today: todayOrYesterday) {
                return 7
            }
            
        }
        if unactivatedPeriod <= 10 {  // try finding if there's special(middle) momentumLevel
            if checkMomentumLevel(ratio: 0.1, termLength: 60, today: todayOrYesterday) {
                return 6
            }
            else if checkMomentumLevel(ratio: 0.1, termLength: 50, today: todayOrYesterday) {
                return 5
            }
            else if checkMomentumLevel(ratio: 0.1, termLength: 40, today: todayOrYesterday) {
                return 4
            }
            else if checkMomentumLevel(ratio: 0.1, termLength: 30, today: todayOrYesterday) {
                return 3
            }
            else if checkMomentumLevel(ratio: 0.1, termLength: 20, today: todayOrYesterday) {
                return 2
            }
            else if checkMomentumLevel(ratio: 0.1, termLength: 10, today: todayOrYesterday) {
                return 1
            }
        }

        return 0
        
    }
    
    func checkMomentumLevel(ratio:CGFloat,termLength:Int, today: Date) -> Bool {

        // 기준이 되는 날짜: 오늘 것을 기록했을 때는 오늘, 아직 기록 안했으면 어제 것 기준으로 계산
        
        
        let baseDate:Date = Calendar.current.date(byAdding: .day, value: -termLength, to: today) ?? today
        
        let numberOfRecordedDates:Int = self.dailyData.filter({ element in
            calculateDaysBetweenTwoDates(from: baseDate, to: element.key) > 0
        }).count
        
        return ratio <= CGFloat(numberOfRecordedDates)/CGFloat(termLength)
        
    }
    
    
    func textForMomentumLevel() -> String {
        
        if self.dailyData.count == 0 {
            return "기록 없음"
        }
        
        let latestRecordDate: Date = self.dailyData.sorted { element1, element2 in
            element1.key < element2.key
        }.last!.key
//        let today: Date = getStandardDateOfNow()
//        let todayOrYesterday = latestRecordDate == today ? today : getStandardDateOfYesterday()
        let datesRecorded:[Date] = self.dailyData.keys.filter({(self.dailyData[$0] ?? 0) > 0})
        let boolArray60days:[Bool] = generateBoolArray(from:datesRecorded)
//        let (days, percentage) = getRecentPercentage(from:boolArray60days)
        if momentumLevel >= 19 {
            let n:Int = boolArray60days.firstIndex(where:{!$0}) ?? 60
            return "\(n)일 연속 기록 중"
        } else if momentumLevel >= 1 {
            let days:Int = {
                switch momentumLevel {
                case 25,18,12,6: return 60
                case 24,17,11: return 30
                case 23,16,10: return 20
                case 22,15,9: return 10
                case 21,14,8: return 5
                case 20,13,7: return 3
                case 5: return 50
                case 4: return 40
                case 3: return 30
                case 2: return 20
                case 1: return 10
                case 19: return 1
                default: return 0
                }
            }()
            return "최근 \(days)일 \(boolArray60days[..<days].filter({$0}).count)회 기록"
        } else {
            if boolArray60days.filter({$0}).count == 0 { return "마지막 기록: \(kor_yyyymmddFormatOf(standardDateToLocalStartOfDay(std:latestRecordDate)))"}
            else { return "마지막 기록: \((boolArray60days.firstIndex(where:{$0}) ?? -99999) + 1)일 전" }
        }
    }
    
    func getRatio(termLength:Int, today: Date) -> CGFloat {
        
        // 기준이 되는 날짜: 오늘 것을 기록했을 때는 오늘, 아직 기록 안했으면 어제 것 기준으로 계산
        
        let baseDate:Date = Calendar.current.date(byAdding: .day, value: -termLength, to: today) ?? Date()
        
        let numberOfRecordedDates:Int = self.dailyData.filter({ element in
            calculateDaysBetweenTwoDates(from: baseDate, to: element.key) > 0
        }).count
        
        return CGFloat(numberOfRecordedDates)/CGFloat(termLength)
        
    }
    
//    func checkMomentumLevel(ratio:CGFloat, termLength:Int, today: Date) -> Bool {
//
//        let baseDate:Date = Calendar.current.date(byAdding: .day, value: -termLength, to: today) ?? Date()
//
//        let numberOfRecordedDates:Int = self.dailyData.filter({ element in
//            calculateDaysBetweenTwoDates(from: baseDate, to: element.key) > 0
//        }).count
//
//        return ratio <= CGFloat(numberOfRecordedDates)/CGFloat(termLength)
//
//    }
    
    
    
    func generateBoolArray(from dates: [Date]) -> [Bool] {
        var result = [Bool](repeating: false, count: 60)
        let calendar = Calendar.current
        let recentDate = {
            let today = getStandardDateOfNow()
            if dates.contains(today) { return today }
            else { return today.addingDays(-1)}
        }()

        for i in 0..<60 {
            if let dateToCheck = calendar.date(byAdding: .day, value: -i, to: recentDate) {
                if dates.contains(where: { calendar.isDate($0, inSameDayAs: dateToCheck) }) {
                    result[i] = true
                }
            }
        }
        
        return result
    }
//
//    func getRecentPercentage(from isDone: [Bool]) -> (Int,CGFloat) {
//
//        if let first = isDone.first {
//            if first == true {
//                var cnt:Int = 0
//                var i:Int = 0
//                while isDone[i] {
//                    i += 1
//                    cnt += 1
//                }
//                return (cnt,1.0)
//            }
//            else {
//                let percentageArr = getPercentageArray(from:isDone)
//                if percentageArr[9] == 0 { return (0,0.0)}
//
//                if let arrMax = percentageArr.max()  {
//                    let cnt:Int
//                    if arrMax >= 0.25 { cnt = (percentageArr.firstIndex(of:arrMax) ?? 0) + 1 }
////                    if arrMax >= 0.75 { cnt = percentageArr.lastIndex(where:{$0 >= 0.75}) ?? 0 }
////                    else if arrMax >= 0.5 { cnt = percentageArr.lastIndex(where:{$0 >= 0.5}) ?? 0 }
////                    else  { cnt = percentageArr.lastIndex(where:{$0 >= 0.25}) ?? 0 }
//                    else { cnt = (isDone.lastIndex(where:{$0}) ?? 0)+1 }
//                    return (cnt, percentageArr[cnt-1])
//                }
//                else { return (0, 0.0) }
//
//            }
//        }
//        else { return (0,0.0) }
//
//    }
//
//
//    func getPercentageArray(from isDone: [Bool]) -> [CGFloat] {
//        var returnArray: [CGFloat] = []
//        for i in 0..<isDone.count {
//            returnArray.append(CGFloat(isDone[...i].filter({$0}).count)/CGFloat(i+1))
//        }
//        return returnArray
//    }

}

