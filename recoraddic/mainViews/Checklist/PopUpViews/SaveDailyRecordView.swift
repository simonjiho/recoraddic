//
//  GetDailyStoneView.swift
//  recoraddic
//
//  Created by 김지호 on 12/23/23.
//

import Foundation
import SwiftUI
import SwiftData

struct SaveDailyRecordView_confirmation: View {
    @Environment (\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    
    var currentDailyRecordSet: DailyRecordSet
    var currentDailyRecord: DailyRecord
    @Binding var popUp_self: Bool
    let saveAsToday: Bool
    let todayRecordExists: Bool
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView:MainViewName
    
    let questionValue1: Int?
    let questionValue2: Int?
    let questionValue3: Int?
    
    let askQuestions: Bool
    let savingDate: Date


    init(currentDailyRecordSet: DailyRecordSet, currentDailyRecord: DailyRecord, popUp_self: Binding<Bool>, saveAsToday: Bool, todayRecordExists: Bool, isNewDailyRecordAdded: Binding<Bool>, selectedView: Binding<MainViewName>, qVal1: Int?, qVal2: Int?, qVal3: Int?) {
        
        self._quests = Query()
        self._dailyRecords = Query(sort:\DailyRecord.date)
        
        self.currentDailyRecordSet = currentDailyRecordSet
        self.currentDailyRecord = currentDailyRecord
        self._popUp_self = popUp_self
        self.saveAsToday = saveAsToday
        self.todayRecordExists = todayRecordExists
        self._isNewDailyRecordAdded = isNewDailyRecordAdded
        self._selectedView = selectedView
        
        self.questionValue1 = qVal1
        self.questionValue2 = qVal2
        self.questionValue3 = qVal3

        
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
                Button(action:{popUp_self.toggle()}) {
                    Image(systemName: "x.circle")
                }
                .frame(width:geometry.size.width*0.95, alignment: .trailing)
                
                VStack {
                    Text("\(yyyymmddFormatOf(savingDate)) 로 저장하시겠습니까?")

                    HStack(spacing:30) {
                        Button(action: {
                            saveDailyRecord()
                            popUp_self.toggle()
                            selectedView = .seeMyRecord
                        }) {
                            Text("예")
                        }
                        Button(action: {popUp_self.toggle()}) {
                            Text("아니오")
                        }
                    }
                    
                } // Vstack
                .frame(width: geoWidth, height:geoWidth)
                

            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)

        }

    }
    


    
    func saveDailyRecord() -> Void { // TODO: 이 과정에서 에러 일어나면 전부 undo 처리하고, 똑같은 에러가 다시 일어나지 않게 처리
        
        currentDailyRecord.date = savingDate
        
        if currentDailyRecordSet.dailyRecords!.count == 0 {
            currentDailyRecordSet.start = savingDate
        }

        currentDailyRecord.dailyRecordSet = currentDailyRecordSet
        
        currentDailyRecord.questionValue1 = questionValue1
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
        
        if !saveAsToday && todayRecordExists && askQuestions {
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


struct AnswerQuestions: View {
    
    @Environment (\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    
    var currentDailyRecordSet: DailyRecordSet
    var currentDailyRecord: DailyRecord
    @Binding var popUp_self: Bool
    let saveAsToday: Bool
    let todayRecordExists: Bool
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView:MainViewName
    
    
    @State var questionValue1: Int? = 0
    @State var questionValue2: Int?
    @State var questionValue3: Int?
    @State var questionValue1_nonNil: Int = 0
    @State var questionValue2_nonNil: Int = 0
    @State var questionValue3_nonNil: Int = 0
    
    @State var popUp_saveConfirm: Bool = false
    
    let savingDate: Date
    
    
    init(currentDailyRecordSet: DailyRecordSet, currentDailyRecord: DailyRecord, popUp_self: Binding<Bool>, saveAsToday: Bool, todayRecordExists: Bool, isNewDailyRecordAdded: Binding<Bool>, selectedView: Binding<MainViewName>) {
        
        self._quests = Query()
        self._dailyRecords = Query(sort:\DailyRecord.date)
        
        self.currentDailyRecordSet = currentDailyRecordSet
        self.currentDailyRecord = currentDailyRecord
        self._popUp_self = popUp_self
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
            
            ZStack {
                VStack {
                    Button(action:{popUp_self.toggle()}) {
                        Image(systemName: "x.circle")
                    }
                    .frame(width:geometry.size.width*0.95, alignment: .trailing)
                    
                    VStack {
                        Group {
                            if currentDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
                                // 어떻게 하지..........?????????
                                VStack {
                                    StoneTower_1_stone(
                                        shapeNum: StoneTower_1.calculateVisualValue1(qVal1: questionValue1, qVal2: questionValue2, qVal3: questionValue3),
                                        brightness: StoneTower_1.calculateVisualValue2(qVal1: questionValue1, qVal2: questionValue2, qVal3: questionValue3),
                                        defaultColorIndex: currentDailyRecordSet.dailyRecordColorIndex,
                                        facialExpressionNum: currentDailyRecord.mood,
                                        selected: false
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
                                
                                
                            }
                            if questionValue2 != nil {
                                VStack {
                                    Text(currentDailyRecordSet.dailyQuestions[1])
                                    NumberPadForQuestionValue(questionValue:$questionValue2_nonNil)
                                        .frame(width:numberPadWidth, height:numberPadHeight)
                                        .onChange(of: questionValue2_nonNil) {
                                            questionValue2 = questionValue2_nonNil
                                        }
                                    
                                    
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
                                    
                                }
                            }
                            
                            
                            
                        }
                        .frame(width:questionBoxWidth, height:questionBoxHeight)
                        
                        
                        
                    } // Vstack
                    .frame(width: stepsContentViewWidth, height:stepsContentViewHeight)
                    
                    Button(action: {popUp_saveConfirm.toggle()}) { Text("저장") }
                        .padding(.top,15)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                
                if popUp_saveConfirm {
                    Color.gray.opacity(0.6)
                        .ignoresSafeArea(.all)
                    SaveDailyRecordView_confirmation(
                        currentDailyRecordSet: currentDailyRecordSet,
                        currentDailyRecord: currentDailyRecord,
                        popUp_self: $popUp_saveConfirm,
                        saveAsToday: saveAsToday,
                        todayRecordExists: todayRecordExists,
                        isNewDailyRecordAdded: $isNewDailyRecordAdded,
                        selectedView: $selectedView,
                        qVal1: questionValue1,
                        qVal2: questionValue2,
                        qVal3: questionValue3
                    )
                    .popUpViewLayout(width: geometry.size.width/0.9*0.8, height: geometry.size.height/0.95*0.4, color: colorSchemeColor)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .onChange(of: isNewDailyRecordAdded) {
                popUp_self.toggle()
            }
            
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





