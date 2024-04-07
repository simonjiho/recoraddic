


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

// 펜타닐 은어: ‘아파치(apache)’ ‘차이나 화이트(china white)’ ‘롤리팝(lollipop)’ ‘그레 이트 베어(great bear)’ ‘블루 돌핀(blue dolphin)’


// CheckList 떠 있는데, 다음날 12시가 넘어가면 다음날 것으로 나타남.
 

// this view controls all the other part of ChecklistView. ChecklistView only visualizes data and provide simpleMenus for each data.
// MainView_checklist와 CheckㅣistView의 역할 분배가 관리하기 쉽게 이루어졌는지 나중에 검토 필요(24.03.07)
// 그냥 합칠까??????????????????????????????????????????????? 
struct MainView_checklist: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query var profiles: [Profile]
    @Query var quests: [Quest]
//    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]

    @State var recordOfToday: DailyRecord
    
    @State var recordOfYesterday: DailyRecord? // nil when no remainedData or dailyrecords.count < 2
    
    var currentRecordSet: DailyRecordSet

    @Binding var selectedView: MainViewName
    @Binding var isNewDailyRecordAdded: Bool
    
    
    @State var popUp_addDailyQuest: Bool = false
//    @State var popUp_addDailyQuest_done: Bool = false
    @State var popUp_addDiary: Bool = false
    @State var popUp_saveDailyRecord: Bool = false
    @State var popUp_changePurpose: Bool = false
    
    @State var selectDiaryOption = false

    
    @State var selectedDailyQuest: DailyQuest? = nil
    
    
    @State var isTodayRelated: Bool = true // isTodayRelated controls the selectedDailyRecord, delclared inside the viewBuilder
    @State var yesterdayDataRemains: Bool // initialized by recordOfYesterday is nil, need to change in 수동
    
    @State var keyboardAppeared = false
    
    @State var editDiary = false
    
    @State var yesterdayRecordDeleted:Bool = false
    
    @State var isAnimating = false
    @State var isAnimating2 = false
    @State var isAnimating3 = false

    
    
//    init(recordOfToday: DailyRecord, recordOfYesterday: DailyRecord?, currentRecordSet: DailyRecordSet, popUp_addQuest_plan: Binding<Bool>, popUp_addQuest_done: Binding<Bool>, popUp_addDiary: Binding<Bool>, popUp_createRecordStone: Binding<Bool>, selectedView: Binding<MainViewName>)
    init(recordOfToday: DailyRecord, recordOfYesterday: DailyRecord?, currentRecordSet: DailyRecordSet, selectedView: Binding<MainViewName>, isNewDailyRecordAdded: Binding<Bool>)
    {
        self._recordOfToday = State(initialValue: recordOfToday)
        self._recordOfYesterday = State(initialValue: recordOfYesterday)
        self.currentRecordSet = currentRecordSet
//        let today = recordOfToday.date
        
//        let predicate = #Predicate<DailyQuest> { dailyQuest in
//            dailyQuest.dailyRecord?.date == today
//        }
        
        _profiles = Query()
        
//        self._popUp_addQuest_plan = popUp_addQuest_plan
//        self._popUp_addQuest_done = popUp_addQuest_done
//        self._popUp_addDiary = popUp_addDiary
//        self._popUp_saveDailyRecord = popUp_createRecordStone
        self._selectedView = selectedView
        self._isNewDailyRecordAdded = isNewDailyRecordAdded
//
        
        self._yesterdayDataRemains = State(initialValue: recordOfYesterday != nil)
        
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
            
            let selectedDailyRecord:DailyRecord = (isTodayRelated ? recordOfToday : recordOfYesterday)!
            
            
            
            let popUp_addQuest_height = geometry.size.height*(keyboardAppeared ? 0.6 : 0.8)
            let popUp_addQuest_yPos = keyboardAppeared ? 35 + popUp_addQuest_height/2 : geometry.size.height/2
            

            ZStack {
                VStack {
                    ZStack{

                        


                        ZStack {
                            ForEach(0..<2) { i in
                                linearGradient1
                                    .frame(width: geoWidth)
                                    .offset(x: (CGFloat(i) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                                    .animation(Animation.linear(duration: 4).repeatForever(autoreverses: false), value: isAnimating)
                            }
                        }
                        .mask(
                            Text("\(kor_yyyymmddFormatOf(selectedDailyRecord.date))")
                                .font(.title3)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        )
                        .frame(width:geoWidth*0.5, height: geoHeight*0.07)
                        .onAppear() {
                            self.isAnimating = true
                        }
//                            .border(.red)

                        
                        Button("어제", systemImage:"chevron.left", action:{isTodayRelated = false})
                            .disabled(!(yesterdayDataRemains && isTodayRelated))
                            .opacity((yesterdayDataRemains && isTodayRelated) ? 1.0 : 0.0)
                            .labelStyle(.titleAndIcon)
                            .frame(width: geometry.size.width*0.93, alignment: .leading)
                            .foregroundStyle(reversedColorSchemeColor)
                        
                        Button("오늘", systemImage:"chevron.right", action:{isTodayRelated = true})
                            .disabled(isTodayRelated)
                            .opacity(!isTodayRelated ? 1.0 : 0.0)
                            .labelStyle(.titleAndIcon)
                            .frame(width: geometry.size.width*0.93, alignment: .trailing)
                            .foregroundStyle(reversedColorSchemeColor)

                    } // hstack
                    .frame(width:geoWidth, height: geoHeight*0.07, alignment: .center)
                    .padding(.vertical, 10)
                    

                    

                    ChecklistView(
                        selectedDailyRecord: selectedDailyRecord,
                        popUp_addQuest: $popUp_addDailyQuest,
//                        popUp_addQuest_plan: $popUp_addDailyQuest_plan,
//                        popUp_addQuest_done: $popUp_addDailyQuest_done,
                        popUp_addDiary: $popUp_addDiary,
                        popUp_createRecordStone: $popUp_saveDailyRecord,
//                        popUp_changePurpose: $popUp_changePurpose,
                        isTodayRelated: $isTodayRelated,
                        yesterdayDataRemains: $yesterdayDataRemains,
                        editDiary: $editDiary,
                        yesterdayRecordDeleted: $yesterdayRecordDeleted,
                        selectDiaryOption: $selectDiaryOption
                    )

                }

                Menu {
                    HStack {
                        Button("일일 퀘스트",systemImage:"checkmark.square", action:{
                            popUp_addDailyQuest.toggle()
                        })
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderedProminent)

//                        Button("달성",systemImage:"checkmark.square", action:{
//                            popUp_addDailyQuest_done.toggle()
//                        })
//                        .labelStyle(.iconOnly)
//                        .buttonStyle(.borderedProminent)
//                        Button("하루요약",systemImage:"book.closed.fill", action:{
//                            editDiary = true // 아래하고 순서 바뀌면 안됨
//                            selectedDailyRecord.dailyTextType = DailyTextType.inShort
//                            selectedDailyRecord.dailyText = ""
//                            
//                            
//                        })
//                        .labelStyle(.iconOnly)
//                        .buttonStyle(.borderedProminent)
//                        .disabled(selectedDailyRecord.dailyTextType != nil)
//                        Button("일기",systemImage:"book.closed.fill", action:{
//                            editDiary = true // 아래하고 순서 바뀌면 안됨
////                            popUp_addDiary.toggle()
//                            selectedDailyRecord.dailyTextType = DailyTextType.diary
//                            selectedDailyRecord.dailyText = ""
//                            
//
//                        })
//                        .labelStyle(.iconOnly)
//                        .buttonStyle(.borderedProminent)
//                        .disabled(selectedDailyRecord.dailyTextType != nil)
                        Button("일기",systemImage:"book.closed.fill", action:{
                            selectDiaryOption = true

                        })
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedDailyRecord.dailyTextType != nil)

                    }
                } label: {

//                    ZStack {
                    ZStack {
                            ForEach(0..<2) { i in
                                linearGradient2
                                    .frame(width:geoWidth, height:geoWidth/10)
                                    .offset(x: (CGFloat(i) - (self.isAnimating2 ? 0.0 : 1.0)) * geoWidth)
                                    .animation(Animation.linear(duration: 6).repeatForever(autoreverses: false), value: isAnimating2)
                                    .onAppear() {
                                        isAnimating2 = true
                                    }
                            }
                        }
                        .mask {
//                            Text("asdfasdfasdfasdf")
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width:geoWidth/10, height:geoWidth/10)
//                                .bold()
                        }
                        .frame(width:geoWidth/10, height:geoWidth/10)


//                    }
//                    .frame(width:geoWidth/10, height:geoWidth/10)

                }
                .buttonStyle(.plain)
                .frame(width:geoWidth/10, height:geoWidth/10)
                .position(x:geoWidth/2, y:geoHeight*0.95 - 10)
            
                
                
                Menu {

                    Button(action:{popUp_saveDailyRecord.toggle()}) {
                        Text(isTodayRelated&&yesterdayDataRemains ? "전날의 기록부터 저장하세요!" :"저장")
                    }
                    .disabled( isTodayRelated && ( selectedDailyRecord.date != getDateOfNow() || yesterdayDataRemains ) )
                    if (yesterdayDataRemains && !isTodayRelated) {
                        Button("넘어가기") {
                            isTodayRelated.toggle()
                            yesterdayRecordDeleted.toggle()
                        }
                    }
                    
                } label: {
                    Image(systemName: "arrowshape.forward.fill")
                        .resizable()
                        .frame(width:geoWidth/10, height:geoWidth/10)

//                    ZStack {
//                        ForEach(0..<2) { i in
//                            linearGradient2
//                                .frame(width:geoWidth, height:geoWidth/10)
//                                .offset(x: (CGFloat(i) - (self.isAnimating3 ? 0.0 : 1.0)) * geoWidth)
//                                .animation(Animation.linear(duration: 12).repeatForever(autoreverses: false), value: isAnimating3)
//                                .onAppear() {
//                                    isAnimating3 = true
//                                }
//                        }
//                    }
//                    .frame(width:geoWidth/10, height:geoWidth/10)
//                    .mask(
//                        ZStack {
//                            Rectangle()
//                                .foregroundStyle(.foreground)
//                                .clipShape(.buttonBorder)
//                            Text("저장")
//                                .bold()
//                        }
//                        .frame(width:geoWidth/10, height:geoWidth/10)
//
////                        Image(systemName: "arrowshape.forward.fill")
////                            .resizable()
////                            .frame(width:geoWidth/10, height:geoWidth/10)
//                    )
                }
                .buttonStyle(.plain)
                .position(x:geoWidth*0.9, y: geoHeight*0.95 - 10)

                
                
                if popUp_addDailyQuest || popUp_addDiary || popUp_saveDailyRecord {
                    Color.gray.opacity(0.6)
                        .ignoresSafeArea(.all)

                }
                

                if popUp_addDailyQuest {
                    AddDailyQuestView(
                        recordOfToday: selectedDailyRecord,
                        popUp_addDailyQuest: $popUp_addDailyQuest,
                        selectedView:$selectedView,
                        isDone: isTodayRelated ? false : true
                    )
                    .popUpViewLayout(width: geometry.size.width*0.9, height: popUp_addQuest_height, color: colorSchemeColor)
                    .position(x: geometry.size.width/2, y: popUp_addQuest_yPos)
                    
                }
                
//                if popUp_addDailyQuest_done {
//                    AddDailyQuestView(
//                        recordOfToday: selectedDailyRecord,
//                        popUp_addDailyQuest: $popUp_addDailyQuest_done,
//                        isPlan: false
//                    )
//                    .popUpViewLayout(width: geometry.size.width*0.9, height: popUp_addQuest_height, color: colorSchemeColor)
//                    .position(x: geometry.size.width/2, y: popUp_addQuest_yPos)
//
//
//                }
                
                
//                else if popUp_addDiary {
//                    AddDiaryView(
//                        selectedDailyRecord: selectedDailyRecord,
//                        diaryText: selectedDailyRecord.dailyText == nil ? "" : selectedDailyRecord.dailyText!,
//                        popUp_addDiary: $popUp_addDiary,
//                        selectedImageData: selectedDailyRecord.diaryImage
//                    )
//                    .popUpViewLayout(width: geometry.size.width*0.95, height: geometry.size.height*0.95, color: colorSchemeColor)
//
//
////                        .ignoresSafeArea(.keyboard, edges:[])
//
//                }
                else if popUp_saveDailyRecord {
                    SaveDailyRecordView(
                        currentDailyRecordSet: currentRecordSet,
                        selectedDailyRecord: selectedDailyRecord,
                        popUp_createRecordStone: $popUp_saveDailyRecord,
                        isTodayRelated: $isTodayRelated,
                        yesterdayDataRemains: $yesterdayDataRemains,
                        selectedView: $selectedView,
                        isNewDailyRecordAdded: $isNewDailyRecordAdded
                    )
                    .popUpViewLayout(width: geometry.size.width*0.9, height: geometry.size.height*0.95, color: colorSchemeColor)
                    .zIndex(2)

                }
            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear {
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    //                    let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    //                    let height = value.height
                    withAnimation {
                        keyboardAppeared = true
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation {
                        keyboardAppeared = false
                    }
                }
                
                updateTargetDailyRecord()
                
                
                

            }
            .onChange(of: yesterdayRecordDeleted) {
                let deletedRecord: DailyRecord = recordOfYesterday!
                recordOfYesterday = nil
                modelContext.delete(deletedRecord)
                yesterdayDataRemains = false
            }


        }



    }
    
    // MARK: 여러 기기에서 접속 시 다음날 기록이 여러번 추가될 수 있음. -> 스스로 삭제 가능하게끔 하여 해결
    // TODO: 추가적으로, View가 appear 안되면 계속 전날과 그저께 것으로 남아있는 문제도 해결해야함. -> update()를 ContentView로 옮기고 각종 유지해야할 statedata도 contentView로 이동
    func updateTargetDailyRecord() -> Void {
        // MARK: (24.02.17 해결) 시작할 때는 잘 작동하는데(exampleData에 expired 된 데이터 넣으면 그저께꺼 지우고 오늘->어제거 로 잘 옮김), 나중에 앱이 실행 중에는 그저께 것이 안지워졌다가, 다른 View로 넘어갔다가 오면 전날과 그저께 것이 동시에 사라지는 현상 발생(그저께 것만 사라져야하는데)
        // 위의 문제가 발생한 이유: recordOf today만 있는 상황에서 이틀이상 안들어갔다가 들어가서 view를 다시 로드하면 recordOfToday만 있지만 recordOfYesterday는 없는 상태이다. recordOfToday는 recordOfYesterday로 넘어가지만 이미 없는 상태이다.
        
        print("updateData")
        // 전날 것을 저장 안 했을 때

        let daysPassed: Int = calculateDaysBetweenTwoDates(from:getDateOfNow(),to:getStartOfDate(date:recordOfToday.date))
        print(daysPassed)
        if daysPassed == -1 {
            print("record of today is expired")
            let recordOfTwoDaysAgo_afterUpdate:DailyRecord? = recordOfYesterday
            let recordOfYesterDay_afterUpdate:DailyRecord = recordOfToday
            let recordOfToday_afterUpdate:DailyRecord = DailyRecord(date:getDateOfNow())
            
            modelContext.insert(recordOfToday_afterUpdate)
            
            recordOfYesterday = recordOfYesterDay_afterUpdate
            recordOfToday = recordOfToday_afterUpdate

            if recordOfTwoDaysAgo_afterUpdate != nil { // previous yesterday data that didn't save
                modelContext.delete(recordOfTwoDaysAgo_afterUpdate!) // 같이 있는 dailyQuest도 사라짐 (.cascade)
            }
            yesterdayDataRemains = true

        }
        else if daysPassed < -1 {
            let expiredRecord1_afterUpdate:DailyRecord? = recordOfYesterday
            let expiredRecord2_afterUpdate:DailyRecord = recordOfToday
            let recordOfYesterDay_afterUpdate:DailyRecord = DailyRecord(date:getDateOfYesterDay())
            let recordOfToday_afterUpdate:DailyRecord = DailyRecord(date:getDateOfNow())
            
            modelContext.insert(recordOfToday_afterUpdate)
            
            recordOfYesterday = recordOfYesterDay_afterUpdate
            recordOfToday = recordOfToday_afterUpdate

            
            if expiredRecord1_afterUpdate != nil { // previous yesterday data that didn't save
                modelContext.delete(expiredRecord1_afterUpdate!) // 같이 있는 dailyQuest도 사라짐 (.cascade)
            }
            modelContext.delete(expiredRecord2_afterUpdate) // 같이 있는 dailyQuest도 사라짐 (.cascade)

            yesterdayDataRemains = true
            
        }
        else if recordOfYesterday != nil {
            if recordOfYesterday!.date != getDateOfYesterDay() { // when the recordOfYesterday that has already passed the data remains in somehow unknown reason, delete it.
                print("record of yesterday's date is not the date of ")
                let recordOfYesterday_deprecated: DailyRecord = recordOfYesterday!
                recordOfYesterday = nil
                modelContext.delete(recordOfYesterday_deprecated)
                yesterdayDataRemains = false
            }
        }
        
        
        if daysPassed <= -1 {
            for quest in quests {
                quest.updateTier()
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

    var selectedDailyRecord: DailyRecord
    
    var dailyQuests_forSelectedDailyRecord: [DailyQuest] {
        dailyQuests.filter({$0.dailyRecord == selectedDailyRecord})
    }
    
    @Binding var popUp_addQuest: Bool
//    @Binding var popUp_addQuest_plan: Bool
//    @Binding var popUp_addQuest_done: Bool
    @Binding var popUp_addDiary: Bool
    @Binding var popUp_createRecordStone: Bool
    
    @Binding var isTodayRelated: Bool
    @Binding var yesterdayDataRemains: Bool
    
    @Binding var editDiary: Bool
    @Binding var yesterdayRecordDeleted: Bool
    
    @Binding var selectDiaryOption: Bool

    @State var applyDailyQuestRemoval: Bool = false
    @State var applyDailyTextRemoval: Bool = false
//    @State var applyDailyEventRemoval: Bool  = false
    @State var dailyQuestToDelete: DailyQuest?
//    @State var eventCheckBoxDataToDelete: EventCheckBoxData?
    @State var popUp_changePurpose: Bool = false
    @State var selectedDailyQuest: DailyQuest?
    @State var buffer_chosenPurposes: Set<String> = Set()

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
            
            let questCheckBoxHeight = geometry.size.height*0.08
            let purposeTagsMaxLength = geometry.size.width*0.2
            let purposeTagsHeight = geometry.size.height*0.04
            
//            let diaryHeight = diaryViewWiden ? geometry.size.height * (editDiary ? 0.6 : 0.9) : 60
            let diaryHeight = (selectedDailyRecord.dailyTextType == DailyTextType.diary && editDiary) ? geometry.size.height * 0.6 : questCheckBoxHeight


            ZStack {
                ScrollView {
                    
                    
                    VStack(alignment: .center) {
                        
                        Spacer()
                            .frame(width:geometry.size.width, height: 20)
                        
                        if selectDiaryOption {
                            HStack(spacing:geoWidth*0.1) {
                                Button("한줄요약", action:{
                                    editDiary = true // 아래하고 순서 바뀌면 안됨
                                    selectedDailyRecord.dailyTextType = DailyTextType.inShort
                                    selectedDailyRecord.dailyText = ""
                                    selectDiaryOption = false
                                })
                                .buttonStyle(.bordered)
                                Button("길게", action:{
                                    editDiary = true // 아래하고 순서 바뀌면 안됨
                                    //                            popUp_addDiary.toggle()
                                    selectedDailyRecord.dailyTextType = DailyTextType.diary
                                    selectedDailyRecord.dailyText = ""
                                    selectDiaryOption = false
                                    
                                })
                                .buttonStyle(.bordered)
                            }

                        }
                        else if (selectedDailyRecord.dailyTextType == DailyTextType.diary) {

                            DiaryView(
                                selectedDailyRecord: selectedDailyRecord,
                                diaryText: selectedDailyRecord.dailyText!,
                                applyDiaryRemoval: $applyDailyTextRemoval,
                                isEdit: $editDiary
                            )
                            .frame(width:checkListElementWidth, height: diaryHeight)
                            .frame(width:checkListElementWidth)
                            .background(.background)
                            .clipShape(.containerRelative)
                            .border(.gray)
                            .shadow(color:shadowColor.opacity(0.5), radius: 2)

                            
                        }
                        else if (selectedDailyRecord.dailyTextType == DailyTextType.inShort) {
                            InShortView(
                                selectedDailyRecord: selectedDailyRecord,
                                inShortText: selectedDailyRecord.dailyText!,
                                applyDailyTextRemoval: $applyDailyTextRemoval,
                                isEdit: $editDiary
                            )
                            .frame(width:checkListElementWidth, height: diaryHeight)
                            .background(.background)
                            .clipShape(.buttonBorder)
                            .shadow(color:shadowColor, radius: 3)

                        }


                        
                        ForEach(dailyQuests_forSelectedDailyRecord, id: \.self) { dailyQuest in
                            
                            
                            VStack(spacing: 0) {
                                
                                PurposeOfDailyQuestView(dailyQuest: dailyQuest)
                                    .frame(width:checkListElementWidth, height: purposeTagsHeight, alignment: .leading)
//                                .border(.red)

//                                .sheet(isPresented: $popUp_changePurpose) {
//                                    Text("example")
//                                        .presentationDetents([.height(150)])
//                                        .presentationCompactAdaptation(.none)
//                                }
                
//                                .popover(isPresented: $popUp_changePurpose) {

                                
                                
                                
                                
                                if dailyQuest.dataType == DataType.OX {
                                    QuestCheckBoxView_OX(
                                        dailyQuest: dailyQuest,
                                        themeSetName: profile.adjustedThemeSetName,
                                        checkBoxToggle: dailyQuest.data == 1,
                                        applyDailyQuestRemoval: $applyDailyQuestRemoval,
                                        dailyQuestToDelete: $dailyQuestToDelete
                                    )
                                        .frame(width:checkListElementWidth, height: questCheckBoxHeight)
                                        .shadow(color:shadowColor, radius: 3)
                                }
                                else {
                                    
                                    let data = dailyQuest.data
                                    let xOffset = CGFloat(data).map(from:0.0...CGFloat(dailyQuest.dailyGoal), to: 0...checkListElementWidth)

                                    // 원하는 기능
                                    // 첫 생성 시: popUp view
                                    // 기존 것 고를 시: 그냥 누르면 가장 최근 데이터, 프리셋 데이터 선택 시 프리셋 선택 및 추가/삭제 가능한 창
                                
                                    
                                    QuestCheckBoxView(
                                        dailyQuest: dailyQuest,
                                        themeSetName: profile.adjustedThemeSetName,
                                        value: data,
                                        width: checkListElementWidth,
                                        xOffset: xOffset,
                                        applyDailyQuestRemoval: $applyDailyQuestRemoval,
                                        dailyQuestToDelete: $dailyQuestToDelete
                                    )                          
                                    .frame(width:checkListElementWidth, height: questCheckBoxHeight)
                                    .shadow(color:shadowColor, radius: 3)
                                }
                                
                            }
                            .padding(5)



                        }

                    

//                        if isTodayRelated && yesterdayDataRemains {
//                            Text("전날의 기록부터 저장하세요!")
//                                .padding(.top, 20)
//                        }
                        if !editDiary {
                            if isTodayRelated && selectedDailyRecord.date != getDateOfNow() {
                                Text("오전10시부터 저장할 수 있습니다!")
                                    .foregroundStyle(.opacity(0.5))
                                    .padding(.top, 20)
                                
                            }
                            else if !isTodayRelated {
                                VStack {
                                    HStack {
                                        Text("기록소멸까지")
                                        CountdownView(dueDate: Calendar.current.date(byAdding:.day, value:2, to: selectedDailyRecord.date)!)
                                    }
                                    .padding(.top, 20)
                                }
                                .foregroundStyle(.opacity(0.5))
                                Text("빨리 저장하세요!")
                                    .foregroundStyle(.opacity(0.5))
                            }
                        }
                        Spacer()
                            .frame(width: geometry.size.width, height: geometry.size.height*0.2)


                    } // VStack

                } // scroll view
                .frame(width:geometry.size.width, height: geometry.size.height)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    print(selectedDailyRecord.dailyQuestList!.map({$0.data}))
                }
                .scrollDisabled(editDiary)
//                .scrollDisabled(diaryViewWiden) // does not work on debug mode, how about in non debug mode?

                
//                if popUp_changePurpose {
//                    ChoosePurposeView(chosenPurposes:$buffer_chosenPurposes, viewToggler:$popUp_changePurpose)
//                        .onDisappear() {
//                            selectedDailyQuest?.defaultPurposes = buffer_chosenPurposes
//                            selectedDailyQuest = nil
//                            buffer_chosenPurposes = Set()
//                        }
////                        .frame(width:geoWidth*0.8, height:geoHeight*0.8)
//                        .popUpViewLayout(width: geometry.size.width*0.9, height: geometry.size.height*0.9, color: colorSchemeColor)
//
////                        .backButton(viewToggler: $popUp_changePurpose)
//                }
                if selectedDailyRecord.dailyQuestList!.isEmpty && selectedDailyRecord.dailyTextType == nil {
                    Text("체크리스트에 내용을 추가하세요!")
                        .opacity(0.5)
                }



            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onChange(of: applyDailyQuestRemoval, removeDailyQuest)
            .onChange(of: applyDailyTextRemoval, removeDailyText)
            .onChange(of: selectedDailyRecord, {
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
        selectedDailyRecord.dailyText = nil
        selectedDailyRecord.dailyTextType = nil
        selectedDailyRecord.diaryImage = nil
        editDiary = false
        diaryViewWiden = false
    }
    
    



}


struct PurposeOfDailyQuestView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var popUp_changePurpose: Bool = false
    var dailyQuest: DailyQuest
    
    var body: some View {
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            Group {
                Group {
                    // purpose 0개일 때는?
                    if dailyQuest.defaultPurposes.count == 0 {
                        Image(systemName:"questionmark.square")
                            .resizable()
                            .frame(width:geoHeight*0.7, height:geoHeight*0.7)
                            .foregroundStyle(reversedColorSchemeColor)
                    }
                    else {
                        PurposeTagsView_leading(purposes:dailyQuest.defaultPurposes)
                            .frame(width: geoWidth*0.2, height:geoHeight)
                    }
                    
                }
                .onTapGesture {
                    popUp_changePurpose.toggle()
                }
                //                                    .popover(isPresented: $popUp_changePurpose) {
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView2(dailyQuest: dailyQuest)
                        .padding(.leading,3)
                        .frame(width:geoWidth*0.65)
                        .presentationCompactAdaptation(.popover)
                    
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
