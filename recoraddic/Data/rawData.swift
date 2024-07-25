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


// Record와 Quest의 완전분리

// 나중에 서버 만들면 구조 살짝 변경하기 -> 관리 및 분석 용이하게 (+보안)

// Each property should be unique,to prevent extra synchronization process. No need to store the same property in each classes.


import Foundation
import SwiftUI
import SwiftData
// use @observable after update to swift 5.9

// didn't use enums for HowFrequent, DataType, GoalType to use SwiftData


// ------------ Custom enum behaviored classes for @Model --------------- //

// if this is okay, change RecordInterval and DataType into enum (23.11.08) -> Nope. Impossible
//@Model
//enum testForCaseIterable: CaseIterable {
//    case one
//    case two
//    case three
////    static var allCases: [testForCaseIterable]
//}


@Model
final class RecordInterval {
    static let everyDay = 0
    static let onceInNdays = 1
    static let chooseInCalander = 2
    
    init() {
    }
}

final class DefaultPurpose {
    
    
    // 개인지향
    static let atr = "attractiveness" // 외모, 매력 (atr)
    static let inq = "inquisitiveness" // 지식, 탐구 (inq)
    static let ent = "entertainmentAndFun" // 즐거움 (ent)
    static let hlt = "personalHealth" // 건강 (hlt)
    static let ftr = "myFuture" // 개인적인 미래 (ftr)
    static let ach = "selfAchievement"
    static let rts = "relationship"

    // 타인지향
    static let sgn = "significantOther" // 사랑하는, 소중한 사람 (sgn)
    static let fml = "family" // 가족 (fml)
    static let cmn = "community" // 공동체 (cmn)
    static let alt = "alturism" // 이타심 (alt)
    static let wrl = "world"  // 인류의 미래 (wrl)
    
    
    
    static func inKorean(_ input: String) -> String {
        if input == DefaultPurpose.atr {
            return "나의 매력"
        }
        else if input == DefaultPurpose.inq {
            return "탐구심"
        }
        else if input == DefaultPurpose.ent {
            return "행복/즐거움"
        }
        else if input == DefaultPurpose.hlt {
            return "나의 건강"
        }
        else if input == DefaultPurpose.ftr {
            return "나의 미래"
        }
        else if input == DefaultPurpose.ach {
            return "성취감"
        }
        else if input  == DefaultPurpose.rts {
            return "인간관계"
        }
        
        
        else if input == DefaultPurpose.sgn {
            return "사랑하는 사람"
        }
        else if input == DefaultPurpose.fml {
            return "가족"
        }
        else if input == DefaultPurpose.cmn {
            return "공동체"
        }
        else if input == DefaultPurpose.alt {
            return "이타심"
        }
        else if input == DefaultPurpose.wrl {
            return "세상"
        }
        else {
            return "에러: KORPURP"
        }
        
    }
    
    
}



@Model
final class DailyTextType {
    // 소감 / 감정 / 다짐 / 피드백 / 즐거웠던 일 / 인상깊었던 일 / 기억하고 싶은 일

    static let inShort = "inShort" // 한줄평 (-) : 오늘 하루를 최대한 간략하고 위트있게 표현해보세요!
//    static let feedbacks = "feedbacks" // 더 나은 내가 되려면 어떻게 해야할까요?(can tag on quests or purpose)
    static let diary = "diary" // 오늘 있었던 특별했던, 또는 중요했던, 잊고 싶지 않은 일을 상세히 기록하세요!
    
    init() {
    }
}



// 이놈도 데이터 따로 저장하는 이유: quest가 삭제되어도 기록 유지하기 위해서
@Model
final class DefaultPurposeData {
    
//    @Attribute(.unique)
    var name: String = ""
    
    var cumulativeData: [String:[Date:Int]] = [:] // for each dataType, add data
    var cumulativeData_custom: [String:[Date:Int]] = [:]
    // 1 week, 1 month, 3 months, 6 months, 1 years, 3 years, 10 years, cumulative
    
    var tier_notHour: Int = 0
    var tier_hour: Int = 0
    
    var feedBacks: [String] = []
    
    init(name: String) {
        self.name = name
    }
    
}



// 여기에 데이터를 따로 담는 이유: quest가 삭제 되어도 일일기록은 남게 하기 위해
@Model
class DailyQuest: Hashable, Equatable, Identifiable {
    
    var id:UUID = UUID()
    
//    @Attribute(.unique)
    var createdTime: Date = Date()
    
    var questName: String = ""
    var questSubName: String? //MARK: 아직 사용하지는 않지만, 일단 만들어둠. 쓸까 말까..
    var data: Int = 0
    var dataType: Int = 1
    var defaultPurposes: Set<String> = []
    var dailyGoal: Int? = nil
    var currentTier: Int = 0
    var alermTime: Date? = nil
    var customDataTypeNotation: String?
    
    var dailyRecord: DailyRecord?
    
    
    init(createdTime: Date = .now, questName: String, data: Int, dataType: Int, defaultPurposes: Set<String>, customDataTypeNotation:String? = nil, dailyGoal: Int? = nil) {
        self.createdTime = createdTime
        self.questName = questName
        self.data = data
        self.dataType = dataType
        self.defaultPurposes = defaultPurposes
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
//final class Todo {
final class Todo: Hashable, Identifiable, Equatable {
    var id:UUID = UUID()
    var createdTime: Date = Date()

    var index: Int = 0
    var content: String = ""
    var done: Bool = false
    var purpose: Set<String> = []
    
    var dailyRecord: DailyRecord?
    
    init(dailyRecord: DailyRecord, index: Int) {
        self.dailyRecord = dailyRecord
        self.index = index
    }
    
    init() {
        self.index = -1
    }
    
    init(content: String) {
        self.index = -1
        self.content = content
    }
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
            return lhs.createdTime == rhs.createdTime && lhs.index == rhs.index
            // Add any other properties that determine equality
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(createdTime)
        hasher.combine(index)
            // Add any other properties that should be included in the hash
    }
    
}


@Model
//final class Todo {
final class Todo_preset: Hashable, Identifiable, Equatable {
    var id:UUID = UUID()
    var createdTime: Date = Date()

    var content: String = ""
    var purpose: Set<String> = []
        
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
    
    var createdTime: Date = Date()
    
    var start:Date = Date()
    var end:Date?
    
    var dailyQuestions: [String] = []

    var dailyRecordThemeName: String = "StoneTower"
    var backgroundThemeName: String = "stoneTowerBackground_1" //MARK: backgroundSetting 하는 view에서 dailyRecordThemeName에 따라서 선택할 수 있는 backgroundThemeName 제한
    var dailyRecordColorIndex: Int = 0
    
    var termGoals: [String] = []
    
//    var isArchived: Bool = false
    var isHidden: Bool = false
    var inTrashCan: Bool = false
    
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
            return StoneTower.getIntegratedDailyRecordColor(
                index: dailyRecordColorIndex,
                colorScheme: colorScheme
            )
        }
        else {
            return StoneTower.getIntegratedDailyRecordColor(
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
    
    func isVisible() -> Bool {
//        return !isArchived && !isHidden && !inTrashCan
        return !isHidden && !inTrashCan

    }
    
    func updateDailyRecordsMomentum() -> Void {
        if let dailyRecords = self.dailyRecords {
            let dates = dailyRecords.filter({$0.hasContent}).compactMap({$0.date})
            for dailyRecord in dailyRecords {
                if let date = dailyRecord.date {
                    let dates_beforeDate:[Date] = dates.filter({$0 < date})
                    if let nearestDate:Date = dates_beforeDate.sorted().last {
                        dailyRecord.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
                        if dailyRecord.absence == 0 {
                            dailyRecord.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
                        } else {
                            dailyRecord.streak = 0
                        }
                    }
                }
            }
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
final class DailyRecord: Equatable, Hashable {
//final class DailyRecord: Equatable {

    
    var createdTime: Date = Date()

//    @Attribute(.unique)
    var date: Date?
    
    @Relationship(deleteRule:.cascade, inverse: \DailyQuest.dailyRecord)
    var dailyQuestList:[DailyQuest]? = []
    @Relationship(deleteRule:.cascade, inverse: \Todo.dailyRecord)
    var todoList:[Todo]? = []
    
    var diaryImage: Data?
    var dailyTextType: String? // diary or inShort
    var dailyText: String?

    var mood: Int = 0 // facial expression
    
    // TODO: change steppedForward into dailyQuestionValue1, dailyQuestionValue2(for subscribers)
    
    
    // TODO: visual value: is determined by the sequence of steppedForward in dailyRecords, and each theme of StoneTower has it's unique function to caculate them, based on the theme's concept and design. Also, when theme changes, the whole visual value will be recalculated to fit it's theme.
//    var questionValue1: Int?
//    var questionValue2: Int?
//    var questionValue3: Int?
    var recordedAmount: Int {(dailyQuestList?.filter({$0.data != 0}).count ?? 0) + (todoList?.filter({$0.done}).count ?? 0)} // 기록 갯수
    var recordedMinutes: Int = 0 // 기록 시간(색)
    var absence: Int = 0 // 기록 절단성
    var streak: Int = 0 // 기록 연속성2


    
    var isFavorite: Bool = false
    
//    var isArchived: Bool = false
    var isHidden: Bool = false
    var inTrashCan: Bool = false

    
    var dailyRecordThemeNum: Int? // stone + background
    var dailyRecordStoneActionNum: Int?
    var dailyRecordStoneAccesseryNum: Int?
    
    var dailyRecordSet: DailyRecordSet?
    
    var hasContent: Bool { self.recordedAmount > 0 || self.dailyText != nil}
    var singleElm_dailyQuestOrTodo: Bool { self.dailyText == nil && self.recordedAmount == 1 }
    var singleElm_diary: Bool { self.dailyText != nil && self.recordedAmount == 0 }
    
    
    init() {
        
    }
    
    init(date:Date) {
        print("dailyRecordinitialization start")
        self.date = date
        

        print("dailyRecordinitialized")
    }
    
    
    static func == (lhs: DailyRecord, rhs: DailyRecord) -> Bool {
            return lhs.createdTime == rhs.createdTime
            // Add any other properties that determine equality
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(createdTime)
//        hasher.combine(date)
            // Add any other properties that should be included in the hash
    }
    
    func isVisible() -> Bool {
//        return !isArchived && !isHidden && !inTrashCan
        return !isHidden && !inTrashCan

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
    
    
    
}





// ----------------------------------------------------------------- //




//보류! calendar 만들게 되면 만들기
//@Model
//class QuestSchedule {
//    
//    var questName: String
//    var dataType: Int
//    var createdDate: Date
//    var lock: Bool = true
//    
//
//    var defaultPurposeTags: Set<String> = []
//    var dailyGoal: Int = 0
//    var checkDates: [Date] = []
//    
//    
//    // variables below here should go to option of record..?
//
//    var adjustedThemeSetName: String = "default1"
//    
//
//    
////    var achievements
////    var metaData: RecordMetaData!
////    var metadata
////    var statistics
//
//    
//    init(questName:String, dataType: Int) {
////    init(name in0: String, start in1 : Date, end in2: Date) {
//
//        self.questName = questName
//        self.dataType = dataType
//        self.createdDate = Date()
//
//    
//    }
//    
//    
//
//}

// 데이터 구조를 record 바로 아래에 quest로 두고, purpose를 quest 속성으로 만들고, quest를 Purpose별로 정렬하는 함수 만들기 -> View 구성 때 써먹기 위해

// 외모/지식/건강/지구/가족/공동체/타인/미래(돈?권력?)/취미&재미/모름


// 만약 Data를 하나의 model로 만든다면? 그리고 dailyRecord를 없애는 거임.
// quest, purpose(이것 역시 model화), date, value


// 커스텀 기능들 제공 (ex: 매일/며칠/특정일(캘린더 통해 선택) 마다 몇 시간/분/회/OX/money)
// 설정 주기보다 더 자주 한 날은 더 큰 버닝 게이지 제공
@Model
class Quest: Equatable, Identifiable, Hashable {
    
    var createdTime: Date = Date()

//    @Attribute(.unique)
    var name: String = ""
    var subName: String? //MARK: 아직 사용하지는 않지만, 일단 만들어둠. 쓸까 말까..
    var dataType: Int = 1
    var pastCumulatve: Int = 0
    var dailyData: [Date:Int] = [:]
    
    var recentData: Int = 0 // DailyQuest 새로 생성 및 수정 시 새로이 수정
    var freeSetDatas: [Int] = []
    
    var lock: Bool = true
    
    // 나중에 알림 설정 기능 추가
    var recentPurpose: Set<String> = []
    
    
    // Default settings
    var customDataTypeNotation: String?
    var dailyGoal: Int = 0
    
    var comments: [String] = []  // 나중을 위해 일단 만들어둠.
    
    var representingData: Int = QuestRepresentingData.cumulativeData
    
    var isArchived:Bool = false
    var isHidden:Bool = false // not used yet.
    var inTrashCan: Bool = false
    
    var tier: Int = 0 // 0~40
    //MARK: 0~9: 1시간(회) 10~19: 10시간(회) 10
    var momentumLevel: Int = 0
    // normal momentum: 0~10
    // special momentum: 11~31
    
     
//    @Relationship(deleteRule:.cascade)
//    var metaData: QuestMetaData?
    
    
//    // find belongingRecords by startDate
//    var belongingRecordsStartDate: [Date] = []
    
    // setting options
    init(name: String, dataType: Int) {
        self.name = name
        
        self.dataType = dataType
        
        
//        metaData = QuestMetaData(input: self)
        
        
    }
    
    static func == (lhs: Quest, rhs: Quest) -> Bool {
            return lhs.createdTime == rhs.createdTime
            // Add any other properties that determine equality
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(createdTime)
        hasher.combine(name)
        hasher.combine(dailyData)
            // Add any other properties that should be included in the hash
    }

    
    func changeLockState() {
        lock.toggle()
        print(lock)
//        if lock {lock = false}
//        else {lock = true}
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
}



@Model
class Profile {
    
    var name: String = ""
    var birthDay: Date = Date.now
    var email: String = ""
    
    // need other cumulative times also..
    var cumulativeRecordHours: Int = 0 // will be used later..
    var numberOfDailyRecords: Int = 0
    //    var cumulativeRecord
    // unit of sleepingTime: 1 -> 5min, 12 -> 1hour
    var sleepingTime: Int = 0 // deprecated...
    
    var adjustedThemeSetName: String = "default1" // deprecated....
    
    
    

    
    init() {
    
    }
}



final class QuestRepresentingData {
    
    static let cumulativeData = 0
    static let recentMontlyData = 1
    static let recentYearlyData = 2
    
    init() {}
    
    static func titleOf(representingData:Int) -> String {
        if representingData == QuestRepresentingData.cumulativeData {
            return "누적:"
        }
        
        else if representingData == QuestRepresentingData.recentMontlyData {
            return "최근 30일:"
        }
        else {
            return "titleOfRepresentingData: Error"
        }
    }
    
}


    
// 누적데이터 -> (전체/purpose별/quest별)
// quest별 -> 원래 다 저장되어 있음
// purpose별, 전체 -> 따로 저장해주어야 함.




struct objective_rowdata {}
struct objective_metadata {}
struct Purpose_metadata {}



