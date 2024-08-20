


//
//  recommendationsView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
// TODO: (iCloud 사용 시) 각각의 ElementView들은 Query를 사용하지 않기에, 프로퍼티들이 SwiftUI내에서 바로 최신화 되지 않는다. Query를 통해 접근한 데이터 만이 SwiftUI View내에서 바로 최신화 된다. 바로 최신화를 하려면 Query를 통해 접근하는 방식을 취할 것.

import Foundation
import SwiftUI
import SwiftData
import UIKit // not available on macOS
import Combine
import ActivityKit



// this view controls all the other part of ChecklistView. ChecklistView only visualizes data and provide simpleMenus for each data.
// MainView_checklist와 CheckㅣistView의 역할 분배가 관리하기 쉽게 이루어졌는지 나중에 검토 필요(24.03.07)
// 그냥 합칠까??????????????????????????????????????????????? 
struct MainView_checklist: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var profiles: [Profile]
    @Query var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]

//    var currentRecordSet: DailyRecordSet
    
    @Binding var selectedView: MainViewName
    
    @State var currentDailyRecord: DailyRecord = DailyRecord()
    
    @State var selectedDate: Date = getStandardDateOfNow()
    @State var popUp_addDailyQuest: Bool = false
    @State var popUp_changePurpose: Bool = false
    @State var editDiary = false
    @State var selectDiaryOption = false
    @State var selectedDailyQuest: DailyQuest? = nil
    @State private var timer: Timer? = nil
    @State var todoActivated: Bool = false
    @State var keyboardAppeared = false
    @State var keyboardHeight: CGFloat = 0
    @State var changeMood: Bool = false
    @State var forceToChooseMood: Bool = false
    @State var selectedClassification: String = "전체"
    
//    @StateObject private var notificationManager = NotificationManager()

    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { $0.keyboardHeight },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }



    var body: some View {

        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let topForegroundColor: Color = {
            if getStartOfDate(date: selectedDate) == getStartDateOfNow() {
                return reversedColorSchemeColor
            } else if getStartOfDate(date: selectedDate) > getStartDateOfNow() {
                if colorScheme == .light {
                    return Color.blue.adjust(saturation:-0.5, brightness: -0.4)
                } else {
                    return Color.blue.adjust(saturation:-0.35, brightness: 0.7)
                }
            } else {
                if colorScheme == .light {
                    return Color.green.adjust(saturation:-0.3, brightness: -0.4)
                } else {
                    return Color.green.adjust(saturation:-0.2, brightness: 0.7)
                }
            }
        }()
        
//        let shadowColor:Color = getShadowColor(colorScheme)

        let middleColor:Color = colorScheme == .light ? Color.black.adjust(brightness: 0.2) : Color.white
//        let linearGradient1: LinearGradient =
//        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, middleColor, Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing)
//        let linearGradient2: LinearGradient =
//        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, middleColor, Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
        
        let bgColor: Color = currentDailyRecord.dailyRecordSet?.getIntegratedDailyRecordColor(colorScheme: colorScheme) ?? Color.gray
        
        
        // currentRecord == records.last => 기간이 지났어도 currentRecord임
        GeometryReader { geometry in

            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            let checkListElementWidth: CGFloat = geoWidth * 0.95
            
            let buttonSize = geoWidth*0.06
//            let buttonSize = geoWidth/13 // ~24.08.17
            
//            let popUp_addQuest_height = geometry.size.height*(keyboardAppeared ? 0.6 : 0.8)
//            let popUp_addQuest_yPos = keyboardAppeared ? 35 + popUp_addQuest_height/2 : geometry.size.height/2
            
//            let popOver_changeMood_width = geoWidth*0.6
//            let popOver_changeMood_height = geoHeight*0.6
            
            let popUp_changeMood_width = geoWidth * 0.7
            let popUp_changeMood_height = geoHeight * 0.7

            let facialExpressionSize = geoWidth*0.085
//            facialExpressionSize*0.7
//            let isNotToday: Bool = getStartOfDate(date: selectedDate) != getStartDateOfNow()
            
            ZStack {

                VStack(spacing:0.0) {

                    HStack(spacing:0.0) {
                        if currentDailyRecord.dailyText == nil {
                            Button(action:{selectDiaryOption = true}) {
                                Image(systemName:"book.closed.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: facialExpressionSize*0.7, height: facialExpressionSize*0.7)

                            }
                            .padding(.trailing)
                            .frame(width:geoWidth*0.15, alignment: .trailing)
                            .buttonStyle(.plain)
//                            .border(.red)
                        } else {
                            Spacer()
                                .frame(width:geoWidth*0.15)
                        }
                        
                        HStack(spacing: 0.0) {
//                            HStack(spacing:10.0) {
//                                if getStartOfDate(date: selectedDate) > getStartDateOfNow() {
//                                    Button(action: {selectedDate = getStartDateOfNow()}) {
//                                        Image(systemName: "arrow.uturn.left")
//                                    }
//            //                        .frame(height: geoHeight*0.05)
//                                }
//                                Button(action:{selectedDate = selectedDate.addingDays(-1)}) {
//                                    Image(systemName: "chevron.left")
//                                }
//                                .buttonStyle(.plain)
//
//                            }
//                            .padding(.trailing,7)
//                            .frame(width: geoWidth*0.15, alignment: .trailing)

                            if getStartOfDate(date: selectedDate) > getStartDateOfNow() {
                                Button(action: {selectedDate = getStartDateOfNow()}) {
                                    Image(systemName: "arrow.uturn.left")
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing,7)
                                .frame(width: geoWidth*0.15, alignment: .trailing)
//                                .border(.red)
                            }
                            else {
                                Spacer()
                                    .frame(width: geoWidth*0.15)

                            }
                            DatePicker(selection: $selectedDate,displayedComponents: [.date]) {}
                                .labelsHidden()
                                .foregroundStyle(topForegroundColor)
//                                .frame(width: geoWidth*0.5)
//                            HStack(spacing:10.0) {
//                                Button(action:{selectedDate = selectedDate.addingDays(1)}) {
//                                    Image(systemName: "chevron.right")
//                                }
//                                .buttonStyle(.plain)
//                                if getStartOfDate(date: selectedDate) < getStartDateOfNow() {
//                                    Button(action: {selectedDate = getStartDateOfNow()}) {
//                                        Image(systemName: "arrow.uturn.right")
//                                    }
//                                    .buttonStyle(.plain)
//            //                        .frame(height: geoHeight*0.05)
//                                }
//                            }
//                            .padding(.leading,7)
//                            .frame(width: geoWidth*0.15, alignment: .leading)
                            if getStartOfDate(date: selectedDate) < getStartDateOfNow() {
                                Button(action: {selectedDate = getStartDateOfNow()}) {
                                    Image(systemName: "arrow.uturn.right")
                                }
                                .padding(.leading,7)
                                .frame(width: geoWidth*0.15, alignment: .leading)
                                .buttonStyle(.plain)
                            }
                            else {
                                Spacer()
                                    .frame(width: geoWidth*0.15)
                                
                            }
                            
                        }
                        .frame(width: geoWidth*0.7)
                        
                            
                        
                        Group {
                            if currentDailyRecord.mood == 0 {
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .frame(width: facialExpressionSize, height: facialExpressionSize)
                                
                            }
                            else {
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: geoWidth*0.002)
                                        .frame(width:facialExpressionSize, height: facialExpressionSize)
                                    topForegroundColor
                                        .frame(width:facialExpressionSize, height: facialExpressionSize)
                                        .mask(
                                            Image("facialExpression_\(currentDailyRecord.mood)")
                                                .resizable()
                                                .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                        )
                                }
                            }
                        }
                        .padding(.trailing)
                        .frame(width:geoWidth*0.15,alignment: .trailing)
                        .onTapGesture {
                            changeMood.toggle()
                        }
                        .popover(isPresented: $changeMood) {
                            VStack {
                                Picker("분류", selection: $selectedClassification) {
                                    ForEach(["전체", "😆","😀","😐","😟","😩"],id:\.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                //                            .frame(height:geoHeight*0.06)
                                ScrollView {
                                    let numList:[Int] = {
                                        
                                        if selectedClassification == "전체" {return Array(1...125)}
                                        else if selectedClassification == "😆" {return recoraddic.facialExpression_Good2}
                                        else if selectedClassification == "😀" {return recoraddic.facialExpression_Good1}
                                        else if selectedClassification == "😟" {return recoraddic.facialExpression_Bad1}
                                        else if selectedClassification == "😩" {return recoraddic.facialExpression_Bad2}
                                        else if selectedClassification == "😐" {return recoraddic.facialExpression_Middle}
                                        else { return [1]}
                                    }()
                                    let VGridSize = popUp_changeMood_width * 0.2
                                    
                                    if forceToChooseMood {
                                        Text("하루를 표현할 표정을 선택하세요!")
                                            .foregroundStyle(.red)
                                            .minimumScaleFactor(0.5)
                                    }
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: VGridSize))]) {
                                        Color.black.opacity(0.6)
                                            .mask {
                                                Image(systemName: "questionmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .blur(radius: 0.2)
                                                    .frame(width:VGridSize*0.7, height: VGridSize*0.7)
                                            }
                                            .frame(width:VGridSize, height: VGridSize)
                                            .background(bgColor.opacity(0.3))
                                            .onTapGesture {
                                                
                                                currentDailyRecord.mood = numList[Int.random(in: 0...numList.count-1)]
                                                changeMood.toggle()

                                                
                                            } // onTapGesture
                                        
                                        
                                        ForEach(numList, id: \.self) { index in
                                            Color.black.opacity(0.6)
                                                .mask {
                                                    Image("facialExpression_\(index)")
                                                        .resizable()
                                                        .blur(radius: 0.2)
                                                        .frame(width:VGridSize*0.7, height: VGridSize*0.7)
                                                }
                                                .frame(width:VGridSize, height: VGridSize)
                                                .background(bgColor.opacity(currentDailyRecord.mood == index ? 1.0 : 0.3))
                                            
                                                .shadow(radius: 1)
                                            //                                            .border(reversedColorSchemeColor, width: /* border width */ 1)
                                            
                                            
                                                .onTapGesture {
                                                    
                                                    if currentDailyRecord.mood == index {
                                                        currentDailyRecord.mood = 0
                                                    }
                                                    else {
                                                        currentDailyRecord.mood = index
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                            changeMood.toggle()
                                                        }
                                                    }
                                                    
                                                } // onTapGesture
                                        }
                                        
                                    } // LazyVGrid
                                    .padding(.top,10)
                                } // ScrollView
                                .frame(width: popUp_changeMood_width*0.95, height: popUp_changeMood_height*0.9)
                            }
                            .padding(.horizontal,popUp_changeMood_width*0.02)
                            .padding(.vertical,popUp_changeMood_height*0.02)
                            .frame(width: popUp_changeMood_width, height: popUp_changeMood_height, alignment: .top)
                            .presentationCompactAdaptation(.popover)
                            
                            
                        }
                        
                        // use "in:" to add date range
                    }
//                    .frame(width: geoWidth, height: 100)
                    .padding(.top,geoHeight*0.035)
                    .padding(.bottom, geoHeight*0.005)
                    .foregroundStyle(topForegroundColor) // 너무 튀는 것 같기도 하고..
//                    .foregroundStyle(reversedColorSchemeColor.opacity(getStartOfDate(date: selectedDate) == getStartDateOfNow() ? 1.0 : 0.6))
                    


                    Color.gray
                        .opacity(0.4)
                        .frame(width: checkListElementWidth, height: 1)
                        .padding(.top, geoHeight*0.015)

                    ChecklistView(
                        currentDailyRecord: currentDailyRecord,
                        editDiary: $editDiary,
                        selectDiaryOption: $selectDiaryOption,
                        todoActivated: $todoActivated,
                        keyboardAppeared: $keyboardAppeared,
                        keyboardHeight: $keyboardHeight,
                        changeMood: $changeMood,
                        forceToChooseMood: $forceToChooseMood
                    )
//                    .frame(height: isToday ? geoHeight*0.93 : geoHeight*0.88)
//                    .frame(height:geoHeight*0.93)
//                    .border(.red)
                }
                .frame(width:geometry.size.width, height: geometry.size.height, alignment: .top)
//                .border(.blue)

                HStack(spacing:0.0) {
                    
                    Button(action:{selectedDate = selectedDate.addingDays(-1)}) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .padding(.leading, 20)
                    .frame(width:geoWidth*0.35, alignment: .leading)
                    .buttonStyle(CheckListButtonStyle3(color: topForegroundColor))

                    Button(action:{
                        popUp_addDailyQuest.toggle()
                        selectDiaryOption = false // ??
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .buttonStyle(CheckListButtonStyle3(color: topForegroundColor))
//                    .frame(width:buttonSize, height:buttonSize)
                    .frame(width:geoWidth*0.3)
                    
                    Button(action:{selectedDate = selectedDate.addingDays(1)}) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .padding(.trailing, 20)
                    .frame(width:geoWidth*0.35, alignment: .trailing)
                    .buttonStyle(CheckListButtonStyle3(color: topForegroundColor))

                }
                .position(x:geoWidth/2, y:geoHeight*0.95 - 10)


                
            
                
//                let nothingToSave: Bool = currentDailyRecord.dailyText == nil && currentDailyRecord.dailyQuestList!.count == 0 && currentDailyRecord.todoList!.count == 0
                



                
            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear {
                
//                updateExistency()
                changeDailyRecord()
//                updateDailyQuestAlerm()
                startTimer()
                setKeyboardAppearanceStateValue()
                
//                NotificationCenter.default.addObserver(forName: ., object: <#T##Any?#>, queue: <#T##OperationQueue?#>, using: <#T##(Notification) -> Void#>)
                
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .onReceive(keyboardHeightPublisher) { value in

                if keyboardAppeared {
                    withAnimation {
                        self.keyboardHeight = value*0.75 //MARK: navigationBarHeight does not contain the bottom safeArea of display, so it is less than actual navigationBarHeight that is displayed
                    }


                }
                else {
                    withAnimation { //MARK: debuger message: Bound preference ViewFrameKey tried to update multiple times per frame. May cause problem later.
                        self.keyboardHeight = value
                    }
                }

            }
            .onChange(of: selectedView) { oldValue, newValue in
//                currentDailyRecord = dailyRecords.first ?? DailyRecord()
//                updateExistency()
//                updateDailyQuestAlerm()
                
                for dailyQuest in currentDailyRecord.dailyQuestList! {
                    dailyQuest.currentTier = quests.first(where: {$0.name == dailyQuest.questName && !$0.inTrashCan})?.tier ?? 0
                }
                
            }
            .onChange(of: changeMood) {
                if !changeMood && forceToChooseMood {
                    forceToChooseMood = false
                }
            }
//            .onReceive(notificationManager.$notificationData) { userInfo in
//                
////                updateDailyQuestAlerm()
//            }
            .popover(isPresented: $popUp_addDailyQuest) {
                EditCheckListView(
                    currentDailyRecord: currentDailyRecord,
                    popUp_self: $popUp_addDailyQuest,
                    selectedView: $selectedView,
                    todoIsEmpty: currentDailyRecord.todoList?.isEmpty ?? true
                )
                .presentationCompactAdaptation(.fullScreenCover)
                .ignoresSafeArea(.keyboard)

            }
            
            .onChange(of: selectedDate) { oldValue, newValue in
                
//                selectedDate = getStandardDate(from: newValue) // No worry of infinite onChangeCall
                
                
                
                if oldValue < getStandardDateOfYesterday() {
                    removeEmptyDailyQuests()
                }
                changeDailyRecord()
            }
//            .onChange(of: scenePhase) { oldValue, newValue in
//                if scenePhase == .active {
//                    if let newDate = Activity<RecoraddicWidgetAttributes>.activities.map({$0.attributes.containedDate}).sorted().first {
//                        selectedDate = getStartOfDate(date: newDate)
//                    }
//                }
//            }
            
//            .onReceive(NotificationCenter.default.publisher(for: .specificNotification)) { notification in
//                if let userInfo = notification.userInfo {
//                    
//                    if let date = userInfo["date"] as? Int {
//                        print("Received extraInfo: \(extraInfo)")
//                    }
//                }
//            }

 

        }
        



    }
    


    
//    private func updateDailyQuestAlerm() {
//        // MARK: 앱을 끈 상태에서 들어가면 잘 nil처리 됨, 킨 상태이면 안됨
//        // Your function to be executed when the app is opened via notification
//        if let dailyQuests = currentDailyRecord.dailyQuestList {
//            //            print("hallo~~~")
//            for dailyQuest in dailyQuests {
//                if let alermTime = dailyQuest.alermTime {
//                    if alermTime.isExpired_local {
//                        dailyQuest.alermTime = nil
//                    }
//                }
//            }
//        }
//    }
    
    
    func startTimer() { // 오늘의 자정에 timer 맞추기 ( 24/07/11 12:00 -> 24/07/12 00:00 에 작동하는 타이머 설정)
        // MARK: 과연 00:00 에 작동하는가? 23:59에 작동할 가능성은?
        let date = Date()
        let calendar = Calendar.current
        let tommorow = getTomorrowOf(date)
        let timeInterval = tommorow.timeIntervalSince(date)

//        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
//            updateExistency()
//        }
    }
    
    func setKeyboardAppearanceStateValue() -> Void {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in

            withAnimation {
                keyboardAppeared = true
            }
        }
        

        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardAppeared = false
            }
        }
    }
    
    
    func changeDailyRecord() -> Void {
        if let targetDailyRecord:DailyRecord = dailyRecords.first(where: {$0.getLocalDate() == getStartOfDate(date: selectedDate)}) { // found target
            currentDailyRecord = targetDailyRecord
//            currentDailyRecord.dailyRecordSet = currentRecordSet
        } else if let nilDailyRecord: DailyRecord = dailyRecords.first(where: {$0.date == nil}) { // use buffer dailyRecord
            nilDailyRecord.date = getStandardDate(from: selectedDate)
            currentDailyRecord = nilDailyRecord
            currentDailyRecord.dailyRecordSet = findDailyRecordSet(selectedDate)
            let newNilDailyRecord: DailyRecord = DailyRecord()
            modelContext.insert(newNilDailyRecord)
            print("no!!!!")
        } else { // no buffer dailyRecord
            print("no!!!!!!!")
            let newDailyRecord: DailyRecord = DailyRecord(date: getStandardDate(from: selectedDate))
            currentDailyRecord = newDailyRecord
            currentDailyRecord.dailyRecordSet = findDailyRecordSet(selectedDate)
            modelContext.insert(newDailyRecord)
            let newNilDailyRecord2: DailyRecord = DailyRecord()
            modelContext.insert(newNilDailyRecord2)
        }
    }
    
    func findDailyRecordSet(_ date: Date) -> DailyRecordSet?  {
        return dailyRecordSets.filter({$0.start <= date}).last
//        if let dailyRecordSet = dailyRecordSets.filter({$0.start <= date}).last {
//            return dailyRecordSet
//        }
//        else { // will not be executed in most normal situations
//            let newDailyRecordSet = DailyRecordSet(start: date)
//            modelContext.insert(newDailyRecordSet)
//            return newDailyRecordSet
//        }
    }
    
    func removeEmptyDailyQuests() -> Void {
            
        for dailyQuest in currentDailyRecord.dailyQuestList! {
            if dailyQuest.data == 0 {
                modelContext.delete(dailyQuest)

            }
        }
        
        for todo in currentDailyRecord.todoList! {
            if todo.content == "" || !todo.done {
                modelContext.delete(todo)
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
        if !currentDailyRecord.hasContent {
            currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
        }
            
//        }
        
    }
    
    func cleanUpDailyRecords() -> Void { // 1. keep dailyRecord whose date is nil be unique  / 2. delete empty DailyRecords that's been not used for a long
        
    }

    

}


struct CheckListButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    

    init() {
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal,10)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
//            .background(getColorSchemeColor(colorScheme))
            .background(.thinMaterial)
            .clipShape(.buttonBorder)

    }
}

struct CheckListButtonStyle2: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    

    init() {
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
//            .background(getColorSchemeColor(colorScheme))
            .background(.ultraThinMaterial)
            .clipShape(.buttonBorder)

    }
}


struct CheckListButtonStyle3: ButtonStyle {
    
    let color: Color

    init(color:Color) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .foregroundStyle(color)
//            .background(getColorSchemeColor(colorScheme))
            .background(.ultraThinMaterial)
            .clipShape(.buttonBorder)

    }
}




// + special + dayOff(아무것도 기록하고 싶지 않은 날) -> dates/7 개 주어짐.
// 여기서는 checklist의 data들이 시각화되고, 시각화된 부분을 제스처로 제어하는 부분만 구현(QCBD 수정&삭제, DR.diary 수정&삭제 등등)
struct ChecklistView: View {


    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query(sort:\DailyQuest.createdTime) var dailyQuests: [DailyQuest]
    @Query var quests: [Quest]


    var currentDailyRecord: DailyRecord
    

    @Binding var editDiary: Bool
    @Binding var selectDiaryOption: Bool
    @Binding var todoActivated: Bool
    @Binding var keyboardAppeared: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var changeMood: Bool
    @Binding var forceToChooseMood: Bool


    @State var applyDailyQuestRemoval: Bool = false
    @State var applyDailyTextRemoval: Bool = false
//    @State var applyDailyEventRemoval: Bool  = false
    @State var dailyQuestToDelete: DailyQuest?
//    @State var eventCheckBoxDataToDelete: EventCheckBoxData?
    @State var popUp_changePurpose: Bool = false
    @State var selectedDailyQuest: DailyQuest?
    @State var buffer_chosenPurposes: Set<String> = Set()

    @State var editingIndex: Int?
    @State var editingTodo: Todo?
    @State var doneButtonPressed: Bool = false
    
//    @State var todoText: [String] = []
//    @State var todoDone: [Bool] = []
    
    
    @State var diaryViewWiden: Bool = false
    
    
    


//    @State var dailyQuest_justCreated: DailyQuest? = nil

    var profile:Profile {
        profiles.count != 0 ? profiles[0] : Profile() // MARK: signOutErrorPrevention
    }


    var body: some View {
        
//        let shadowColor:Color = getShadowColor(colorScheme)
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)


        let showHiddenQuests = profile.showHiddenQuests
        let hiddenQuestNames: [String] = showHiddenQuests ? [] : quests.filter({$0.isHidden}).map({$0.name})
        
        let dailyQuests_notHidden_sorted = currentDailyRecord.dailyQuestList!.filter({!hiddenQuestNames.contains($0.questName)}).sorted(by:{
            if $0.alermTime != nil && $1.alermTime != nil {
                return $0.alermTime! <= $1.alermTime!
            }
            else if $0.alermTime != nil && $1.alermTime == nil {
                return true
            }
            else if $0.alermTime == nil && $1.alermTime != nil {
                return false
            }
            else if $0.dataType != $1.dataType {
                return $0.dataType < $1.dataType  // Sort by Age in ascending order
            }

            else {
                return $0.createdTime < $1.createdTime  // Sort by Name in ascending order
            }
            

        })
        
        let diaryExists: Bool = currentDailyRecord.dailyTextType != nil
        let dailyQuestExists: Bool = dailyQuests_notHidden_sorted.count !=  0
        let todoExists: Bool = currentDailyRecord.todoList!.count != 0
        
        
        GeometryReader { geometry in


            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height

            
            let checkListElementWidth = geometry.size.width*0.97
            
            let questCheckBox_purposeTagsWidth = checkListElementWidth*0.1
            let questCheckBoxWidth = checkListElementWidth*0.9
//            let questCheckBoxHeight = geoHeight*0.075
            let questCheckBoxHeight:CGFloat = 55.0
//            let questCheckBoxHeight_hours: CGFloat = 70.0
//            let questCheckBoxHeight_custom: CGFloat = 60.0
//            let questCheckBoxHeight_ox: CGFloat = 45.0
            
            let todo_purposeTagsWidth = checkListElementWidth * 0.1
            let todo_checkBoxSize = checkListElementWidth * 0.1
            let todo_textWidth = editingIndex == nil ? checkListElementWidth * 0.7 : checkListElementWidth * 0.8
            let todo_xmarkSize = checkListElementWidth * 0.1
            let todo_height = geoHeight * 0.06
            
            let purposeTagsMaxLength = geometry.size.width*0.2
            let purposeTagsHeight = geometry.size.height*0.04
            
//            let diaryHeight = diaryViewWiden ? geometry.size.height * (editDiary ? 0.6 : 0.9) : 60
            let diaryHeight = (currentDailyRecord.dailyTextType == DailyTextType.diary && editDiary) ? (geometry.size.height - keyboardHeight)*0.9 : questCheckBoxHeight


            ZStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        
//                        VStack {
//
                            Spacer()
                                .frame(height: geoHeight*0.02)
                            
                            if selectDiaryOption {
                                ZStack {
                                    HStack(spacing:geoWidth*0.1) {
                                        Button("요약", action:{
                                            editDiary = true // 아래하고 순서 바뀌면 안됨
                                            currentDailyRecord.dailyTextType = DailyTextType.inShort
                                            currentDailyRecord.dailyText = ""
                                            if currentDailyRecord.singleElm_diary {
                                                currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
                                            }
                                            selectDiaryOption = false
                                        })
                                        .buttonStyle(.bordered)
                                        Button("길게", action:{
                                            editDiary = true // 아래하고 순서 바뀌면 안됨
                                            //                            popUp_addDiary.toggle()
                                            currentDailyRecord.dailyTextType = DailyTextType.diary
                                            currentDailyRecord.dailyText = ""
                                            if currentDailyRecord.singleElm_diary {
                                                currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
                                            }
                                            selectDiaryOption = false
                                            
                                        })
                                        .buttonStyle(.bordered)
                                    }
                                    Button(action:{
                                        selectDiaryOption.toggle()
                                    }) {
                                        Image(systemName: "xmark")
                                    }
                                    .frame(width:checkListElementWidth, alignment:.trailing)
                                }
                                .padding()
                                
                            }
                            //                            if (currentDailyRecord.dailyTextType != nil && !editDiary) {
                            //                                Text("일기")
                            ////                                    .bold()
                            //                                    .frame(width:checkListElementWidth, alignment:.leading)
                            //                            }
                        
                            
                            if (currentDailyRecord.dailyTextType == DailyTextType.diary) {
                                
                                DiaryView(
                                    currentDailyRecord: currentDailyRecord,
                                    diaryText: currentDailyRecord.dailyText!,
                                    applyDiaryRemoval: $applyDailyTextRemoval,
                                    isEdit: $editDiary
                                )
                                .frame(width:checkListElementWidth, height: diaryHeight)
//                                .frame(width:checkListElementWidth)
//                                .zIndex(3)

                                
                                
                            }
                            else if (currentDailyRecord.dailyTextType == DailyTextType.inShort) {
                                InShortView(
                                    currentDailyRecord: currentDailyRecord,
                                    inShortText: currentDailyRecord.dailyText!,
                                    applyDailyTextRemoval: $applyDailyTextRemoval
//                                    isEdit: $editDiary
                                )
                                .frame(width:checkListElementWidth, height: diaryHeight)
                                //                            .background(.gray.adjust(brightness: 0.4).opacity(0.7))
//                                .clipShape(.buttonBorder)
                                
                            }
                            

//                            if diaryExists && (dailyQuestExists || todoExists) {
                            if diaryExists {
                                Color.gray
                                    .opacity(0.4)
                                    .frame(width: checkListElementWidth, height: 1)
                                    .padding(.vertical, geoHeight*0.01)
                            }
                            
//                            if currentDailyRecord.dailyQuestList!.count !=  0 {
//                                Text("누적 퀘스트")
//                                    .frame(width:checkListElementWidth,alignment: .leading)
//                            }

                            VStack(spacing:5.0) {
                                ForEach(dailyQuests_notHidden_sorted, id: \.self) { dailyQuest in
//                                ForEach(currentDailyRecord.dailyQuestList!, id: \.self) { dailyQuest in
                                    
                                    HStack(spacing: 0) {
                                        
                                        let height:CGFloat = dailyQuest.dataType != DataType.ox.rawValue ? 60.0 : 50.0

                                        
                                        PurposeOfDailyQuestView(dailyQuest: dailyQuest, parentWidth: geoWidth, parentHeight: geoHeight)
                                            .frame(width:questCheckBox_purposeTagsWidth, height: height, alignment: .leading)
                                            .opacity(0.9)
                                            .zIndex(3)


                                        let data = dailyQuest.data
                                        
                                        let xOffset:CGFloat = data == 0 ? 0.1 : CGFloat(data).map(from:0.0...CGFloat(dailyQuest.dailyGoal ?? dailyQuest.data), to: 0...questCheckBoxWidth)
                                        
                                        
                                        QuestCheckBoxView(
                                            dailyQuest: dailyQuest,
                                            targetDailyQuest: $dailyQuestToDelete,
                                            deleteTarget: $applyDailyQuestRemoval,
                                            value: data,
                                            dailyGoal: dailyQuest.dailyGoal,
                                            xOffset: xOffset,
                                            width: questCheckBoxWidth
                                        )
                                        .opacity(0.85)

//
                                        
                                    }
                                    .frame(width: checkListElementWidth, alignment:.leading)
                                    

                                }
                            }
                            
                            
//                            Spacer()
//                                .frame(width:checkListElementWidth, height: dailyQuestExists ? geoHeight*0.08 : 0.0)
                            
                            
                            if dailyQuestExists {
                                Color.gray
                                    .opacity(0.4)
                                    .frame(width: checkListElementWidth, height: 1)
                                    .padding(.vertical, geoHeight*0.01)
                            }
                            
                            
                            let todoList_sorted = currentDailyRecord.todoList!.sorted(by: {$0.idx < $1.idx})
//                            if todoList_sorted.count != 0 {
//                                Text("일반 퀘스트")
//                                    .frame(width:checkListElementWidth,alignment: .leading)
//                            }
                            VStack (spacing:todo_height*0.2) {
                                ForEach(todoList_sorted, id:\.self) { todo in
                                    
                                    // view에 반영하는 내용은 stateVariable로 전부 대체 -> 처음 불러올 때 적용, 그리고 tapgesture on checkbox, submission(추가), 완료, x(삭제) 때만 modelContext의 데이터 변경해주기

                                    HStack(spacing:0.0) {
                                        
                                        PurposeOfTodoView(todo: todo, parentWidth: geoWidth, parentHeight: geoHeight)
                                            .frame(width:todo_purposeTagsWidth, height: todo_height)
                                        
                                        Button(action:{
                                            todo.done.toggle()
                                        }) {
                                            let checkBoxSize = min(todo_checkBoxSize, todo_height)
                                            Image(systemName: todo.done ? "checkmark.circle" : "circle")
                                                .resizable()
                                                .frame(width: questCheckBoxWidth*0.1*0.65, height: questCheckBoxWidth*0.1*0.65)
//                                                .bold()
//                                                .frame(width:checkBoxSize*0.8, height: checkBoxSize*0.8)
                                        }
                                        .frame(width: questCheckBoxWidth*0.1, alignment: .center)
                                        .buttonStyle(.plain)
//                                        .border(.red)

//                                        HStack(spacing:0.0) {
//                                            Text("\(todo.idx)")
                                        Group {
                                            textFieldView(currentDailyRecord: currentDailyRecord, todo: todo, text: todo.content, editingTodo:$editingTodo, idx: $editingIndex, doneButtonPressed: $doneButtonPressed)
                                                .frame(width:editingIndex == todo.idx ? todo_textWidth*0.8 : todo_textWidth)
//                                                .frame(width:todo_textWidth*0.8)
                                        }
                                        .frame(width:questCheckBoxWidth*0.8, alignment:.leading)
//                                        .border(.red)
                                        
                                        if editingIndex == todo.idx {
                                            Button("완료") {
                                                doneButtonPressed.toggle()
                                            }
                                            .frame(width:questCheckBoxWidth*0.1)
                                        }
                                        
                                        if editingIndex == nil {
                                            Button(action:{
                                                let targetIndex = todo.idx
                                                
                                                modelContext.delete(todo)
                                                if !currentDailyRecord.hasContent {
                                                    currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
                                                }

                                            }) {
                                                let xmarkSize = min(todo_xmarkSize, todo_height)
                                                Image(systemName: "xmark")
//                                                    .resizable()
//                                                    .frame(width: questCheckBoxWidth*0.1*0.65, height: questCheckBoxWidth*0.1*0.65)
//                                                    .frame(width:xmarkSize*0.5, height: xmarkSize*0.5)
                                            }
//                                            .border(.yellow)
                                            .buttonStyle(.plain)
//                                            .frame(width: todo_xmarkSize, alignment: .trailing)
//                                            .frame(width: questCheckBoxWidth*0.1, alignment:.leading)
                                            .frame(width: questCheckBoxWidth*0.1)
//                                            .border(.red)
                                        }
                                        
                                        
                                        
                                    }
                                    .frame(width: checkListElementWidth, height:todo_height, alignment:.leading)
                                    
                                    .id(todo.idx)
                                    
                                }
                                .onAppear() {
                                    print("hohoh")
                                    print(todoList_sorted.map({$0.idx}))
                                }
                                
                                if editingIndex != nil {
                                    HStack {
                                        Image(systemName: "return")
                                        Text("엔터 키를 통해 계속 입력 가능")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(width:checkListElementWidth)
                                    .opacity(0.5)
                                } else {
                                    HStack(spacing:0.0) {
                                        let tagSize = min(todo_purposeTagsWidth*0.8,todo_height*0.3)
                                        HStack {
                                            Image(systemName:"questionmark.square")
                                                .resizable()
                                                .frame(width:tagSize, height:tagSize)
                                                .foregroundStyle(reversedColorSchemeColor)
                                        }
                                        .frame(width: todo_purposeTagsWidth)

                                        HStack {
                                            Image(systemName: "checkmark.circle")
                                                .resizable()
                                                .frame(width: questCheckBoxWidth*0.1*0.65, height: questCheckBoxWidth*0.1*0.65)
                                        }
                                        .frame(width: questCheckBoxWidth*0.1, alignment: .center)

//                                        HStack(spacing:0.0) {
                                        if let date = currentDailyRecord.getLocalDate() {
                                            if date < getStartDateOfNow() {
                                                Text("클릭하여 달성한 일 적기")
                                                    .frame(width:questCheckBoxWidth*0.8, alignment:.leading)
                                            }
                                            else if date == getStartDateOfNow() {
                                                Text("클릭하여 당장 생각나는 할 일 적기")
                                                    .frame(width:questCheckBoxWidth*0.8, alignment:.leading)
                                            }
                                            else {
                                                Text("클릭하여 나중에 할 일 적기")
                                                    .frame(width:questCheckBoxWidth*0.8, alignment:.leading)
                                            }
                                        }

//                                            }
//                                        }
//                                        .frame(width:questCheckBoxWidth*0.8, alignment:.leading)
                                        
                                        Spacer()
                                            .frame(width:questCheckBoxWidth*0.1)
                                    }
                                    .frame(width: checkListElementWidth, height:todo_height, alignment:.leading)
                                    .opacity(0.5)
                                    .onTapGesture {
//                                        let firstTodo = Todo(dailyRecord: currentDailyRecord, index: 0)
//                                        modelContext.insert(firstTodo)
//                                        let newIdx:Int = (todoList_sorted.map({$0.idx}).sorted(by:{$0 < $1}).last + 1) ?? 0
                                        let newIdx:Int = todoList_sorted.map({$0.idx + 1}).sorted(by:{$0 < $1}).last ?? 0
                                        let newTodo = Todo(dailyRecord: currentDailyRecord, index: newIdx)
                                        modelContext.insert(newTodo)
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            editingIndex = newIdx
//                                        }
                                    }
                                    
                                }
                            }
                            
                            
                            Spacer()
//                                .frame(width: geometry.size.width, height: keyboardAppeared ? keyboardHeight*1.1 : geometry.size.height*0.2) // ~24.08.02
                                .frame(width: geometry.size.width, height: keyboardAppeared ? ( editDiary ? keyboardHeight*1.1 : keyboardHeight + geoHeight * 0.3): geometry.size.height*0.4)
                            
//                            TestNotificationView()
                            
                            
                            
//                        } // VStack


                    } // scroll view
                    .frame(width:geometry.size.width, height: geometry.size.height)
                    .onChange(of: editingIndex) {
//                            print("changed!!!")
                        if editingIndex != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    scrollProxy.scrollTo(editingIndex,anchor: .center)
                                }
                            }
                        }
                    }
                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
                    .scrollDisabled(editDiary)
//                    .defaultScrollAnchor(.bottom)
                    
                }
//                }
//                if currentDailyRecord.dailyQuestList!.isEmpty && currentDailyRecord.dailyTextType == nil && currentDailyRecord.todoList?.count == 0 && !selectDiaryOption {
//                    Text("체크리스트에 내용을 추가하세요!")
//                        .opacity(0.5)
//                    
//                }



            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear() {
                
            }
            .onChange(of: applyDailyQuestRemoval, removeDailyQuest)
            .onChange(of: applyDailyTextRemoval, removeDailyText)
            .onChange(of: currentDailyRecord, {
                editDiary = false
                editingIndex = nil
                diaryViewWiden = false
                
            })
            .refreshable {
                // when refreshed?
                // 아래로 당기면?
            }
            .onTapGesture {
                dailyQuestToDelete = nil
            }
            
            

            
            
            


        }



    }
    
    
//    func updateQuestCheckBowHeight() -> Void {
//        
//    }





    func removeDailyQuest() -> Void {
        
        
        if let dailyQuest = dailyQuestToDelete {
            updateQuest_onDelete(for: dailyQuest)
            if let alermTime = dailyQuest.alermTime {
                removeNotification(at: alermTime, for: dailyQuest.getName()) // MARK: questName 변경 시 지울 수 없음
            }
            modelContext.delete(dailyQuest)
        }
        dailyQuestToDelete = nil
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
        if !currentDailyRecord.hasContent {
            currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
        }
//        }
        // dailyGoal에서 제외
    }
    
    func updateQuest_onDelete(for dailyQuest: DailyQuest) -> Void {
        if let date = currentDailyRecord.date {
            if let targetQuest = findQuest(dailyQuest.questName) {
                targetQuest.dailyData.removeValue(forKey: date)
                targetQuest.updateTier()
                targetQuest.updateMomentumLevel()
            }
        }
    }

    
    func removeDailyText() -> Void {
        currentDailyRecord.dailyText = nil
        currentDailyRecord.dailyTextType = nil
//        currentDailyRecord.diaryImage = nil
        if !currentDailyRecord.hasContent {
            currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
        }
        editDiary = false
        diaryViewWiden = false
    }
    
    
        
        
        
    
    func findQuest(_ name: String) -> Quest? {
        if let quest_notDeleted = quests.first(where: {$0.name == name && !$0.inTrashCan}) {
            return quest_notDeleted
        } else {
            return quests.first(where: {$0.name == name})
        }
    }
    



}


struct textFieldView: View {
    
    @Environment(\.modelContext) var modelContext
    
    var currentDailyRecord: DailyRecord
    var todo: Todo
    @State var text: String
    
    @Binding var editingTodo: Todo?
    @Binding var idx: Int?
    @Binding var doneButtonPressed: Bool
    @FocusState var isFocused: Bool

    // MARK: 오류발생 -> 실제로 일어날 확률이 적지만, 엄청빠른 속도로 todo를 생성 시 focus된 textfield가 여러개
    var body: some View {
        
        
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height

            TextField("할 일을 입력하세요",text: $text, axis:.horizontal)
            .padding(.leading, 5)
            .frame(width:geoWidth, height: geoHeight)
//            .lineLimit(2) // does not work
            .minimumScaleFactor(0.7)
            .focused($isFocused)
            .onSubmit { // only when return button pressed.
                
                todo.content = text

//                let todos = currentDailyRecord.todoList!.filter({$0.idx > todo.idx}).sorted(by: {$0.idx > $1.idx})
//                for todo2 in todos {
//                    todo2.idx += 1
//                }
//                try? modelContext.save()

                let a = todo.idx
                let date = currentDailyRecord.date
                let predicate = #Predicate<Todo> { todo2 in
                    todo2.dailyRecord?.date == date && todo2.idx > a
//                    todo2.idx > 0
                }

                var descriptor = FetchDescriptor(predicate: predicate)
//                var todos = try! modelContext.fetch(descriptor)
                descriptor.sortBy = [SortDescriptor(\.idx)]

                try! modelContext.enumerate(
                    descriptor,
                    batchSize: 5000,
                    allowEscapingMutations: false
                ) { todo2 in
                    todo2.idx += 1
                }
                
                
                modelContext.insert(Todo(dailyRecord:currentDailyRecord, index: todo.idx + 1))
                idx = todo.idx + 1
                //                }
                //                else {
                //                    doneButtonPressed = false
                //                }
            }
            .onChange(of: doneButtonPressed, {
                //                if idx == todo.index {
                todo.content = text
                idx = nil
                //                }
                isFocused = false
                
            })
            .onChange(of: idx) {
                if idx == todo.idx {
                    isFocused = true
                }
                else {
                    isFocused = false
                }
            }
            .onChange(of: isFocused, {
                //                if isFocused && idx != todo.index {
                //                if isFocused && idx == nil {
                //                    idx = todo.index
                //                }
                if isFocused {
                    idx = todo.idx
                }
                
            })
            .onAppear() {
                if idx == todo.idx {
                    isFocused = true
                }
            }
                

            
        }

    }
}

struct PurposeOfDailyQuestView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query var quests: [Quest]
    
    @State var popUp_changePurpose: Bool = false
    var dailyQuest: DailyQuest
    var parentWidth: CGFloat
    var parentHeight: CGFloat
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let tagSize = min(geoWidth*0.8,geoHeight*0.3)

            
//            Group {
                Group {
                    // purpose 0개일 때
                    if dailyQuest.defaultPurposes.count == 0 {
                        Color.white.opacity(0.01)
                            .overlay(
                                Image(systemName:"questionmark.square")
                                    .resizable()
                                    .frame(width:tagSize, height:tagSize)
                                    .foregroundStyle(reversedColorSchemeColor)
                            )
                        // MARK: 이렇게 안 하면 외부의 zIndex가 작동 안 함.
                    }
                    else {
                        PurposeTagsView_vertical(purposes:dailyQuest.defaultPurposes)
                            .frame(width: geoWidth, height:geoHeight)
                    }
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                .onTapGesture {
                    popUp_changePurpose.toggle()
                }
                
                //                                    .popover(isPresented: $popUp_changePurpose) {
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView3(dailyQuest: dailyQuest)
                        .frame(width:parentWidth*0.6, height: parentWidth*0.8) // 12개 3*4 grid
                        .presentationCompactAdaptation(.popover)
                        .onDisappear() {
                            if let quest = quests.first(where:{$0.name == dailyQuest.questName && !$0.inTrashCan}) {
                                quest.recentPurpose = dailyQuest.defaultPurposes
                            } else if let quest = quests.first(where:{$0.name == dailyQuest.questName}){
                                quest.recentPurpose = dailyQuest.defaultPurposes
                            }
                        }
                    
                }
//            }
            
            
        }
    }
}

struct PurposeOfTodoView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query var todos_preset: [Todo_preset]
    
    @State var popUp_changePurpose: Bool = false
    var todo: Todo
    var parentWidth: CGFloat
    var parentHeight: CGFloat
    
    var body: some View {
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let tagSize = min(geoWidth*0.8,geoHeight*0.3)

            
            Group {
                Group {
                    // purpose 0개일 때
                    if todo.purpose.count == 0 {
                        Image(systemName:"questionmark.square")
                            .resizable()
                            .frame(width:tagSize, height:tagSize)
                            .foregroundStyle(reversedColorSchemeColor)
                    }
                    else {
                        PurposeTagsView_vertical(purposes:todo.purpose)
                            .frame(width: geoWidth, height:geoHeight)
                    }
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                .onTapGesture {
                    popUp_changePurpose.toggle()
                }
                
                //                                    .popover(isPresented: $popUp_changePurpose) {
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView4(todo: todo)
                        .frame(width:parentWidth*0.6, height: parentWidth*0.8) // 12개 3*4 grid
                        .presentationCompactAdaptation(.popover)
                        .onDisappear() {
                            if let todo_preset = todos_preset.first(where:{$0.content == todo.content}) {
                                todo_preset.purpose = todo.purpose
                            }
                        }
                    
                }
            }
            
        }
    }
}




struct CountdownView: View {
    
    
    @State private var timeRemaining: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(dueDate: Date) {
        let dueDate_10am: Date = Calendar.current.date(byAdding: .hour, value: 10, to: dueDate)!
        _timeRemaining = State(initialValue: Int(dueDate_10am.timeIntervalSince(Date())))
    }

    var body: some View {
        Text("\(timeString(time: TimeInterval(timeRemaining)))")
            .opacity(0.5)
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }

    }

    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}







//struct TestNotificationView: View {
//    @State private var selectedDate = Date()
//    
//    var body: some View {
//        VStack {
//            DatePicker("Select time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
//                .datePickerStyle(WheelDatePickerStyle())
//                .labelsHidden()
//            
//            Button(action: {
//                scheduleNotification(at: selectedDate)
//            }) {
//                Text("Schedule Notification")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//}
