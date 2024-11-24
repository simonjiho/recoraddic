//
//  userDataModel.swift
//  recoraddic
//
//  Created by 김지호 on 12/27/24.
//

//
// Favourite.swift
// Favourites (iOS)
//
// Created by Peter Friese on 24.11.22.
// Copyright © 2021 Google LLC. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// MARK: let it as structure, but if necessary, modify them into class
// MARK: Also, if necessary, apply observable features.
// MARK: Important! @Observable macros are not available since it crashes the @DocumentId. Use ObservableObject protocol instead, if observable features required.
// MARK: Caution! If class is necessary, you must put observable features, since the advantage from ViewModel(which is Observable) gets lost.

import Foundation
import SwiftUI
import FirebaseFirestore
//import FirebaseFirestoreSwift



typealias YYYYMMDD = String


struct UserData: Codable, Identifiable {
    @DocumentID var id: String?
    var startedDate: Date
    var isPublic: Bool

    var archivedMountainIds:[String] = []
    var hiddenMountainIds: [String] = []
    var deletedMountainIds:[String] = []

    var showHiddenMountain: Bool = false
//    var userId: String
}

extension UserData {
    static var empty: UserData {
        UserData(startedDate: Date(), isPublic: false)
    }
}



struct DailyRecordSet_fb: Codable {
    @DocumentID var id: String?
    var start: Date
    var end: Date?
    var themeName: String = "StoneTower"
    var backgroundThemeName: String = "stoneTowerBackground_1" //MARK: backgroundSetting 하는 view에서 dailyRecordThemeName에 따라서 선택할 수 있는 backgroundThemeName 제한
    var themeStyleIndex1: Int = 0
    var termGoals: [String] = []
    
    
//    init(start: Date) {
//        self.start = date
//    }
}
extension DailyRecordSet_fb {
    static var empty: DailyRecordSet_fb {
        DailyRecordSet_fb(start: Date())
    }
}



struct DailyRecord_fb: Codable { // 하나에 다 넣은 이유: 순서를 임의로 지정하려면
    @DocumentID var id: YYYYMMDD? // date as string
//    var date: Date?
    var dailyTextType: String? // diary or inShort
    var dailyText: String?
    var mood: Int = 0 // facial expression
    var isFavorite: Bool = false
    
    var recordedMinutes: Int = 0
//    var mountainCount: Int = 0
//    var todoCount: Int = 0
//    var scheduleCount: Int = 0
//    var absence: Int = 0
//    var streak: Int = 0
    
    var ascentData: [String:Int] = [:] // mountainId:Data
    var dailyGoals: [String:Int] = [:] // mountainId:DailyGoal
    var notfTimes: [String:Date] = [:] // mountainId:Time
//    var mountainTodos: [String:String] = [:] // mountainId:todos

    
    var todos: [String:String] = [:] // todoId:content
    var todos_done: [String:Bool] = [:]
    var todos_spentTime:[String:Int] = [:] // todoId: minutes
    var todos_purposes:[String:[String]] = [:] //todoId: purposes
    var todos_order: [String] = [] // [todoId]
    
    var schedules: [String:String] = [:] // scheduleId: content
    var schedules_spentTime:[String:Int] = [:] // scheduleId: minutes
    var schedules_purposes:[String:[String]] = [:] //schduleId: purposes
    var schedules_order: [String] = [] // [scheduleId]
    
    
}
extension DailyRecord_fb {
    static var empty: DailyRecord_fb {
        DailyRecord_fb()
    }
}


struct Mountain_fb: Codable {
    @DocumentID var id: String? = UUID().uuidString
    var createdTime: Date = Date()
    var deletedTime: Date? = nil
    var name: String = ""
    var subName: String?
    var pastCumulatve: Int = 0
    var dailyAscent: [String:Int] = [:] // [Date:Int]
        
    var recentPurpose: Set<String> = []
    
    // Default settings
    var customDataTypeNotation: String?
    
    var memo: String = ""
    var goals: [String] = []
    var achievements: [String:String] = [:] // Date:String
    
    var representingData: Int = MountainRepresentingData.cumulativeData
        
    var mountainState: MountainState = .available
    
    enum MountainState: Int, Codable {
        case available = 0
        case archived = 1
        case hidden = 2
        case deleted = 3
    }

    
    var tier: Int = 0 // 0~40
    var momentumLevel: Int = 0
    
}

extension Mountain_fb {
    static var empty: Mountain_fb {
        Mountain_fb()
    }

}
    
    


//struct TodoPreset_fb: Codable {
//    @DocumentID var id: String? = UUID().uuidString
//    var createdTime: Date = Date()
//    var content: String = ""
//    var purposes: Set<String> = []
//
//}
//extension TodoPreset_fb {
//    static var empty: TodoPreset_fb {
//        TodoPreset_fb()
//    }
//}


//struct AscentData_fb: Codable {
//    @DocumentID var id: String? // same with related mountain id
//
//    var createdTime: Date = Date()
//    var mountainName: String = ""
//    var mountainSubName: String?
//    var data: Int = 0
//    var dataType: Int = 1
//    var dailyGoal: Int? = nil
//    var currentTier: Int = 0
//    var notfTime: Date? = nil
//    var stopwatchStart: Date? = nil
//    var customDataTypeNotation: String?
//    var mountainId: String // same with related mountain id
//    var todos: [String] = []
//    
//
//
//
//    
//}
//extension AscentData_fb {
//    static var empty: AscentData_fb {
//        AscentData_fb()
//    }
//}


//struct Todo_fb: Codable { // keep permanent or not
//    @DocumentID var id: String?
//
//    var createdTime: Date = Date()
//    var idx: Int = 0
//    var content: String = ""
//    var done: Bool = false
//    var purposes: Set<String> = []
//
//    
//}
//extension Todo_fb {
//    static var empty: Todo_fb {
//        Todo_fb()
//    }
//}

//struct Schedule_fb: Codable {
//    @DocumentID var id: String?
//
//    var createdTime: Date = Date()
//    var content: String = ""
//    var time: Date = Date()
//    var timeSpent: Int = 0
////    var notfTime: Date? = nil
//    var purposes: Set<String> = []
////    var dailyRecordSetId: String?
//}

struct LongSchedule_fb: Codable {
    @DocumentID var id: String?
    var createdTime: Date = Date()
    var startDate:String = ""
    var endDate:String = ""
    var content:String = ""
    var notfTime: Date? = nil
}

struct RepeatSchedule_fb: Codable {
    @DocumentID var id: String?
    var createdTime: Date = Date()
    var startDate:String = ""
    var endDate:String = ""
    var content:String = ""
    var notfTime: Date? = nil
    var repeatType: RepeatType.RawValue
    
    enum RepeatType: Int {
        case everyDay = 1
        case onceIn = 2
        case weekly = 3
        case monthly = 4
        case yearly = 5
    }
}

//extension Schedule_fb {
//    static var empty: Schedule_fb {
//        Schedule_fb()
//    }
//}

struct HabitGemstone_fb: Codable {
    @DocumentID var id: String?

    var createdTime: Date = Date()
    var startDate: String = ""
    var name: String = ""
    var notfTime: Date? = nil
    var streak: Int = 0
    var difficulty: HabitMakerDifficulty = HabitMakerDifficulty.easy // 0 -> easy
    var purposes: Set<String> = []
    var isDone: Bool = false
}
extension HabitGemstone_fb {
    static var empty: HabitGemstone_fb {
        HabitGemstone_fb()
    }
}


