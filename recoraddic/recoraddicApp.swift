//
//  recoraddictionApp.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

import SwiftUI
import SwiftData

@main
struct recoraddicApp: App {
    
    @MainActor
    static var sampleContainer: ModelContainer = {
        let s = DateComponents(year:2023, month:6, day:11)
        let e = DateComponents(year:2023, month:10, day:11)
        
        let sampleStart:Date! = Calendar.current.date(from: s)
        let sampleEnd:Date! = Calendar.current.date(from: e)
        
        let schema = Schema([Record.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        
        let container: ModelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        
        var context_root: ModelContext = container.mainContext
        context_root.insert(Record(name: "SampleRecord", start: sampleStart, end: sampleEnd))
        
        return container
        
        
    }()

    
    
    
    var body: some Scene {

        
        WindowGroup {
            ContentView()
//        }.modelContainer(for:Record.self)
        }.modelContainer(recoraddicApp.sampleContainer)

    }
}
