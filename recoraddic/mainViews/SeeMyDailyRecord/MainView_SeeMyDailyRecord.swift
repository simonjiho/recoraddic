//
//  shelf.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/28.
//

// TODO: .swipeActions 이용해서 넘겨서 볼 수 있게 만들기
// TODO: 메뉴 공중에 떠 있게 만들기

import Foundation
import SwiftUI
import SwiftData

// 기본: 책장 / 미술관 / 일기장..?
// 얘도 다양한 형태로 저장소 스킨 바꿀 수 있음 (정말 다양하게!)

// 삭제/숨기기 되면 -> 삭제/숨기기

// TODO: 계산 중에는 selectedDR, selectedDRS 의 변경 막기

// TODO: 공통 부분 다 여기로 불러오기, 미리 설정해야 그래픽 크기는 staticfunc로 만들어서 여기서 설정해서 넣어주기
struct MainView_SeeMyDailyRecord: View { //MARK: selectedDailyRecordSet은 selectedDrsIdx로 컨트롤한다. selectedDailyRecordSet은 직접 건드리지 않는다.
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    @Query var quests: [Quest]

    
    
    @State var selectedDrsIdx: Int // it does not automatically changes selectedDailyRecordSet. you need to toggle updateSelectedDailyRecordSet to update selectedDailyRecordSet
    @State var selectedDailyRecordSet: DailyRecordSet
    
    
//    var navigationBarHeight: CGFloat
    
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView: MainViewName
    @Binding var restrictedHeight: CGFloat
    @Binding var topEdgeIgnoredHeight: CGFloat
    
    @State var popUp_startNewRecordSet: Bool = false
    @State var popUp_recordInDetail = false
    @State var popUp_changeStyle = false
    @State var selectedRecord: DailyRecord? = nil
    @State var selectedDrDate: Date? = nil
    @State var updateSelectedDailyRecordSet: Bool = false
    @State var recalculatingVisualValues_themeChanged: Bool = false // not used yet. Will be used to hide when calculation is on process
    @State var dailyRecordSetHiddenOrDeleted: Bool = false
    @State var isEditingTermGoals: Bool = false
    @State var newDailyRecordSetAdded: Bool = false
    @State var undoNewDRS: Bool = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var lastTapTime: Date = Date()
    @State var lastEditedTime: Date = Date()
    @State var selectedDrIdx:Int? = nil
    @State var alert_confirmDrsDeletion: Bool = false
    @State var drsDeleted: Bool = false
    @State var buttonOpacity: CGFloat = 0.5
    @State var lastDrSelectedTime: Date = Date()
    
    var body: some View {
        
        let showHiddenQuests = profiles.first?.showHiddenQuests ?? false
        let hiddenQuestNames: Set<String> = showHiddenQuests ? [] : Set(quests.filter({$0.isHidden}).map({$0.name}))

//        let dailyRecords_withContent:[DailyRecord] = {
//            if showHiddenQuests {
//                return selectedDailyRecordSet.dailyRecords!
//                    .filter({$0.hasContent})
//                    .sorted(by: {
//                        if $0.date != nil && $1.date != nil { return $0.date! < $1.date! }
//                        else { return false }
//                    })
//            } else {
//                return selectedDailyRecordSet.dailyRecords!
//                    .filter({
//                        $0.hasContent &&
//                        ($0.hasTodoOrDiary ||
//                         !Set($0.dailyQuestList!.filter({$0.data != 0}).map{$0.questName}).subtracting(hiddenQuestNames).isEmpty)
//                    })
//                    .sorted(by:{
//                        if $0.date != nil && $1.date != nil { return $0.date! < $1.date! }
//                        else { return false }
//                    }
//                )
//            }
//        }()
        let dailyRecords_withContent:[DailyRecord] = selectedDailyRecordSet.dailyRecordsWithContent(hiddenQuestNames: hiddenQuestNames, showHiddenQuests: showHiddenQuests)
        
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        let backGroundColor:Color = getColorSchemeColor(colorScheme)
        let statusBarHeight:CGFloat = getStatusBarHeight()

        let dailyRecordSetEmpty: Bool = selectedDailyRecordSet.dailyRecords!.filter({$0.hasContent}).count == 0
        
        let nextDRS: DailyRecordSet? = selectedDrsIdx < dailyRecordSets.count - 1  ? dailyRecordSets[selectedDrsIdx+1] : nil
        
        let prevDRS_start: Date? = standardDateToLocalStartOfDay(std:dailyRecordSets.map({$0.start}).filter({$0 < selectedDailyRecordSet.start}).sorted().last)
        let nextDRS_start: Date? = standardDateToLocalStartOfDay(std:dailyRecordSets.map({$0.start}).filter({$0 > selectedDailyRecordSet.start}).sorted().first)
        let nextDRS_end: Date? = {if let end = nextDRS?.end {return end} else {return nil}}()
        
        let startRange: ClosedRange<Date> = {
            if let min = prevDRS_start?.addingDays(-1) {
                if let max = standardDateToLocalStartOfDay(std: selectedDailyRecordSet.end)  {
                    print(min)
                    print(max)
                    return min...max
                }
                else {
                    return min...Calendar.current.date(byAdding: .year, value: 50, to: min)!
                }
            }
            else {
                if let max = standardDateToLocalStartOfDay(std: selectedDailyRecordSet.end) {
                    return Calendar.current.date(byAdding: .year, value: -50, to: max)!...max
                }
                else {
                    return Calendar.current.date(byAdding: .year, value: -50, to: standardDateToLocalStartOfDay(std: selectedDailyRecordSet.start))!...Calendar.current.date(byAdding: .year, value: 50, to: standardDateToLocalStartOfDay(std: selectedDailyRecordSet.start))!
                }
            }
        }()
        let endRange: ClosedRange<Date> = {
            let min = standardDateToLocalStartOfDay(std: selectedDailyRecordSet.start)
            if let max = standardDateToLocalStartOfDay(std: nextDRS_end)?.addingDays(-1) {
//                print(min)
//                print(max)
//                if selectedDrsIdx <
                if max >= min {
                    return min...max
                } else {
                    return min...min
                }
            }
            else {
                return min...Calendar.current.date(byAdding: .year, value: 50, to: min)!
            }
        }()

        let isLastDailyRecordSet: Bool = selectedDrsIdx == dailyRecordSets.count - 1


        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height

            ZStack {
                
                if !recalculatingVisualValues_themeChanged {
                    if updateSelectedDailyRecordSet {
                        Text("변경중")
                        // MARK: 없으면 drs바뀔 때 이전 drs의 theme이 바뀐 drs에 적용되는 경우가 생김 -> 에러 가능성 up (실제로 질문 없는 DRS에 질문있는 theme이 적용되면 에러 발생)
                        // TODO: 변경 시 눈에 안보일 정도로 빠르게 지나가지만 오래걸린다면? -> 자연스러운 view로 바꾸기
                    }
                    else if selectedDailyRecordSet.dailyRecordThemeName == "StoneTower" {
                        StoneTower(
                            selectedDailyRecordSet: $selectedDailyRecordSet,
                            selectedDrsIdx: $selectedDrsIdx,
                            selectedDailyRecord: $selectedRecord,
                            selectedDrIdx: $selectedDrIdx,
                            dailyRecords_withContent: dailyRecords_withContent,
                            popUp_startNewRecordSet: $popUp_startNewRecordSet,
                            popUp_recordInDetail: $popUp_recordInDetail,
//                            alert_drsHidden: $alert_drsHidden,
//                            alert_drsInTrashCan: $alert_drsInTrashCan,
//                            dailyRecordSetHiddenOrDeleted: $dailyRecordSetHiddenOrDeleted,
                            popUp_changeStyle: $popUp_changeStyle,
                            isEditingTermGoals: $isEditingTermGoals,
                            undoNewDRS: $undoNewDRS,
                            drsDeleted: $drsDeleted,
                            startDate: $startDate,
                            endDate: $endDate,
                            prevDRS_start: prevDRS_start,
                            nextDRS_start: nextDRS_start,
                            startRange: startRange,
                            endRange: endRange
//                            selectedDrsIdx: $selectedDrsIdx
                            
                        )
//                        Text("")
                        .frame(width:geoWidth, height: geoHeight)
                    }

                    
                    else {
                        
                        Text("can't find theme")
                    }
                    
                }
                else {
                    Text("변경하는 중..")
                }
                
                HStack(spacing:0.0) {
                    Button(action:{
                        
                        selectedDrsIdx -= 1
                        isEditingTermGoals = false
                    }) {
                        Image(systemName: "arrowtriangle.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:geoWidth*0.08)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedDrsIdx == 0 || isEditingTermGoals)
                    .opacity((selectedDrsIdx == 0 || isEditingTermGoals) ? 0.0 : buttonOpacity)
                    .padding(.leading,10)
                    .frame(width:geoWidth/2, alignment:.leading)
                    
                    Button(action:{
                        selectedDrsIdx += 1
                    }) {
                        Image(systemName: "arrowtriangle.forward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:geoWidth*0.08)
                    }
                    .buttonStyle(.plain)
//                    .foregroundStyle(.ultraThinMaterial)
                    .disabled(isLastDailyRecordSet || isEditingTermGoals)
                    .opacity((isLastDailyRecordSet || isEditingTermGoals) ? 0.0 : buttonOpacity)

                    .padding(.trailing,10)
                    .frame(width:geoWidth/2, alignment:.trailing)

                }
//                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                
                // 790 849(790 + 59) 54 932(790 + 59 + ?)

//                let restrictedScreenBoundsHeight:CGFloat = 10 /*UIScreen.main.bounds.height - geoHeight*/
                HStack {
                    if selectedDailyRecordSet.end != nil {
                        DatePicker(
                            "",
                            selection: $startDate,
                            in: startRange,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
//                        .frame(width:geoWidth*0.25)

                        
                        Text("~")
                            .bold()
                            .padding(.horizontal,3)
                        DatePicker(
                            "",
                            selection: $endDate,
                            in: endRange,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
//                        .frame(width:geoWidth*0.25)

                    }
                    else {
                        DatePicker(
                            "",
                            selection: $startDate,
                            in: startRange,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()

                        Text("~")
                            .bold()
                            .padding(.horizontal,5)
                            .minimumScaleFactor(0.5)
                            .frame(width:30.0, alignment:.leading)

                    }

                }
                .frame(width:geoWidth*0.95, height:restrictedHeight*0.05)
                .position(x:geoWidth*0.5, y: (geoHeight - restrictedHeight) + restrictedHeight*0.035 + restrictedHeight*0.025 )
                .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)
                .offset(x: selectedDailyRecordSet.end != nil ? 0.0 : 15.0)


//                    .frame(width:geoWidth*0.7, height:groundHeight*0.15, alignment: .center)
                
                Menu { // menu의 요소들에는 dynamicTypeSize 안 통함
                    
                    Button("도움말") {
                        
                    }
//                    .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)

                    
                    Button("스타일 변경") { // 나중에 theme, theme별 선택 가능 요소(색,배경 등등들 다 바꿀 수 있게 하기
                        popUp_changeStyle.toggle()
                    }
//                    .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)

                    if selectedDrsIdx != 0 {
                        Button("현재 기록의 탑 삭제") {
                            alert_confirmDrsDeletion.toggle()
                        }
                        
                    }
                    
                    if isLastDailyRecordSet {
                        Button(action: {
                            popUp_startNewRecordSet.toggle()
                        }) {
                            Text("다음 기록의 탑 생성")
                        }


                    }
                    
                } label: {
                    Image(systemName:"line.3.horizontal")
                }
                .frame(width:geoWidth*0.95, height:restrictedHeight*0.05, alignment: .trailing)
                .position(x:geoWidth*0.5, y: (geoHeight - restrictedHeight) + restrictedHeight*0.035 + restrictedHeight*0.025 )
                .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)
                .buttonStyle(.plain)
                .alert("해당 기록의 탑을 삭제하시겠습니까?", isPresented: $alert_confirmDrsDeletion) {
                    Button("삭제") {
                        alert_confirmDrsDeletion.toggle()
                        drsDeleted.toggle()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                    Button("아니오") {
                        alert_confirmDrsDeletion.toggle()
                    }
                } message: {
                    Text("모든 기록은 직전 기록의 탑과 병합됩니다.")
                }
                
                
                if popUp_startNewRecordSet {
                    Color.gray.opacity(0.5)
                    let minDate = standardDateToLocalStartOfDay(std:selectedDailyRecordSet.start.addingDays(1))
                    StartNewRecordSet(
                        popUp_startNewRecordSet: $popUp_startNewRecordSet,
                        newDailyRecordSetAdded: $newDailyRecordSetAdded,
                        minDate: minDate,
                        selectedDate:max(minDate, getStartDateOfNow())
                    )
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .popUpViewLayout(width: geoWidth*0.9, height: (geoHeight-statusBarHeight)*0.6, color: backGroundColor)
                        .position(x:geoWidth/2,y: statusBarHeight + (geoHeight-statusBarHeight)/2 )
                }
                
                if popUp_changeStyle { //TODO: 나중에는 theme에 관계없이 통일된 popup창 -> 동일한 theme내에서 색만 변경 가능, 질문 있는 theme -> 질문없는 theme으로 변경 가능(경고메시지), 질문 있는 theme -> 질문 있는 theme, 질문 없는 theme -> 질문 없는 theme 기능 제공
                    Color.gray.opacity(0.5)
                        .onTapGesture {
                            popUp_changeStyle.toggle()
                        }
                    if selectedDailyRecordSet.dailyRecordThemeName == "StoneTower" {
                        StoneTower_popUp_ChangeStyleView(
                            popUp_changeStyle:$popUp_changeStyle,
                            defaultColorIndex_tmp: $selectedDailyRecordSet.dailyRecordColorIndex
                        )
                        .frame(width: geoWidth*0.8, height: geoHeight*0.7)
                        .background(.background)
                        .clipShape(.rect(cornerSize: CGSize(width: geoWidth*0.8*0.1, height: geoHeight*0.7*0.1)))
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }

                }
//                if popUp_recordInDetail {
                if selectedDrIdx != nil && popUp_recordInDetail {
                    Color.gray.opacity(0.5)
                        .onTapGesture {
                            popUp_recordInDetail.toggle()
                        }
                    RecordInDetailView_new(
                        dailyRecords_withContent: dailyRecords_withContent,
                        showHiddenQuests:showHiddenQuests,
//                        selectedDailyRecord:$selectedRecord,
                        popUp_recordInDetail: $popUp_recordInDetail,
                        selectedDrIdx: $selectedDrIdx
//                        selectedDrDate:$selectedDrDate
//                        selectedDrDate: selectedRecord?.date ?? nil
                    )
                    .frame(width: geoWidth*0.95, height: geoHeight*0.7)
                    .background(.background)
                    .clipShape(.rect(cornerSize: CGSize(width: geoWidth*0.95*0.1, height: geoHeight*0.7*0.1)))
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                }
                
                
                
                
                
            }
            .frame(width:geoWidth,height:geoHeight)
            .scrollDisabled(dailyRecordSetEmpty)
            .onAppear() {
                if topEdgeIgnoredHeight == 0 {topEdgeIgnoredHeight = geoHeight}
            }
        }
        .onChange(of: selectedDrsIdx) {
            updateSelectedDailyRecordSet = true
        }
        .onChange(of: updateSelectedDailyRecordSet) {
            if updateSelectedDailyRecordSet {
                


                // MARK: 오류!
                selectedDailyRecordSet = dailyRecordSets[selectedDrsIdx]
                
                // tmp code
                if selectedDrsIdx == dailyRecordSets.count - 1 {
                    selectedDailyRecordSet.end = nil
                }
                updateSelectedDailyRecordSet = false // MARK: 무한 루프가 생성되지 않는다. 바꿔줘도 됨.
//                updateStartAndEnd()
                selectedRecord = nil
                startDate = standardDateToLocalStartOfDay(std:selectedDailyRecordSet.start)
                endDate = standardDateToLocalStartOfDay(std:selectedDailyRecordSet.end ?? Date())
            }
            
        }
        .onAppear() {
            startDate = standardDateToLocalStartOfDay(std: selectedDailyRecordSet.start)
            endDate = standardDateToLocalStartOfDay(std:selectedDailyRecordSet.end ?? Date())
        }
        .onChange(of: selectedView) {
            selectedDrsIdx = dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).count > 0 ? dailyRecordSets.filter({$0.start < .now}).count-1 : 0
            popUp_changeStyle = false
            popUp_startNewRecordSet = false
            popUp_recordInDetail = false
            selectedDrIdx = nil
            selectedRecord = nil
            
            
            // 후보 코드: 오랫동안 seeMyRecord를 안들어가면 currentDailyRecord로 돌아감과 동시에 맨 위로 스크롤 돌아감.
//            if selectedView != .seeMyRecord {
//                lastEditedTime = Date()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
//                    if Date().timeIntervalSince(lastEditedTime) > 19.0 && selectedView != .seeMyRecord { // additional condition: if current DailyRecordSet
//                        // code that scrolls to the top of the View
//                    }
//                }
//            }
            
        }
        .onChange(of: newDailyRecordSetAdded) {
            selectedDrsIdx = dailyRecordSets.count - 1
        }
        .onChange(of: selectedRecord) { oldValue, newValue in
            selectedDrDate = selectedRecord?.date
            if selectedRecord != nil {
                lastTapTime = Date()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    if Date().timeIntervalSince(lastTapTime) > 9.0 {
                        selectedRecord = nil
                    }
                }
            }

        }
        
        
        .onChange(of: selectedDailyRecordSet.dailyRecordThemeName) {
            
            recalculatingVisualValues_themeChanged = true
            recalculatingVisualValues_themeChanged = false
            
        }
        .onChange(of: startDate) { oldValue, newValue in
            
            if newValue != selectedDailyRecordSet.start {
                
                let stdStartDate = getStandardDate(from: newValue)
                // 1.change selectedDRS.start
                selectedDailyRecordSet.start = stdStartDate
                let prevDrsExists = selectedDrsIdx > 0
                
                // 2.change prevDRS.end if exists
                if prevDrsExists {dailyRecordSets[selectedDrsIdx-1].end = stdStartDate.addingDays(-1)}
                
                // 3.move dailyRecords between prevDRS and
                if oldValue < newValue && prevDrsExists {
                    let prevDRS = dailyRecordSets[selectedDrsIdx-1]
                    for dailyRecord in selectedDailyRecordSet.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date < stdStartDate {
                                dailyRecord.dailyRecordSet = prevDRS
                            }
                        }
                    }
                }
                else if oldValue < newValue && !prevDrsExists {
                    for dailyRecord in selectedDailyRecordSet.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date < stdStartDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                    }
                }
                else if oldValue > newValue && prevDrsExists {
                    let prevDRS = dailyRecordSets[selectedDrsIdx-1]
                    for dailyRecord in prevDRS.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date >= stdStartDate {
                                dailyRecord.dailyRecordSet = selectedDailyRecordSet
                            }
                        }
                    }
                }
                else if oldValue > newValue && !prevDrsExists {
                    for dailyRecord in dailyRecords.filter({$0.dailyRecordSet == nil}) {
                        if let date = dailyRecord.date {
                            if date >= stdStartDate {
                                dailyRecord.dailyRecordSet = selectedDailyRecordSet
                            }
                        }
                    }
                    
                    
                }
            }
        }

        .onChange(of: endDate) { oldValue, newValue in
        
            if newValue != selectedDailyRecordSet.end {
                
                let stdEndDate = getStandardDate(from: newValue)

                let nextDrsExists = selectedDrsIdx < dailyRecordSets.count - 1
                // 1.change nextDRS.start if exists
                if nextDrsExists {dailyRecordSets[selectedDrsIdx+1].start = stdEndDate.addingDays(1)}
                
                // 2.change selectedDRS.end
                if nextDrsExists {selectedDailyRecordSet.end = stdEndDate }
                else { selectedDailyRecordSet.end = nil }
                
                // 3.move dailyRecords between nextDRS and selectedDRS
                if oldValue > newValue && nextDrsExists  {
                    let nextDRS = dailyRecordSets[selectedDrsIdx+1]
                    for dailyRecord in selectedDailyRecordSet.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date > stdEndDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                    }
                }
                else if oldValue > newValue && !nextDrsExists {
                    for dailyRecord in selectedDailyRecordSet.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date > stdEndDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                    }
                }
                else if oldValue < newValue && nextDrsExists  {
                    let nextDRS = dailyRecordSets[selectedDrsIdx+1]
                    for dailyRecord in nextDRS.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date <= stdEndDate {
                                dailyRecord.dailyRecordSet = selectedDailyRecordSet
                            }
                        }
                    }
                }
                else if oldValue < newValue && !nextDrsExists {
                    for dailyRecord in dailyRecords.filter({$0.dailyRecordSet == nil}) {
                        if let date = dailyRecord.date {
                            if date <= stdEndDate {
                                dailyRecord.dailyRecordSet = selectedDailyRecordSet
                            }
                        }
                    }
                    
                    
                }
            }

        }
        
        .onChange(of: drsDeleted) {
            if drsDeleted && selectedDrsIdx > 0 {
                let prevDrs:DailyRecordSet = dailyRecordSets[selectedDrsIdx-1]
                for dr in selectedDailyRecordSet.dailyRecords! {
                    dr.dailyRecordSet = prevDrs
                }
                prevDrs.end = selectedDailyRecordSet.end
                let deleteTarget: DailyRecordSet = selectedDailyRecordSet
                selectedDrsIdx -= 1
                modelContext.delete(deleteTarget)
                
                drsDeleted = false
                
            }
        }
        
        .onChange(of: selectedDrDate) {
            if selectedDrDate != nil {
                buttonOpacity = 0.0
                lastDrSelectedTime = Date()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if Date().timeIntervalSince(lastDrSelectedTime) > 2.5 {
                        buttonOpacity = 0.5
                    }
                }
            } else {
                buttonOpacity = 0.5
            }
        }
//        .onChange(of: popUp_recordInDetail) {
////            if popUp_recordInDetail && selectedDrIdx == nil && selectedRecord != nil {
//            if popUp_recordInDetail {
//                DispatchQueue.main.async {
//                    selectedDrIdx = dailyRecords_withContent.firstIndex(of: selectedRecord!) ?? 0
//                    print(selectedDrIdx)
//                }
//            }
//        }
        
        
    }
        
    

    
//    func updateStartAndEnd() -> Void {
//        let dates: [Date] = selectedDailyRecordSet.dailyRecords!.compactMap{$0.date}.sorted()
//        if let start: Date = dates.first {
//            selectedDailyRecordSet.start = start
//        }
//        if let end: Date = dates.last {
//            selectedDailyRecordSet.end = end
//        }
//    }
//    

    
    
}




