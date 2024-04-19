


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



// this view controls all the other part of ChecklistView. ChecklistView only visualizes data and provide simpleMenus for each data.
// MainView_checklist와 CheckㅣistView의 역할 분배가 관리하기 쉽게 이루어졌는지 나중에 검토 필요(24.03.07)
// 그냥 합칠까??????????????????????????????????????????????? 
struct MainView_checklist: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    @Query var profiles: [Profile]
    @Query var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
//    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]


    @State var currentDailyRecord: DailyRecord
    
    var currentRecordSet: DailyRecordSet

    @Binding var selectedView: MainViewName
    @Binding var isNewDailyRecordAdded: Bool
    
    @State var todayRecordExists: Bool = false
    @State var yesterdayRecordExists: Bool = false
    
    @State var popUp_addDailyQuest: Bool = false
//    @State var popUp_addDailyQuest_done: Bool = false
    @State var popUp_addDiary: Bool = false
    @State var popUp_saveDailyRecord: Bool = false
    @State var popUp_changePurpose: Bool = false
    
    @State var selectDiaryOption = false
    
    @State var selectedDailyQuest: DailyQuest? = nil
    
    
    @State var editDiary = false
    
    @State var yesterdayRecordDeleted:Bool = false
    
    @State var isAnimating = false
    @State var isAnimating2 = false
    @State var isAnimating3 = false

    @State var saveAsToday = true
    
    @State private var timer: Timer? = nil

    @State var todoActivated: Bool = false

    
    @State var keyboardAppeared = false
    @State var keyboardHeight: CGFloat = 0
    
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
        
        let shadowColor:Color = getShadowColor(colorScheme)

        let middleColor:Color = colorScheme == .light ? Color.black.adjust(brightness: 0.2) : Color.white
        let linearGradient1: LinearGradient =
        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, middleColor, Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing)
        let linearGradient2: LinearGradient =
        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, middleColor, Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
        
        // currentRecord == records.last => 기간이 지났어도 currentRecord임
        GeometryReader { geometry in

            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            

            
            let buttonSize = geoWidth/13
            
            let popUp_addQuest_height = geometry.size.height*(keyboardAppeared ? 0.6 : 0.8)
            let popUp_addQuest_yPos = keyboardAppeared ? 35 + popUp_addQuest_height/2 : geometry.size.height/2
            

            ZStack {
//                VStack {
//                    ZStack{
//
//                        ZStack {
//                            ForEach(0..<2) { i in
//                                linearGradient1
//                                    .frame(width: geoWidth)
//                                    .offset(x: (CGFloat(i) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
//                                    .animation(Animation.linear(duration: 4).repeatForever(autoreverses: false), value: isAnimating)
//                            }
//                        }
//                        .mask(
//                            Text("\(kor_yyyymmddFormatOf(Date()))")
//                                .font(.title3)
//                                .bold()
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.5)
//                        )
//                        .frame(width:geoWidth*0.5, height: geoHeight*0.07)
//                        .onAppear() {
//                            self.isAnimating = true
//                        }
//
//
//                    } // hstack
//                    .frame(width:geoWidth, height: geoHeight*0.07, alignment: .center)
//                    .padding(.vertical, 10)
                    

                    

                    ChecklistView(
                        currentDailyRecord: currentDailyRecord,
                        popUp_addQuest: $popUp_addDailyQuest,
                        popUp_addDiary: $popUp_addDiary,
                        popUp_createRecordStone: $popUp_saveDailyRecord,
                        editDiary: $editDiary,
                        selectDiaryOption: $selectDiaryOption,
                        todoActivated: $todoActivated,
                        keyboardAppeared: $keyboardAppeared,
                        keyboardHeight: $keyboardHeight
                    )

//                }

                Menu {




                    if currentDailyRecord.todoList!.count == 0 {
                        Button("일반 퀘스트", systemImage:"checkmark.circle") {
                            todoActivated = true
                            modelContext.insert(Todo(dailyRecord: currentDailyRecord, index: 0))
                        }
                    }
                    
                    Button("누적 퀘스트",systemImage:"checkmark.square", action:{
                        popUp_addDailyQuest.toggle()
                        selectDiaryOption = false
                    })
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderedProminent)
                    
                    if currentDailyRecord.dailyText == nil {
                        Button("일기",systemImage:"book.closed.fill", action:{
                            selectDiaryOption = true

                        })
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderedProminent)
                        .disabled(currentDailyRecord.dailyTextType != nil)
                    }


                } label: {


                    ZStack {
                            ForEach(0..<2) { i in
                                linearGradient2
                                    .frame(width:geoWidth, height:buttonSize)
                                    .offset(x: (CGFloat(i) - (self.isAnimating2 ? 0.0 : 1.0)) * geoWidth)
                                    .animation(Animation.linear(duration: 6).repeatForever(autoreverses: false), value: isAnimating2)
                                    .onAppear() {
                                        isAnimating2 = true
                                    }
                            }
                        }
                        .mask {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width:buttonSize, height:buttonSize)
//                                .bold()
                        }
                        .frame(width:buttonSize, height:buttonSize)


//                    }
//                    .frame(width:geoWidth/10, height:geoWidth/10)

                }
                .buttonStyle(.plain)
                .frame(width:buttonSize, height:buttonSize)
                .position(x:geoWidth/2, y:geoHeight*0.95 - 10)
            
                

                
                Menu {

                    if todayRecordExists && yesterdayRecordExists {
                        Text("어제/오늘의 기록이 모두 저장되어있습니다.")
                    }
                    else if currentDailyRecord.dailyText == nil && currentDailyRecord.dailyQuestList!.count == 0 && currentDailyRecord.todoList!.count == 0 {
                        Text("저장할 내용이 없습니다.")
                    }
                    else {
                        if !yesterdayRecordExists {
                            Button("어제로 저장") {
                                saveAsToday = false
                                popUp_saveDailyRecord.toggle()
                            }
                        }
                        if !todayRecordExists {
                            Button("오늘로 저장") {
                                saveAsToday = true
                                popUp_saveDailyRecord.toggle()
                            }
                        }
                    }
                    
                    
                } label: {

                    Button("저장",systemImage: "map.fill") {
                    }
                    .labelStyle(.titleAndIcon)
                    
                }
                .buttonStyle(.plain)
                .position(x:geoWidth*0.85, y: geoHeight*0.95 - 10)

                
                
                if popUp_addDailyQuest || popUp_addDiary || popUp_saveDailyRecord {
                    Color.gray.opacity(0.6)
                        .ignoresSafeArea(.all)

                }
                

                if popUp_addDailyQuest {
                    AddDailyQuestView(
                        currentDailyRecord: currentDailyRecord,
                        popUp_addDailyQuest: $popUp_addDailyQuest,
                        selectedView:$selectedView,
                        isDone: saveAsToday ? false : true
                    )
                    .popUpViewLayout(width: geometry.size.width*0.9, height: popUp_addQuest_height, color: colorSchemeColor)
                    .position(x: geometry.size.width/2, y: popUp_addQuest_yPos)
                    
                }

                else if popUp_saveDailyRecord {
                    SaveDailyRecordView(
                        currentDailyRecordSet: currentRecordSet,
                        currentDailyRecord: currentDailyRecord,
                        popUp_createRecordStone: $popUp_saveDailyRecord,
                        saveAsToday: saveAsToday,
                        todayRecordExists: todayRecordExists,
                        isNewDailyRecordAdded: $isNewDailyRecordAdded,
                        selectedView: $selectedView
                    )
                    .popUpViewLayout(width: geometry.size.width*0.9, height: geometry.size.height*0.95, color: colorSchemeColor)
                    .zIndex(2)

                }
            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear {
                
                updateExistency()
                startTimer()
                setKeyboardAppearanceStateValue()
                
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
                currentDailyRecord = dailyRecords.first ?? DailyRecord()
                updateExistency()
                
                for dailyQuest in currentDailyRecord.dailyQuestList! {
                    dailyQuest.currentTier = quests.first(where: {$0.name == dailyQuest.questName})?.tier ?? 0
                }
                
            }
            
 

        }



    }
    
    func updateExistency() -> Void {
        todayRecordExists = dailyRecords.contains(where: {$0.date == getStartDateOfNow()})

        let currentRecordSet_isEmpty: Bool = currentRecordSet.dailyRecords!.isEmpty
        print("currentRecordSet_isEmpty: ", currentRecordSet_isEmpty)
        
        if todayRecordExists && currentRecordSet_isEmpty {
            yesterdayRecordExists = true
        }
        else {
            yesterdayRecordExists = dailyRecords.contains(where: {$0.date == getStartDateOfYesterday()})
        }
    }
    
    func startTimer() {
        let date = Date()
        let calendar = Calendar.current
        let tommorow = getTomorrowOf(date)
        let timeInterval = tommorow.timeIntervalSince(date)

        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            updateExistency()
        }
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
    
    
    

    

}





// + special + dayOff(아무것도 기록하고 싶지 않은 날) -> dates/7 개 주어짐.
// 여기서는 checklist의 data들이 시각화되고, 시각화된 부분을 제스처로 제어하는 부분만 구현(QCBD 수정&삭제, DR.diary 수정&삭제 등등)
struct ChecklistView: View {


    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
//    @Query(sort:\recordOfToday.date) var recordOfTodays: [recordOfToday]
    @Query var profiles: [Profile]
    @Query(sort:\DailyQuest.createdTime) var dailyQuests: [DailyQuest]

//    @Query(sort:\EventCheckBoxData.createdTime) private var eventCheckBoxDatas: [EventCheckBoxData]

    var currentDailyRecord: DailyRecord
    
//    var dailyQuests_forcurrentDailyRecord: [DailyQuest] {
//        dailyQuests.filter({$0.dailyRecord == currentDailyRecord})
//    }
    
    @Binding var popUp_addQuest: Bool
//    @Binding var popUp_addQuest_plan: Bool
//    @Binding var popUp_addQuest_done: Bool
    @Binding var popUp_addDiary: Bool
    @Binding var popUp_createRecordStone: Bool
    
    
    @Binding var editDiary: Bool
    
    @Binding var selectDiaryOption: Bool
    @Binding var todoActivated: Bool
    
    @Binding var keyboardAppeared: Bool
    @Binding var keyboardHeight: CGFloat


    @State var applyDailyQuestRemoval: Bool = false
    @State var applyDailyTextRemoval: Bool = false
//    @State var applyDailyEventRemoval: Bool  = false
    @State var dailyQuestToDelete: DailyQuest?
//    @State var eventCheckBoxDataToDelete: EventCheckBoxData?
    @State var popUp_changePurpose: Bool = false
    @State var selectedDailyQuest: DailyQuest?
    @State var buffer_chosenPurposes: Set<String> = Set()

    @State var editingIndex: Int?
    @State var doneButtonPressed: Bool = false
    
//    @State var todoText: [String] = []
//    @State var todoDone: [Bool] = []
//    @State var todoPurpose: [Set<String>] = []
    
    
    @State var diaryViewWiden: Bool = false
    
    
    


//    @State var dailyQuest_justCreated: DailyQuest? = nil

    var profile:Profile {
        profiles.count != 0 ? profiles[0] : Profile() // MARK: signOutErrorPrevention
    }


    var body: some View {
        
        let shadowColor:Color = getShadowColor(colorScheme)
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in


            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height

            
            let checkListElementWidth = geometry.size.width*0.95
            
            let questCheckBox_purposeTagsWidth = checkListElementWidth*0.1
            let questCheckBoxWidth = checkListElementWidth*0.9
            let questCheckBoxHeight = geometry.size.height*0.07
            
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
                        
                        
                        VStack(alignment: .center) {
                            
                            Spacer()
                                .frame(width:geometry.size.width, height: 20)
                            
                            if selectDiaryOption {
                                ZStack {
                                    HStack(spacing:geoWidth*0.1) {
                                        Button("요약", action:{
                                            editDiary = true // 아래하고 순서 바뀌면 안됨
                                            currentDailyRecord.dailyTextType = DailyTextType.inShort
                                            currentDailyRecord.dailyText = ""
                                            selectDiaryOption = false
                                        })
                                        .buttonStyle(.bordered)
                                        Button("길게", action:{
                                            editDiary = true // 아래하고 순서 바뀌면 안됨
                                            //                            popUp_addDiary.toggle()
                                            currentDailyRecord.dailyTextType = DailyTextType.diary
                                            currentDailyRecord.dailyText = ""
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
                                
                            }
                            else if (currentDailyRecord.dailyTextType == DailyTextType.diary) {
                                
                                DiaryView(
                                    currentDailyRecord: currentDailyRecord,
                                    diaryText: currentDailyRecord.dailyText!,
                                    applyDiaryRemoval: $applyDailyTextRemoval,
                                    isEdit: $editDiary
                                )
                                .frame(width:checkListElementWidth, height: diaryHeight)

                                
                                
                            }
                            else if (currentDailyRecord.dailyTextType == DailyTextType.inShort) {
                                InShortView(
                                    currentDailyRecord: currentDailyRecord,
                                    inShortText: currentDailyRecord.dailyText!,
                                    applyDailyTextRemoval: $applyDailyTextRemoval,
                                    isEdit: $editDiary
                                )
                                .frame(width:checkListElementWidth, height: diaryHeight)
                                //                            .background(.gray.adjust(brightness: 0.4).opacity(0.7))
                                .clipShape(.buttonBorder)
                                
                            }
                            
                            Spacer()
                                .frame(width:checkListElementWidth, height: geoHeight*0.05)
                            
                            
                            if currentDailyRecord.dailyQuestList!.count !=  0 {
                                Text("누적 퀘스트")
                                    .frame(width:checkListElementWidth,alignment: .leading)
                            }
                            ForEach(currentDailyRecord.dailyQuestList!, id: \.self) { dailyQuest in
                                
                                
                                HStack(spacing: 0) {
                                    

                                    
                                    PurposeOfDailyQuestView(dailyQuest: dailyQuest, parentWidth: geoWidth, parentHeight: geoHeight)
                                        .frame(width:questCheckBox_purposeTagsWidth, height: questCheckBoxHeight, alignment: .leading)
                                        .opacity(0.9)
                                    
                                    
                                    
                                    
                                    
                                    if dailyQuest.dataType == DataType.OX {
                                        QuestCheckBoxView_OX(
                                            dailyQuest: dailyQuest,
                                            themeSetName: profile.adjustedThemeSetName,
                                            checkBoxToggle: dailyQuest.data == 1,
                                            applyDailyQuestRemoval: $applyDailyQuestRemoval,
                                            dailyQuestToDelete: $dailyQuestToDelete
                                        )
                                        .frame(width:questCheckBoxWidth, height: questCheckBoxHeight)
                                        .opacity(0.85)
                                        
                                    }
                                    else {
                                        
                                        let data = dailyQuest.data
                                        let xOffset = CGFloat(data).map(from:0.0...CGFloat(dailyQuest.dailyGoal), to: 0...questCheckBoxWidth)
                                        
                                        // 원하는 기능
                                        // 첫 생성 시: popUp view
                                        // 기존 것 고를 시: 그냥 누르면 가장 최근 데이터, 프리셋 데이터 선택 시 프리셋 선택 및 추가/삭제 가능한 창
                                        
                                        
                                        QuestCheckBoxView(
                                            dailyQuest: dailyQuest,
                                            themeSetName: profile.adjustedThemeSetName,
                                            value: data,
                                            xOffset: xOffset,
                                            applyDailyQuestRemoval: $applyDailyQuestRemoval,
                                            dailyQuestToDelete: $dailyQuestToDelete
                                        )
                                        .frame(width:questCheckBoxWidth, height: questCheckBoxHeight)
                                        //                                    .shadow(color:shadowColor, radius: 3)
                                        .opacity(0.85)
                                        
                                    }
                                    
                                }
                                .padding(5)
                            }
                            
                            Spacer()
                                .frame(width:geoWidth, height: geoHeight*0.05)
                            
                            
                            let todoList_sorted = currentDailyRecord.todoList!.sorted(by: {$0.index < $1.index})
                            if todoList_sorted.count != 0 {
                                Text("일반 퀘스트")
                                    .frame(width:checkListElementWidth,alignment: .leading)
                            }
                            ForEach(todoList_sorted, id:\.self) { todo in
                                
                                // view에 반영하는 내용은 stateVariable로 전부 대체 -> 처음 불러올 때 적용, 그리고 tapgesture on checkbox, submission(추가), 완료, x(삭제) 때만 modelContext의 데이터 변경해주기
                                
                                HStack(spacing:0.0) {
                                    ////
//                                    if todo.purpose.count == 0 {
//                                        ////
//                                    }
//                                    PurposeTagsView_vertical(purposes: todo.purpose)
//                                        .frame(width:todo_purposeTagsWidth, height: todo_height)
                                    
                                    PurposeOfTodoView(todo: todo, parentWidth: geoWidth, parentHeight: geoHeight)
                                        .frame(width:todo_purposeTagsWidth, height: todo_height)
                                    
                                    Button(action:{
                                        todo.done.toggle()
                                    }) {
                                        let checkBoxSize = min(todo_checkBoxSize, todo_height)
                                        Image(systemName: todo.done ? "checkmark.circle" : "circle")
                                            .resizable()
                                            .frame(width:checkBoxSize*0.8, height: checkBoxSize*0.8)
                                    }
                                    .frame(width: todo_checkBoxSize, alignment: .leading)
                                    
                                    
                                    textFieldView(currentDailyRecord: currentDailyRecord, todo: todo, text: todo.content, idx: $editingIndex, doneButtonPressed: $doneButtonPressed)
                                        .frame(width:editingIndex == todo.index ? todo_textWidth*0.8 : todo_textWidth)
                                    if editingIndex == todo.index {
                                        Button("완료") {
                                            doneButtonPressed.toggle()
                                        }
                                        .frame(width:todo_textWidth*0.2)
                                    }
                                    
                                    if editingIndex == nil {
                                        Button(action:{
                                            let targetIndex = todo.index
                                            
                                            modelContext.delete(todo)
                                            
                                            if editingIndex != nil && targetIndex < (editingIndex ?? -1) {
                                                editingIndex! -= 1
                                            }
                                            else if editingIndex == targetIndex {
                                                editingIndex = nil
                                            }
                                            
                                            for todo2 in currentDailyRecord.todoList! {
                                                if todo2.index > targetIndex {
                                                    todo2.index -= 1
                                                }
                                            }
                                        }) {
                                            let xmarkSize = min(todo_xmarkSize, todo_height)
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .frame(width:xmarkSize*0.5, height: xmarkSize*0.5)
                                        }
                                        .frame(width: todo_xmarkSize, alignment: .trailing)
                                    }
                                    
                                    
                                    
                                }
                                .frame(width: checkListElementWidth, height:todo_height)
                                .padding(.vertical,5.0)
                                .id(todo.index)

                            }
                            
                            
                            
                            Spacer()
                                .frame(width: geometry.size.width, height: keyboardAppeared ? keyboardHeight*1.1 : geometry.size.height*0.2)
                            
                            
                        } // VStack
                        .onChange(of: editingIndex) {
                            if editingIndex != nil {
                                withAnimation {
                                    scrollProxy.scrollTo(editingIndex,anchor: .center)
                                }
                            }
                        }
                        
                    } // scroll view
                    .frame(width:geometry.size.width, height: geometry.size.height)
                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
                    .scrollDisabled(editDiary)
                    
                }
//                }
                if currentDailyRecord.dailyQuestList!.isEmpty && currentDailyRecord.dailyTextType == nil && currentDailyRecord.todoList?.count == 0 && !selectDiaryOption {
                    VStack {
                        let ratios = [1.0, 0.7, 0.5, 0.3, 0.1]
                        ForEach(ratios, id:\.self) { ratio in
                            VStack(spacing:0.0) {
                                ZStack(alignment: .leading) {
                                    Color.red.opacity(0.0)
                                    Image(systemName:"questionmark.square")
                                        .resizable()
                                        .frame(width:purposeTagsHeight*0.7, height:purposeTagsHeight*0.7)
                                        .foregroundStyle(reversedColorSchemeColor)
                                }
                                .frame(width:checkListElementWidth,height: purposeTagsHeight)

                                EmptyQuestCheckBoxView(ratio:ratio)
                                    .frame(width:checkListElementWidth, height: questCheckBoxHeight)
                            }
                            .opacity(0.1)
                            .padding(5)
                        }
                    }
                    .frame(width: geoWidth, height: geoHeight, alignment: .top)
                    Text("체크리스트에 내용을 추가하세요!")
                        .opacity(0.5)
                    
                }



            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onChange(of: applyDailyQuestRemoval, removeDailyQuest)
            .onChange(of: applyDailyTextRemoval, removeDailyText)
            .onChange(of: currentDailyRecord, {
                editDiary = false
                diaryViewWiden = false
                
            })
            

            
            
            


        }



    }
    
    





    func removeDailyQuest() -> Void {
        
        modelContext.delete(dailyQuestToDelete!)
        dailyQuestToDelete = nil

        // dailyGoal에서 제외
    }
    
    func removeDailyText() -> Void {
        currentDailyRecord.dailyText = nil
        currentDailyRecord.dailyTextType = nil
        currentDailyRecord.diaryImage = nil
        editDiary = false
        diaryViewWiden = false
    }
    
    



}

struct textFieldView: View {
    
    @Environment(\.modelContext) var modelContext
    
    var currentDailyRecord: DailyRecord
    var todo: Todo
    @State var text: String
    
    @Binding var idx: Int?
    @Binding var doneButtonPressed: Bool
    @FocusState var isFocused: Bool

    // MARK: 오류발생 -> 실제로 일어날 확률이 적지만, 엄청빠른 속도로 todo를 생성 시 focus된 textfield가 여러개
    var body: some View {
        
        let todos = currentDailyRecord.todoList!.sorted(by: {$0.index < $1.index})
        
        TextField("할 일을 입력하세요",text: $text, axis:.horizontal)
            .focused($isFocused)
            .onSubmit { // only when return button pressed.
                todo.content = text
                

                    for todo2 in todos {
                        if todo2.index > todo.index {
                            todo2.index += 1
                        }
                    }
                    modelContext.insert(Todo(dailyRecord:currentDailyRecord, index: todo.index + 1))
                    idx = todo.index + 1
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
                if idx == todo.index {
                    isFocused = true
                }
                else {
                    isFocused = false
                }
            }
            .onChange(of: isFocused, {
//                if isFocused && idx != todo.index {
                if isFocused && idx == nil {

                    idx = todo.index
                }
            })
            .onAppear() {
                if idx == todo.index {
                    isFocused = true
                }
            }

        

    }
}

struct PurposeOfDailyQuestView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var popUp_changePurpose: Bool = false
    var dailyQuest: DailyQuest
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
                    if dailyQuest.defaultPurposes.count == 0 {
                        Image(systemName:"questionmark.square")
                            .resizable()
                            .frame(width:tagSize, height:tagSize)
                            .foregroundStyle(reversedColorSchemeColor)
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
                    
                }
            }
            
            
        }
    }
}

struct PurposeOfTodoView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

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
                    
                }
            }
            
        }
    }
}


//struct PurposeOfDailyQuestView: View {
//    
//    @Environment(\.modelContext) var modelContext
//    @Environment(\.colorScheme) var colorScheme
//
//    @State var popUp_changePurpose: Bool = false
//    var dailyQuest: DailyQuest
//    
//    var body: some View {
////        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
//        
//        GeometryReader { geometry in
//            let geoWidth: CGFloat = geometry.size.width
//            let geoHeight: CGFloat = geometry.size.height
//            
//            Group {
//                Group {
//                    // purpose 0개일 때는?
//                    if dailyQuest.defaultPurposes.count == 0 {
//                        Image(systemName:"questionmark.square")
//                            .resizable()
//                            .frame(width:geoHeight*0.7, height:geoHeight*0.7)
//                            .foregroundStyle(reversedColorSchemeColor)
//                    }
//                    else {
//                        PurposeTagsView_leading(purposes:dailyQuest.defaultPurposes)
//                            .frame(width: geoWidth*0.2, height:geoHeight)
//                    }
//                    
//                }
//                .onTapGesture {
//                    popUp_changePurpose.toggle()
//                }
//                //                                    .popover(isPresented: $popUp_changePurpose) {
//                .popover(isPresented: $popUp_changePurpose) {
//                    ChoosePurposeView2(dailyQuest: dailyQuest)
//                        .padding(.leading,3)
//                        .frame(width:geoWidth*0.65)
//                        .presentationCompactAdaptation(.popover)
//                    
//                }
//            }
//        }
//    }
//}



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






//
//struct ChecklistSelectionButtonStyle: ButtonStyle {
//    
//    var width: CGFloat
//    var height: CGFloat
//    @Binding var isSelected: Bool
//    
//    init(width: CGFloat, height: CGFloat, isSelected: Binding<Bool>) {
//        self.width = width
//        self.height = height
//        self._isSelected = isSelected
//    }
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding(.vertical, height/10)
//            .padding(.horizontal, width/10)
//            .frame(width: width, height: height)
//            .background(isSelected ? Color.black : Color.gray.adjust(brightness: 0.3))
//            .cornerRadius(8)
//            .foregroundStyle(.white)
//            
//
//    }
//}
