//
//  StartNewRecordSet.swift
//  recoraddic
//
//  Created by 김지호 on 3/3/24.
//

import Foundation
import SwiftUI
import SwiftData

//MARK: 이전 DRS가 비어있다면 자동으로 삭제하고 새로 만들어줌.

struct StartNewRecordSet:View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    

    
    @Binding var popUp_startNewRecordSet: Bool
    @Binding var newDailyRecordSetAdded: Bool
    @State var selectedDailyRecordThemeName:String?
    let minDate: Date
    
    @State var dailyRecordSetThemeContainsDailyQuestions: Bool = false
    
    @State var numberOfQuestions: Int = 1
    @State var question1: String = recoraddic.defaultQuestions[0]
    @State var question2: String = recoraddic.defaultQuestions[1]
    @State var question3: String = ""

    
    @State var steps: Int = 0
    
    @State var selectedDate = getStartDateOfNow()
    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth/4
            
            let xButtonHeight = geoHeight*0.05
            
            let questionBoxSize = geoHeight*0.17
            
            let mainContentSize = geoHeight*0.65
            let questionsSize = mainContentSize*0.8
            let warningSize = mainContentSize*0.2
            
            let buttonsFrameSize = geoHeight*0.13
            
            
            
            // dismiss keyboard part
            VStack(spacing: 0.0) {
                Button(action:{popUp_startNewRecordSet.toggle()}) {
                    Image(systemName: "xmark")
                }
//                .padding(10)
                .frame(width: geoWidth*0.95, height: xButtonHeight, alignment: .trailing)
                    
                HStack {
                    Text("시작일:")
                    DatePicker("",selection: $selectedDate, in: minDate...minDate.addingDays(500), displayedComponents: [.date])
                        .labelsHidden()
                }
                .frame(width: geoWidth*0.9, alignment: .leading)
                .padding(.bottom)
//                .padding(5)
//                .border(.gray)
//                .padding()
                
                
                VStack {
                    Text("스타일 선택")
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
                            ForEach(recoraddic.dailyRecordThemeNames, id:\.self) { dailyRecordThemeName in
                                Button(action:{
                                    selectedDailyRecordThemeName = dailyRecordThemeName
                                }) {
                                    DRSThemeThumbnailView(dailyRecordThemeName: dailyRecordThemeName)
                                        .frame(width:gridSize, height: gridSize)
                                        .border(.gray.opacity(selectedDailyRecordThemeName == dailyRecordThemeName ? 1.0 : 0.0),width:3.0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(width:geoWidth*0.8)
                }
                .frame(width:geoWidth*0.9)
                .padding(.vertical)
                .border(.gray)

                Button("생성") {
                    if selectedDailyRecordThemeName == "StoneTower" {
                        createNewDailyRecordSet()
                        popUp_startNewRecordSet.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedDailyRecordThemeName == nil)
                .padding()
                
                
            }
            .frame(width: geoWidth,height: geoHeight,alignment: .top)
            .background(.background.opacity(0.3))
//            .dismissingKeyboard()
            



        }

    }
    
    func createNewDailyRecordSet() -> Void {
        
        // (deprecated note) 만약 그전에 dailyRecordSet에 dailyRecords가 없다면, 그 전의 것을 지움.(시작 날짜가 같다면, 그 전 것에 dr이 있을리가 없음)
        // 24.07.30 -> 애초에 데이터가 없다면 새로 만들기가 없다
        
        
        // 이전 drs end 설정
        dailyRecordSets.last?.end = getStandardDate(from: selectedDate.addingDays(-1))
        
        let newDailyRecordSet: DailyRecordSet = DailyRecordSet(start:getStandardDate(from:selectedDate))
        newDailyRecordSet.dailyRecordThemeName = selectedDailyRecordThemeName!
        modelContext.insert(newDailyRecordSet)
        newDailyRecordSetAdded.toggle()
    }

}


struct DRSThemeThumbnailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var dailyRecordThemeName: String
    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            if dailyRecordThemeName == "StoneTower" {
                VStack(spacing:0.0) {
                    StoneTower_stone(
                        shapeNum: 3, brightness: 3, defaultColorIndex: 0, facialExpressionNum: 0, selected: false
                    )
                    .frame(width:geoWidth*0.75, height: geoHeight*0.5)
                    Text("기본")
                        .font(.caption)
                        .frame(height: geoHeight*0.25, alignment: .bottom)
//                        .padding(.top,10)
                }
                .padding(.vertical,geoHeight*0.15)
                .frame(width: geoWidth, height: geoHeight)
                .background(.gray.opacity(0.3))
//                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                .border(getReversedColorSchemeColor(colorScheme))
                
            }

      
            else {
                Text("error")
            }
        }
    }
}

