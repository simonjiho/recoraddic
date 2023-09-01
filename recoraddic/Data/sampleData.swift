//
//  sampleData.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation


//class SampleData: ObservableObject {
//    var records: [Record]
//    
//    init() {
//        records = [SampleRecord(name:"예시기록", start: sampleStart, end: sampleEnd, groups: sampleGroups)]
//    }
//    
//}

class SampleData: Data {
    
    override init() {
        super.init()
        records = SampleRecords()
    }
    
}



class SampleRecords: Records {
    override init() {
        super.init()
        inventory = [SampleRecord(name:"예시기록", start: sampleStart, end: sampleEnd, groups: sampleGroups)]
    }
}


class SampleRecord: Record {
    // only add on sample record class
    
    override init(name in0: String, start in1: Date, end in2: Date, groups in3: Array<Group>) {
        
        super.init(name: in0, start: in1, end: in2, groups: in3)
        
        for group in groups {
            for goal in group.goals {
                for _ in 1...10 {
                    goal.addData(Float(Int.random(in: 0..<2)))
                }
            }
        }
        
        
        
    }
            
}



    


let sampleGoals1 = [
    Goal(name:"데이터 구조화", option: Option(.everyDay, .HOUR, .setFinalGoal, 10.0)),
    Goal(name:"main UI 생성", option: Option(.everyDay, .HOUR, .setFinalGoal, 8.0)),
    Goal(name:"네비게이션 바 생성", option: Option(.everyDay, .HOUR, .setFinalGoal, 9.0))
]
let sampleGoals2 = [
    Goal(name:"아침간단운동",option: Option(.everyDay, .OX, .setDailyGoal, 1.0)),
    Goal(name:"밤에 운동 1.5시간",option: Option(.everyDay, .OX, .setDailyGoal, 1.0)),
]
let sampleGoals3 = [
    Goal(name:"영양제 2회",option: Option(.everyDay, .OX, .setDailyGoal, 1.0)),
    Goal(name:"3000kcal",option: Option(.everyDay, .OX, .setDailyGoal, 1.0))
]
let sampleGoals4 = [
    Goal(name:"10000원 저금", option: Option(.everyDay, .OX, .setDailyGoal, 1.0))
]
let sampleGoals5 = [
    Goal(name:"자기 2시간 전 취식 no", option: Option(.everyDay, .OX, .setDailyGoal, 1.0)),
    Goal(name:"안먹는 시간 10시간 이상 유지", option: Option(.everyDay, .OX, .setDailyGoal, 1.0))
]


let sampleGroups = [
    Group(name:"recoraddic 만들기", goals:sampleGoals1),
    Group(name: "운동", goals:sampleGoals2),
    Group(name: "식건강", goals:sampleGoals3),
    Group(name: "금전", goals:sampleGoals4),
    Group(name: "수면건강", goals:sampleGoals5)
]

let s = DateComponents(year:2023, month:6, day:11)
let e = DateComponents(year:2023, month:10, day:11)

let sampleStart:Date! = Calendar.current.date(from: s)
let sampleEnd:Date! = Calendar.current.date(from: e)





