//
//  migration.swift
//  recoraddic
//
//  Created by 김지호 on 11/19/24.
//
import Foundation
import SwiftData

typealias Quest = RecoraddicSchemaV2.Quest
typealias DailyQuest = RecoraddicSchemaV2.DailyQuest
typealias Todo = RecoraddicSchemaV2.Todo
typealias Todo_preset = RecoraddicSchemaV2.Todo_preset
typealias DailyRecordSet = RecoraddicSchemaV2.DailyRecordSet
typealias DailyRecord = RecoraddicSchemaV2.DailyRecord
typealias Profile = RecoraddicSchemaV2.Profile



enum RecoraddicMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [RecoraddicSchemaV1.self, RecoraddicSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
//        [migrateV1toV2, migrateV2toV3]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: RecoraddicSchemaV1.self,
        toVersion: RecoraddicSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            if let quests = try? context.fetch(FetchDescriptor<RecoraddicSchemaV2.Quest>()) {
                for quest in quests {
                    quest.id = UUID() // if not do this, some duplicated ids will be generated.(Don't know why) (11.21.2024)
                    if let dailyQuests = try? context.fetch(FetchDescriptor<RecoraddicSchemaV2.DailyQuest>()) {
                        for dailyQuest in dailyQuests {
                            if dailyQuest.quest == nil && dailyQuest.questName == quest.name {
                                dailyQuest.quest = quest
                            }
                        }
                        try? context.save()
                    }
                    
                }

                try? context.save()

            }
            
            
        }
    )
  
//    static let migrateV2toV3 = MigrationStage.lightweight(
//        fromVersion: SampleTripsSchemaV2.self,
//        toVersion: SampleTripsSchemaV3.self
//    )
}
