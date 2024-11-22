//
//  rawData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//


// dailyRecord의 두가지 역할: 다음날 해야하는 일 알려주기 / 그 날 한 일 기록하기
// dailyRecord는 이미 만들어져있어야 하고, 기댓값과 실제 수행값을 따로 저장해야 함...!!!!!!
// 새로 만들면 안됨. Record가 변화함에 따라 계속 달라져야 함. -> 추가/삭제/수정되는 quest와 그룹, 목표치 수정 -> daily record의
// 수치 기록 시 희미하게 뒤쪽에 실제 해야하는 양 보여주기
// dailyRecord 수정 중에는 UI상에서도 다른 작업 금지


// Each property should be unique,to prevent extra synchronization process. No need to store the same property in each classes.

import Foundation
import SwiftUI
import SwiftData


enum RecoraddicSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    

    static var models: [any PersistentModel.Type] = [DailyQuest.self, Todo.self, Todo_preset.self, DailyRecordSet.self, DailyRecord.self, Quest.self, Profile.self]
    
    // 여기에 데이터를 따로 담는 이유: quest가 삭제 되어도 일일기록은 남게 하기 위해
    @Model
    class DailyQuest: Hashable, Equatable, Identifiable {
        
        var id:UUID = UUID()
        var createdTime: Date = Date()
        var questName: String = ""
        var questSubName: String?
        var data: Int = 0
        var dataType: Int = 1
        var purposes: Set<String> = []
        var dailyGoal: Int? = nil
        var currentTier: Int = 0
        var notfTime: Date? = nil
        var stopwatchStart: Date? = nil
        var customDataTypeNotation: String?
        
        var dailyRecord: DailyRecord?
        
        
        init(createdTime: Date = .now, questName: String, data: Int, dataType: Int, defaultPurposes: Set<String>, customDataTypeNotation:String? = nil, dailyGoal: Int? = nil) {
            self.createdTime = createdTime
            self.questName = questName
            self.data = data
            self.dataType = dataType
            self.purposes = defaultPurposes
            self.customDataTypeNotation = customDataTypeNotation
            self.dailyGoal = dailyGoal
        }
        
        static func == (lhs: DailyQuest, rhs: DailyQuest) -> Bool {
            return lhs.createdTime == rhs.createdTime
            // Add any other properties that determine equality
        }
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(createdTime)
            hasher.combine(id)
            
            
            // Add any other properties that should be included in the hash
        }
        
        
    }
    
    @Model
    final class Todo: Hashable, Identifiable, Equatable {
        var id:UUID = UUID()
        var createdTime: Date = Date()
        var idx: Int = 0
        var content: String = ""
        var done: Bool = false
        var purposes: Set<String> = []
        var dailyRecord: DailyRecord?
        
        init(dailyRecord: DailyRecord, index: Int) {
            self.dailyRecord = dailyRecord
            self.idx = index
        }
        
        init() {
            self.idx = -1
        }
        
        init(content: String) {
            self.idx = -1
            self.content = content
        }
        
        static func == (lhs: Todo, rhs: Todo) -> Bool {
            return lhs.createdTime == rhs.createdTime && lhs.idx == rhs.idx && lhs.id == rhs.id
            // Add any other properties that determine equality
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(createdTime)
            hasher.combine(id)
            // Add any other properties that should be included in the hash
        }
        
    }
    
    @Model
    final class Todo_preset: Hashable, Identifiable, Equatable {
        var id:UUID = UUID()
        var createdTime: Date = Date()
        var content: String = ""
        var purposes: Set<String> = []
        
        init(content: String) {
            self.content = content
        }
        
        static func == (lhs: Todo_preset, rhs: Todo_preset) -> Bool {
            return lhs.createdTime == rhs.createdTime && lhs.content == rhs.content && lhs.id == rhs.id
            // Add any other properties that determine equality
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(createdTime)
            hasher.combine(content)
            // Add any other properties that should be included in the hash
        }
        
    }
    
    @Model
    final class DailyRecordSet: Equatable {
        
        var id: UUID = UUID()
        var createdTime: Date = Date()
        var start:Date = Date()
        var end:Date?
        var dailyRecordThemeName: String = "StoneTower"
        var backgroundThemeName: String = "stoneTowerBackground_1" //MARK: backgroundSetting 하는 view에서 dailyRecordThemeName에 따라서 선택할 수 있는 backgroundThemeName 제한
        var dailyRecordColorIndex: Int = 0
        var termGoals: [String] = []
        
        
        @Relationship(deleteRule:.cascade, inverse: \DailyRecord.dailyRecordSet)
        var dailyRecords:[DailyRecord]? = []
        
        init(start: Date) {
            self.start = start
        }
        
        
        static func == (lhs: DailyRecordSet, rhs: DailyRecordSet) -> Bool {
            return lhs.createdTime == rhs.createdTime
            // Add any other properties that determine equality
        }

        
        
        
    }
    
    @Model
    final class DailyRecord: Equatable, Identifiable, Hashable {
        
        var id: UUID = UUID()
        var createdTime: Date = Date()
        var date: Date?
        var dailyTextType: String? // diary or inShort
        var dailyText: String?
        var mood: Int = 0 // facial expression
        var recordedMinutes: Int = 0 // 기록 시간(색)
        var absence: Int = 0 // 기록 절단성
        var streak: Int = 0 // 기록 연속성 (아직 사용되고 있지 않음)
        var isFavorite: Bool = false
        var dailyRecordSet: DailyRecordSet?
        
        
        @Relationship(deleteRule:.cascade, inverse: \DailyQuest.dailyRecord)
        var dailyQuestList:[DailyQuest]? = []
        @Relationship(deleteRule:.cascade, inverse: \Todo.dailyRecord)
        var todoList:[Todo]? = []
        
        var recordedAmount: Int {(dailyQuestList?.filter({$0.data != 0}).count ?? 0) + (todoList?.filter({$0.done}).count ?? 0)} // 기록 갯수
        var hasContent: Bool { self.recordedAmount > 0 || (self.dailyText != nil && self.dailyText != "")}
        var singleElm_dailyQuestOrTodo: Bool { self.dailyText == nil && self.recordedAmount == 1 }
        var singleElm_diary: Bool { self.dailyText != nil && self.recordedAmount == 0 }
        var hasTodoOrDiary: Bool { todoList?.filter({$0.done}).count != 0 || self.dailyText != nil }
        
        init() {
            
        }
        
        init(date:Date) {
            print("dailyRecordinitialization start")
            self.date = date
            
            
            print("dailyRecordinitialized")
        }
        
        
        static func == (lhs: DailyRecord, rhs: DailyRecord) -> Bool {
            return lhs.createdTime == rhs.createdTime && lhs.id == rhs.id
            // Add any other properties that determine equality
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(createdTime)
            hasher.combine(id)
            // Add any other properties that should be included in the hash
        }
        
        
        
        
    }
    
    
    @Model
    class Quest: Equatable, Identifiable, Hashable {
        
        var createdTime: Date = Date()
        
        var name: String = ""
        var subName: String? //MARK: 아직 사용하지는 않지만, 일단 만들어둠. 쓸까 말까..
        var dataType: Int = 0
        var pastCumulatve: Int = 0
        var dailyData: [Date:Int] = [:]
        
        
        // 나중에 알림 설정 기능 추가
        var recentPurpose: Set<String> = []
        
        
        // Default settings
        var customDataTypeNotation: String?
        
        var memo: String = ""
        
        var representingData: Int = QuestRepresentingData.cumulativeData
        
        var isArchived:Bool = false
        var isHidden:Bool = false
        var inTrashCan: Bool = false
        
        var tier: Int = 0 // 0~40
        var momentumLevel: Int = 0
        
        
        // setting options
        init(name: String, dataType: Int) {
            self.name = name
            
            self.dataType = dataType
            
            
            
        }
        
        static func == (lhs: Quest, rhs: Quest) -> Bool {
            return lhs.createdTime == rhs.createdTime && lhs.name == rhs.name && lhs.dailyData == rhs.dailyData
            // Add any other properties that determine equality
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(createdTime)
            hasher.combine(name)
            hasher.combine(dailyData)
            // Add any other properties that should be included in the hash
        }
        
        
        
    }
    
    
    
    @Model
    class Profile {
        
        var createdTime: Date = Date()
        
        var name: String = ""
        var birthDay: Date = Date.now
        var email: String = ""
        
        
        var showHiddenQuests: Bool = false
        
        
        var memo: String = ""
        
        
        
        init() {
            
        }
    }
    


    
}
    



