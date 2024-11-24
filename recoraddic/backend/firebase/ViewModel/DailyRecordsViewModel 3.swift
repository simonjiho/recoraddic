//
//  crud.swift
//  recoraddic
//
//  Created by 김지호 on 12/26/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
//import FirebaseFirestoreSwift


// MARK: Important: If you try to send request to update the dailyRecord by setData, some updates may be ignored, since lots of data is stored in

//@MainActor
@Observable class DailyRecordsViewModel {
    var currentDailyRecord = DailyRecord_fb.empty
    var dailyRecords:[YYYYMMDD:DailyRecord_fb] = [:]
    
    private var user: User?
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private var lastTimeMomentumChecked: Date = Date()
    
    var latestFetchTime: Date = Date()
    var latestUpdateTime1: Date = Date()
    var latestUpdateTime2: Date = Date()
    var latestUpdateTime3: Date = Date()
    
    
    // pending data waitng for update to Firestore
    private var created_ascentData: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var updated_ascentData: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var deleted_ascentData: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var created_todo: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var updated_todo: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var deleted_todo: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var created_schedule: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var updated_schedule: [YYYYMMDD:[String]] = [:] // [date : [id]]
    private var deleted_schedule: [YYYYMMDD:[String]] = [:] // [date : [id]]
    
    var needsUpdate: Bool {
        pendingCreateExists || pendingUpdateExists || pendingDeleteExists
    }
        
    var pendingCreateExists: Bool {
        !created_ascentData.isEmpty || !created_todo.isEmpty || !created_schedule.isEmpty
    }
    var pendingUpdateExists: Bool {
        !updated_ascentData.isEmpty || !updated_todo.isEmpty || !updated_schedule.isEmpty
    }
    var pendingDeleteExists: Bool {
        !deleted_ascentData.isEmpty || !deleted_todo.isEmpty || !deleted_schedule.isEmpty
    }
    
    var pendingDates: [YYYYMMDD] {
        Array(Set(Array(self.created_ascentData.keys) + self.created_todo.keys + self.created_schedule.keys + self.updated_ascentData.keys + self.updated_todo.keys + self.updated_schedule.keys + self.deleted_ascentData.keys + self.deleted_todo.keys + self.deleted_schedule.keys)).sorted(by: {$0 > $1})
    }
    
    var timer: Timer?
    let delay: TimeInterval = 7.0
    
    
    init() {
        registerAuthStateHandler()
        
        //        $user
        //            .compactMap { $0 }
        //            .sink { user in
        ////                self.favourite.userId = user.uid
        ////                self.addCurrentDailyRecordListenter()
        //
        //            }
        //            .store(in: &cancellables) // didn't understand here.
        
        fetchDailyRecords()
        changeCurrentDailyRecord(Date())
        adddailyRecordsListener()
        
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
            }
        }
    }
    
    func changeCurrentDailyRecord(_ currentDate:Date) {
        let currentDate_str = dateToString(currentDate)
        if let targetDailyRecord = self.dailyRecords[currentDate_str] {
            self.currentDailyRecord = targetDailyRecord
        } else {
            createNewDailyRecord(currentDate_str)
        }
    }
    
    func createNewDailyRecord(_ currentDate_str: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        
        let newDailyRecord = DailyRecord_fb(id: currentDate_str)
        self.currentDailyRecord = newDailyRecord
        self.dailyRecords[currentDate_str] = newDailyRecord
        
        do {
            try userData.collection(dailyRecordCollection).addDocument(from: newDailyRecord)
        } catch {
            print("failed to add new dailyRecord on fireStore: \(error)")
        }
    }
    
    func addCurrentDailyRecordUpdateTimer() {
        
        // JONNA 짜임새 있게 짜보자.
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if Date().timeIntervalSince(self.latestUpdateTime2) > delay { return }
            if !needsUpdate { return }
            
            for date in pendingDates {
                sendRequest_create(for: date)
                sendRequest_update(for: date)
                sendRequest_delete(for: date)
                sendRequest_updateOrders(for: date)
            }

            clearPendingData()
            
            
            self.latestUpdateTime2 = Date()
        }
    }
        
    private func sendRequest_create(for date: YYYYMMDD) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dailyRecordsCollection = db.collection(usersDataCollection).document(uid).collection(dailyRecordCollection)
        var dataForCreate: [String: Any] = [:]
        if let mountainIds = self.created_ascentData[date] {
            for mountainId in mountainIds {
                guard let ascentData = self.dailyRecords[date]?.ascentData[mountainId] else { continue }
                let dailyGoal = self.dailyRecords[date]?.dailyGoals[mountainId]
                let notfTime = self.dailyRecords[date]?.notfTimes[mountainId]
                dataForCreate["ascentData.\(mountainId)"] = ascentData
                dataForCreate["dailyGoals.\(mountainId)"] = dailyGoal
                dataForCreate["notfTimes.\(mountainId)"] = notfTime
            }
        }

        if let todoIds = self.created_todo[date] {
            for todoId in todoIds {
                guard let todoData = self.dailyRecords[date]?.todos[todoId] else { continue }
                let todo_done = self.dailyRecords[date]?.todos_done[todoId]
                let todo_purposes = self.dailyRecords[date]?.todos_purposes[todoId]
                dataForCreate["todos.\(todoId)"] = todoData
                dataForCreate["todos_done.\(todoId)"] = todo_done
                dataForCreate["todos_purposes.\(todoId)"] = todo_purposes
            }
        }
        
        if let scheduleIds = self.created_schedule[date] {
            for scheduleId in scheduleIds {
                guard let scheduleData = self.dailyRecords[date]?.schedules[scheduleId] else { continue }
                dataForCreate["schedules.\(scheduleId)"] = scheduleData
            }
        }
        dailyRecordsCollection.document(date).setData(dataForCreate)
    }
    
    private func sendRequest_update(for date: YYYYMMDD) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dailyRecordsCollection = db.collection(usersDataCollection).document(uid).collection(dailyRecordCollection)
        
        for date_str in self.updated_ascentData.keys {
            if let prevAscentDataId = self.updated_ascentData[date_str] {
                self.updated_ascentData[date_str] = Array(Set(prevAscentDataId))
            }
        }
        
        var dataForCreate: [String: Any] = [:]
        if let mountainIds = self.updated_ascentData[date] {
            for mountainId in mountainIds {
                guard let ascentData = self.dailyRecords[date]?.ascentData[mountainId] else { continue }
                dataForCreate["ascentData.\(mountainId)"] = ascentData
            }
        }

        if let todoIds = self.updated_todo[date] {
            for todoId in todoIds {
                guard let todoData = self.dailyRecords[date]?.todos[todoId] else { continue }
                dataForCreate["todos.\(todoId)"] = todoData
            }
        }
        
        if let scheduleIds = self.updated_schedule[date] {
            for scheduleId in scheduleIds {
                guard let scheduleData = self.dailyRecords[date]?.schedules[scheduleId] else { continue }
                dataForCreate["schedules.\(scheduleId)"] = scheduleData
            }
        }
        dailyRecordsCollection.document(date).updateData(dataForCreate)
    }
    
    private func sendRequest_delete(for date: YYYYMMDD) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dailyRecordsCollection = db.collection(usersDataCollection).document(uid).collection(dailyRecordCollection)
        var dataForCreate: [String: Any] = [:]
        if let mountainIds = self.deleted_ascentData[date] {
            for mountainId in mountainIds {
                dataForCreate["ascentData.\(mountainId)"] = FieldValue.delete()
            }
        }

        if let todoIds = self.deleted_todo[date] {
            for todoId in todoIds {
                dataForCreate["todos.\(todoId)"] = FieldValue.delete()
            }
        }
        
        if let scheduleIds = self.deleted_schedule[date] {
            for scheduleId in scheduleIds {
                dataForCreate["schedules.\(scheduleId)"] = FieldValue.delete()
            }
        }
        dailyRecordsCollection.document(date).updateData(dataForCreate)
    }
    
    private func sendRequest_updateOrders(for date: YYYYMMDD) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dailyRecordsCollection = db.collection(usersDataCollection).document(uid).collection(dailyRecordCollection)
        
        if let dailyRecord = self.dailyRecords[date] {
            dailyRecordsCollection.document(date).updateData([
                "todos_order": dailyRecord.todos_order,
                "schedules_order": dailyRecord.schedules_order
            ])
        }

    }
    
    private func clearPendingData() {
        self.created_ascentData.removeAll()
        self.updated_ascentData.removeAll()
        self.deleted_ascentData.removeAll()
        self.created_todo.removeAll()
        self.updated_todo.removeAll()
        self.deleted_todo.removeAll()
        self.created_schedule.removeAll()
        self.updated_schedule.removeAll()
        self.deleted_schedule.removeAll()
    }
    
    func adddailyRecordsListener() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        userData.collection(dailyRecordCollection)
        //          .order(by: "orderIndex", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if Date().timeIntervalSince(self.latestUpdateTime3) > self.delay { return }
                guard let documents = querySnapshot?.documents else { return }
                
                for document in documents {
                    let date = document.documentID
                    if !self.pendingDates.contains(date) {
                        self.dailyRecords[date] = try? document.data(as: DailyRecord_fb.self)
                    }
                }
                
                Task {
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for date in self.pendingDates {
                            guard var dailyRecord = try documents.first(where: {$0.documentID == date})?.data(as: DailyRecord_fb.self) else { continue }
                            guard let dailyRecord_prev = self.dailyRecords[date] else { continue }
                            
                            group.addTask {
                                for id in self.created_ascentData[date] ?? [] {
                                    guard let value = self.dailyRecords[date]?.ascentData[id] else { continue }
                                    dailyRecord.ascentData[id] = value
                                }
                                for id in self.created_todo[date] ?? [] {
                                    guard let content = self.dailyRecords[date]?.todos[id] else { continue }
                                    dailyRecord.todos[id] = content
                                }
                                for id in self.created_schedule[date] ?? [] {
                                    guard let content = self.dailyRecords[date]?.schedules[id] else { continue }
                                    dailyRecord.schedules[id] = content
                                }
                                for id in self.updated_ascentData[date] ?? [] {
                                    guard let value = self.dailyRecords[date]?.ascentData[id] else { continue }
                                    
                                    dailyRecord.ascentData[id]? = value
                                    if let notfTimes = self.dailyRecords[date]?.notfTimes[id] {
                                        dailyRecord.notfTimes[id] = notfTimes
                                    }
                                    
                                }
                                for id in self.updated_todo[date] ?? [] {
                                    guard let content = self.dailyRecords[date]?.todos[id] else { continue }
                                    
                                    dailyRecord.todos[id]? = content
                                    if let purposes = self.dailyRecords[date]?.todos_purposes[id] {
                                        dailyRecord.todos_purposes[id] = purposes
                                    }
                                    if let spentTime = self.dailyRecords[date]?.todos_spentTime[id] {
                                        dailyRecord.todos_spentTime[id] = spentTime
                                    }
                                    
                                }
                                for id in self.updated_schedule[date] ?? [] {
                                    guard let content = self.dailyRecords[date]?.schedules[id] else { continue }
                                    
                                    dailyRecord.schedules[id]? = content
                                    if let purposes = self.dailyRecords[date]?.schedules_purposes[id] {
                                        dailyRecord.schedules_purposes[id] = purposes
                                    }
                                    if let spentTime = self.dailyRecords[date]?.schedules_spentTime[id] {
                                        dailyRecord.schedules_spentTime[id] = spentTime
                                    }

                                }
                                for id in self.deleted_ascentData[date] ?? [] {
                                    dailyRecord.ascentData.removeValue(forKey: id)
                                }
                                for id in self.deleted_todo[date] ?? [] {
                                    dailyRecord.todos.removeValue(forKey: id)
                                }
                                for id in self.created_schedule[date] ?? [] {
                                    dailyRecord.schedules.removeValue(forKey: id)
                                }
                                
                            }
                            
                            
                            let adjustedTodoOrder:[String] = self.adjustedOrder(prev: dailyRecord_prev.todos_order, new: dailyRecord.todos_order, existingIds: Array(dailyRecord.todos.keys))
                            let adjustedScheduleOrder:[String] = self.adjustedOrder(prev: dailyRecord_prev.schedules_order, new: dailyRecord.schedules_order, existingIds: Array(dailyRecord.schedules.keys))
                            
                            dailyRecord.todos_order = adjustedTodoOrder
                            dailyRecord.schedules_order = adjustedScheduleOrder
                            
                            self.dailyRecords[date] = dailyRecord
                            if self.currentDailyRecord.id == dailyRecord.id {
                                self.currentDailyRecord = dailyRecord
                            }
                        }
                    }

            

                    

                    

                }
                
                self.latestUpdateTime3 = Date()
                //              documents.compactMap { try? $0.data(as: Task.self) }
            }
        
    }
    

    func fetchDailyRecords() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        Task {
            do {
                let querySnapshot = try await userData.collection(dailyRecordCollection).getDocuments()
                if !querySnapshot.isEmpty {
                    for queryDocument in querySnapshot.documents {
                        let dailyRecord = try queryDocument.data(as: DailyRecord_fb.self)
                        await MainActor.run {
                            self.dailyRecords[queryDocument.documentID] = dailyRecord
                        }
                    }
                    
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
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
//            //                if reference.isEmpty { return }
//            if try await !reference.getDocument().exists { return }
//            
//            if self.currentDailyRecord.id == currentDate_str {
//                self.currentDailyRecord = try await reference.getDocument().data(as: DailyRecord_fb.self)
//            }
//            
//        } catch {
//            print("error during refreshing current daily record: \(error)")
//        }
//        
//    }
    
    
    func saveDailyRecord(_ date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        let currentDate_str = dateToString(date)
        
        do {
            try userData.collection(dailyRecordCollection).document(currentDate_str).setData(from: self.currentDailyRecord)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func saveCurrentDailyRecord() {
        if let date = self.currentDailyRecord.id {
            self.dailyRecords[date] = self.currentDailyRecord
        }
    }
    func fetchCurrentDailyRecord() {
        if let date = self.currentDailyRecord.id {
            guard let dailyRecord = self.dailyRecords[date] else {return}
            self.currentDailyRecord = dailyRecord
        }
    }
    
    
}



// TODO: ascentData, todos, schedules -> create, update, delete 시 pending 목록에 올려놓게 + 최대갯수 제한
// TODO: ascentData, todos, schedules 에 달려있는 다른 data 처리 방식 맞는지 확인

extension DailyRecordsViewModel { // ascentData
    
    func createAscentData(_ mountainIds: [String]) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.created_ascentData[date] == nil { self.created_ascentData[date] = []}
        
        for mountainId in mountainIds {
            self.currentDailyRecord.ascentData[mountainId] = 0
            self.created_ascentData[date]?.append(mountainId)
        }
        
        saveCurrentDailyRecord()
    }
    
//    func updateAscentData(_ mountainId : String,_ value: Minutes) {
//        guard let date = self.currentDailyRecord.id else { return }
//        if self.updated_ascentData[date] == nil { self.updated_ascentData[date] = []}
//        
//        self.updated_ascentData[date]?.append(mountainId)
//        self.currentDailyRecord.ascentData[mountainId]? = value
//        
//        saveCurrentDailyRecord()
//    }
    
//    func updateDailyGoal(of mountainId: String, value: Minutes?) {
//        if let value = value {
//            self.currentDailyRecord.dailyGoals[mountainId] = value
//        } else {
//            self.currentDailyRecord.dailyGoals.removeValue(forKey: mountainId)
//        }
//    }
    func markUpdate_ascentData(of mountainId: String) {
        if self.updated_ascentData[self.currentDate] == nil { self.updated_ascentData[self.currentDate] = []}
        self.updated_ascentData[self.currentDate]?.append(mountainId)
    }
    
    func deleteAscentData(_ mountainId : String) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.deleted_ascentData[date] == nil { self.deleted_ascentData[date] = []}
        
        self.deleted_ascentData[date]?.append(mountainId)
        self.currentDailyRecord.ascentData.removeValue(forKey: mountainId)
        
        saveCurrentDailyRecord()
    }
    
    func bindingAscentData(for mileStoneId: String) -> Binding<Minutes> {
        Binding(
            get: { self.currentDailyRecord.ascentData[mileStoneId, default: 0] }, // Fallback value
            set: { self.currentDailyRecord.ascentData[mileStoneId] = $0 }
        )
    }
    func bindingDailyGoal(for mileStoneId: String) -> Binding<Minutes?> {
        Binding<Minutes?>(
            get: { self.currentDailyRecord.dailyGoals[mileStoneId] ?? nil }, // Fallback value
            set: { self.currentDailyRecord.dailyGoals[mileStoneId] = $0 }
        )
    }
    
    func bindingNotfTime(for mileStoneId: String) -> Binding<Date?> {
        Binding<Date?>(
            get: { self.currentDailyRecord.notfTimes[mileStoneId] ?? nil }, // Fallback value
            set: { self.currentDailyRecord.notfTimes[mileStoneId] = $0 }
        )
    }

}


extension DailyRecordsViewModel { // todo
    
    func insertTodo(after todoId: String) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.created_todo[date] == nil { self.created_todo[date] = []}

        let newTodoId = UUID().uuidString
        self.created_todo[date]?.append(newTodoId)
        self.currentDailyRecord.todos[newTodoId] = ""
        self.currentDailyRecord.todos_done[newTodoId] = false
//        self.currentDailyRecord.todoCount = self.currentDailyRecord.todos.count
        
        if let targetIdx = self.currentDailyRecord.todos_order.firstIndex(of: todoId) {
            self.currentDailyRecord.todos_order.insert(newTodoId, at: targetIdx+1)
        }
        else { // if deleted on other device, todoId can be deleted due to fetch from listener. Then append it at last
            self.currentDailyRecord.todos_order.append(newTodoId)
        }

        saveCurrentDailyRecord()

    }
    
    func markUpdate_todo(of todoId: String) {
        if self.updated_todo[self.currentDate] == nil { self.updated_todo[self.currentDate] = []}
        self.updated_todo[self.currentDate]?.append(todoId)
    }
//    func updateTodoContent(todoId: String, to updatedContent: String) {
//        guard let date = currentDailyRecord.id else { return }
//        if self.updated_todo[date] == nil { self.updated_todo[date] = []}
//        
//        self.updated_todo[date]?.append(todoId)
//        self.currentDailyRecord.todos[todoId]? = updatedContent
//        
//        saveCurrentDailyRecord()
//    }
//    func updateTodoDone(todoId: String){
//        guard let date = currentDailyRecord.id else { return }
//        if self.updated_todo[date] == nil { self.updated_todo[date] = []}
//        
//        self.updated_todo[date]?.append(todoId)
//        self.currentDailyRecord.todos_done[todoId]?.toggle()
//        
//        saveCurrentDailyRecord()
//
//    }
//    func updateTodoPurposes(todoId: String, to updatedPurposes: [String]){
//        guard let date = currentDailyRecord.id else { return }
//        if self.updated_todo[date] == nil { self.updated_todo[date] = []}
//        
//        self.updated_todo[date]?.append(todoId)
//        self.currentDailyRecord.todos_purposes[todoId] = updatedPurposes
//        
//        saveCurrentDailyRecord()
//
//    }
    
    func deleteTodo(_ todoId: String) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.deleted_todo[date] == nil { self.deleted_todo[date] = []}
        
        self.deleted_todo[date]?.append(todoId)
        self.currentDailyRecord.todos.removeValue(forKey: todoId)
        self.currentDailyRecord.todos_done.removeValue(forKey: todoId)
//        self.currentDailyRecord.todoCount = self.currentDailyRecord.todos.count
        
        if let targetIdx = self.currentDailyRecord.todos_order.firstIndex(of: todoId) {
            self.currentDailyRecord.todos_order.remove(at: targetIdx)
        }
                
        saveCurrentDailyRecord()
        
    }
    
    var todoOrder_existencySafe: [String] {
        self.currentDailyRecord.todos_order.compactMap { self.currentDailyRecord.todos[$0] == nil ? nil : $0 }
    }
    

    
}

extension DailyRecordsViewModel { // schedule
    
    func insertSchedule(after scheduleId: String) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.created_schedule[date] == nil { self.created_schedule[date] = []}

        let newScheduleId = UUID().uuidString
        self.created_schedule[date]?.append(newScheduleId)
        self.currentDailyRecord.schedules[newScheduleId] = ""
//        self.currentDailyRecord.scheduleCount = self.currentDailyRecord.schedules.count
        
        if let targetIdx = self.currentDailyRecord.schedules_order.firstIndex(of: scheduleId) {
            self.currentDailyRecord.schedules_order.insert(newScheduleId, at: targetIdx+1)
        }
        else { // if deleted on other device, scheduleId can be deleted due to fetch from listener. Then append it at last
            self.currentDailyRecord.schedules_order.append(newScheduleId)
        }

        saveCurrentDailyRecord()
        
    }
    
    func updateSchedule(scheduleId: String, to updatedContent: String) {
        guard let date = currentDailyRecord.id else { return }
        if self.updated_schedule[date] == nil { self.updated_schedule[date] = []}
        
        self.updated_schedule[date]?.append(scheduleId)
        self.currentDailyRecord.schedules[scheduleId]? = updatedContent
        
        saveCurrentDailyRecord()
    }
    func updateSchedulePurposes(scheduleId: String, to updatedPurposes: [String]){
        guard let date = currentDailyRecord.id else { return }
        if self.updated_schedule[date] == nil { self.updated_schedule[date] = []}
        
        self.updated_schedule[date]?.append(scheduleId)
        self.currentDailyRecord.schedules_purposes[scheduleId] = updatedPurposes
        
        saveCurrentDailyRecord()
    }

    
    func deleteSchedule(_ scheduleId: String) {
        guard let date = self.currentDailyRecord.id else { return }
        if self.deleted_schedule[date] == nil { self.deleted_schedule[date] = []}
        
        self.deleted_schedule[date]?.append(scheduleId)
        self.currentDailyRecord.schedules.removeValue(forKey: scheduleId)
//        self.currentDailyRecord.scheduleCount = self.currentDailyRecord.schedules.count
        
        if let targetIdx = self.currentDailyRecord.schedules_order.firstIndex(of: scheduleId) {
            self.currentDailyRecord.schedules_order.remove(at: targetIdx)
        }
                
        saveCurrentDailyRecord()
        
    }
    

}


extension DailyRecordsViewModel { // 기타

    func adjustedOrder(prev:[String], new:[String], existingIds:[String]) -> [String] {
        
        let ghostIds:[String] = new.filter({!existingIds.contains($0)})
        var result:[String] = new
        
        for id in existingIds {
            if !new.contains(id) {
                result.append(id)
            }
        }
        
        for id in ghostIds {
            result.removeAll {$0 == id}
        }
        
//        if !ghostIds.isEmpty {
//            
//        }
        
        return result
        
        
    }
    

    
    func purposesOf(_ id: String) -> [String] {
        if let purposes = self.currentDailyRecord.todos_purposes[id] {
            return purposes
        } else if let purposes = self.currentDailyRecord.schedules_purposes[id] {
            return purposes
        } else { return [] }
    }
    

    func minutesOf(_ mountainId: String) -> Minutes {
        return self.currentDailyRecord.ascentData[mountainId] ?? 0
    }
    func goalOf(_ mountainId: String) -> Minutes? {
        return self.currentDailyRecord.dailyGoals[mountainId]
    }
    func notfTimeOf(_ mountainId: String) -> Date? {
        return self.currentDailyRecord.notfTimes[mountainId]
    }
    
    var currentDate: YYYYMMDD {
        return self.currentDailyRecord.id ?? dateToString(Date())
    }
    
//    func visibleDailyRecords(hiddenMountainIds:Set<String>, showHiddenMountains:Bool) -> [DailyRecord_fb] {
//        let dailyRecords_filtered:[DailyRecord_fb] = self.dailyRecords.values
//            .filter({$0.hasContent && $0.id != nil})
//            .filter({($0.getLocalDate() ?? getStartDateOfNow()) < .now })
//        if showHiddenMountains {
//            return dailyRecords_filtered
//                .sorted(by: {
//                    if let date0 = $0.id, let date1 = $1.id {
//                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
//                    } else if $0.id == nil {
//                        return false  // Places items with nil date after those with a non-nil date
//                    } else {
//                        return true  // Ensures $0 with a date is before $1 with nil
//                    }
//                })
//        } else {
//            return dailyRecords_filtered
//                .filter({
//                    $0.hasTodoOrDiary ||
//                    !Set($0.ascentData.filter({$0.value != 0}).map{$0.key})
//                    .subtracting(hiddenMountainIds).isEmpty
//                })
//                .sorted(by:{
//                    if let date0 = $0.id, let date1 = $1.id {
//                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
//                    } else if $0.id == nil {
//                        return false  // Places items with nil date after those with a non-nil date
//                    } else {
//                        return true  // Ensures $0 with a date is before $1 with nil
//                    }
//                })
//        }
//    }

    
//    func saveTodo
}




//class UserDataModel
