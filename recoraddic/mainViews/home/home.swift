//
//  mainView.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

import SwiftUI

struct MainView_Home: View {
    
    @ObservedObject var records: Records
    
    

    
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
            CurrentRecord(currentRecord: records.inventory[0])

        }
    }
}
//
//struct mainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
