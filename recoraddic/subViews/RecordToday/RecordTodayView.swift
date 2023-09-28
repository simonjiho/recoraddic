//
//  RecordTodayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/09/23.
//

import Foundation
import SwiftUI

// dailyRecord 추가: 모든 과정이 완료되었을 때
// 그 전까지는 임시 데이터 생성, x하거나 종료 시 자동으로 사라지게끔
// dailyRecord를 맨 마지막에 record에 추가하는 방식으로 만들기

struct RecordTodayView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var currentRecord: Record!
    
    @Binding var isRecordTodayActivated: Bool
    
    
    var body: some View {
        
        VStack {
            Spacer()
                .frame(height: 50)
            
//            'X'(close) button
            HStack{
                Spacer()
                Button(action: {
                    isRecordTodayActivated.toggle()
                }) {
                    Image(systemName: "x.square")
                }.frame(alignment: .trailing)
                    .padding(10)
            }
            .frame(alignment: .top)
            
            
            Spacer()
            
//            main part of this view
            RecordTodayStepsView(currentRecord: currentRecord)


            Spacer()

            Text("recording Today")
            Spacer()
                .frame(height: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        
        
    }
    
}


struct RecordTodayStepsView: View {
    
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record!
    
    
    // create DailyRecord
    //
    
    
    @State private var pageIndex = 0

    var body: some View {
        
        Group {
            if pageIndex <= 1 {
                IntroView(currentRecord: currentRecord, pageIndex: $pageIndex)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            pageIndex += 1
                        }
                    }
            }
            else if pageIndex == 2 {
                BuildDailyRecordStoneView(currentRecord: currentRecord)
//                    .frame(height: 400)
//                    .background(Color.gray)
            }
            else if pageIndex == 3 {
                Text("View 4: get rectanyl and get dailyRecordStone")
            }
            else if pageIndex == 4 {
                Text("tommorow's plan")
            }
        }
        .frame(width: 400, height: 400)
        .background(Color.gray)


    }
}
