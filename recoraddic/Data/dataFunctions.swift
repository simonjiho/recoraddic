//
//  dataFunctions.swift
//  recoraddic
//
//  Created by 김지호 on 2/9/24.
//

import Foundation

extension Quest {
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
                return 24
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 30, today: todayOrYesterday) {
                return 23
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 20, today: todayOrYesterday) {
                return 22
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 10, today: todayOrYesterday) {
                return 21
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 5, today: todayOrYesterday) {
                return 20
            }
            else if checkMomentumLevel(ratio: 1.0, termLength: 3, today: todayOrYesterday) {
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
                case 18,12,6: return 60
                case 17,11: return 30
                case 16,10: return 20
                case 15,9: return 10
                case 14,8: return 5
                case 13,7: return 3
                case 5: return 50
                case 4: return 40
                case 3: return 30
                case 2: return 20
                case 1: return 10
                default: return 1
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
