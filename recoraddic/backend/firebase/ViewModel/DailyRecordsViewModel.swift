////
////  crud.swift
////  recoraddic
////
////  Created by 김지호 on 12/26/24.
////
//
//import Foundation
//import SwiftUI
//import Combine
//import FirebaseAuth
//import FirebaseFirestore
////import FirebaseFirestoreSwift
//
//
////@MainActor
//@Observable class DailyRecordsViewModel {
//    var currentDailyRecord = DailyRecord_fb.empty
////    var currentDailyQuests:[DailyQuest_fb] = []
////    var currentTodos:[Todo_fb] = []
////    var currentSchedules:[Schedule_fb] = []
//    
//    var dailyRecords:[String:DailyRecord_fb] = [:]
//    
////    var dailyQuests:[String:[DailyQuest_fb]] = [:]// 처음 키면 불러오기, 그 이후에는 local 접근
////    var todos:[String:[Todo_fb]] = [:]
////    var schedules:[String:[Schedule_fb]] = [:]
//    
//    
////    @Published var currentDate: Date = getStartDateOfNow()
////    @Published var currentDate_str: String
//    
//    private var user: User?
//    private var db = Firestore.firestore()
//    private var cancellables = Set<AnyCancellable>()
//    
//    private var lastTimeMomentumChecked: Date = Date()
//    
//    var latestFetchTime: Date = Date()
//    var latestUpdateTime: Date = Date()
//    
//    
////    private var dailyRecordsListener: ListenerRegistration?
//    
//    init() {
//        registerAuthStateHandler()
//        
////        $user
////            .compactMap { $0 }
////            .sink { user in
//////                self.favourite.userId = user.uid
//////                self.addCurrentDailyRecordListenter()
////
////            }
////            .store(in: &cancellables) // didn't understand here.
//        
//        fetchDailyRecords()
////        fetchDailyQuests()
////        fetchTodos()
//        changeCurrentDailyRecord(Date())
////        self.addCurrentDailyRecordListenter(Date())
//
//    }
//    
//    private var authStateHandler: AuthStateDidChangeListenerHandle?
//    
//    func registerAuthStateHandler() {
//        if authStateHandler == nil {
//            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
//                self.user = user
//            }
//        }
//    }
//    
//    func changeCurrentDailyRecord(_ currentDate:Date) {
//        let currentDate_str = dateToString(currentDate)
//        
//        let newDailyQuests: [DailyQuest_fb] = self.dailyQuests[currentDate_str] ?? []
//        let newDailyTodos: [Todo_fb] = self.todos[currentDate_str] ?? []
//        let newSchedules: [Schedule_fb] = self.schedules[currentDate_str] ?? []
//        
////        if let targetDailyRecord = self.dailyRecords.first(where: {$0.id == currentDate_str}) {
//        if let targetDailyRecord = self.dailyRecords[currentDate_str] {
//            self.currentDailyRecord = targetDailyRecord
//        } else {
//            let newDailyRecord = DailyRecord_fb(id: currentDate_str)
//            self.currentDailyRecord = newDailyRecord
////            self.dailyRecords.append(newDailyRecord)
//            self.dailyRecords[currentDate_str] = newDailyRecord
//        }
//        
//        self.currentTodos = newDailyTodos
//        self.currentDailyQuests = newDailyQuests
//        self.currentSchedules = newSchedules
//    }
//    
//    func refreshCurrentDailyRecord(_ currentDate:Date) async { // usage: updating CurrentDailyRecord from fireStore
//        
//        let currentDate_str = dateToString(currentDate)
//        await refreshCurrentDailyRecord(currentDate_str)
//        
//    }
//    
//    func refreshCurrentDailyRecord(_ currentDate_str :String) async { // usage: updating CurrentDailyRecord from fireStore
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        do {
//            let reference = userData.collection(dailyRecordCollection).document(currentDate_str)
////                if reference.isEmpty { return }
//            if try await !reference.getDocument().exists { return }
//            
//            if self.currentDailyRecord.id == currentDate_str {
//                self.currentDailyRecord = try await reference.getDocument().data(as: DailyRecord_fb.self)
//            }
//
//            
//            await withThrowingTaskGroup(of: Void.self) { group in
//                group.addTask {
//                    var dailyQuests2: [DailyQuest_fb] = []
//                    for queryDocument in try await reference.collection(dailyQuestCollection).getDocuments().documents {
//                        let dailyQuest = try queryDocument.data(as: DailyQuest_fb.self)
//                        dailyQuests2.append(dailyQuest)
//                    }
//                    self.dailyQuests.updateValue(dailyQuests2, forKey: currentDate_str)
//                    if self.currentDailyRecord.id == currentDate_str {
//                        self.currentDailyQuests = dailyQuests2
//                    }
//
//                }
//                group.addTask {
//                    var todos2: [Todo_fb] = []
//                    for queryDocument in try await reference.collection(todoCollection).getDocuments().documents {
//                        let todo = try queryDocument.data(as: Todo_fb.self)
//                        todos2.append(todo)
//                    }
//                    self.todos.updateValue(todos2, forKey: currentDate_str)
//                    if self.currentDailyRecord.id == currentDate_str {
//                        self.currentTodos = todos2
//                    }
//                    
//                }
//                group.addTask {
//                    var schedules2: [Schedule_fb] = []
//                    for queryDocument in try await reference.collection(scheduleCollection).getDocuments().documents {
//                        let schedule = try queryDocument.data(as: Schedule_fb.self)
//                        schedules2.append(schedule)
//                    }
//                    self.schedules.updateValue(schedules2, forKey: currentDate_str)
//                    if self.currentDailyRecord.id == currentDate_str {
//                        self.currentSchedules = schedules2
//                    }
//                }
//
//            }
//        } catch {
//            print("error during refreshing current daily record: \(error)")
//        }
//    
//    }
//    
//    
////    func addCurrentDailyRecordListenter(_ currentDate:Date) {
////        
////        if let dailyRecordsListener = self.dailyRecordsListener {
////            dailyRecordsListener.remove()
////        }
////        
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        
////        let currentDate_str = dateToString(currentDate)
////        
////        
////        Task {
////            self.dailyRecordsListener = userData.collection(dailyRecordCollection).document(currentDate_str).addSnapshotListener({ snapshot, error in
////                guard let document = snapshot else {
////                    print("Error fetching document: \(error!)")
////                    return
////                }
////                
////                do {
////                    self.currentDailyRecord = try document.data(as: DailyRecord_fb.self)
////                } catch {
////                    print("failed to fetch current dailyRecord: \(error)")
////                }
////                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
////                print("\(source) data: \(document.data() ?? [:])")
////
////            })
////        }
////    }
//    
//    
//    func fetchDailyRecords() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        Task {
//            do {
//                let querySnapshot = try await userData.collection(dailyRecordCollection).getDocuments()
//                if !querySnapshot.isEmpty {
//                    for queryDocument in querySnapshot.documents {
//                        let dailyRecord = try queryDocument.data(as: DailyRecord_fb.self)
//                        await MainActor.run {
////                            self.dailyRecords.append(dailyRecord)
//                            self.dailyRecords[queryDocument.documentID] = dailyRecord
//                        }
//                    }
//
//                }
//            }
//            catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//    
////    func fetchDailyQuests() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        Task {
////            do {
////                let querySnapshot = try await userData.collection(dailyRecordCollection).getDocuments()
////                if querySnapshot.isEmpty { return }
////                try await withThrowingTaskGroup(of: (String, [DailyQuest_fb]).self) { group in
////                    for queryDocument in querySnapshot.documents {
////                        group.addTask {
////                            let date = queryDocument.documentID
////                            var dailyQuests2: [DailyQuest_fb] = []
////                            let querySnapshot2 = try await queryDocument.reference.collection(dailyQuestCollection).getDocuments()
////                            for queryDocument2 in querySnapshot2.documents {
////                                let dailyQuest = try queryDocument.data(as: DailyQuest_fb.self)
////                                dailyQuests2.append(dailyQuest)
////                            }
////                            return (date, dailyQuests2)
////                        }
////                    }
////                    for try await (date, dailyQuests2) in group {
////                        dailyQuests.updateValue(dailyQuests2, forKey: date)
////                    }
////                }
////                
////            }
////            catch {
////                print(error.localizedDescription)
////            }
////        }
////    }
//    
////    func fetchTodos() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        Task {
////            do {
////                let querySnapshot = try await userData.collection(dailyRecordCollection).getDocuments()
////                if querySnapshot.isEmpty { return }
////                try await withThrowingTaskGroup(of: (String, [Todo_fb]).self) { group in
////                    for queryDocument in querySnapshot.documents {
////                        group.addTask {
////                            let date = queryDocument.documentID
////                            var todos2: [Todo_fb] = []
////                            let querySnapshot2 = try await queryDocument.reference.collection(todoCollection).getDocuments()
////                            for queryDocument2 in querySnapshot2.documents {
////                                let todo = try queryDocument.data(as: Todo_fb.self)
////                                todos2.append(todo)
////                            }
////                            return (date, todos2)
////                        }
////                    }
////                    for try await (date, todos2) in group {
////                        todos.updateValue(todos2, forKey: date)
////                    }
////                }
////                
////            }
////            catch {
////                print(error.localizedDescription)
////            }
////        }
////    }
//    
////    func fetchSchedules() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        Task {
////            do {
////                let querySnapshot = try await userData.collection(dailyRecordCollection).getDocuments()
////                if querySnapshot.isEmpty { return }
////                try await withThrowingTaskGroup(of: (String, [Schedule_fb]).self) { group in
////                    for queryDocument in querySnapshot.documents {
////                        group.addTask {
////                            let date = queryDocument.documentID
////                            var schedules2: [Schedule_fb] = []
////                            let querySnapshot2 = try await queryDocument.reference.collection(scheduleCollection).getDocuments()
////                            for queryDocument2 in querySnapshot2.documents {
////                                let schedule = try queryDocument.data(as: Schedule_fb.self)
////                                schedules2.append(schedule)
////                            }
////                            return (date, schedules2)
////                        }
////                    }
////                    for try await (date, schedules2) in group {
////                        schedules.updateValue(schedules2, forKey: date)
////                    }
////                }
////                
////            }
////            catch {
////                print(error.localizedDescription)
////            }
////        }
////    }
//    
//    func addNewDailyQuests(_ mountainIds: [String]) {
//        
//        // add new dailyQuests -> on currentDailyQuests, dailyQuests, and fireStore
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let currentDate_str = currentDailyRecord.id else { return /*which will never happen*/ }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        for mountainId in mountainIds {
//            self.currentDailyRecord.addDailyRecord(mountainId)
//            userData.collection(dailyRecordCollection).document(currentDate_str).updateData(["mileStoneData.\(mountainId)":0])
//
//        }
//
//    }
//    
//    
////    func updateDailyQuests(for mountain: MileStone_fb, addSubName: Bool) { // update name, currentTier, subname
////        
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        
////        let dates_str = Array(dailyQuests.keys)
////        Task {
////            for date_str in dates_str {
////                guard let count = self.dailyQuests[date_str]?.count else { continue }
////                if count > 0 {
////                    for idx in 0..<count {
////                        if self.dailyQuests[date_str]![idx].mountainId != mountain.id { continue }
////                        if var newDailyQuest = self.dailyQuests[date_str]?[idx] {
////                            newDailyQuest.mountainName = mountain.name
////                            if addSubName {
////                                newDailyQuest.mountainSubName = mountain.subName
////                            } else {
////                                newDailyQuest.mountainSubName = nil
////                            }
////                            if ascentDataType == .custom { dailyQuest.customDataTypeNotation = customDataTypeNotation }                            newDailyQuest.currentTier = mountain.tier
////                            self.dailyQuests[date_str]![idx] = newDailyQuest
////                            if Date().timeIntervalSince(latestUpdateTime) > 5 {
////                                try userData.collection(dailyRecordCollection).document(date_str).collection(dailyQuestCollection).document(newDailyQuest.mountainId).setData(from: newDailyQuest)
////                            }
////                        }
////                    }
////                }
////            }
////            self.latestUpdateTime = Date()
////        }
////    }
//    
//    func saveDailyRecord(_ date: Date) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        let currentDate_str = dateToString(date)
//        
//        do {
//            try userData.collection(dailyRecordCollection).document(currentDate_str).setData(from: self.currentDailyRecord)
//        }
//        catch {
//            print(error.localizedDescription)
//        }
//    }
//    
//    
//    func deleteDailyQuest(_ date_str :String,_ : DailyQuest_fb) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        Task {
//            try await userData.collection(dailyRecordCollection).document(date_str).collection(dailyQuestCollection).document(dailyQuest.id ?? "").delete()
////            await refreshCurrentDailyRecord(currentDate_str)
//
//        }
//
//        self.dailyQuests[currentDate_str]?.removeAll(where: { $0.id == dailyQuest.id })
//        
//    }
//    
//    
//    func deleteDailyQuest(_ currentDate:Date,_ dailyQuest: DailyQuest_fb) {
//
//        let currentDate_str = dateToString(currentDate)
//        deleteDailyQuest(currentDate_str, dailyQuest)
//
//
//    }
//    
//    func updateDailyRecordsMomentum() {
//        let dailyRecords_ids: [String] = Array(self.dailyRecords.keys).sorted()
//        let dates_withContent: [Date] = dailyRecords_ids.filter({self.dailyRecords[$0]?.hasContent ?? false}).map({stringToDate($0)})
//
//        for date_str in dailyRecords_ids {
//            updateDailyRecordMomentum(&self.dailyRecords[date_str], dates_withContent)
//            
//        }
//        
//        
//        
//        // save in fireStore, not so frequently
//        if Date().timeIntervalSince(lastTimeMomentumChecked) > 10 {
//            for dailyRecords_Id in dailyRecords_ids {
//                let date:Date = stringToDate(dailyRecords_Id)
//                saveDailyRecord(date)
//            }
//            lastTimeMomentumChecked = Date()
//        }
//        
//        
//        
//
//        
//        
//
//    }
//    
//    func updateDailyRecordMomentum(_ dailyRecord:inout DailyRecord_fb?, _ dates_withContent: [Date]) {
//        guard let date_str = dailyRecord?.id else { return }
//
//        dailyRecord?.recordedMinutes = self.dailyQuests[date_str]?.filter({$0.dataType == DataType.hour.rawValue}).map{$0.data}.reduce(0, +) ?? 0
//        dailyRecord?.dailyQuestCount = self.dailyQuests[date_str]?.filter({$0.data == 0}).count ?? 0
//        dailyRecord?.todoCount = self.todos[date_str]?.filter({$0.done}).count ?? 0
//        dailyRecord?.scheduleCount = self.schedules[date_str]?.count ?? 0
//        
//        let date:Date = stringToDate(date_str)
//        if !dates_withContent.contains(date) { return }
//
//        let dates_beforeDate:[Date] = dates_withContent.filter({$0 < date})
//        if let nearestDate:Date = dates_beforeDate.last {
//            dailyRecord?.absence = calculateDaysBetweenTwoDates(from: nearestDate, to: date)
//            if dailyRecord?.absence == 0 {
//                dailyRecord?.streak = dailyStreak(from: dates_beforeDate, targetDate: date)
//            } else {
//                dailyRecord?.streak = 0
//            }
//        } else { // first dailyRecord in drs
//            dailyRecord?.absence = 0
//            dailyRecord?.streak = 0
//        }
//    }
//    
////    func saveTodo
//}
//
//
//
//
////class UserDataModel
