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
import Combine

// 기본: 책장 / 미술관 / 일기장..?
// 얘도 다양한 형태로 저장소 스킨 바꿀 수 있음 (정말 다양하게!)

// 삭제/숨기기 되면 -> 삭제/숨기기

// TODO: 계산 중에는 selectedDR, selectedDRS 의 변경 막기

// TODO: 공통 부분 다 여기로 불러오기, 미리 설정해야 그래픽 크기는 staticfunc로 만들어서 여기서 설정해서 넣어주기
struct MainView_TermSummation: View { //MARK: selectedDailyRecordSet은 selectedDrsIdx로 컨트롤한다. selectedDailyRecordSet은 직접 건드리지 않는다.
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    @Query var quests: [Quest]

    
    
    @State var selectedDrsIdx: Int? // it does not automatically changes selectedDailyRecordSet. you need to toggle updateSelectedDailyRecordSet to update selectedDailyRecordSet
    @State var selectedDailyRecordSet: DailyRecordSet
    
    
//    var navigationBarHeight: CGFloat
    
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView: MainViewName
    @Binding var restrictedHeight: CGFloat
    @Binding var topEdgeIgnoredHeight: CGFloat
    
    @State var popUp_startNewRecordSet: Bool = false
    @State var selectedRecord: DailyRecord? = nil
    @State var selectedDrDate: Date? = nil
    @State var updateSelectedDailyRecordSet: Bool = false
    @State var recalculatingVisualValues_themeChanged: Bool = false // not used yet. Will be used to hide when calculation is on process
    @State var dailyRecordSetHiddenOrDeleted: Bool = false
    @State var isEditingTermGoals: Bool = false
    @State var newDailyRecordSetAdded: Bool = false
    @State var undoNewDRS: Bool = false
    @State var lastTapTime: Date = Date()
    @State var lastEditedTime: Date = Date()
    @State var selectedDrIdx:Int? = nil
    @State var drsDeleted: Bool = false
    @State var buttonOpacity: CGFloat = 0.5
    @State var lastDrSelectedTime: Date = Date()
    
    var body: some View {
        
        let showHiddenQuests = profiles.first?.showHiddenQuests ?? false

        
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        let backGroundColor:Color = getColorSchemeColor(colorScheme)
        let statusBarHeight:CGFloat = getStatusBarHeight()

        let dailyRecordSetEmpty: Bool = selectedDailyRecordSet.dailyRecords!.filter({$0.hasContent}).count == 0
        
//        let nextDRS: DailyRecordSet? = selectedDrsIdx < dailyRecordSets.count - 1  ? dailyRecordSets[selectedDrsIdx+1] : nil
//        
//
//        let nextDRS_end: Date? = {if let end = nextDRS?.end {return end} else {return nil}}()
//        
//
//
//        let isLastDailyRecordSet: Bool = selectedDrsIdx == dailyRecordSets.count - 1


        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
                
            ZStack {
                ScrollView(.horizontal) {
                    LazyHStack(spacing:0.0) {
                        ForEach(dailyRecordSets.indices, id:\.self) { idx in
                            let drs = dailyRecordSets[idx]
                            //                            Text("test")
                            DrsSummationView(
                                drs: drs,
                                drsIdx: idx,
                                selectedDrsIdx: $selectedDrIdx,
                                undoNewDRS: $undoNewDRS,
                                restrictedHeight: $restrictedHeight
                            )
                            .frame(width:geoWidth, height:geoHeight)
                            
                            //                                .containerRelativeFrame([.horizontal, .vertical])
                            .id(idx)
                            
                            
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedDrsIdx) // 가볍게 해야 초기화 시 오래 안걸림. 초기화 시간 오래걸리면 해당 index로 바로 안넘어감
                .frame(width:geoWidth, height:geoHeight)
                .scrollTargetBehavior(.paging)
                
                Button(action:{popUp_startNewRecordSet.toggle()}) {
                    VStack {
                        Image(systemName:"arrowshape.right")
                        Text("새로 만들기")
                            .font(.caption)
                    }
                    
                }
                .padding(10)
                .frame(width:geoWidth, height:geoHeight, alignment: .bottomTrailing)
                
                
                if popUp_startNewRecordSet {
                    Color.gray.opacity(0.5)
                    let minDate = standardDateToLocalStartOfDay(std:dailyRecordSets.last?.start.addingDays(1) ?? getStandardDateOfNow())
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

                
                
                
                
                
            }
            .frame(width:geoWidth,height:geoHeight)
            .onAppear() {
                selectedDrsIdx = dailyRecordSets.count - 1
                if topEdgeIgnoredHeight == 0 {topEdgeIgnoredHeight = geoHeight}
            }
            
        }
        .onChange(of: selectedDrsIdx) {
            updateSelectedDailyRecordSet = true
        }


        .onChange(of: selectedView) {
//            selectedDrsIdx = dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).count > 0 ? dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).count-1 : 0
            popUp_startNewRecordSet = false
//            selectedDrIdx = nil
            selectedRecord = nil
            
//            selectedDrsIdx = dailyRecordSets.count - 1
            let data_filtered = dailyRecords.filter({$0.date != nil}).filter({Calendar.current.dateComponents([.month, .day],from: $0.date!).month == 9})
            print("9/19 count: ")
            print(data_filtered.filter({Calendar.current.dateComponents([.month, .day],from: getStandardDate(from: $0.date!)).day == 19}).count)
            
        }
        .onChange(of: newDailyRecordSetAdded) {
            selectedDrsIdx = dailyRecordSets.count - 1
            
        }



        
        
    }
        
    


    
}


// TODO: 글씨 색도 stonecolor에 맞춰서.
struct DrsSummationView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    
    
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    @Query var dailyRecords: [DailyRecord]
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query var quests: [Quest]
    
    
    
    var drs:DailyRecordSet
    var drsIdx: Int
    @Binding var selectedDrsIdx: Int?
    @Binding var undoNewDRS: Bool
    @Binding var restrictedHeight: CGFloat
    

    
    //    let selectedDrsIdx: Int
    @State var checkQuest_hourly: Bool = true
    @State var popUp_changeStyle = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var drsDeleted: Bool = false
    
    @State var termModified: Bool = false


    @State var alert_confirmDrsDeletion: Bool = false
    @State var scrollViewCenterY: CGFloat = 0
    @State var editText:[String] = []
    @State private var keyboardHeight: CGFloat = 0
    @State var keyboardAppeared: Bool = false
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { $0.keyboardHeight },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }
    @State var presentQuestions: Bool = false
    @State var showDailyQuestionStatistics: Bool = false
    @FocusState var editTermGoals: Int?
    
    @State var pickerSelectedValue: Int = 0
    
    
    var body: some View {

        let drsStart = drs.start
        let drsEnd = drs.end
        let prevDRS_start: Date? = standardDateToLocalStartOfDay(std:dailyRecordSets.map({$0.start}).filter({$0 < drs.start}).sorted().last)
        let nextDRS_start: Date? = standardDateToLocalStartOfDay(std:dailyRecordSets.map({$0.start}).filter({$0 > drs.start}).sorted().first)
        let nextDRS: DailyRecordSet? = drsIdx < dailyRecordSets.count - 1  ? dailyRecordSets[drsIdx+1] : nil
        let nextDRS_end: Date? = {if let end = nextDRS?.end {return end} else {return nil}}()
        let startRange: ClosedRange<Date> = {
//            if let min = prevDRS_start?.addingDays(-1) {
            if let min = prevDRS_start?.addingDays(1) {
                if let max = standardDateToLocalStartOfDay(std: drs.end)  {
//                    print(min)
//                    print(max)
                    return min...max
                }
                else {
                    return min...Calendar.current.date(byAdding: .year, value: 50, to: min)!
                }
            }
            else {
                if let max = standardDateToLocalStartOfDay(std: drs.end) {
                    return Calendar.current.date(byAdding: .year, value: -50, to: max)!...max
                }
                else {
                    return Calendar.current.date(byAdding: .year, value: -50, to: standardDateToLocalStartOfDay(std: drs.start))!...Calendar.current.date(byAdding: .year, value: 50, to: standardDateToLocalStartOfDay(std: drs.start))!
                }
            }
        }()
        let endRange: ClosedRange<Date> = {
            let min = standardDateToLocalStartOfDay(std: drs.start)
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
        
        
//        let dailyRecords_visible: [DailyRecord] = drs.visibleDailyRecords()
        
        let showHiddenQuests = profiles.first?.showHiddenQuests ?? false

        let hiddenQuestNames: Set<String> = showHiddenQuests ? [] : Set(quests.filter({$0.isHidden}).map({$0.name}))

        let dailyRecords_visible:[DailyRecord] = drs.visibleDailyRecords(hiddenQuestNames: hiddenQuestNames, showHiddenQuests: showHiddenQuests) // already sorted
        let dailyRecords_withDiaries:[DailyRecord] = dailyRecords_visible.filter({$0.dailyTextType != nil && $0.dailyText != ""})

        
        let shadowColor: Color = getShadowColor(colorScheme)
        
        
        
        let quests_recorded:[Quest] = quests.filter{showHiddenQuests ? true : !$0.isHidden}.filter{$0.getCumulative(from: drsStart, to: drsEnd) > 0}
        
        let quests_recorded_hours:[Quest] = quests_recorded.filter{$0.dataType == DataType.hour.rawValue}

        let questData:[Quest:Int] = {
            var returnDict: [Quest:Int] = [:]
            for quest in quests_recorded {
                returnDict[quest] = quest.getCount(from: drsStart, to: drsEnd)
            }
            return returnDict
        }()
        let questData_hours:[Quest:CGFloat] = {
            var returnDict: [Quest:CGFloat] = [:]
            for quest in quests_recorded_hours {
                if !quest.isHidden {
                    returnDict[quest] = CGFloat(quest.getCumulative(from: drsStart, to: drsEnd)) / 60.0
                }
            }
            return returnDict
        }()
        let purposeData:[String:Int] = {
            var returnDict: [String:Int] = [:]
            for purpose in defaultPurposes {
                returnDict[purpose] = 0
            }
            for (quest, val) in questData {
                for purpose in quest.recentPurpose {
                    returnDict[purpose]? += val
                }
            }
            return returnDict
        }()
        let purposeData_hours:[String:CGFloat] = {
            var returnDict: [String:CGFloat] = [:]
            for purpose in defaultPurposes {
                returnDict[purpose] = 0
            }
            for (quest, val) in questData_hours {
                for purpose in quest.recentPurpose {
                    returnDict[purpose]? += val
                }
            }
            return returnDict
        }()
        
        let quests_sorted:[Quest] = questData.keys.sorted(by:{
            if questData[$0] ?? 0 != questData[$1] ?? 0 {
                questData[$0] ?? 0 >= questData[$1] ?? 0
            }
            else {
                $0.name < $1.name
            }
        })
        let quests_sorted_hours:[Quest] = questData_hours.keys.sorted(by:{
            if questData_hours[$0] ?? 0 != questData_hours[$1] ?? 0 {
                questData_hours[$0] ?? 0 >= questData_hours[$1] ?? 0
            }
            else {
                $0.name < $1.name
            }
        })
        let purposes_sorted:[String] = purposeData.keys.filter({purposeData[$0] ?? 0 != 0}).sorted(by:{
            if purposeData[$0] ?? 0 != purposeData[$1] ?? 0 {
                purposeData[$0] ?? 0 >= purposeData[$1] ?? 0
            }
            else {
                $0 < $1
            }
        })
        let purposes_sorted_hours:[String] = purposeData_hours.keys.filter({purposeData_hours[$0] ?? 0.0 != 0.0}).sorted(by:{
            if purposeData_hours[$0] ?? 0 != purposeData_hours[$1] ?? 0 {
                purposeData_hours[$0] ?? 0 >= purposeData_hours[$1] ?? 0
            }
            else {
                $0 < $1
            }
        })
        
        let cumulative_cnt:Int = questData.values.reduce(0, +)
        let cumulative_hours:CGFloat = questData_hours.values.reduce(0, +)
        
        GeometryReader { geometry in
            
            let geoWidth:CGFloat = geometry.size.width
            let geoHeight:CGFloat = geometry.size.height
            
            let topHeight = restrictedHeight*0.05
            let content1TopPadding:CGFloat = geoHeight*0.15
            let content1Height:CGFloat = geoHeight*0.35
            let content2Height:CGFloat = geoHeight*0.5
            let content2TopPadding:CGFloat = content2Height*0.1
            let content2CumulativeHeight:CGFloat = content2Height*0.3
            let content2TowerHeight:CGFloat = content2Height*0.6
            
            
                
                
            ZStack {
                if drs.dailyRecordThemeName == "StoneTower" {
                    StoneTower(
                        questData:questData,
                        questData_hours:questData_hours,
                        purposeData: purposeData,
                        purposeData_hours: purposeData_hours,
                        quests_sorted: quests_sorted,
                        quests_sorted_hours: quests_sorted_hours,
                        purposes_sorted: purposes_sorted,
                        purposes_sorted_hours: purposes_sorted_hours,
                        restrictedHeight: restrictedHeight,
                        cumulative_cnt: cumulative_cnt,
                        cumulative_hours: cumulative_hours,
                        dailyRecords_visible: dailyRecords_visible,
                        dailyRecords_withDiaries: dailyRecords_withDiaries
                    )
                }
                
                
                
                HStack {
                    if drs.end != nil {
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
                .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)
                .frame(width:geoWidth*0.95, height:restrictedHeight*0.05)
                .position(x:geoWidth*0.5, y: (geoHeight - restrictedHeight) + restrictedHeight*0.035 + restrictedHeight*0.025 )
//                .position(x:geoWidth*0.5, y: (geoHeight - restrictedHeight)/2 + restrictedHeight*0.035 + restrictedHeight*0.025 )
//                .position(x:geoWidth*0.5, y: restrictedHeight*0.035 + restrictedHeight*0.025 )
                .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)
                .offset(x: drs.end != nil ? 0.0 : 15.0)
                
                if drsIdx != 0 { // 나중에 다양한 스타일 생기면 drsIdx == 0 이어도 Menu 만들고 menu에 스타일 변경 넣기
                    
                    Menu { // menu의 요소들에는 dynamicTypeSize 안 통함
                        
                        //                    Button("스타일 변경") { // 나중에 theme, theme별 선택 가능 요소(색,배경 등등들 다 바꿀 수 있게 하기
                        //                        popUp_changeStyle.toggle()
                        //                    }
                        
                        //                    if drsIdx != 0 {
                        Button("현재 기록의 탑 삭제") {
                            alert_confirmDrsDeletion.toggle()
                        }
                        //                    }
                        
                    } label: {
                        Image(systemName:"line.3.horizontal.circle")
                        //                    Image(systemName:"line.3.horizontal") // 24.09.28 os issue: ios 18.0 에서 line.3.horizontal 작동 안 ㅎ마
                    }
                    .frame(width:geoWidth*0.95, height:restrictedHeight*0.05, alignment: .leading)
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
                }
            }
            .frame(width:geoWidth, height:geoHeight)
//            .border(.red)


            

        
            
            
        } // geometryReader
        .onAppear() {
            
            startDate = standardDateToLocalStartOfDay(std: drs.start)
            endDate = standardDateToLocalStartOfDay(std:drs.end ?? Date())
            
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
        .onChange(of: startDate) { oldValue, newValue in
            
            if newValue != drs.start {
                
                let stdStartDate = getStandardDate(from: newValue)
                // 1.change selectedDRS.start
                drs.start = stdStartDate
                let prevDrsExists = drsIdx > 0
                
                // 2.change prevDRS.end if exists
                if prevDrsExists {dailyRecordSets[drsIdx-1].end = stdStartDate.addingDays(-1)}
                
                // 3.move dailyRecords between prevDRS and
                if oldValue < newValue && prevDrsExists {
                    let prevDRS = dailyRecordSets[drsIdx-1]
                    for dailyRecord in drs.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date < stdStartDate {
                                dailyRecord.dailyRecordSet = prevDRS
                            }
                        }
                        else { dailyRecord.dailyRecordSet = nil }
                    }
                }
                else if oldValue < newValue && !prevDrsExists {
                    for dailyRecord in drs.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date < stdStartDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                        else { dailyRecord.dailyRecordSet = nil }
                    }
                }
                else if oldValue > newValue && prevDrsExists {
                    let prevDRS = dailyRecordSets[drsIdx-1]
                    for dailyRecord in prevDRS.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date >= stdStartDate {
                                dailyRecord.dailyRecordSet = drs
                            }
                        }
                        else { dailyRecord.dailyRecordSet = nil }
                    }
                }
                else if oldValue > newValue && !prevDrsExists {
                    for dailyRecord in dailyRecords.filter({$0.dailyRecordSet == nil}) {
                        if let date = dailyRecord.date {
                            if date >= stdStartDate {
                                dailyRecord.dailyRecordSet = drs
                            }
                        }
                        else { dailyRecord.dailyRecordSet = nil }
                    }
                    
                    
                }
            }
            
        }
        

        .onChange(of: endDate) { oldValue, newValue in
        
            if newValue != drs.end {
                
                let stdEndDate = getStandardDate(from: newValue)

                let nextDrsExists = drsIdx < dailyRecordSets.count - 1
                // 1.change nextDRS.start if exists
                if nextDrsExists {dailyRecordSets[drsIdx+1].start = stdEndDate.addingDays(1)}
                
                // 2.change selectedDRS.end
                if nextDrsExists {drs.end = stdEndDate }
                else { drs.end = nil }
                
                // 3.move dailyRecords between nextDRS and selectedDRS
                if oldValue > newValue && nextDrsExists  {
                    let nextDRS = dailyRecordSets[drsIdx+1]
                    for dailyRecord in drs.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date > stdEndDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                    }
                }
                else if oldValue > newValue && !nextDrsExists {
                    for dailyRecord in drs.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date > stdEndDate {
                                dailyRecord.dailyRecordSet = nil
                            }
                        }
                    }
                }
                else if oldValue < newValue && nextDrsExists  {
                    let nextDRS = dailyRecordSets[drsIdx+1]
                    for dailyRecord in nextDRS.dailyRecords! {
                        if let date = dailyRecord.date {
                            if date <= stdEndDate {
                                dailyRecord.dailyRecordSet = drs
                            }
                        }
                    }
                }
                else if oldValue < newValue && !nextDrsExists {
                    for dailyRecord in dailyRecords.filter({$0.dailyRecordSet == nil}) {
                        if let date = dailyRecord.date {
                            if date <= stdEndDate {
                                dailyRecord.dailyRecordSet = drs
                            }
                        }
                    }
                    
                    
                }
            }


            
        }
        .onChange(of: drs.start) {
            termModified.toggle()
            startDate = standardDateToLocalStartOfDay(std: drs.start)
            
        }
        .onChange(of: drs.end) {
            termModified.toggle()
            endDate = standardDateToLocalStartOfDay(std:drs.end ?? Date())
        }
        
        .onChange(of: drsDeleted) {
            if drsDeleted && drsIdx > 0 {
                let prevDrs:DailyRecordSet = dailyRecordSets[drsIdx-1]
                for dr in drs.dailyRecords! {
                    dr.dailyRecordSet = prevDrs
                }
                prevDrs.end = drs.end
                let deleteTarget: DailyRecordSet = drs
                selectedDrsIdx = drsIdx-1 // drsIdx가 0인 애는 애초에 삭제 못 함
                modelContext.delete(deleteTarget)
                drsDeleted = false
                
            }
        }
        
        .onChange(of: termModified) {
            for dr in dailyRecords {
                if let date = dr.date {
                    if date >= drs.start {
                        if let end = drs.end {
                            if date <= end { dr.dailyRecordSet = drs }
                            else if drsIdx == dailyRecordSets.count - 1 {
                                dr.dailyRecordSet = drs
                            }
                        }
                    }
                }
            }
        }
        
    }
    

    
    

    
    
}

