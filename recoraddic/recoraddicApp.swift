//
//  recoraddictionApp.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//



// MARK: Recoraddic의 기조: 1)기록 삭제는 가능하지만 기록 수정은 불가능하다. 2)각각의 기록 삭제(quest <-> dr&drs)는 서로의 데이터에 영향을 끼치지 않는다.


// openSettingsURLString -> For direct to cloud setting


import SwiftUI
import SwiftData
import CloudKit

@main
struct recoraddicApp: App {
    
    
    static let container = try! ModelContainer(for:Schema([Quest.self, DailyRecord.self, DefaultPurposeData.self, DailyRecordSet.self, Profile.self]), configurations: ModelConfiguration(cloudKitDatabase: ModelConfiguration.CloudKitDatabase.automatic))

    var syncManager: SyncManager = SyncManager()

    
    var body: some Scene {

        
        WindowGroup {
            ContentView()
                .onAppear() {
                    print("App started")

                }
        }

        .modelContainer(Self.container)

    


    }
}
