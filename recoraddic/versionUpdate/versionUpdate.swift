//import Foundation
//import SwiftData
//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
//
//
//struct FbMigrationLoadingView: View { // migration for users updated from earlier version than 1.1.0 (will be deprecated after 2025)
//    
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort:\Profile.createdTime) var profiles: [Profile]
//    @Query(sort:\Quest.name) var quests: [Quest]
//    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord] // currentDailyRecord -> date = nil -> thus it places on first on sorted array
//    @Query var dailyQuests: [DailyQuest]
//    @Query var todos: [Todo]
//    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
//    @Query var todo_presets: [Todo_preset]
//    
//    @Binding var migrationCompleted: Bool
//    
//    
//    var body: some View {
//        VStack {
//            Image("loadingLogo")
//                .resizable()
//                .scaledToFit()
//                .frame(width: UIScreen.main.bounds.width/5)
//            
//            
//            HStack(spacing:10.0) {
//                Text("업데이트 중...")
//                ProgressView() // This is the loading circle
//                    .progressViewStyle(CircularProgressViewStyle())
//                //                    .scaleEffect(1.5) // Adjust the scale of the loading circle
//            }
//            .padding(.top, 5)
//            
//        }
//        .containerRelativeFrame([.horizontal,.vertical])
//        .background(.quinary)
//        .onAppear() {
//            if profiles.count == 0 { migrationCompleted = true }
//            else {
//                Task {
//                    do {
//                        if readyToMigrateFromSwiftData() {
//                            try await firebaseMigration()
//                        }
//                    }
//                    migrationCompleted = true
//                }
//            }
//        }
//    }
//    
//    func allDataRemoved() -> Bool {
//        return quests.isEmpty && dailyRecords.isEmpty && dailyQuests.isEmpty && dailyRecordSets.isEmpty && todo_presets.isEmpty && todos.isEmpty
//    }
//    
//    func readyToMigrateFromSwiftData() -> Bool {
//        let needMigrationFromSwiftData:Bool = !profiles.isEmpty
//        if needMigrationFromSwiftData == false { return false }
//        
//        var db = Firestore.firestore()
//        guard let uid = Auth.auth().currentUser?.uid else { return false }
//        
//        return true
//        
////        do {
////            let querySnapshot = try await db.collection(userDataCollection).whereField("userId", isEqualTo: uid).limit(to: 1).getDocuments()
////            
////            var (userInfo, documentId):(UserData,String) = try {
////                if let userInfo = try querySnapshot.documents.first?.data(as: UserData.self) {
////                    return (userInfo, querySnapshot.documents.first?.documentID ?? "")
////                    
////                }
////                else {
////                    var userInfo:UserData = UserData.empty
////                    userInfo.userId = uid
////                    let documentId = try db.collection(userDataCollection).addDocument(from:userInfo).documentID
////                    return (userInfo,documentId)
////                }
////            }()
////            
////            if needMigrationFromSwiftData {
////                userInfo.needsMigrationFromSwiftData = true
//////                try await db.collection(userDataCollection).document(documentId).updateData(["needsMigrationFromSwiftData":true])
////                try db.collection(userDataCollection).document(documentId).setData(from: userInfo)
////            }
////            
////            return true
////        } catch {
////            print("failed to save on firestore if it needs migration: \(error)")
////            return false
////        }
//        
//        
//    }
//    
//    func firebaseMigration() async throws {
//        
//        var db = Firestore.firestore()
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userDataPath = db.collection(usersDataCollection)
//
//        Task {
//
//            do {
//                let snapshot = try await userDataPath.whereField("userId", isEqualTo: uid).limit(to: 1).getDocuments()
//                
//                var userData = UserData.empty
//                userData.userId = uid
//                if let profile = profiles.first {
//                    userData.startedDate = profile.createdTime
//                }
//                
//                if snapshot.isEmpty {
//                    let documentReference = try userDataPath.addDocument(from: userData)
//                } else {
//                    try snapshot.documents.first?.reference.setData(from: userData)
//                }
//                
//            } catch {
//                print("error during migrating userData:\(error)")
//            }
//            
//            
//            let userDataRootPath: DocumentReference? = try await userDataPath.whereField("userId", isEqualTo: uid).limit(to: 1).getDocuments().documents.first?.reference
//            let dailyRecordSetsPath: CollectionReference? = userDataRootPath?.collection(dailyRecordSetsCollection)
//            let dailyRecordsPath: CollectionReference? = userDataRootPath?.collection(dailyRecordsCollection)
//            let questsPath: CollectionReference? = userDataRootPath?.collection(dailyRecordsCollection)
//            let presets_TodoPath: CollectionReference? = userDataRootPath?.collection(presets_TodoCollection)
//            
//            
//            do {
//                for dailyRecordSet in dailyRecordSets {
//                    var dailyRecordSet_fb = DailyRecordSet_fb.empty
//                    dailyRecordSet_fb.backgroundThemeName = dailyRecordSet.backgroundThemeName
//                    dailyRecordSet_fb.start = dailyRecordSet.start
//                    dailyRecordSet_fb.end = dailyRecordSet.end
//                    dailyRecordSet_fb.themeName = dailyRecordSet.dailyRecordThemeName
//                    dailyRecordSet_fb.themeStyleIndex1 = dailyRecordSet.dailyRecordColorIndex
//                    dailyRecordSet_fb.termGoals = dailyRecordSet.termGoals
//                    try dailyRecordSetsPath?.addDocument(from: dailyRecordSet_fb)
//                    
//                    guard let dailyRecords = dailyRecordSet.dailyRecords else { continue }
//                    for dr in dailyRecords {
//                        var dailyRecord_fb = DailyRecord_fb.empty
//                        dailyRecord_fb.dailyText = dr.dailyText
//                        dailyRecord_fb.dailyTextType = dr.dailyTextType
//                        dailyRecord_fb.date = dr.date
//                        dailyRecord_fb.isFavorite = dr.isFavorite
//                        dailyRecord_fb.mood = dr.mood
//                        let dailyRecordDocRef = try dailyRecordsPath?.addDocument(from: dailyRecord_fb)
//                        let todoCollectionPath = dailyRecordDocRef?.collection(todoCollection)
//                        let dailyQuestCollectionPath = dailyRecordDocRef?.collection(dailyQuestCollection)
//                        
//                        guard let todoList = dr.todoList else { continue } // will not happen
//                        for todo in todos {
//                            var todo_fb = Todo_fb.empty
//                            todo_fb.content = todo.content
//                            todo_fb.createdTime = todo.createdTime
//                            todo_fb.done = todo.done
//                            todo_fb.idx = todo.idx
//                            todo_fb.purposes = todo.purposes
//                            try todoCollectionPath?.addDocument(from: todo_fb)
//                        }
//                        
//                        guard let dailyQuestList = dr.dailyQuestList else { continue } // will not happen
//                        for dailyQuest in dailyQuestList {
//                            var dailyQuest_fb = DailyQuest_fb.empty
//                            dailyQuest_fb.dailyGoal = dailyQuest.dailyGoal
//                            dailyQuest_fb.data = dailyQuest.data
//                            dailyQuest_fb.createdTime = dailyQuest.createdTime
//                            dailyQuest_fb.currentTier = dailyQuest.currentTier
//                            dailyQuest_fb.customDataTypeNotation = dailyQuest.customDataTypeNotation
//                            dailyQuest_fb.dataType = dailyQuest.dataType
//                            dailyQuest_fb.notfTime = dailyQuest.notfTime
//                            dailyQuest_fb.purposes = dailyQuest.purposes
//                            dailyQuest_fb.questSubName = dailyQuest.questSubName
//                            dailyQuest_fb.stopwatchStart = dailyQuest.stopwatchStart
//                            try dailyQuestCollectionPath?.addDocument(from: dailyQuest_fb)
//                        }
//                    }
//                    
//                    modelContext.delete(dailyRecordSet) // cascading dailyRecords that cascades with todos and dailyQuests
//                }
//            } catch {
//                print("error during migrating dailyRecordSets:\(error)")
//            }
//            
//            
//            for quest in quests {
//                modelContext.delete(quest)
//            }
//            
//            for todo_preset in todo_presets {
//                modelContext.delete(todo_preset)
//            }
//            
//            
//            // todo: connect all dailyRecords with dailyQuests
//            
//            if allDataRemoved() {
//                for profile in profiles {
//                    modelContext.delete(profile)
//                }
//            }
//            
//        }
//        
//    }
//
//        
//
//    
//    
//    
//    func handleUpdateFromOldVersion() {
//        
//        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
//        let defaults = UserDefaults.standard
//        let lastVersionKey = "lastAppVersion"
//        
//        if defaults.value(forKey: "") == nil {
//            
//        }
//        
//        guard let lastVersion = defaults.string(forKey: lastVersionKey) else {
//            defaults.set(currentVersion, forKey: lastVersionKey)
//            return
//        }
//        if lastVersion == currentVersion { return }
//
//        // Update codes
//        
//        // Save the current version for future checks
//        defaults.set(currentVersion, forKey: lastVersionKey)
//        
//
//    }
//    
//
//    
//    
//}
//
//
//
//func isOlderVersion(_ version: String, than otherVersion: String) -> Bool {
//    let versionComponents = version.split(separator: ".").compactMap { Int($0) }
//    let otherVersionComponents = otherVersion.split(separator: ".").compactMap { Int($0) }
//    
//    for (v1, v2) in zip(versionComponents, otherVersionComponents) {
//        if v1 < v2 {
//            return true
//        } else if v1 > v2 {
//            return false
//        }
//    }
//    
//    return versionComponents.count < otherVersionComponents.count
//}
//
//
