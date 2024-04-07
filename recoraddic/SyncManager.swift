//
//  ckContainer.swift
//  recoraddic
//
//  Created by 김지호 on 3/1/24.
//

// 나중에는 이미지같은 큰데이터가 늦게 동기화 되더라도 다른 데이터들은 매우 빠른 속도로 동기화 되게 만들기? fetch주기를 자주 바꿀 수 있나?
// 나중에 알아서 같은것 없애기
import CloudKit
import Foundation
import os.log
import SwiftData
//MARK: 삭제 후 재설치 -> 기존데이터 가져오기만 함 / 로그아웃 후 재로그인 -> 기존데이터 가지고 오고 반영 전에 query에서 늦게 받아들여서.. 데이터 또 쌓임
//MARK: 처음인지는 Cloud에 저장하기

// TODO: Cloud 오랫동안 끊기면 경고 주기
// TODO: Cloud 연결 끊긴 상태 추적해서 cloud 연결 특정시간(몇분정도) 이상 끊기면 userdefaults에 cloudstatus 저장하는 변수 변경해서 view에 cloud연결 끊겼다고 알리기


final actor SyncManager : Sendable, ObservableObject {
    
    /// The CloudKit container to sync with.
    static let container: CKContainer = CKContainer.init(identifier: "iCloud.recoraddic")

    /// The sync engine being used to sync.
    /// This is lazily initialized. You can re-initialize the sync engine by setting `_syncEngine` to nil then calling `self.syncEngine`.
    var syncEngine: CKSyncEngine {
        if _syncEngine == nil {
            self.initializeSyncEngine()
        }
        return _syncEngine!
    }
    var _syncEngine: CKSyncEngine?
    
    /// True if we want the sync engine to sync automatically.
    /// This should always be true in a production app, but we set this to false when testing.
    let automaticallySync: Bool
    
//    var modelContext: ModelContext?
    

    
    init(automaticallySync: Bool = true) {
        
        // Load the data from disk.
        // Note that this is not a very efficient way to store data, but this is a sample app.

//        self.modelContext = modelContext
        
        self.automaticallySync = automaticallySync
        
        Task {
            /// We want to initialize our sync engine lazily, but we also want to make sure it happens pretty soon after launch.
            
            if UserDefaults.standard.value(forKey: "stateSerialization") == nil {
                UserDefaults.standard.setValue(nil, forKey: "stateSerialization")

            }
            if UserDefaults.standard.value(forKey: "shouldBlockTheView") == nil {
                UserDefaults.standard.setValue(true,forKey: "shouldBlockTheView") // at initial, it starts with true
            }
            if UserDefaults.standard.value(forKey: "iCloudAvailable") == nil {
                UserDefaults.standard.setValue(false,forKey: "iCloudAvailable")
            }
//            if UserDefaults.standard.value(forKey: "cloudAuthenticated") == nil {
//                UserDefaults.standard.setValue(false,forKey: "cloudAuthenticated")
//            }
//            
            if UserDefaults.standard.value(forKey: "fetchDone") == nil {
                UserDefaults.standard.setValue(false,forKey: "fetchDone")
            }
            
            await self.initializeSyncEngine()
        }
        

    }
    
    func initializeSyncEngine() {
        var serializedState: CKSyncEngine.State.Serialization?

        do {
            if UserDefaults.standard.value(forKey: "stateSerialization") != nil {
                serializedState = try JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: UserDefaults.standard.data(forKey: "stateSerialization")!) // might cause error
            }
            else {
                serializedState = nil
            }
        } catch {
            Logger.database.error("Failed to load app data: \(error)")
            print("serialization error: \(error)")
        }

//        let state_serialized: CKSyncEngine.State.Serialization? = serializedState_tmp
//        print("containerName: \(Self.container.containerIdentifier!)")
        var configuration = CKSyncEngine.Configuration(
            database: Self.container.privateCloudDatabase,
            stateSerialization: serializedState,
            delegate: self
        )
        configuration.automaticallySync = self.automaticallySync
        let syncEngine = CKSyncEngine(configuration)
        _syncEngine = syncEngine
//        Logger.database.log("Initialized sync engine: \(syncEngine)")
        
    }
}

// MARK: - CKSyncEngineDelegate

extension SyncManager : CKSyncEngineDelegate {
    
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        

        
//        syncEngine.state.
        
        switch event {
            
        case .stateUpdate(let event):
            do {
                let data = try JSONEncoder().encode(event.stateSerialization)
                UserDefaults.standard.set(data, forKey: "stateSerialization")
            } catch {
                print("Failed to write stateSerialization to UserDefaults:", error)
            }
//            UserDefaults.standard.setValue(event.stateSerialization, forKey: "stateSerialization")
            
        case .accountChange(let event):
            self.handleAccountChange(event)
            
        case .willFetchChanges:
            // The sample app doesn't track sent database changes in any meaningful way, but this might be useful depending on your data model.
            print("willFetchChanges")
//            UserDefaults.standard.setValue(true, forKey: "iCloudAuthenticated")
            UserDefaults.standard.setValue(false, forKey: "fetchDone")

            break
            
        case .didFetchChanges:
            print("didFetchChanges")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                UserDefaults.standard.setValue(false, forKey: "shouldBlockTheView") // MARK: 너무 빨리 풀면 query가 적용이 안됨...swiftData와 cloudSyncEngine의 문제인가? 로그인 후 설치는 괜찮지만 설치 후 로그인은 문제가 됨.... ㅅㅂ?
                UserDefaults.standard.setValue(true, forKey: "fetchDone")

//            }
//            do {
//                let container:CKContainer = CKContainer(identifier: "iCloud.recoraddic")
//                let status:CKAccountStatus = try await container.accountStatus()
//                if status == .noAccount {
//                    UserDefaults.standard.setValue(false, forKey: "iCloudAuthenticated")
//
//                }
//            } catch {
//                Logger.database.error("failed to find CKAccountStatus")
//                print("failed to find CKAccountStatus", error)
//
//            }

            break
        case .fetchedDatabaseChanges:
            print("fetchedDatabaseChanges")
        case .fetchedRecordZoneChanges:
            print("fetchedRecordZoneChanges")

        case .didFetchRecordZoneChanges:
            print("didFetchRecordZoneChanges")
            
        case .sentDatabaseChanges, .willFetchRecordZoneChanges, .willSendChanges, .didSendChanges, .sentRecordZoneChanges:
            // We don't do anything here in the sample app, but these events might be helpful if you need to do any setup/cleanup when sync starts/ends.
            break
            
        @unknown default:
//            Logger.database.info("Received unknown event: \(event)")
            break
        }
    }
    
    func nextRecordZoneChangeBatch(_ context: CKSyncEngine.SendChangesContext, syncEngine: CKSyncEngine) async -> CKSyncEngine.RecordZoneChangeBatch? {
        
//        Logger.database.info("Returning next record change batch for context: \(context)")
        
//        let scope = context.options.scope
//        let changes = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }
        
//        let batch = await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
//            
//            if let contact = contacts[recordID.recordName] {
//                let record = contact.lastKnownRecord ?? CKRecord(recordType: Contact.recordType, recordID: recordID)
//                contact.populateRecord(record)
//                return record
//            } else {
//                // We might have pending changes that no longer exist in our database. We can remove those from the state.
//                syncEngine.state.remove(pendingRecordZoneChanges: [ .saveRecord(recordID) ])
//                return nil
//            }
//        }
//        return batch
        return nil
    }
    
    // MARK: - CKSyncEngine Events

    
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) {
        
        
        
        switch event.changeType {
            
        case .signIn,.switchAccounts :
            // 화면 막고 동기화 완료 시까지 기다리게 만들기
            // 완전 처음일 때는?
            print("signIn or switchedAccount")
            UserDefaults.standard.setValue(true, forKey: "iCloudAvailable") // MARK: 만약 처음 시작할 때 이게 안된다면...? 됨 언제든
            UserDefaults.standard.setValue(true, forKey: "shouldBlockTheView")
            break

            
        case .signOut:
            UserDefaults.standard.setValue(false, forKey: "iCloudAvailable")
            print("signOut")
            break
            //            shouldDeleteLocalData = true
            //            shouldReUploadLocalData = false
            
        @unknown default:
            break
            //            Logger.database.log("Unknown account change type: \(event)")
            //            shouldDeleteLocalData = false
            //            shouldReUploadLocalData = false
        }
    }
        
}


