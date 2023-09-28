//
//  mainView.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

import SwiftUI
import SwiftData

struct MainView_Home: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [Record]
    
    

    
    var body: some View {
        VStack {
            AllRecordPieces(records: records)
            #if os(macOS)
                .frame(width: 1000, height: 300)
            #endif
            
            #if os(iOS)
                .frame(width: 400, height: 300)
            #endif
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("calender expose/hide")
            Text("progress_time")
            if records.count != 0 {
                CurrentRecord(currentRecord: records[0])
            } else {
                CurrentRecord(currentRecord: nil)
            }

        }
    }
}
//
//struct mainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
