//
//  ExampleData.swift
//  recoraddic
//
//  Created by 김지호 on 1/10/24.
//

import Foundation
import SwiftUI
import SwiftData

// 나중에 정말 여러개의 데이터를 랜덤으로 자동 생성해주는 function 만들어서 코드 줄이기

extension ContentView {
//    @Environment(\.modelContext) 
    
    func defaultInitialization() -> Void {
        let firstDailyRecord = DailyRecord(date: getDateOfNow())
        let firstDailyRecordSet = DailyRecordSet(start: getDateOfNow())
        modelContext.insert(firstDailyRecord)
        modelContext.insert(firstDailyRecordSet)
        
        // dailyRecord는 절대 저장 전까지 ㄴㄴ
//        firstDailyRecord.dailyRecordSet = firstDailyRecordSet // 이거 먼저 적으면 drs가 두번 추가됨

    }
    
    
    
    func situation_YesterdayDataRemains() -> Void {
        print("generating example data.....")
        
        let q1 = Quest(name: "Workout", dataType: DataType.HOUR)
        let q2 = Quest(name: "Create apps", dataType: DataType.HOUR)
        let q3 = Quest(name: "Drink milk", dataType: DataType.CUSTOM)
        q3.customDataTypeNotation = "ml"
        
        // need to set recent purpose, if not, will have no recentpurpose when adding quest at first, still no problem to system.
        
        modelContext.insert(q1)
        modelContext.insert(q2)
        modelContext.insert(q3)
            
        
        
        
//        let day1 = Calendar.current.date(byAdding: .day, value:-8, to: getDateOfYesterDay())!
//        let day2 = Calendar.current.date(byAdding: .day, value:-7, to: getDateOfYesterDay())!
//        let day3 = Calendar.current.date(byAdding: .day, value:-6, to: getDateOfYesterDay())!
//        let day4 = Calendar.current.date(byAdding: .day, value:-5, to: getDateOfYesterDay())!
//        let day5 = Calendar.current.date(byAdding: .day, value:-4, to: getDateOfYesterDay())!
//        let day6 = Calendar.current.date(byAdding: .day, value:-3, to: getDateOfYesterDay())!
//        let day7 = Calendar.current.date(byAdding: .day, value:-2, to: getDateOfYesterDay())!
//        let day8 = Calendar.current.date(byAdding: .day, value:-1, to: getDateOfYesterDay())!
//        let day9 = getDateOfYesterDay()
//        let day10 = getDateOfNow()
        
        let day1 = Calendar.current.date(byAdding: .day, value:-9, to: getDateOfYesterDay())!
        let day2 = Calendar.current.date(byAdding: .day, value:-8, to: getDateOfYesterDay())!
        let day3 = Calendar.current.date(byAdding: .day, value:-7, to: getDateOfYesterDay())!
        let day4 = Calendar.current.date(byAdding: .day, value:-6, to: getDateOfYesterDay())!
        let day5 = Calendar.current.date(byAdding: .day, value:-5, to: getDateOfYesterDay())!
        let day6 = Calendar.current.date(byAdding: .day, value:-4, to: getDateOfYesterDay())!
        let day7 = Calendar.current.date(byAdding: .day, value:-3, to: getDateOfYesterDay())!
        let day8 = Calendar.current.date(byAdding: .day, value:-2, to: getDateOfYesterDay())!
        let day9 = Calendar.current.date(byAdding: .day, value:-1, to: getDateOfYesterDay())!
        let day10 = getDateOfYesterDay()
        
        
        let initialDailyRecordSet = DailyRecordSet(start:day1)
        initialDailyRecordSet.dailyRecordThemeName = "stoneTower_0"
        initialDailyRecordSet.termGoals.append("앱 완성하기")
        initialDailyRecordSet.termGoals.append("2일이상 쉬지 않고 운동하기")
//        initialDailyRecordSet.dailyQuestions.append(recoraddic.defaultQuestions[0])
        modelContext.insert(initialDailyRecordSet)
        
        
        
        
        let dr1 = DailyRecord(date:day1)
        let dr1_qd1 = DailyQuest(
            questName: "Workout",
            data: 5,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 5
        )
        dr1.mood = 21
        dr1.questionValue1 = 3
        dr1.visualValue1 = 3
        dr1.visualValue2 = 0
        dr1.visualValue3 = 0
        dr1.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr1)
        dr1_qd1.dailyRecord = dr1
        modelContext.insert(dr1_qd1)
        
        
        
        
        
        let dr2 = DailyRecord(date: day2)
        let dr2_qd1 = DailyQuest(
            questName: "Create apps",
            data: 20,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 30
        )
        let dr2_qd2 = DailyQuest(
            questName: "Drink milk",
            data: 500,
            dataType: DataType.CUSTOM,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 500
        )
        dr2.dailyTextType = DailyTextType.diary
        dr2.dailyText = "ㅋㅋㅋㅋㅋ 호호호호호호홐ㅋㅋㅋ 홈ㅋㅋㅎㅇㅁㅇㄴㅁㅇㄴㄹㅁㄴㅇㅎㄴ앞ㅍㅁㅎㅁㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㄹㅇㄹㅁㄴㄹㅁㄴㅇㄹㅁㄴㅇㄹㄴㅁㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㄴㅁㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㄴㅁㅇㄹㅁㄴㅇㄹㅁㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹ"
        dr2.mood = 48 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr2.questionValue1 = 2
        dr2.visualValue1 = 3
        dr2.visualValue2 = 0
        dr2.visualValue3 = 0
        dr2.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr2)
        dr2_qd1.dailyRecord = dr2
        dr2_qd2.dailyRecord = dr2
        dr2_qd2.customDataTypeNotation = "ml"
        modelContext.insert(dr2_qd1)
        modelContext.insert(dr2_qd2)
        
        
        
        
        
        
        let dr3 = DailyRecord(date: day3)
        let dr3_qd1 = DailyQuest(
            questName: "Create apps",
            data: 20,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 30
        )
        let dr3_qd2 = DailyQuest(
            questName: "Workout",
            data: 30,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 30
        )
        dr3.dailyTextType = DailyTextType.inShort
        dr3.dailyText = "세번째 날의 일기"
        dr3.mood = 124 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr3.questionValue1 = 1
        dr3.visualValue1 = 3
        dr3.visualValue2 = 0
        dr3.visualValue3 = 0
        dr3.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr3)
        dr3_qd1.dailyRecord = dr3
        dr3_qd2.dailyRecord = dr3
        modelContext.insert(dr3_qd1)
        modelContext.insert(dr3_qd2)
        
        
        
        
        let dr4 = DailyRecord(date: day4)
        let dr4_qd1 = DailyQuest(
            questName: "Create apps",
            data: 24,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 18
        )
        let dr4_qd2 = DailyQuest(
            questName: "Workout",
            data: 36,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 36
        )
        dr4.dailyTextType = DailyTextType.inShort
        dr4.dailyText = "네번째 날의 일기"
        dr4.mood = 14 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr4.questionValue1 = 0
        dr4.visualValue1 = 3
        dr4.visualValue2 = 0
        dr4.visualValue3 = 0
        dr4.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr4)
        dr4_qd1.dailyRecord = dr4
        dr4_qd2.dailyRecord = dr4
        modelContext.insert(dr4_qd1)
        modelContext.insert(dr4_qd2)
        
        
        
        
        
        
        let dr5 = DailyRecord(date: day5)
        let dr5_qd1 = DailyQuest(
            questName: "Create apps",
            data: 33,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 30
        )
        let dr5_qd2 = DailyQuest(
            questName: "Workout",
            data: 5,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 5
        )
        dr5.dailyTextType = DailyTextType.inShort
        dr5.dailyText = "다섯번째 날의 일기"
        dr5.mood = 12 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr5.questionValue1 = -1
        dr5.visualValue1 = 3
        dr5.visualValue2 = 0
        dr5.visualValue3 = 0
        dr5.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr5)
        dr5_qd1.dailyRecord = dr5
        dr5_qd2.dailyRecord = dr5
        modelContext.insert(dr5_qd1)
        modelContext.insert(dr5_qd2)
        
        
        
        
        
        let dr6 = DailyRecord(date: day6)
        let dr6_qd1 = DailyQuest(
            questName: "Create apps",
            data: 24,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 18
        )
        let dr6_qd2 = DailyQuest(
            questName: "Workout",
            data: 15,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 15
        )
        dr6.dailyTextType = DailyTextType.inShort
        dr6.dailyText = "여섯번째 날의 일기"
        dr6.mood = 65 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr6.questionValue1 = -2
        dr6.visualValue1 = 3
        dr6.visualValue2 = 0
        dr6.visualValue3 = 0
        dr6.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr6)
        dr6_qd1.dailyRecord = dr6
        dr6_qd2.dailyRecord = dr6
        modelContext.insert(dr6_qd1)
        modelContext.insert(dr6_qd2)
        
        
        
        
        
        let dr7 = DailyRecord(date: day7)
        let dr7_qd1 = DailyQuest(
            questName: "Create apps",
            data: 24,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 18
        )
        let dr7_qd2 = DailyQuest(
            questName: "Workout",
            data: 36,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 36
        )
        dr7.dailyTextType = DailyTextType.inShort
        dr7.dailyText = "일곱번째 날의 일기"
        dr7.mood = 90 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr7.questionValue1 = -3
        dr7.visualValue1 = 3
        dr7.visualValue2 = 0
        dr7.visualValue3 = 0
        dr7.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr7)
        dr7_qd1.dailyRecord = dr7
        dr7_qd2.dailyRecord = dr7
        modelContext.insert(dr7_qd1)
        modelContext.insert(dr7_qd2)
        
        
        
        
        
        
        
        let dr8 = DailyRecord(date: day8)
        let dr8_qd1 = DailyQuest(
            questName: "Create apps",
            data: 24,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 18
        )
        let dr8_qd2 = DailyQuest(
            questName: "Workout",
            data: 36,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 36
        )
        dr8.dailyTextType = DailyTextType.inShort
        dr8.dailyText = "여덟번째 날의 일기"
        dr8.mood = 98 // 이게 있으면 yesterday not remained, 없으면 yesterday remained
        dr8.questionValue1 = -3
        dr8.visualValue1 = 3
        dr8.visualValue2 = 0
        dr8.visualValue3 = 0
        dr8.dailyRecordSet = initialDailyRecordSet
        modelContext.insert(dr8)
        dr8_qd1.dailyRecord = dr8
        dr8_qd2.dailyRecord = dr8
        modelContext.insert(dr8_qd1)
        modelContext.insert(dr8_qd2)
        
        
        
        
        let dr9 = DailyRecord(date: day9)
        let dr9_qd1 = DailyQuest(
            questName: "Create apps",
            data: 0,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
            dailyGoal: 18
        )
        let dr9_qd2 = DailyQuest(
            questName: "Workout",
            data: 20,
            dataType: DataType.HOUR,
            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
            dailyGoal: 36
        )
        dr9.dailyTextType = DailyTextType.inShort
        dr9.dailyText = "아홉번째 날의 일기"
        modelContext.insert(dr9)
        dr9_qd1.dailyRecord = dr9
        dr9_qd2.dailyRecord = dr9
        modelContext.insert(dr9_qd1)
        modelContext.insert(dr9_qd2)
        
        
        
        
        let dr10 = DailyRecord(date: day10)
//        let dr10_qd1 = DailyQuest(
//            questName: "Create apps",
//            data: 0,
//            dataType: DataType.HOUR,
//            defaultPurposes: Set([DefaultPurpose.wrl, DefaultPurpose.ach, DefaultPurpose.ftr]),
//            dailyGoal: 18
//        )
//        let dr10_qd2 = DailyQuest(
//            questName: "Workout",
//            data: 0,
//            dataType: DataType.HOUR,
//            defaultPurposes: Set([DefaultPurpose.hlt, DefaultPurpose.atr]),
//            dailyGoal: 36
//        )
//        dr10.dailyTextType = DiaryTopic.inShort
//        dr10.dailyText = "열번째 날의 일기"
        modelContext.insert(dr10)
//        dr10_qd1.dailyRecord = dr10
//        dr10_qd2.dailyRecord = dr10
//        modelContext.insert(dr10_qd1)
//        modelContext.insert(dr10_qd2)
        
        
        
        
        
        
        
        
        
        
        // adding QuestData
        let doneList: [DailyQuest] = [dr1_qd1, dr2_qd1, dr2_qd2, dr3_qd1, dr3_qd2, dr4_qd1, dr4_qd2, dr5_qd1, dr5_qd2, dr6_qd1, dr6_qd2, dr7_qd1, dr7_qd2, dr8_qd1, dr8_qd2]
        for questData in doneList {
            quests.first(where: {quest in quest.name == questData.questName})!.dailyData[questData.dailyRecord!.date] = questData.data
            
        }
        
        q1.updateTier()
        q2.updateTier()
        q3.updateTier()
        q1.updateMomentumLevel()
        q2.updateMomentumLevel()
        q3.updateMomentumLevel()


        
    }
}


