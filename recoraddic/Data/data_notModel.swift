//
//  data_notModel.swift
//  recoraddic
//
//  Created by 김지호 on 9/28/23.
//

import Foundation


@Observable
class DailyRecord_notModel {
    
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
    
    var dailyAccomplishment: DailyAccomplishment_notModel?
    
    var isDataLoaded: Bool = false
    
    //    ImageData is not available -> Store it seperately
    //    var picture: Image = Image(systemName: "rectangle.fill.badge.xmark")
    var belongingRecord: Record?
    
    
    init(date:Date) {
        print("dailRecordinitialization start")
        self.date = date
        
        self.dailyAccomplishment = DailyAccomplishment_notModel(date: self.date)
        print(dailyAccomplishment == nil)

        print("dailyRecordinitialized")
    }
    
    
    func getData(record: Record) -> Void {
        

        
        self.dailyAccomplishment!.getData(record)
        isDataLoaded = true
        // 필요한 것만 쏙쏙 빼오기

        
    }
    
    func fetchData() -> Void {
        // update each quest
    }
    
}


@Observable
class DailyAccomplishment_notModel:Identifiable {
    var date: Date
    var purposeNames: [String] = []
    var questNames: [String:[String]] = [:]
    var questDailyGoals: [String:Float] = [:]
    var questIsCheckingDate: [String:Bool] = [:]
    var questDataTypes: [String:Int] = [:]
    var questInputDatas: [String:Int] = [:]
    
    
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
