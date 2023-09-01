//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI

struct MainView_GetRectanyl: View {
    
    @State var recordTodayVisible:Bool = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Button(action: {
                    recordTodayVisible.toggle()
                }) {
                    Text("record today")
                }
                
                Text("광고평가").padding(20)
                Text("오늘의 글귀/새로고침/오늘의 기록에 저장/\n기간기록에 저장/shelf에 저장").padding(20)
                Text("다른 사람 응원하기").padding(20)
                
            }
            
            if recordTodayVisible {
                
                //
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        recordTodayVisible.toggle()
                    }
                
                RecordToday(recordTodayVisible: $recordTodayVisible)
                #if os(iOS)
                    .padding(30)
                #elseif os(macOS)
                    .padding(50)
                #endif
                
            }
            
            
            
        }
    }
}


struct RecordToday: View {
    
    @Binding var recordTodayVisible: Bool
    
    var body: some View {
        
        VStack {
            
            HStack{
                
                Spacer()
                Button(action: {recordTodayVisible.toggle()}) {
                    Image(systemName: "x.square")
                }.frame(alignment: .trailing)
                    .padding(10)
            }
            .frame(alignment: .top)
            
            
            Spacer()

            Text("recording Today")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        
    }
}
