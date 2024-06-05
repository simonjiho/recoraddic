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
//    @Binding var selectedDailyRecordSetIndex: Int
    @Binding var newDailyRecordSetAdded: Bool
    
    @State var selectedDailyRecordThemeName:String?
    
    @State var dailyRecordSetThemeContainsDailyQuestions: Bool = false
    
    @State var numberOfQuestions: Int = 1
    @State var question1: String = recoraddic.defaultQuestions[0]
    @State var question2: String = recoraddic.defaultQuestions[1]
    @State var question3: String = ""

    
    @State var steps: Int = 0
    
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
            
            
            ZStack {
            
                // dismiss keyboard part
                VStack(spacing: 0.0) {
                    Button(action:{popUp_startNewRecordSet.toggle()}) {
                        Image(systemName: "xmark")
                    }
                    .frame(width: geoWidth*0.95, height: xButtonHeight, alignment: .trailing)
                    if steps == 0 { // theme선택 (배경은 나중에 선택)
                        
                        Text("기록 유형 선택")
                            .frame(height: questionBoxSize)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
                                ForEach(recoraddic.dailyRecordThemeNames, id:\.self) { dailyRecordThemeName in
                                    Button(action:{
                                        selectedDailyRecordThemeName = dailyRecordThemeName
                                        if selectedDailyRecordThemeName == "stoneTower_0" {
                                            createNewDailyRecordSet_withQuestion()
                                            popUp_startNewRecordSet.toggle()
                                        }
                                        else {
                                            
                                            steps += 1
                                        }
                                    }) {
                                        DRSThemeThumbnailView(dailyRecordThemeName: dailyRecordThemeName)
                                            .frame(width:gridSize, height: gridSize)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(width:geoWidth*0.9)
                    }
                    else if steps == 1 {
                        
                        VStack(spacing:questionBoxSize*0.1){
                            Text("매일 할 질문을 설정하세요!")
                            HStack(spacing:geoWidth*0.15) {
                                Button(action:{numberOfQuestions -= 1}) {
                                    Image(systemName: "minus.circle")
                                }
                                .disabled(numberOfQuestions == 1)
                                Button(action:{numberOfQuestions += 1}) {
                                    Image(systemName: "plus.circle")
                                }
                                .disabled(numberOfQuestions == 3)
                            }
                        }
                        .frame(height: questionBoxSize)
                        
                        Spacer()
                            .frame(width:geoWidth*0.9, height: questionsSize)
                        
                            
                        VStack {
                            Text("설정한 질문은 중간에 수정할 수 없으니")
                                .font(.caption)
                                .padding(.top, 30)
                            
                            Text("신중하게 설정하세요!")
                                .font(.caption)
                        }
                        .frame(height: warningSize, alignment: .center)
                        
                        HStack(spacing:0.0) {
                            Button("뒤로",systemImage: "chevron.left") {
                                steps -= 1
                            }
                            .frame(width: geoWidth*0.45, alignment: .leading)

                            Button(action:{
                                createNewDailyRecordSet_withQuestion() // 완료 -> 새로운 dailyRecordSet 생성,
                                popUp_startNewRecordSet.toggle()
                            }) {
                                Text("생성")
                            }
                            .frame(width: geoWidth*0.45, alignment: .trailing)

                        }
                        .frame(width:geoWidth*0.9, height:buttonsFrameSize)
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                .frame(width: geoWidth,height: geoHeight,alignment: .top)
                .background(.background)
                .dismissingKeyboard()
                
                //TODO: theme에 따라 어떤게 어떻게 변화하는지 설명
                if steps == 1 {
                    
                    
                    VStack(spacing: 10) {
                        if numberOfQuestions >= 1 {
                            HStack {
                                Text("1. ")
                                TextField("질문1", text: $question1)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                            }
                            Text("표현 방식: \(getVisualRepresentationExpression(index: 0))")
                                .font(.caption)
                                .opacity(0.7)

                        }
                        if numberOfQuestions >= 2 {
                            HStack {
                                Text("2. ")
                                TextField("질문2", text: $question2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Text("표현 방식: \(getVisualRepresentationExpression(index: 1))")
                                .font(.caption)
                                .opacity(0.7)

                        }
                        if numberOfQuestions == 3 {
                            HStack {
                                Text("3. ")
                                TextField("질문3", text: $question3)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Text("표현 방식: \(getVisualRepresentationExpression(index: 2))")
                                .font(.caption)
                                .opacity(0.7)

                        }
                    }
                    .frame(width:geoWidth*0.9, height:questionsSize, alignment: .top)
                    .position(x:geoWidth/2, y:xButtonHeight + questionBoxSize + questionsSize/2)
                    

                    
                }
                
            }
            .frame(width: geoWidth,height: geoHeight)


        }

    }
    
    func createNewDailyRecordSet_withQuestion() -> Void {
        
        // 만약 그전에 dailyRecordSet에 dailyRecords가 없다면, 그 전의 것을 지움.(시작 날짜가 같다면, 그 전 것에 dr이 있을리가 없음)
        let newDailyRecordSet: DailyRecordSet
        if dailyRecordSets.last!.dailyRecords!.count == 0 {
            // reset current daily record set
            newDailyRecordSet = dailyRecordSets.last!
            newDailyRecordSet.start = getStartDateOfNow()
            newDailyRecordSet.dailyQuestions = []
            
            // newDailyRecordSet 생성, 설정해준 값들 넣어주기(DRThemeName, questions)
            newDailyRecordSet.dailyRecordThemeName = selectedDailyRecordThemeName!
            newDailyRecordSet.dailyQuestions.append(question1)
            if numberOfQuestions >= 2 {newDailyRecordSet.dailyQuestions.append(question2)}
            if numberOfQuestions == 3 {newDailyRecordSet.dailyQuestions.append(question3)}
            
            
        }
        
        else {
            
            let prev_drs_end: Date = dailyRecordSets.last!.dailyRecords!.sorted(by: { dr1, dr2 in
                dr1.date! < dr2.date!
            }).last!.date!
            
            dailyRecordSets.last!.end = prev_drs_end

            let new_drs_start: Date
            if prev_drs_end == getStartDateOfNow() {//MARK: 만약 오늘저장한 dr이 이미 이전의 drs에 저장된 상태에서 새로운 drs를 만든다면?
                new_drs_start = Calendar.current.date(byAdding: .day, value: 1, to: prev_drs_end)!
            }
            else {
                new_drs_start = getStartDateOfNow()
            }
            
            newDailyRecordSet = DailyRecordSet(start: new_drs_start)
            
            modelContext.insert(newDailyRecordSet)
            
            let dailyRecordSets_isVisible_count:Int = dailyRecordSets.filter({$0.isVisible()}).count
            
            // newDailyRecordSet 생성, 설정해준 값들 넣어주기(DRThemeName, questions)
            newDailyRecordSet.dailyRecordThemeName = selectedDailyRecordThemeName!
            newDailyRecordSet.dailyQuestions.append(question1)
            if numberOfQuestions >= 2 {newDailyRecordSet.dailyQuestions.append(question2)}
            if numberOfQuestions == 3 {newDailyRecordSet.dailyQuestions.append(question3)}
            
            newDailyRecordSetAdded.toggle()
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // 빠르게 바꾸면, insert되어서 반영되기 전에 해당 코드가 실행된다. SwiftData의 modelContext는 독립적인 flow로 작동하기 때문에 기다려 새로운 내용이 저장되기 전에 읽으려고 하면 곧바로 작동하지 않는다.
//                selectedDailyRecordSetIndex = dailyRecordSets_isVisible_count - 1 // onChangeOf..
//            }
            
        }
        

    }
    
    func getVisualRepresentationExpression(index: Int) -> String {
        if selectedDailyRecordThemeName == "stoneTower_1" {
            switch numberOfQuestions {
            case 1: return StoneTower_1.oneQuestion[index]
            case 2: return StoneTower_1.twoQuestions[index]
            case 3: return StoneTower_1.threeQuestions[index]
            default: return "?"
            }
        }
        else {
            return "?"
        }
    }
    
}


struct DRSThemeThumbnailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var dailyRecordThemeName: String
    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            if dailyRecordThemeName == "stoneTower_0" {
                VStack {
                    StoneTower_0_stone(
                        defaultColorIndex: 0,
                        facialExpressionNum: 0,
                        selected: false
                    )
                    .frame(width:geoWidth*0.75, height: geoHeight*0.5)
                    Text("탑쌓기(질문x)")
                        .font(.caption)
                }
                .frame(width: geoWidth, height: geoHeight)
                .border(getReversedColorSchemeColor(colorScheme))
            }
            else if dailyRecordThemeName == "stoneTower_1" {
                VStack {
                    StoneTower_1_stone(
                        shapeNum: 3,
                        brightness: 0,
                        defaultColorIndex: 0,
                        facialExpressionNum: 0,
                        selected: false
                    )
                    .frame(width:geoWidth*0.75, height: geoHeight*0.5)
                    Text("탑쌓기(질문o)")
                        .font(.caption)

                }
                .frame(width: geoWidth, height: geoHeight)
                .border(getReversedColorSchemeColor(colorScheme))
            }
      
            else {
                Text("error")
            }
        }
    }
}

