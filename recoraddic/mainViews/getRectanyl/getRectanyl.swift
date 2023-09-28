//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI
import SwiftData

struct MainView_GetRectanyl: View {
    
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record
    
    @Binding var isRecordTodayActivated:Bool
    
//    @Binding var isRecordTodayActivated: Bool
    
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Button(action: {
                    isRecordTodayActivated.toggle()
                }) {
                    Text("record today")
                }
                
                Text("광고평가").padding(20)
                Text("오늘의 글귀/새로고침/오늘의 기록에 저장/\n기간기록에 저장/shelf에 저장").padding(20)
                Text("다른 사람 응원하기").padding(20)
                
            }
            

            
            
        }
    }
}





