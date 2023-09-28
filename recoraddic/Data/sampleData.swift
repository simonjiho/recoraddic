//
//  sampleData.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation
import SwiftData



extension Record {
    func createSample() {
        purposes.append(Purpose(name: "recoraddic 만들기"))
        purposes.append(Purpose(name: "운동"))
        purposes.append(Purpose(name: "식건강"))
        purposes.append(Purpose(name: "금전"))
        purposes.append(Purpose(name: "수면건강"))
        
        for purpose in purposes {
            purpose.belongingRecord = self
            
            if purpose.name == "recoraddic 만들기" {
                purpose.quests.append(
                    Quest(
                        name: "데이터 구조화",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.HOUR,
                        goalSetting: GoalSetting.setFinalGoal,
                        goalValue: 10.0
                    )
                )
                purpose.quests.append(
                    Quest(
                        name: "main UI 생성",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.HOUR,
                        goalSetting: GoalSetting.setFinalGoal,
                        goalValue: 8.0
                    )
                )
                purpose.quests.append(
                    Quest(
                        name: "네비게이션 바 생성",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.HOUR,
                        goalSetting: GoalSetting.setFinalGoal,
                        goalValue: 9.0
                    )
                )

            }
            
            else if purpose.name == "운동" {
                purpose.quests.append(
                    Quest(
                        name: "아침간단운동",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )
                purpose.quests.append(
                    Quest(
                        name: "밤에 운동 1.5시간",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )
            }
            
            else if purpose.name == "식건강" {
                purpose.quests.append(
                    Quest(
                        name: "영양제 2회",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )
                purpose.quests.append(
                    Quest(
                        name: "3000kcal",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0)
                )
            }
            
            else if purpose.name == "금전" {
                purpose.quests.append(
                    Quest(
                        name: "10000원 저금",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )

            }
            
            else if purpose.name == "수면건강" {
                purpose.quests.append(
                    Quest(
                        name: "자기 2시간 전 취식 no",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )
                purpose.quests.append(
                    Quest(
                        name: "안먹는 시간 10시간 이상 유지",
                        recordPeriod:RecordPeriod.everyDay,
                        dataType: DataType.OX,
                        goalSetting: GoalSetting.setDailyGoal,
                        goalValue: 1.0
                    )
                )

            }
            
        }
        for purpose in purposes {
            for quest in purpose.quests {
                for _ in 1...10 {
                    quest.addData(Float(Int.random(in: 0..<2)))
                }
            }
        }
        
    }
}



//actor SampleData {
//    
//    @MainActor
//    static var sampleContainer: ModelContainer = {
//        let s = DateComponents(year:2023, month:6, day:11)
//        let e = DateComponents(year:2023, month:10, day:11)
//        
//        let sampleStart:Date! = Calendar.current.date(from: s)
//        let sampleEnd:Date! = Calendar.current.date(from: e)
//        
//        let schema = Schema([Record.self])
//        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
//        
//        let container: ModelContainer = try! ModelContainer(for: schema, configurations: [configuration])
//        
//        var context_root: ModelContext = container.mainContext
//        context_root.insert(Record(name: "SampleRecord", start: sampleStart, end: sampleEnd))
//        
//        for model_record in context_root.insertedModelsArray {
//            print("yoho")
//            var context_record:ModelContext! = model_record.modelContext
//            context_root.insertedModelsArray[0].modelContext!.insert(Purpose(name: "recoraddic 만들기"))
//            context_record.insert(Purpose(name: "운동"))
//            context_record.insert(Purpose(name: "식건강"))
//            context_record.insert(Purpose(name: "금전"))
//            context_record.insert(Purpose(name: "수면건강"))
//            //                try! context_record.save()
//            var i = 0
//            for model_purpose in context_record.insertedModelsArray {
//                var context_purpose: ModelContext! = model_purpose.modelContext
//                if i == 0 {
//                    print("wow!!!!!")
//                    context_purpose.insert(Quest(name: "데이터 구조화", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 10.0))
//                    context_purpose.insert(Quest(name: "main UI 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 8.0))
//                    context_purpose.insert(Quest(name: "네비게이션 바 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 9.0))
//                }
//                else if i == 1 {
//                    context_purpose.insert(Quest(name: "아침간단운동", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    context_purpose.insert(Quest(name: "밤에 운동 1.5시간", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                }
//                else if i == 2 {
//                    context_purpose.insert(Quest(name: "영양제 2회", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    context_purpose.insert(Quest(name: "3000kcal", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                }
//                else if i == 3 {
//                    context_purpose.insert(Quest(name: "10000원 저금", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                }
//                else if i == 4 {
//                    print("quests for last purpose")
//                    context_purpose.insert(Quest(name: "자기 2시간 전 취식 no", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    context_purpose.insert(Quest(name: "안먹는 시간 10시간 이상 유지", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                }
//                i += 1
//            }
//        }
//        return container
//        
//        
//        //        return try! inMemoryContainer()
//    }()
//}

//    static var inMemoryContainer: () throws -> ModelContainer = {
//
//        let s = DateComponents(year:2023, month:6, day:11)
//        let e = DateComponents(year:2023, month:10, day:11)
//
//        let sampleStart:Date! = Calendar.current.date(from: s)
//        let sampleEnd:Date! = Calendar.current.date(from: e)
//
//        let schema = Schema([Record.self])
//        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
//        
//        let container: ModelContainer = try! ModelContainer(for: schema, configurations: [configuration])
//        
//        Task { @MainActor in
//            var context_root: ModelContext = container.mainContext
//            context_root.insert(Record(name: "SampleRecord", start: sampleStart, end: sampleEnd))
//            
//            for model_record in context_root.insertedModelsArray {
//                print("yoho")
//                var context_record:ModelContext! = model_record.modelContext
//                context_root.insertedModelsArray[0].modelContext!.insert(Purpose(name: "recoraddic 만들기"))
//                context_record.insert(Purpose(name: "운동"))
//                context_record.insert(Purpose(name: "식건강"))
//                context_record.insert(Purpose(name: "금전"))
//                context_record.insert(Purpose(name: "수면건강"))
////                try! context_record.save()
//                var i = 0
//                for model_purpose in context_record.insertedModelsArray {
//                    var context_purpose: ModelContext! = model_purpose.modelContext
//                    if i == 0 {
//                        print("wow!!!!!")
//                        context_purpose.insert(Quest(name: "데이터 구조화", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 10.0))
//                        context_purpose.insert(Quest(name: "main UI 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 8.0))
//                        context_purpose.insert(Quest(name: "네비게이션 바 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 9.0))
//                    }
//                    else if i == 1 {
//                        context_purpose.insert(Quest(name: "아침간단운동", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                        context_purpose.insert(Quest(name: "밤에 운동 1.5시간", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    }
//                    else if i == 2 {
//                        context_purpose.insert(Quest(name: "영양제 2회", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                        context_purpose.insert(Quest(name: "3000kcal", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    }
//                    else if i == 3 {
//                        context_purpose.insert(Quest(name: "10000원 저금", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    }
//                    else if i == 4 {
//                        context_purpose.insert(Quest(name: "자기 2시간 전 취식 no", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                        context_purpose.insert(Quest(name: "안먹는 시간 10시간 이상 유지", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0))
//                    }
//                    i += 1
//                }
//            }
//
//            
//        }
//        
//        
////        Task { @MainActor in
////            sampleData.forEach {
////                container.mainContext.insert($0)
////                container.mainContext.insertedModelsArray
////            }
////        }
//        return container
//    }
//}
//


//extension Record {
//
//    // only add on sample record class
//    
//    static var sampleRecord: Record {
//        do {
//            
//            let sampleQuests1 = [
//                Quest(name: "데이터 구조화", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 10.0),
//                Quest(name: "main UI 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 8.0),
//                Quest(name: "네비게이션 바 생성", recordPeriod:RecordPeriod.everyDay , dataType: DataType.HOUR, goalSetting: GoalSetting.setFinalGoal, goalValue: 9.0)
//            ]
//            let sampleQuests2 = [
//                Quest(name: "아침간단운동", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0),
//                Quest(name: "밤에 운동 1.5시간", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0)
//            ]
//            let sampleQuests3 = [
//                Quest(name: "영양제 2회", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0),
//                Quest(name: "3000kcal", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0)
//
//            ]
//
//            let sampleQuests4 = [
//                Quest(name: "10000원 저금", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0)
//            ]
//
//            let sampleQuests5 = [
//                Quest(name: "자기 2시간 전 취식 no", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0),
//                Quest(name: "안먹는 시간 10시간 이상 유지", recordPeriod:RecordPeriod.everyDay , dataType: DataType.OX, goalSetting: GoalSetting.setDailyGoal, goalValue: 1.0)
//
//            ]
//
//            let samplePurposes = [
//                Purpose(name:"recoraddic 만들기", quests:sampleQuests1),
//                Purpose(name: "운동", quests:sampleQuests2),
//                Purpose(name: "식건강", quests:sampleQuests3),
//                Purpose(name: "금전", quests:sampleQuests4),
//                Purpose(name: "수면건강", quests:sampleQuests5)
//            ]
//            
//            for samplePurpose in samplePurposes {
////                sampleQuests.belongingRecord = samplePurposes
//                for sampleQuest in samplePurpose.quests {
//                    sampleQuest.belongingPurpose = samplePurpose
//                    sampleQuest.questOption.belongingQuest = sampleQuest
//                }
//            }
//
//            let s = DateComponents(year:2023, month:6, day:11)
//            let e = DateComponents(year:2023, month:10, day:11)
//
//            let sampleStart:Date! = Calendar.current.date(from: s)
//            let sampleEnd:Date! = Calendar.current.date(from: e)
//
//            var record = Record(name:"예시기록", start: sampleStart, end: sampleEnd, purposes: samplePurposes)
//            for purpose in record.purposes {
//                for goal in purpose.quests {
//                    for _ in 1...10 {
//                        goal.addData(Float(Int.random(in: 0..<2)))
//                    }
//                }
//            }
//            return record
//        }
//    }
//    
//
//}
    
    


    




//let sampleRecord:Record = {
//    print("there's sample record!")
//    let record = Record(name:"예시기록", start: sampleStart, end: sampleEnd, purposes: samplePurposes)
//    for purpose in record.purposes {
//        for goal in purpose.quests {
//            for _ in 1...10 {
//                goal.addData(Float(Int.random(in: 0..<2)))
//            }
//        }
//    }
//    return record
//    
//} ()



