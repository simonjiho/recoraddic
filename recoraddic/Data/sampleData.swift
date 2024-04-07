//
//  sampleData.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation
import SwiftData



//extension Record {
//    func createSample() {
////        let tenDates = nDates(from: start, n: 10)
////        purposes.append(Purpose(name: "recoraddic 만들기",color:1))
////        purposes.append(Purpose(name: "운동", color:2))
////        purposes.append(Purpose(name: "식건강", color:3))
////        purposes.append(Purpose(name: "금전", color:4))
////        purposes.append(Purpose(name: "수면건강", color: 5))
////        
////        for purpose in purposes {
////            purpose.belongingRecord = self
////            
////            if purpose.name == "recoraddic 만들기" {
////                purpose.quests.append(
////                    Quest(
////                        name: "데이터 구조화",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.HOUR,
////                        goalSetting: GoalSetting.setFinalGoal,
////                        goalValue: 10,
////                        checkDate: tenDates
////                    )
////                )
////
////                purpose.quests.append(
////                    Quest(
////                        name: "main UI 생성",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.HOUR,
////                        goalSetting: GoalSetting.setFinalGoal,
////                        goalValue: 8,
////                        checkDate: tenDates
////
////                    )
////                )
////                purpose.quests.append(
////                    Quest(
////                        name: "네비게이션 바 생성",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.HOUR,
////                        goalSetting: GoalSetting.setFinalGoal,
////                        goalValue: 9*6,
////                        checkDate: tenDates
////                    )
////                )
////
////            }
////            
////            else if purpose.name == "운동" {
////                purpose.quests.append(
////                    Quest(
////                        name: "아침간단운동",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////                purpose.quests.append(
////                    Quest(
////                        name: "밤에 운동 1.5시간",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////            }
////            
////            else if purpose.name == "식건강" {
////                purpose.quests.append(
////                    Quest(
////                        name: "영양제 2회",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////                purpose.quests.append(
////                    Quest(
////                        name: "3000kcal",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////            }
////            
////            else if purpose.name == "금전" {
////                purpose.quests.append(
////                    Quest(
////                        name: "10000원 저금",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////
////            }
////            
////            else if purpose.name == "수면건강" {
////                purpose.quests.append(
////                    Quest(
////                        name: "자기 2시간 전 취식 no",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////                purpose.quests.append(
////                    Quest(
////                        name: "안먹는 시간 10시간 이상 유지",
////                        recordInterval:RecordInterval.everyDay,
////                        dataType: DataType.OX,
////                        goalSetting: GoalSetting.setDailyGoal,
////                        goalValue: 1,
////                        checkDate: tenDates
////
////                    )
////                )
////
////            }
////            
////        }
////        
////        // creating data...
////        for purpose in purposes {
////            for quest in purpose.quests {
////
////                let calendar = Calendar.current
////                let dateFormatter = DateFormatter()
////                dateFormatter.dateFormat = "yyyy/MM/dd"
////                let startDate = dateFormatter.date(from: "2023/06/11") ?? Date()
////
////                var date = calendar.startOfDay(for: startDate)  // start from specific day
////
////                for _ in 1...10 {  // replace 10 with the number of days you want to loop through
////                    quest.addData(when: date, data:Int.random(in: 0..<2))
////                    if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
////                        date = nextDay
////                    }
////                }
////
////
////            }
////        }
////        
//    }
//}
//
