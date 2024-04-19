//
//  GetDailyStoneView.swift
//  recoraddic
//
//  Created by 김지호 on 12/23/23.
//

import Foundation
import SwiftUI
import SwiftData

struct SaveDailyRecordView: View {
    
    @Environment (\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    
    
    
    var currentDailyRecordSet: DailyRecordSet
    var currentDailyRecord: DailyRecord
    @Binding var popUp_createRecordStone: Bool
    let saveAsToday: Bool
    let todayRecordExists: Bool
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView:MainViewName
    
    
    
    @State var selectedClassification: String = "긍정적"
    @State var steps: Int = 0
    @State var selectedFacialExpressionNum: Int = 0
    @State var questionValue1: Int? = 0
    @State var questionValue2: Int?
    @State var questionValue3: Int?
    @State var questionValue1_nonNil: Int = 0
    @State var questionValue2_nonNil: Int = 0
    @State var questionValue3_nonNil: Int = 0
    let askQuestions: Bool
    let savingDate: Date


    init(currentDailyRecordSet: DailyRecordSet, currentDailyRecord: DailyRecord, popUp_createRecordStone: Binding<Bool>, saveAsToday: Bool, todayRecordExists: Bool, isNewDailyRecordAdded: Binding<Bool>, selectedView: Binding<MainViewName>) {
        
        self._quests = Query()
        self._dailyRecords = Query(sort:\DailyRecord.date)
        
        self.currentDailyRecordSet = currentDailyRecordSet
        self.currentDailyRecord = currentDailyRecord
        self._popUp_createRecordStone = popUp_createRecordStone
        self.saveAsToday = saveAsToday
        self.todayRecordExists = todayRecordExists
        self._isNewDailyRecordAdded = isNewDailyRecordAdded
        self._selectedView = selectedView
        
        
        switch currentDailyRecordSet.dailyQuestions.count {
        case 2:
            self._questionValue2 = State(initialValue: 0)
        case 3:
            self._questionValue2 = State(initialValue: 0)
            self._questionValue3 = State(initialValue: 0)
        default:
            _ = 0
        }
        self.askQuestions = doesThemeAskQuestions(currentDailyRecordSet.dailyRecordThemeName)
        self.savingDate = {
            if saveAsToday {
                return getStartDateOfNow()
            }
            else {
                return getStartDateOfYesterday()
            }

        }()

        
    }

    
    var body: some View {
        
        
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let stepsContentViewWidth = geoWidth*0.9
            let stepsContentViewHeight = geoHeight*0.85
            
            let VGridSize = (stepsContentViewWidth*0.75)/3
            
            let recordStoneGridWidth = stepsContentViewWidth
            let recordStoneGridHeight = stepsContentViewHeight*0.35
            let recordStoneWidth = geoWidth*0.3
            let recordStoneHeight = recordStoneWidth*0.67

  
            let questionBoxWidth = stepsContentViewWidth
            let questionBoxHeight = stepsContentViewHeight*0.55
            let numberPadWidth = questionBoxWidth
            let numberPadHeight = questionBoxHeight*0.15

            
            VStack {
                Button(action:{popUp_createRecordStone.toggle()}) {
                    Image(systemName: "x.circle")
                }
                .frame(width:geometry.size.width*0.95, alignment: .trailing)
                
                VStack {
                    //mood -> 표정
                    if steps == 0 {
                        // 나중에 전체/긍정적/부정적/... 등등으로 선택 옵션 고르면 바꾸게 나오기
                        Text("\(yyyymmddFormatOf(savingDate)) 을 표현할 표정을 고르세요!")
//                        HStack {
//                            if selectedFacialExpressionNum != 0 {
//                                Image("facialExpression_\(selectedFacialExpressionNum)")
//                                    .resizable()
////                                    .renderingMode(.template)
////                                    .tint(reversedColorSchemeColor)
////                                    .foregroundStyle(reversedColorSchemeColor)
//                                    .frame(width: VGridSize*0.9, height: VGridSize*0.9)
//                                    .background(.background)
//                                    .clipShape(.rect(cornerRadius: VGridSize*0.05))
//                                    .shadow(radius: 1)
//                                
////                                    .background(.gray)
////                                    .border(reversedColorSchemeColor)
//                            }
//
//                        }
//                        .frame(width: geoWidth*0.9, height: geoHeight*0.2, alignment: .center)

                        ScrollView {
//                            LazyVGrid(columns: [GridItem(.adaptive(minimum:VGridSize))]) {
                            
                            let numList:[Int] = {
                                if selectedClassification == "전체" {return Array(1...125)}
                                else if selectedClassification == "긍정적" {return recoraddic.facialExpression_Good}
                                else if selectedClassification == "부정적" {return recoraddic.facialExpression_Bad}
                                else if selectedClassification == "중립적" {return recoraddic.facialExpression_Middle}
                                else { return [1]}
                            }()
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: VGridSize))]) {

                                ForEach(numList, id: \.self) { index in
                                    reversedColorSchemeColor
                                        .mask {
                                            Image("facialExpression_\(index)")
                                                .resizable()
                                                .blur(radius: 0.2)
        //                                        .foregroundStyle(reversedColorSchemeColor)
                                                .frame(width:VGridSize*0.7, height: VGridSize*0.7)
                                        }
                                        .frame(width:VGridSize, height: VGridSize)
                                        .opacity(0.6)
                                        .background(selectedFacialExpressionNum == index ? Color.blue : colorSchemeColor)                                          .clipShape(.rect(cornerRadius: VGridSize*0.05))
                                        .shadow(radius: 1)
                                        .border(reversedColorSchemeColor, width: /* border width */ 1)

//                                    Image("facialExpression_\(index)")
//                                        .resizable()
//                                        .blur(radius: 0.2)
////                                        .foregroundStyle(reversedColorSchemeColor)
//                                        .frame(width:VGridSize*0.9, height: VGridSize*0.9)
//                                        .frame(width:VGridSize, height: VGridSize)
//                                        .background(.background)
//                                        .clipShape(.rect(cornerRadius: VGridSize*0.05))
//                                        .shadow(radius: 1)
//                                        .background(selectedFacialExpressionNum == index ? Color.blue : Color.gray)
////                                        .foregroundColor(selectedFacialExpressionNum == index ? .white : .black)
//                                        .border(reversedColorSchemeColor, width: /* border width */ 1)
                                        .onTapGesture {
                                            
                                            if selectedFacialExpressionNum == index {
                                                selectedFacialExpressionNum = 0
                                            }
                                            else {
                                                selectedFacialExpressionNum = index
                                            }
                                            
                                        } // onTapGesture
                                }

                            } // LazyVGrid
                        } // ScrollView
                        //TODO: 분류바뀌면 scrollview 위로
                    //TODO: 더 세분화 -> 비슷한 표정끼리 더 세분화해서 분류(놀람,특이,눈물,분노)를 나누던가, 아니면 긍정,부정의 게이지를 만들어놓고 4단계*4단계 -> 16단계의 추천표정 만들기 (한 분류당 최소 10개 최대 30개) (긍정도 0~3, 부정도 0~3)
                        Picker("분류", selection: $selectedClassification) {
                            ForEach(["긍정적","부정적","중립적"],id:\.self) {
                                Text($0)
                            }
                        }
                        .frame(width:stepsContentViewWidth,alignment: .trailing)
                        .pickerStyle(.menu)
                        
                    }

                    //stepped forward -> 쌓는 위치
                    else if steps == 1 {
                        Group {
                            if currentDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
                                // 어떻게 하지..........?????????
                                VStack {
                                    StoneTower_1_stone(
                                        shapeNum: StoneTower_1.calculateVisualValue1(qVal1: questionValue1, qVal2: questionValue2, qVal3: questionValue3),
                                        brightness: StoneTower_1.calculateVisualValue2(qVal1: questionValue1, qVal2: questionValue2, qVal3: questionValue3),
                                        defaultColorIndex: currentDailyRecordSet.dailyRecordColorIndex,
                                        facialExpressionNum: selectedFacialExpressionNum
                                    )
                                    .frame(width: recordStoneWidth, height: recordStoneHeight)
                                    //                                    .offset(x:) // pos 표기
                                    .offset(x:recordStoneWidth*0.115*CGFloat(StoneTower_1.calculateVisualValue3(qVal1: questionValue1, qVal2: questionValue2, qVal3: questionValue3, 0)))
                                    Spacer()
                                        .frame(width:recordStoneWidth/2, height: 10)
                                        .background(.gray)
                                }
                                .frame(width: recordStoneGridWidth, height: recordStoneGridHeight, alignment: .center)
                                .background(StoneTowerBackground_1.getSkyColor(colorScheme: colorScheme))
                                .clipShape(.buttonBorder)
                            }

                        }

                        .shadow(radius: 5)
                        .padding(.bottom,15)


                        
                        VStack(spacing:questionBoxHeight*0.08) {
                            VStack {
                                Text(currentDailyRecordSet.dailyQuestions[0])
                                NumberPadForQuestionValue(questionValue:$questionValue1_nonNil)
                                    .frame(width:numberPadWidth, height:numberPadHeight)
//                                    .border(.red)
                                    .onChange(of: questionValue1_nonNil) {
                                        questionValue1 = questionValue1_nonNil
                                    }
                            
//                                    questionSliderView(
//                                        questionValue: $questionValue1_nonNil,
//                                        xOffset: sliderBoxWidth*0.8*((CGFloat(questionValue1_nonNil+3)/6.0)),
//                                        lastOffset: sliderBoxHeight*0.8*((CGFloat(questionValue1_nonNil+3)/6.0))
//                                    )
//                                    .frame(width:sliderBoxWidth, height:sliderBoxHeight)
//                                    .onChange(of: questionValue1_nonNil) {
//                                        questionValue1 = questionValue1_nonNil
//                                    }
//                                    .onAppear() {
//                                        print(questionValue2)
//                                        print(questionValue3)
//                                    }
                            }
                            if questionValue2 != nil {
                                VStack {
                                    Text(currentDailyRecordSet.dailyQuestions[1])
                                    NumberPadForQuestionValue(questionValue:$questionValue2_nonNil)
                                        .frame(width:numberPadWidth, height:numberPadHeight)
                                        .onChange(of: questionValue2_nonNil) {
                                            questionValue2 = questionValue2_nonNil
                                        }
                                    
                                    //                                        questionSliderView(
                                    //                                            questionValue: $questionValue2_nonNil,
                                    //                                            xOffset: sliderBoxWidth*0.8*((CGFloat(questionValue2_nonNil+3)/6.0)),
                                    //                                            lastOffset: sliderBoxHeight*0.8*((CGFloat(questionValue2_nonNil+3)/6.0))
                                    //                                        )
                                    //                                        .frame(width:sliderBoxWidth, height:sliderBoxHeight)
                                    //                                        .onChange(of: questionValue2_nonNil) {
                                    //                                            questionValue2 = questionValue2_nonNil
                                    //                                        }
                                }
                            }
                            if questionValue3 != nil {
                                VStack {
                                    Text( currentDailyRecordSet.dailyQuestions[2])
                                    NumberPadForQuestionValue(questionValue:$questionValue3_nonNil)
                                        .frame(width:numberPadWidth, height:numberPadHeight)
                                        .onChange(of: questionValue3_nonNil) {
                                            questionValue3 = questionValue3_nonNil
                                        }
                                    //                                        questionSliderView(
                                    //                                            questionValue: $questionValue3_nonNil,
                                    //                                            xOffset: sliderBoxWidth*0.8*((CGFloat(questionValue3_nonNil+3)/6.0)),
                                    //                                            lastOffset: sliderBoxHeight*0.8*((CGFloat(questionValue3_nonNil+3)/6.0))
                                    //                                        )
                                    //                                        .frame(width:sliderBoxWidth, height:sliderBoxHeight)
                                    //                                        .onChange(of: questionValue3_nonNil) {
                                    //                                            questionValue3 = questionValue3_nonNil
                                    //                                        }
                                    //                                        .border(.red)
                                }
                            }
                                
                                
                                
                        }
                        .frame(width:questionBoxWidth, height:questionBoxHeight)

                    }
                    else { // resultView
                        Text("created recordStone")
                    }
                    
                } // Vstack
                .frame(width: stepsContentViewWidth, height:stepsContentViewHeight)
//                .border(.white.adjust(brightness:-0.3))
                

                VStack {
                    HStack(spacing:30) {
                        if steps <= 1 {
                            Button(action: {steps -= 1}) {
                                Text("이전")
                            }
                            .disabled(steps == 0)
                        }
                        
                        Button(action:nextStepOrDone) {
                            Text(steps == 0 && askQuestions ? "다음" : "기록 저장")
                        }
                        .disabled((steps == 0 && selectedFacialExpressionNum == 0))
                    }

                    
                }
                .padding(.top,15)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)

        }

    }
    

    
    func nextStepOrDone() -> Void {
        if (steps == 0 && askQuestions){
            steps += 1
        }
        
        else {
            saveDailyRecord()
            popUp_createRecordStone.toggle()
            selectedView = .seeMyRecord
        }
        
//        else if steps == 2 {
//        }
        
    }
    
    func saveDailyRecord() -> Void { // TODO: 이 과정에서 에러 일어나면 전부 undo 처리하고, 똑같은 에러가 다시 일어나지 않게 처리
        
        currentDailyRecord.date = savingDate
        
        if currentDailyRecordSet.dailyRecords!.count == 0 {
            currentDailyRecordSet.start = savingDate
        }

        
        // TODO: 만약 DRS에 하나도 없었다면 시작 날짜를 첫 DR의 날짜로 바꾸기
        currentDailyRecord.mood = selectedFacialExpressionNum
        currentDailyRecord.questionValue1 = questionValue1
        currentDailyRecord.dailyRecordSet = currentDailyRecordSet
        if questionValue2 != nil { currentDailyRecord.questionValue2 = questionValue2! }
        if questionValue3 != nil { currentDailyRecord.questionValue3 = questionValue3! }


        
        var removingList:[DailyQuest] = []
        
        for dailyQuest in currentDailyRecord.dailyQuestList! {
            if dailyQuest.data == 0 {
                removingList.append(dailyQuest)
            }
        }
        
        for emptyDailyQuest in removingList {
            modelContext.delete(emptyDailyQuest)
        }
        
        
        var removingList2:[Todo] = []
        for todo in currentDailyRecord.todoList! {
            if todo.done == false || todo.content == "" {
                removingList2.append(todo)
            }
        }
        
        for emptyTodo in removingList2 {
            modelContext.delete(emptyTodo)
        }

        
        for questData in currentDailyRecord.dailyQuestList! {
            let quest: Quest? = quests.first(where: {quest in quest.name == questData.questName})
            if quest != nil {
                if quest!.dailyData.keys.contains(savingDate) {
                    quest!.dailyData[savingDate]! += questData.data
                }
                else {
                    quest!.dailyData[savingDate] = questData.data
                }
                quest!.updateTier()
                quest!.updateMomentumLevel()
                quest!.recentPurpose = questData.defaultPurposes
                quest!.recentData = questData.data
            }
        }
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: dateComponents, to: savingDate)
        
        
        calculateVisualValues()
        
        if !saveAsToday && todayRecordExists {
            recalculateVisualValuesOfToday()
        }
        
        // 오늘게 있는데 currentDRS에 없다면 애초에 어제 것을 저장 불가 -> 기록의 탑 저장 시 알려주기
        
        modelContext.insert(DailyRecord())
        
        isNewDailyRecordAdded.toggle()
        
        
    }
    
    func recalculateVisualValuesOfToday() -> Void { // 어제의 기록을 올리는데 이미 오늘의 기록이 있을 때
        
        // savingDate is yesterday in this case
        let today = getTomorrowOf(savingDate)
        let dailyRecord_today = currentDailyRecordSet.dailyRecords?.filter({$0.date == today}).first!
        let dailyRecord_yesterday = currentDailyRecord
        
        let qVal1:Int? = dailyRecord_today!.questionValue1
        let qVal2:Int? = dailyRecord_today!.questionValue2
        let qVal3:Int? = dailyRecord_today!.questionValue3
        
        if currentDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
            let prevVisualVal3 = dailyRecord_yesterday.visualValue3!
            currentDailyRecord.visualValue3 = StoneTower_1.calculateVisualValue3(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3, prevVisualVal3) //위치
        }

        
        
    }
    
    func calculateVisualValues() -> Void {
        
        let qVal1:Int? = currentDailyRecord.questionValue1
        let qVal2:Int? = currentDailyRecord.questionValue2
        let qVal3:Int? = currentDailyRecord.questionValue3
        
        if currentDailyRecordSet.dailyRecordThemeName == "stoneTower_0" {
            currentDailyRecord.visualValue1 = StoneTower_0.calculateVisualValue1(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3)
            currentDailyRecord.visualValue2 = StoneTower_0.calculateVisualValue2(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3)
            currentDailyRecord.visualValue3 = StoneTower_0.calculateVisualValue3(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3)
        }
        else if currentDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
            
            // prevVisualVal3 of latest,saved,unhidden dailyRecord before savingDate
            let prevVisualVal3: Int = currentDailyRecordSet.dailyRecords?.filter({$0.date != nil && !$0.hide}).sorted(by: {$0.date! < $1.date!}).filter({$0.date! < savingDate}).last?.visualValue3 ?? 0
            
            currentDailyRecord.visualValue1 = StoneTower_1.calculateVisualValue1(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3) //모양
            currentDailyRecord.visualValue2 = StoneTower_1.calculateVisualValue2(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3) //색
            currentDailyRecord.visualValue3 = StoneTower_1.calculateVisualValue3(qVal1: qVal1, qVal2: qVal2, qVal3: qVal3, prevVisualVal3) //위치
        }
    }

    
}





struct NumberPadForQuestionValue: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var questionValue:Int
    
    var body: some View {
        GeometryReader {  geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height

            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
            
            HStack(spacing:geoWidth*0.02) {
                ForEach(-3...3, id:\.self) { value in
                    Text("\(value)")
                        .frame(width:geoWidth*0.12, height: geoHeight*0.9)
                        .foregroundStyle(value == questionValue ? colorSchemeColor : reversedColorSchemeColor)
                        .background(value == questionValue ? reversedColorSchemeColor : colorSchemeColor)
                        .clipShape(.buttonBorder)
                        .onTapGesture {
                            questionValue = value
                        }
                    
                }
            }
            .frame(width:geoWidth,height: geoHeight, alignment: .center)
        }
    }
}

//struct questionSliderView: View {
//    
//    
//    @Binding var questionValue: Int
////    @State var sliderValue: CGFloat
//    
//    // make other wasGoodDay that represents CGFloat wasGoodDay ( = wasGoodDay2 )
//    // wasGoodDay is changed when the CGFloat wasGoodDay2 changes
//    
//    var range: ClosedRange<CGFloat> = -3.0...3.0
//    var color: Color = Color.black
//    
//    
//    @State var xOffset: CGFloat
//    @State var lastOffset: CGFloat
////    @State private var lastColor: Color = Color.red
//    @State private var isDragging: Bool = false
//    
//    
//
//    
//
//    var body: some View {
//        GeometryReader { geometry in
//            
//            
//            let barWidth = geometry.size.width*0.76
//            let barHeight = geometry.size.height*0.4
//            let sliderThumbSize = barHeight*1.5
//            let stoneWidth = geometry.size.width*0.24
//            let valueRepresentationSize = barHeight*1.5
//            
//            ZStack(alignment: .leading) {
//                Rectangle()
//                    .foregroundColor(color)
//                    .frame(width:barWidth, height: barHeight)
//                    .clipShape(.buttonBorder)
//                
//
//                Circle()
//                    .frame(width: sliderThumbSize,height: sliderThumbSize)
//                    .foregroundColor(.gray)
//                    .shadow(radius: 5.0)
//                    .offset(x: xOffset - sliderThumbSize/2)
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { draggedValue in
//
//                                let translation = draggedValue.translation
//                                
//                                // geometric position
//                                var sliderPos = max(0, min(lastOffset + translation.width, barWidth))
//                                
//                                // actual wasGoodDay
//                                let sliderVal = round(sliderPos.map(from: 0...barWidth, to: range))
//
//                                
//                                sliderPos = CGFloat(sliderVal).map(from:range, to: 0...barWidth)
//
//
//                                
//                                
//                                if sliderVal.isNormal || sliderVal.isZero {
//                                    xOffset = sliderPos
//                                    self.questionValue = Int(sliderVal)
//                                }
//
//                                
//                                isDragging = true
//                            }
//                            .onEnded { _ in
//                                lastOffset = xOffset
//                                isDragging = false
//                            }
//                    )
//
//                
//                
//                Text("\(questionValue)")
//                    .foregroundStyle(.black)
//                    .frame(width:valueRepresentationSize, height:valueRepresentationSize)
//                    .background(.white.adjust(brightness:-0.3))
//                    .clipShape(.buttonBorder)
//                    .shadow(radius: 5.0)
//                    .offset(x:xOffset-valueRepresentationSize/2, y: sliderThumbSize*1.3)
//
//            }// zstack
//            .frame(width: barWidth, height: geometry.size.height)
//            .padding(.horizontal, stoneWidth/2)
////            .border(.red)
//
//        } // geometryReaader
//    }
//    
//    func applyValueToOffsets() -> Void {
////        wasGoodDay.map(from: 0...(geometry.size.width - 30), to: range)
//    }
//    
//
//}


