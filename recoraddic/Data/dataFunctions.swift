//
//  dataFunctions.swift
//  recoraddic
//
//  Created by 김지호 on 2/9/24.
//

import Foundation

extension Quest {
    func cumulative() -> Int {
        return sumIntArray(Array(self.dailyData.values))
    }
    
    func updateTier() -> Void {
        
        if self.tier == 40 { return }
        
        if dataType == DataType.HOUR {
            var cumulative = cumulative()
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
            var cumulative = self.dailyData.count
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
        
        if self.dataType == DataType.HOUR {
            return returnValue*60
        }
        else {
            return returnValue
        }

        
    }

    func representingDataToString() -> String {
        let calendar = Calendar.current
        
        let currentDate = (dailyData.isEmpty || dailyData.keys.contains(getStartDateOfNow())) ? getStartDateOfNow() : calendar.date(byAdding: .day, value: -1, to: getStartDateOfNow())!
        // 오늘기록완료시(get d -> 마지막기록날짜 / 기록완료 안했을 시: 전날
        
        if representingData == QuestRepresentingData.cumulativeData {
            return "누적 \(DataType.string_fullRepresentableNotation(data: cumulative(), dataType: dataType, customDataTypeNotation: self.customDataTypeNotation))"
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
    
    func returnMomentumLevel() -> Int {
        // 1. special

        
        let today: Date = getStartDateOfNow()
        
        if self.dailyData.count == 0 {
            return 0
        }
        
        
        let latestRecordDate: Date = self.dailyData.sorted { element1, element2 in
            element1.key < element2.key
        }.last!.key
        let unactivatedPeriod: Int = calculateDaysBetweenTwoDates(from:latestRecordDate, to: today)
        
        // activate here later... -> 11~31까지의 불을 다 만든 후 활성화하기
//        if unactivatedPeriod == 0 { // try finding if there's special(extreme high) momentumLevel
//            if checkMomentumLevel(ratio: 1.0, termLength: 100, latestRecordDate: latestRecordDate) {
//                return 31
//            }
//            else if checkMomentumLevel(ratio: 1.0, termLength: 50, latestRecordDate: latestRecordDate) {
//                return 30
//            }
//            else if checkMomentumLevel(ratio: 1.0, termLength: 20, latestRecordDate: latestRecordDate) {
//                return 29
//            }
//            else if checkMomentumLevel(ratio: 1.0, termLength: 5, latestRecordDate: latestRecordDate) {
//                return 28
//            }
//        }
//        else if unactivatedPeriod < 10 { // try finding if there's special(high) momentumLevel
//            if checkMomentumLevel(ratio: 0.85, termLength: 100, latestRecordDate: latestRecordDate) {
//                return 27
//            }
//            else if checkMomentumLevel(ratio: 0.85, termLength: 50, latestRecordDate: latestRecordDate) {
//                return 26
//            }
//            else if checkMomentumLevel(ratio: 0.85, termLength: 20, latestRecordDate: latestRecordDate) {
//                return 25
//            }
//            else if checkMomentumLevel(ratio: 0.85, termLength: 5, latestRecordDate: latestRecordDate) {
//                return 24
//            }
//            else if checkMomentumLevel(ratio: 0.7, termLength: 100, latestRecordDate: latestRecordDate) {
//                return 23
//            }
//            else if checkMomentumLevel(ratio: 0.7, termLength: 50, latestRecordDate: latestRecordDate) {
//                return 22
//            }
//            else if checkMomentumLevel(ratio: 0.7, termLength: 20, latestRecordDate: latestRecordDate) {
//                return 21
//            }
//            else if checkMomentumLevel(ratio: 0.7, termLength: 5, latestRecordDate: latestRecordDate) {
//                return 20
//            }
//
//
//        }
//        else if unactivatedPeriod < 20 {  // try finding if there's special(middle) momentumLevel
//            if checkMomentumLevel(ratio: 0.5, termLength: 180, latestRecordDate: latestRecordDate) {
//                return 19
//            }
//            else if checkMomentumLevel(ratio: 0.5, termLength: 120, latestRecordDate: latestRecordDate) {
//                return 18
//            }
//            else if checkMomentumLevel(ratio: 0.5, termLength: 80, latestRecordDate: latestRecordDate) {
//                return 17
//            }
//            else if checkMomentumLevel(ratio: 0.3, termLength: 180, latestRecordDate: latestRecordDate) {
//                return 16
//            }
//            else if checkMomentumLevel(ratio: 0.3, termLength: 120, latestRecordDate: latestRecordDate) {
//                return 15
//            }
//            else if checkMomentumLevel(ratio: 0.3, termLength: 80, latestRecordDate: latestRecordDate) {
//                return 14
//            }
//        }
//        
//        else if unactivatedPeriod < 30 {  // try finding if there's special(low) momentumLevel
//
//            if checkMomentumLevel(ratio: 0.1, termLength: 180, latestRecordDate: latestRecordDate) {
//                return 13
//            }
//            else if checkMomentumLevel(ratio: 0.1, termLength: 120, latestRecordDate: latestRecordDate) {
//                return 12
//            }
//            else if checkMomentumLevel(ratio: 0.1, termLength: 80, latestRecordDate: latestRecordDate) {
//                return 11
//            }
//
//        }
        
        
        // if no special level, then check normal momentum level (비율에서 다 0.001뺌 혹시 몰라서)
        if checkMomentumLevel(ratio: 0.299, termLength: 50, today: today) {
            return 10
        }
        else if checkMomentumLevel(ratio: 0.299, termLength: 40, today: today) {
            return 9
        }
        else if checkMomentumLevel(ratio: 0.332, termLength: 30, today: today) {
            return 8
        }
        else if checkMomentumLevel(ratio: 0.399, termLength: 20, today: today) {
            return 7
        }
        else if checkMomentumLevel(ratio: 0.428, termLength: 14, today: today) {
            return 6
        }
        else if checkMomentumLevel(ratio: 0.499, termLength: 10, today: today) {
            return 5
        }
        else if checkMomentumLevel(ratio: 0.570, termLength: 7, today: today) {
            return 4
        }
        else if checkMomentumLevel(ratio: 0.599, termLength: 5, today: today) {
            return 3
        }
        else if checkMomentumLevel(ratio: 0.666, termLength: 3, today: today) {
            return 2
        }
        else if checkMomentumLevel(ratio: 1, termLength: 1, today: today) {
            return 1
        }
        else {
            return 0
        }
        

    }
    
    func checkMomentumLevel(ratio:CGFloat,termLength:Int, today: Date) -> Bool {
        
        // 기준이 되는 날짜: 오늘 것을 기록했을 때는 오늘, 아직 기록 안했으면 어제 것 기준으로 계산
        
        
        let baseDate:Date = Calendar.current.date(byAdding: .day, value: -termLength, to: today)!
        
        let numberOfRecordedDates:Int = self.dailyData.filter({ element in
            calculateDaysBetweenTwoDates(from: baseDate, to: element.key) > 0
        }).count
        
        return ratio <= CGFloat(numberOfRecordedDates)/CGFloat(termLength)
    }
}
