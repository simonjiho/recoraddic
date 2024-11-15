//
//  rawData_ver2.swift
//  recoraddic
//
//  Created by 김지호 on 11/19/24.
//

import Foundation
import SwiftUI
import SwiftData

/*
 변경점
    1. dailyQuest에서 quest 직접 참조
    2. quest에 id 추가 (되도록 이름보다 id를 참조하여 관련 탐색 실행) (id는 name, dataType, Date() 를 참조하여 생성)
    3. quest에 deletedTime 추가
    
 migration 할 때 실행사항
    1. dailyQuest와 quest 연결
    2. quest에 id 부여 (defaultvalue는 중복 id 만듦)
 
 
*/



enum RecoraddicSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 7)
    
    static var models: [any PersistentModel.Type] {
        [DailyQuest.self, Todo.self, Todo_preset.self, DailyRecordSet.self, DailyRecord.self, Quest.self, Profile.self]
    }
    
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
        var quest: Quest?
        
        
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
        
        func dataForDataRepresentation() -> (Int, Int, String?) {
            return (data, dataType, customDataTypeNotation)
        }
        
        func getName() -> String {
            if let subName = self.questSubName {
                return subName
            } else {
                return self.questName
            }
        }
        
        //    func modifyData(_ newData: Int) -> Void {
        //        if self.data != 0 && newData == 0 {
        //
        //        }
        //        else if self.data == 0 && newData != 0 {
        //
        //        }
        //
        //
        //        self.data = newData
        //    }
        //
        //    func modifyDailyText(_ newDailyText: String) -> Void {
        //    }
        
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
            //        hasher.combine(idx)
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
        
        
        func getIntegratedDailyRecordColor(colorScheme:ColorScheme) -> Color {
            if self.dailyRecordThemeName == "StoneTower" {
                return TowerView.getIntegratedDailyRecordColor(
                    index: dailyRecordColorIndex,
                    colorScheme: colorScheme
                )
            }
            else {
                return TowerView.getIntegratedDailyRecordColor(
                    index: dailyRecordColorIndex,
                    colorScheme: colorScheme
                )
            }
        }
        
        
        
        func getTerm_string() -> String {
            if self.end != nil {
                return "\(yymmddFormatOf(self.start)) ~ \(yymmddFormatOf(self.end!))"
            }
            else {
                return "\(yymmddFormatOf(self.start)) ~ "
            }
        }
        
        
        
        func updateDailyRecordsMomentum() -> Void { // modify absence and streak
            if let dailyRecords = self.dailyRecords {
                let dates = dailyRecords.filter({$0.hasContent}).compactMap({$0.date}).sorted()
                for dailyRecord in dailyRecords {
                    if let date = dailyRecord.date {
                        let dates_beforeDate:[Date] = dates.filter({$0 < date})
                        if let nearestDate:Date = dates_beforeDate.last {
                            dailyRecord.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
                            if dailyRecord.absence == 0 {
                                dailyRecord.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
                            } else {
                                dailyRecord.streak = 0
                            }
                        } else { // first dailyRecord in drs
                            dailyRecord.absence = 0
                            dailyRecord.streak = 0
                        }
                    }
                }
            }
        }
        
        func getLocalStart() -> Date {
            let date = self.start
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
            // Extract year, month, and day components in UTC
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            // Set calendar to local time zone
            calendar.timeZone = TimeZone.current
            // Create a date from the components, now interpreted in the local time zone
            return calendar.date(from: dateComponents) ?? date
            
            
        }
        func getLocalEnd() -> Date? {
            if let date = self.end {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
                // Extract year, month, and day components in UTC
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                // Set calendar to local time zone
                calendar.timeZone = TimeZone.current
                // Create a date from the components, now interpreted in the local time zone
                return calendar.date(from: dateComponents) ?? date
            } else {
                return nil
            }
            
        }
        
        
        func visibleDailyRecords(hiddenQuestNames:Set<String>, showHiddenQuests:Bool) -> [DailyRecord] {
            let dailyRecords_filtered = self.dailyRecords!
                .filter({$0.hasContent && $0.date != nil})
                .filter({($0.getLocalDate() ?? getStartDateOfNow()) < .now })
            if showHiddenQuests {
                return dailyRecords_filtered
                    .sorted(by: {
                        if let date0 = $0.date, let date1 = $1.date {
                            return date0 > date1  // Sorts by date in descending order if both dates are non-nil
                        } else if $0.date == nil {
                            return false  // Places items with nil date after those with a non-nil date
                        } else {
                            return true  // Ensures $0 with a date is before $1 with nil
                        }
                    })
            } else {
                return dailyRecords_filtered
                    .filter({
                        $0.hasTodoOrDiary ||
                        !Set($0.dailyQuestList!.filter({$0.data != 0}).map{$0.questName}).subtracting(hiddenQuestNames).isEmpty
                    })
                    .sorted(by:{
                        if let date0 = $0.date, let date1 = $1.date {
                            return date0 > date1  // Sorts by date in descending order if both dates are non-nil
                        } else if $0.date == nil {
                            return false  // Places items with nil date after those with a non-nil date
                        } else {
                            return true  // Ensures $0 with a date is before $1 with nil
                        }
                    }
                    )
            }
        }
        
        
        //    func increaseStreak(from date:Date) {
        //        if let dailyRecords = self.dailyRecords {
        //            for dailyRecord in dailyRecords {
        //
        //
        //            }
        //        }
        //
        //        if let dates = dailyRecordSet.dailyRecords?.filter({$0.recordedAmount > 0}).map({ $0.date }) {
        //            if let date = self.date {
        //                let dates_beforeDate:[Date] = dates.compactMap({$0}).filter({$0 < date})
        //                if let nearestDate:Date = dates_beforeDate.sorted().last {
        //                    self.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
        //                    if self.absence == 0 {
        //                        self.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
        //                    } else {
        //                        self.streak = 0
        //                    }
        //                }
        //            }
        //        }
        //    }
        //    func decreaseStreak(from:Date) {
        //
        //    }
        
    }
    
    @Model
    final class DailyRecord: Equatable, Identifiable, Hashable {
        //final class DailyRecord: Equatable {
        
        var id: UUID = UUID()
        var createdTime: Date = Date()
        //    @Attribute(.unique)
        var date: Date?
        //    var diaryImage: Data?
        var dailyTextType: String? // diary or inShort
        var dailyText: String?
        var mood: Int = 0 // facial expression
        var recordedMinutes: Int = 0 // 기록 시간(색)
        var absence: Int = 0 // 기록 절단성
        var streak: Int = 0 // 기록 연속성 (아직 사용되고 있지 않음)
        var isFavorite: Bool = false
        var dailyRecordSet: DailyRecordSet?
        
        //    var dailyRecordThemeNum: Int? // stone + background
        //    var dailyRecordStoneActionNum: Int?
        //    var dailyRecordStoneAccesseryNum: Int?
        
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
            //        hasher.combine(date)
            // Add any other properties that should be included in the hash
        }
        
        
        
        
        func updateRecordedMinutes() -> Void {
            if let dailyQuestList = self.dailyQuestList {
                self.recordedMinutes = sumIntArray(dailyQuestList.filter({dataTypeFrom($0.dataType) == DataType.hour}).map({$0.data}))
            }
        }
        
        func updateExternalFactors() -> Void {
            if let dailyRecordSet = self.dailyRecordSet {
                if let dates = dailyRecordSet.dailyRecords?.filter({$0.hasContent}).map({ $0.date }) {
                    if let date = self.date {
                        let dates_beforeDate:[Date] = dates.compactMap({$0}).filter({$0 < date})
                        if let nearestDate:Date = dates_beforeDate.sorted().last {
                            self.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
                            if self.absence == 0 {
                                self.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
                            } else {
                                self.streak = 0
                            }
                        }
                    }
                }
            }
        }
        
        func getLocalDate() -> Date? {
            if let date = self.date {
                //            print("convert \(date) into")
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
                // Extract year, month, and day components in UTC
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                // Set calendar to local time zone
                calendar.timeZone = TimeZone.current
                // Create a date from the components, now interpreted in the local time zone
                //            print("\(calendar.date(from: dateComponents))")
                
                return calendar.date(from: dateComponents) ?? date
            } else {
                
                return nil
            }
            
        }
        
        
    }
    
    
    @Model
    class Quest: Equatable, Identifiable, Hashable {
        
        
        var createdTime: Date = Date()
        var deletedTime: Date? = nil
        
        var id: UUID = UUID()
        var name: String = ""
        var subName: String? //MARK: 아직 사용하지는 않지만, 일단 만들어둠. 쓸까 말까..
        var dataType: Int = 0
        var pastCumulatve: Int = 0
        var dailyData: [Date:Int] = [:]
        
        //    var recentData: Int = 0 // DailyQuest 새로 생성 및 수정 시 새로이 수정
        //    var freeSetDatas: [Int] = []
        
        // 나중에 알림 설정 기능 추가
        var recentPurpose: Set<String> = []
        
        
        // Default settings
        var customDataTypeNotation: String?
        //    var dailyGoal: Int = 0
        
        //    var comments: [String] = []  // 나중을 위해 일단 만들어둠.
        var memo: String = ""
        
        var representingData: Int = QuestRepresentingData.cumulativeData
        
        var isArchived:Bool = false
        var isHidden:Bool = false // not used yet.
        var inTrashCan: Bool = false
        
        var tier: Int = 0 // 0~40
        var momentumLevel: Int = 0
        
        
        //        @Relationship(deleteRule:.cascade, inverse: \DailyQuest.quest)
        @Relationship(inverse: \DailyQuest.quest)
        var dailyQuests:[DailyQuest]? = []
        
        
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
        
        
        
        func isVisible() -> Bool {
            return !isArchived && !isHidden && !inTrashCan
        }
        
        
        
        func getName() -> String {
            if let subName = self.subName {
                return subName
            } else {
                return self.name
            }
        }
        
        func getCumulative(from start:Date, to end:Date?) -> Int {
            return self.dailyData.filter({$0.key >= start && $0.key <= (end ?? $0.key)}).values.reduce(0,+)
        }
        func getCount(from start:Date, to end:Date?) -> Int {
            return self.dailyData.keys.filter({$0 >= start && $0 <= (end ?? $0) }).count
        }
        
        
    }
    
    
    
    @Model
    class Profile {
        
        var createdTime: Date = Date()
        
        var name: String = ""
        var birthDay: Date = Date.now
        var email: String = ""
        
        // need other cumulative times also..
        //    var cumulativeRecordHours: Int = 0  // will be used later..
        //    var numberOfDailyRecords: Int = 0
        //    var cumulativeRecord
        // unit of sleepingTime: 1 -> 5min, 12 -> 1hour
        //    var sleepingTime: Int = 0 // deprecated...
        
        var showHiddenQuests: Bool = false
        
        //    var adjustedThemeSetName: String = "default1" // deprecated....
        
        var memo: String = ""
        
        
        
        init() {
            
        }
    }
    
    
    

    

    
}
