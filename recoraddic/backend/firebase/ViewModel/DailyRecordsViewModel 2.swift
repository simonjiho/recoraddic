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
//    var dailyRecords:[String:DailyRecord_fb] = [:]
//    
//    private var user: User?
//    private var db = Firestore.firestore()
//    private var cancellables = Set<AnyCancellable>()
//    
//    private var lastTimeMomentumChecked: Date = Date()
//    
//    var latestFetchTime: Date = Date()
//    var latestUpdateTime1: Date = Date()
//    var latestUpdateTime2: Date = Date()
//    
//    
//    // the below dictionaries should be updated immediately if it successes to store in fireStore
//    private var deletedFromThisDevice_onRequest: [String] = [] // todos and schedules id
//    private var createdFromThisDevice_onRequest: [String] = [] // todos and schedules id
//    
//    var timer: Timer?
//    let delay: TimeInterval = 1.0
//    
//    init() {
//        registerAuthStateHandler()
//        
//        //        $user
//        //            .compactMap { $0 }
//        //            .sink { user in
//        ////                self.favourite.userId = user.uid
//        ////                self.addCurrentDailyRecordListenter()
//        //
//        //            }
//        //            .store(in: &cancellables) // didn't understand here.
//        
//        fetchDailyRecords()
//        changeCurrentDailyRecord(Date())
//        addCurrentDailyRecordListener()
//        //        self.addCurrentDailyRecordListenter(Date())
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
//        if let targetDailyRecord = self.dailyRecords[currentDate_str] {
//            self.currentDailyRecord = targetDailyRecord
//        } else {
//            createNewDailyRecord(currentDate_str)
//        }
//    }
//    
//    
//    func createNewDailyRecord(_ currentDate_str: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        let newDailyRecord = DailyRecord_fb(id: currentDate_str)
//        self.currentDailyRecord = newDailyRecord
//        self.dailyRecords[currentDate_str] = newDailyRecord
//        
//        do {
//            try userData.collection(dailyRecordCollection).addDocument(from: newDailyRecord)
//        } catch {
//            print("failed to add new dailyRecord on fireStore: \(error)")
//        }
//    }
//    
//    
//    
//    func addCurrentDailyRecordUpdateTimer() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        
//        // JONNA 짜임새 있게 짜보자.
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            guard let date_str:String = self.currentDailyRecord.id else { return }
//            // TODO: guard로 업데이트 되야하는 것 있는지 미리 체크해보기([새로 생긴/최근에 없앤] [todo/schedule/mountaindata])
//            if self.deletedFromThisDevice_onRequest.count == 0 && self.createdFromThisDevice_onRequest.count == 0 {
//                continue
//            }
//
//            for deletedId in self.deletedFromThisDevice_onRequest {
//                userData.collection(dailyRecordCollection).document(date_str).updateData()
//            }
//            
//            for createdId in self.createdFromThisDevice_onRequest {
//                if self.currentDailyRecord.todos.keys.contains(createdId) {
//                    
//                }
//                else if self.currentDailyRecord.schedules.keys.contains(createdId) {
//                    
//                }
//            }
//        }
//    }
//    
//    private func update
//    
//    
//    func addCurrentDailyRecordListener() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        userData.collection(dailyRecordCollection)
//        //          .order(by: "orderIndex", descending: false)
//            .addSnapshotListener { querySnapshot, error in
//                Task {
//                    guard let currentDate_str = self.currentDailyRecord.id else { return }
//                    var updatedCurrentDailyRecord = try await userData.collection(dailyRecordCollection).document(currentDate_str).getDocument(as: DailyRecord_fb.self)
//                    
//                    for createdId in self.createdFromThisDevice_onRequest {
//                        if !updatedCurrentDailyRecord.todos.keys.contains(createdId) {
//                            updatedCurrentDailyRecord.todos[createdId] = self.currentDailyRecord.todos[createdId]
//                        }
//                        else if !updatedCurrentDailyRecord.schedules.keys.contains(createdId) {
//                            updatedCurrentDailyRecord.schedules[createdId] = self.currentDailyRecord.todos[createdId]
//                        }
//                    }
//                    for deletedId in self.deletedFromThisDevice_onRequest {
//                        if updatedCurrentDailyRecord.todos.keys.contains(deletedId) {
//                            updatedCurrentDailyRecord.todos.removeValue(forKey: deletedId)
//                        }
//                        else if updatedCurrentDailyRecord.schedules.keys.contains(deletedId) {
//                            updatedCurrentDailyRecord.schedules.removeValue(forKey: deletedId)
//                        }
//                    }
//                    
//                    let adjustedTodoOrder:[String] = self.adjustedOrder(prev: self.currentDailyRecord.todos_order, new: updatedCurrentDailyRecord.todos_order, existingIds: Array(updatedCurrentDailyRecord.todos.keys))
//                    let adjustedScheduleOrder:[String] = self.adjustedOrder(prev: self.currentDailyRecord.schedules_order, new: updatedCurrentDailyRecord.schedules_order, existingIds: Array(updatedCurrentDailyRecord.schedules.keys))
//                    
//                    updatedCurrentDailyRecord.todos_order = adjustedTodoOrder
//                    updatedCurrentDailyRecord.schedules_order = adjustedScheduleOrder
//                    
//                    self.currentDailyRecord = updatedCurrentDailyRecord
//                    self.dailyRecords[currentDate_str] = updatedCurrentDailyRecord
//                }
//                //              documents.compactMap { try? $0.data(as: Task.self) }
//            }
//    }
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
//                            //                            self.dailyRecords.append(dailyRecord)
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
//    
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
//}
//
//
//
//    
//
//extension DailyRecordsViewModel { // mileStone
//    
//    func addAscentData(_ mountainIds: [String]) {
//        
//        // add new dailyQuests -> on currentDailyQuests, dailyQuests, and fireStore
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let currentDate_str = currentDailyRecord.id else { return /*which will never happen*/ }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        let dataForUpdate: [String: Any] = {
//            var result: [String: Any] = [:]
//            for mountainId in mountainIds {
//                result["mileStoneData.\(mountainId)"] = 0
//            }
//            return result
//        }()
//        
//        userData.collection(dailyRecordCollection).document(currentDate_str).setData(dataForUpdate)
//        
//        
//    }
//    
//    func updateAscentData(_ date_str :String,_ mountainId : String,_ value: Int) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        self.currentDailyRecord.ascentData[mountainId]? = value
//        
//        
//        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
//            Task {
//                try await userData.collection(dailyRecordCollection).document(date_str).updateData(["mileStoneData.\(mountainId)": value])
//            }
//        }
//    }
//    
//    func deleteAscentData(_ date_str :String,_ mountainId : String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        
//        self.currentDailyRecord.ascentData.removeValue(forKey: mountainId)
//        
//        Task {
//            try await userData.collection(dailyRecordCollection).document(date_str).updateData(["mileStoneData.\(mountainId)": FieldValue.delete()])
//        }
//    }
//    func deleteAscentData(_ date:Date,_ mountainId: String) {
//        let date_str = dateToString(date)
//        deleteAscentData(date_str, mountainId)
//    }
//    
//
//}
//
//
//extension DailyRecordsViewModel { // todo
//    
//    func insertTodo(after todoId: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        // use todoId if todo is not suddenly deleted from other device
//        
//        let newTodoId = UUID().uuidString
//        
//        self.createdFromThisDevice_onRequest.append(newTodoId)
//        
//        self.currentDailyRecord.todos[newTodoId] = ""
//        self.currentDailyRecord.todos_done[newTodoId] = false
//        self.currentDailyRecord.todoCount = self.currentDailyRecord.todos.count
//        
//        if let targetIdx = self.currentDailyRecord.todos_order.firstIndex(of: todoId) {
//            self.currentDailyRecord.todos_order.insert(todoId, at: targetIdx+1)
//        }
//        else { // if deleted on other device, todoId can be deleted due to fetch from listener. Then append it at last
//            self.currentDailyRecord.todos_order.append(todoId)
//        }
//        
//        self.dailyRecords[date] = self.currentDailyRecord
//        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_createTodo(newTodoId, content: "")
////            sendRequest_updateTodoOrder()
////            self.latestUpdateTime1 = Date()
////        }
//        
//    }
//    
////    func insertTodos(of contents:[String]) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        guard let date = currentDailyRecord.id else { return }
////        // use todoId if todo is not suddenly deleted from other device
////        
////        for content in contents {
////            let newTodoId = UUID().uuidString
////            self.createdFromThisDevice_onRequest.append(newTodoId)
////            self.currentDailyRecord.todos[newTodoId] = content
////            self.currentDailyRecord.todos_done[newTodoId] = false
////        }
////
////        self.currentDailyRecord.todoCount = self.currentDailyRecord.todos.count
////        
////        if let targetIdx = self.currentDailyRecord.todos_order.firstIndex(of: todoId) {
////            self.currentDailyRecord.todos_order.insert(todoId, at: targetIdx+1)
////        }
////        else { // if deleted on other device, todoId can be deleted due to fetch from listener. Then append it at last
////            self.currentDailyRecord.todos_order.append(todoId)
////        }
////        
////        self.dailyRecords[date] = self.currentDailyRecord
////        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_createTodo(newTodoId, content: "")
////            sendRequest_updateTodoOrder()
////            self.latestUpdateTime1 = Date()
////        }
////    }
//    
//    
//    func updateTodo(todoId: String, to updatedContent: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        
//        currentDailyRecord.schedules[todoId]? = updatedContent
//        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_updateSchedule(scheduleId: todoId, to: "")
////            self.latestUpdateTime1 = Date()
////        }
//
//        
//    }
//    
////    private func sendRequest_updateTodo(todoId: String, to updatedContent: String) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        guard let date = currentDailyRecord.id else { return }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(date)
////        
////        
////        docRef.updateData([
////            "todos.\(todoId)": updatedContent,
////        ])
////    }
//    
//    // This is recursive func
////    private func sendRequest_createTodo(_ todoId: String, content: String, backOffDelay: TimeInterval = 1.0) { // recursive func
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        if backOffDelay > 10.0 {
////            print("Eventually Failed to update new Todo")
////            return
////        }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDailyRecord.id ?? "")
////        
////        
////        docRef.updateData([
////            "todos.\(todoId)": content,
////            "todoCount": self.currentDailyRecord.todoCount
////        ])
////        ]) { error in
////            if let error = error {
////                print("Error updating document: \(error)")
////                
////                if self.currentDailyRecord.todos[todoId] == nil {
////                    self.createdFromThisDevice_onRequest.removeAll {$0 == todoId}
////                    return
////                }
////                
////                DispatchQueue.main.asyncAfter(deadline: .now() + backOffDelay) {
////                    self.sendRequest_createTodo(todoId, content: self.currentDailyRecord.todos[todoId] ?? "", backOffDelay: backOffDelay*2)
////                }
////                
////            } else {
////                print("Document successfully updated!")
////                self.createdFromThisDevice_onRequest.removeAll {$0 == todoId}
////            }
////        }
////        
////        
////    }
//    
////    private func sendRequest_updateTodoOrder() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        guard let currentDate_str = currentDailyRecord.id else { return }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDate_str)
////        
////        docRef.updateData([
////            "todos_order": self.currentDailyRecord.todos_order
////        ])
////            
////    }
//    
//    func removeTodo(_ todoId: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        // use todoId if todo is not suddenly deleted from other device
//        
//        
//        self.deletedFromThisDevice_onRequest.append(todoId)
//        
//        self.currentDailyRecord.todos.removeValue(forKey: todoId)
//        self.currentDailyRecord.todos_done.removeValue(forKey: todoId)
//        self.currentDailyRecord.todoCount = self.currentDailyRecord.todos.count
//        
//        if let targetIdx = self.currentDailyRecord.todos_order.firstIndex(of: todoId) {
//            self.currentDailyRecord.todos_order.insert(todoId, at: targetIdx+1)
//        }
//        else { // if deleted on other device, todoId can be deleted due to fetch from listener. Then append it at last
//            self.currentDailyRecord.todos_order.append(todoId)
//        }
//        
//        self.dailyRecords[date] = self.currentDailyRecord
//        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_deleteTodo(todoId)
////            sendRequest_updateTodoOrder()
////            self.latestUpdateTime1 = Date()
////        }
//        
//    }
//    
//    // This is recursive func
////    private func sendRequest_deleteTodo(_ todoId: String, backOffDelay: TimeInterval = 1.0) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        if backOffDelay > 10.0 {
////            print("Eventually Failed to update new Todo")
////            return
////        }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDailyRecord.id ?? "")
////        
////        
////        docRef.updateData([
////            "todos.\(todoId)": FieldValue.delete(),
////            "todoCount": self.currentDailyRecord.todoCount
////        ])
////        ]) { error in
////            if let error = error {
////                // Handle failure
////                print("Error updating document: \(error)")
////                
////                DispatchQueue.main.asyncAfter(deadline: .now() + backOffDelay) {
////                    self.sendRequest_deleteTodo(todoId, backOffDelay: backOffDelay*2)
////                }
////                
////            } else {
////                // SUCCESS: The update is on the server
////                print("Document successfully updated!")
////                
////                self.deletedFromThisDevice_onRequest.removeAll {$0 == todoId}
////                
////            }
////        }
////    }
////}
//
//extension DailyRecordsViewModel { // schedule
//    
//    func insertSchedule(after scheduleId: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        // use scheduleId if schedule is not suddenly deleted from other device
//        
//        let newScheduleId = UUID().uuidString
//        
//        self.createdFromThisDevice_onRequest.append(newScheduleId)
//        
//        self.currentDailyRecord.schedules[newScheduleId] = ""
//        self.currentDailyRecord.scheduleCount = self.currentDailyRecord.schedules.count
//        
//        if let targetIdx = self.currentDailyRecord.schedules_order.firstIndex(of:  newScheduleId) {
//            self.currentDailyRecord.schedules_order.insert(scheduleId, at: targetIdx+1)
//        }
//        else { // if deleted on other device, todoId can be deleted due to fetch from listener. Then append it at last
//            self.currentDailyRecord.schedules_order.append(newScheduleId)
//        }
//        
//        self.dailyRecords[date] = self.currentDailyRecord
//        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_createSchedule(newScheduleId, content: "")
////            sendRequest_updateScheduleOrder()
////            self.latestUpdateTime1 = Date()
////        }
//        
//        
//    }
//    
//    func updateSchedule(scheduleId: String, to updatedContent: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        
//        currentDailyRecord.schedules[scheduleId]? = updatedContent
//        
////        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_updateSchedule(scheduleId: scheduleId, to: "")
////            self.latestUpdateTime1 = Date()
////        }
//
//        
//    }
//    
////    func sendRequest_updateSchedule(scheduleId: String, to updatedContent: String) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        guard let date = currentDailyRecord.id else { return }
////        
////        
////        let docRef = userData.collection(dailyRecordCollection).document(date)
////        
////        
////        docRef.updateData([
////            "schedules.\(scheduleId)": updatedContent,
////        ])
////    }
//    
//    
//    // This is recursive func
////    func sendRequest_createSchedule(_ scheduleId: String, content: String, backOffDelay: TimeInterval = 1.0) { // recursive func
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        if backOffDelay > 10.0 {
////            print("Eventually Failed to create new schedule")
////            return
////        }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDailyRecord.id ?? "")
////        
////        
////        docRef.setData([
////            "schedules.\(scheduleId)": content,
////            "scheduleCount": self.currentDailyRecord.scheduleCount
////        ])
////        ]) { error in
////            if let error = error {
////                print("Error updating document: \(error)")
////                
////                if self.currentDailyRecord.schedules[scheduleId] == nil {
////                    self.createdFromThisDevice_onRequest.removeAll {$0 == scheduleId}
////                    return
////                }
////                
////                DispatchQueue.main.asyncAfter(deadline: .now() + backOffDelay) {
////                    self.sendRequest_createSchedule(scheduleId, content: self.currentDailyRecord.schedules[scheduleId] ?? "", backOffDelay: backOffDelay*2)
////                }
////                
////            } else {
////                print("Document successfully updated!")
////                self.createdFromThisDevice_onRequest.removeAll {$0 == scheduleId}
////            }
////        }
////    }
//    
////    func sendRequest_updateScheduleOrder() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        guard let currentDate_str = currentDailyRecord.id else { return }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDate_str)
////        
////        docRef.updateData([
////            "schedules_order": self.currentDailyRecord.schedules_order
////        ])
////            
////    }
//    
//    func removeSchedule(_ scheduleId: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userData = db.collection(usersDataCollection).document(uid)
//        guard let date = currentDailyRecord.id else { return }
//        // use scheduleId if schedule is not suddenly deleted from other device
//        
//        
//        self.deletedFromThisDevice_onRequest.append(scheduleId)
//        
//        self.currentDailyRecord.schedules.removeValue(forKey: scheduleId)
//        self.currentDailyRecord.scheduleCount = self.currentDailyRecord.schedules.count
//        
//        if let targetIdx = self.currentDailyRecord.schedules_order.firstIndex(of: scheduleId) {
//            self.currentDailyRecord.schedules_order.insert(scheduleId, at: targetIdx+1)
//        }
//        else { // if deleted on other device, scheduleId can be deleted due to fetch from listener. Then append it at last
//            self.currentDailyRecord.schedules_order.append(scheduleId)
//        }
//        
//        self.dailyRecords[date] = self.currentDailyRecord
//        
//        if Date().timeIntervalSince(self.latestUpdateTime1) > delay {
////            sendRequest_deleteSchedule(scheduleId)
////            sendRequest_updateScheduleOrder()
//            self.latestUpdateTime1 = Date()
//        }
//        
//    }
//    
//    // This is recursive func
////    func sendRequest_deleteSchedule(_ scheduleId: String, backOffDelay: TimeInterval = 1.0) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let userData = db.collection(usersDataCollection).document(uid)
////        if backOffDelay > 10.0 {
////            print("Eventually Failed to update new schedule")
////            return
////        }
////        
////        let docRef = userData.collection(dailyRecordCollection).document(currentDailyRecord.id ?? "")
////        
////        
////        docRef.updateData([
////            "schedules.\(scheduleId)": FieldValue.delete(),
////            "scheduleCount": self.currentDailyRecord.scheduleCount
////        ])
////        ]) { error in
////            if let error = error {
////                // Handle failure
////                print("Error updating document: \(error)")
////                
////                DispatchQueue.main.asyncAfter(deadline: .now() + backOffDelay) {
////                    self.sendRequest_deleteSchedule(scheduleId, backOffDelay: backOffDelay*2)
////                }
////                
////            } else {
////                // SUCCESS: The update is on the server
////                print("Document successfully updated!")
////                
////                self.deletedFromThisDevice_onRequest.removeAll {$0 == scheduleId}
////                
////            }
////        }
////    }
//}
//
//
//// TODO: update value of schedule or todo -> 그다음 다른것들
//
//
//extension DailyRecordsViewModel {
//    
//
//    
//
//    func adjustedOrder(prev:[String], new:[String], existingIds:[String]) -> [String] {
//        
//        let ghostIds:[String] = new.filter({!existingIds.contains($0)})
//        var result:[String] = new
//        
//        for id in existingIds {
//            if !new.contains(id) {
//                result.append(id)
//            }
//        }
//        
//        for id in ghostIds {
//            result.removeAll {$0 == id}
//        }
//        
////        if !ghostIds.isEmpty {
////            
////        }
//        
//        return result
//        
//        
//    }
//    
//
//    
//    
//    
//    
//    func updateDailyRecordsMomentum() {
//        let dailyRecords_ids: [String] = Array(self.dailyRecords.keys).sorted()
//        let dates_withContent: [Date] = dailyRecords_ids.filter({self.dailyRecords[$0]?.hasContent ?? false}).map({stringToDate($0)})
//
//        for date_str in dailyRecords_ids {
//            updateStreakAndAbsence(of:&self.dailyRecords[date_str], dates_withContent: dates_withContent)
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
//    func updateStreakAndAbsence(of dailyRecord:inout DailyRecord_fb?, dates_withContent: [Date]) {
//        
//        guard let date_str = dailyRecord?.id else { return }
//        let date:Date = stringToDate(date_str)
//        
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
//
//    }
//    
//
//    
//    
////    func visibleDailyRecords(hiddenMountainIds:Set<String>, showHiddenMountains:Bool) -> [DailyRecord_fb] {
////        let dailyRecords_filtered:[DailyRecord_fb] = self.dailyRecords.values
////            .filter({$0.hasContent && $0.id != nil})
////            .filter({($0.getLocalDate() ?? getStartDateOfNow()) < .now })
////        if showHiddenMountains {
////            return dailyRecords_filtered
////                .sorted(by: {
////                    if let date0 = $0.id, let date1 = $1.id {
////                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
////                    } else if $0.id == nil {
////                        return false  // Places items with nil date after those with a non-nil date
////                    } else {
////                        return true  // Ensures $0 with a date is before $1 with nil
////                    }
////                })
////        } else {
////            return dailyRecords_filtered
////                .filter({
////                    $0.hasTodoOrDiary ||
////                    !Set($0.ascentData.filter({$0.value != 0}).map{$0.key})
////                    .subtracting(hiddenMountainIds).isEmpty
////                })
////                .sorted(by:{
////                    if let date0 = $0.id, let date1 = $1.id {
////                        return date0 > date1  // Sorts by date in descending order if both dates are non-nil
////                    } else if $0.id == nil {
////                        return false  // Places items with nil date after those with a non-nil date
////                    } else {
////                        return true  // Ensures $0 with a date is before $1 with nil
////                    }
////                })
////        }
////    }
//
//    
////    func saveTodo
//}
//
//
//
//
////class UserDataModel
