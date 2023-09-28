//
//  rawData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//

// 2023/08/12 : still need to activate more options(now, only .OX)


// dailyRecord의 두가지 역할: 다음날 해야하는 일 알려주기 / 그 날 한 일 기록하기
// dailyRecord는 이미 만들어져있어야 하고, 기댓값과 실제 수행값을 따로 저장해야 함...!!!!!!
// 새로 만들면 안됨. Record가 변화함에 따라 계속 달라져야 함. -> 추가/삭제/수정되는 quest와 그룹, 목표치 수정 -> daily record의
// 수치 기록 시 희미하게 뒤쪽에 실제 해야하는 양 보여주기
// dailyRecord 수정 중에는 UI상에서도 다른 작업 금지


// Each property should be unique,to prevent extra synchronization process. No need to store the same property in each classes.


import Foundation
import SwiftUI
import SwiftData
// use @observable after update to swift 5.9

// didn't use enums for HowFrequent, DataType, GoalType to use SwiftData



// ------------ Custom enum behaviored classes for @Model --------------- //

@Model
final class RecordPeriod {
    static let everyDay = 0
    static let onceInNdays = 1
    static let chooseInCalender = 2
    
    init() {
    }
}


@Model
final class DataType {
    static let OX = 0
    static let REP = 1
    static let HOUR = 2
    static let MIN = 3
    static let MONEY = 4
    
    init() {
    }
}


@Model
final class GoalSetting {
    static let setFinalGoal = 0
    static let setDailyGoal = 1
    
    init() {
    }
    

    
}

//@Model
//final class DailyPlan {
//    
//    var date: Date
//    
//    var plans: [String:[Int]]
//    
//    
//    init () {
//        
//    }
//}
@Model
final class DailyAccomplishment {
    var date: Date
    var purposeNames: [String] = []
    var questNames: [String:[String]] = [:]
    var questDailyGoals: [String:Float] = [:]
    var questIsCheckingDate: [String:Bool] = [:]
    var questDataTypes: [String:Int] = [:]
    
//    var belongingDailyRecord: DailyRecord?
    
    init(date:Date) {
        self.date = date

    }
    
    func getData(_ record:Record) -> Void {
        
        
        for purpose in record.purposes {
            purposeNames.append(purpose.name)
            questNames[purpose.name] = []

            for quest in purpose.quests {
                questNames[purpose.name]?.append(quest.name)
                questDailyGoals[quest.name] = quest.questOption.dailyGoal
                questIsCheckingDate[quest.name] = quest.checkDate.contains(.now)
                questDataTypes[quest.name] = quest.questOption.dataType
            }
            
        }

    }
}


@Model
final class DailyRecord {
    
    // 각 퀘스트별 이름과 수치
    // 기분
    // 효율성
    // 멘트 및 기억하고 싶은 내용 및 하루 소감
    // UI data
    
    var date: Date
    var mood: String = ""
    var achievementRate: Int = 0
    var efficiency: Int = 0
    var comment: String = ""
    
    @Relationship(deleteRule:.cascade)
    var dailyAccomplishment: DailyAccomplishment?
    
    var isDataLoaded: Bool = false
    
    //    ImageData is not available -> Store it seperately
    //    var picture: Image = Image(systemName: "rectangle.fill.badge.xmark")
    var belongingRecord: Record?
    
    
    init(date:Date) {
        print("dailRecordinitialization start")
        self.date = date
        
//        self.dailyAccomplishment = DailyAccomplishment(date: self.date)
        print(dailyAccomplishment == nil)
        print("dailyRecordinitialized")
    }
    
    

    
    func fetchData() -> Void {
        // update each quest
    }
    
}





// ----------------------------------------------------------------- //





@Model
class Record {
    
    var name: String
    
    var start: Date
    var end: Date
    
    @Relationship(deleteRule:.cascade, inverse: \Purpose.belongingRecord)
    var purposes: [Purpose] = [Purpose]()
    
    var lock: Bool = true
    var is_current_record : Bool = false
    

    
    
    
    // variables below here should go to option of record..?

    var adjustedModel: String = "default"
    
//    var uiData_RecordStone: UIData_RecordStone!
//    var uiData_CurrentRecord: UIData_CurrentRecord!
//    var uiData_DailyStones: UIData_DailyStones!
    
//    var achievements
//    var metaData: RecordMetaData!
//    var metadata
//    var statistics
    
    @Relationship(deleteRule:.cascade, inverse: \DailyRecord.belongingRecord)
    var dailyRecords: [DailyRecord] = [DailyRecord]()

    
    init(name: String, start: Date, end: Date) {
//    init(name in0: String, start in1 : Date, end in2: Date) {

        self.name = name
        self.start = start
        self.end = end
        
        
//        for Purpose in Purposes {
//            Purpose.connectRecord(self)
//        }
        
//         위의 과정과 합쳐놓으면 thread에서 문제 생김(connect 되기전에 start와 end를 넘기려고 함)

//        

    }
    
    

}

// 나중에는 상위 그룹으로 한번 더 묶을 수 있게 만들기

@Model
class Purpose {
    
    @Attribute(.unique)
    var name: String
    
    
    @Relationship(deleteRule:.cascade, inverse:\Quest.belongingPurpose)
    var quests: [Quest] = [Quest]()
//    var metaData: PurposeMetaData?
    var belongingRecord: Record?
    
    
    // variables below here should go to option of Purpose
    var lock: Bool = true
    var color: Int?
    

    init(name in1: String) {
        name = in1
        

    }
    

    
}



// 커스텀 기능들 제공 (ex: 매일/며칠/특정일(캘린더 통해 선택) 마다 몇 시간/분/회/OX/money)
// 설정 주기보다 더 자주 한 날은 더 큰 버닝 게이지 제공
@Model
class Quest {
    
    @Attribute(.unique)
    var name: String
    
    var data: [Float] = []
    
    
    @Relationship(deleteRule:.cascade,inverse: \QuestOption.belongingQuest)
    var questOption: QuestOption
    
    
    var checkDate: [Date] = []
    
    @Relationship(deleteRule:.cascade)
    var metaData: QuestMetaData?
    
    var belongingPurpose: Purpose?
    
    // setting options
    init(name in1: String, recordPeriod: Int, dataType: Int, goalSetting:Int, goalValue: Float) {
        name = in1
        questOption = QuestOption(recordPeriod, dataType, goalSetting, goalValue)
        metaData = QuestMetaData(input: self)
        
    }
    


    
    func addData(_ input: Float) -> Void {
        data.append(input)
        metaData!.update()
    }
    

    
    // activated after connected to record.
    func getStartEndDate() -> Void {
        
//       questOption.updateDateRelatedData()
        createCheckDate()
        questOption.calculateFinalGoal()

    }
    
    
    func createCheckDate() {
        
        if questOption.recordPeriod == RecordPeriod.everyDay {
            var start = self.belongingPurpose!.belongingRecord!.start
            let end = self.belongingPurpose!.belongingRecord!.start
            while start <= end {
                checkDate.append(start)
                start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            }
        }
        
//        Schema.PropertyMetadata(name: <#T##String#>, keypath: <#T##AnyKeyPath#>, defaultValue: <#T##Any?#>)
        
    }
    

    
    

}


@Model
class QuestOption {
    
    var lock: Bool = true
    
    
    
    // Default settings
    var recordPeriod: Int = 0
    var dataType: Int = 0
    var goalSetting: Int = 0
    var goalValue: Float = 0.0
    // if .setFinalGoal -> finalGoal = goalValue
    // if .setDailyGoal -> dailyGoal = goalValue

    
    var dailyGoal: Float = 0.0 // if .setFinalGoal -> dailyGoal remains as nil
    var finalGoal: Float = 10.0
    
    // 장소 추가
    
    
    var belongingQuest: Quest?
    

    
    
    init(_ recordPeriod: Int, _ dataType: Int, _ goalSetting: Int, _ goalValue: Float) {
        self.recordPeriod = recordPeriod
        self.dataType = dataType
        self.goalSetting = goalSetting
        self.goalValue = goalValue
        
        if dataType == DataType.OX && goalSetting == GoalSetting.setDailyGoal{
            dailyGoal = goalValue
            
        }
        else if goalSetting == GoalSetting.setFinalGoal {
            finalGoal = goalValue
            // dailyGoal stays as nil
        }
        else {
            
        }
    }

    
    
    // only if .setDailyGoal
    func calculateFinalGoal() -> Void {
        if (goalSetting == GoalSetting.setFinalGoal) {return}
        
        finalGoal = Float(belongingQuest!.checkDate.count) * dailyGoal
        return
    }
    
    func changeLockState() {
        lock.toggle()
        print(lock)
//        if lock {lock = false}
//        else {lock = true}
    }
    
    func calculateDailyGoal() -> Void {
        if (goalSetting == GoalSetting.setDailyGoal) {return}
        
        dailyGoal = finalGoal / Float(belongingQuest!.checkDate.count)
        
        return
    }
    // calculate goals automathically...

    
}



    

    



struct objective_rowdata {}
struct objective_metadata {}
struct Purpose_metadata {}



