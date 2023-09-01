//
//  rawData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//

// 2023/08/12 : still need to activate more options(now, only .OX

import Foundation
// use @observable after update to swift 5.9

enum HowFrequent {
    case everyDay
    case onceInNdays
    case chooseInCalender
}

enum DataType {
    case OX
    case REP
    case HOUR
    case MIN
    case MONEY
}

enum GoalType {
    case setFinalGoal
    case setDailyGoal
}



class Data: ObservableObject {
    @Published var records: Records!
    
    init(records: Records) {
        self.records = records
    }
    
    
    init() {
    }
    
    
}


class Records: ObservableObject {
    @Published var inventory: [Record]!
    
    init(inventory: [Record]) {
        self.inventory = inventory
    }
    
    
    // for sampledata
    init() {
    }
    
    
}



class Record: ObservableObject {
    var name: String
    var start: Date
    var end: Date
    var groups: Array<Group>
    var metaData: RecordMetaData?
    
    
    // variables below here should go to option of record
    var lock: Bool = true
    var is_current_record : Bool = false
    var adjustedModel: String = "default"

    
    init(name in0: String, start in1 : Date, end in2: Date, groups in3: Array<Group>) {
        name = in0
        start = in1
        end = in2
        groups = in3
        
        
        for group in groups {
            group.connectRecord(self)
        }
        
        // 위의 과정과 합쳐놓으면 thread에서 문제 생김(connect 되기전에 start와 end를 넘기려고 함)
        for group in groups {
            for goal in group.goals {
                goal.getStartEndDate()
            }
        }
        

    }
    
    

}

// 나중에는 상위 그룹으로 한번 더 묶을 수 있게 만들기

class Group {
    var name: String
    var goals: Array<Goal>
    var metaData: GroupMetaData?
    var belongingRecord: Record!
    
    
    // variables below here should go to option of group
    var lock: Bool = true
    var color: Int?
    

    init(name in1: String, goals in2: Array<Goal>) {
        name = in1
        goals = in2
        
        for goal in goals {
            goal.connectGroup(self)
        }

    }
    
    
    func connectRecord(_ input:Record) -> Void {
        belongingRecord = input
    }
    
}



// 커스텀 기능들 제공 (ex: 매일/며칠/특정일(캘린더 통해 선택) 마다 몇 시간/분/회/OX/money)
// 설정 주기보다 더 자주 한 날은 더 큰 버닝 게이지 제공
class Goal {
    var name: String
    var data: [Float] = []
    var option: Option
    var checkDate: [Date] = []
    
    
    var metaData: GoalMetaData!
    var belongingGroup: Group!
    
    // setting options
    init(name in1: String, option in2: Option) {
        name = in1
        option = in2
        option.setBelongingGoal(self)
        metaData = GoalMetaData(input: self)
        
    }
    

    
    
    func addData(_ input: Float) -> Void {
        data.append(input)
        metaData.update()
    }
    
    func connectGroup(_ input:Group) -> Void {
        belongingGroup = input
    }
    
    
    // activated after connected to record.
    func getStartEndDate() -> Void {
        
        option.updateDateRelatedData()
        createCheckDate()
        option.calculateFinalGoal()

    }
    
    
    func createCheckDate() {
        
        if option.howFrequent == .everyDay {
            var date = option.start!
            while date <= option.end! {
                checkDate.append(date)
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }
        }
        
        
    }
    

    
    

}

class Option {
    
    
    var belongingGoal: Goal!
    
    var lock: Bool = true
    
    var howFrequent: HowFrequent
    var dataType: DataType
    var goalType: GoalType
    var goalValue: Float
    // if .setFinalGoal -> finalGoal = goalValue
    // if .setDailyGoal -> dailyGoal = goalValue
    
    
    var start: Date!
    var end: Date!
    var termLength: Int!
    
    

    
    var dailyGoal: Float? // if .setFinalGoal -> dailyGoal remains as nil
    var finalGoal: Float!
    
    
    init(_ option1: HowFrequent, _ option2: DataType, _ option3: GoalType, _ option4: Float) {
        howFrequent = option1
        dataType = option2
        goalType = option3
        goalValue = option4
        
        if dataType == .OX && goalType == .setDailyGoal{
            dailyGoal = goalValue
            
        }
        else if goalType == .setFinalGoal {
            finalGoal = goalValue
            // dailyGoal stays as nil
        }
        else {
            
        }
    }

    
    func setBelongingGoal(_ input: Goal) -> Void {
        belongingGoal = input
        
        return
    }
    
    
    // activated after connected to record.
    func updateDateRelatedData() -> Void {
        start = belongingGoal.belongingGroup.belongingRecord.start
        end = belongingGoal.belongingGroup.belongingRecord.start
        termLength = Calendar.current.dateComponents([.day], from: start, to: end).day
        
        return
    }
    
    
    // only if .setDailyGoal
    func calculateFinalGoal() -> Void {
        if (goalType == .setFinalGoal) {return}
        
        finalGoal = Float(belongingGoal.checkDate.count) * dailyGoal!
        return
    }
    
    func changeLockState() {
        lock.toggle()
        print(lock)
//        if lock {lock = false}
//        else {lock = true}
    }

    // calculate goals automathically...

    
}



    
    



struct objective_rowdata {}
struct objective_metadata {}
struct group_metadata {}



