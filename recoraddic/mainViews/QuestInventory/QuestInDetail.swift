//
//  Popup_QuestStatistics.swift
//  recoraddic
//
//  Created by 김지호 on 3/16/24.
//

import Foundation
import SwiftUI
import Charts
import SwiftData
import ActivityKit




struct QuestInDetail: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests: [Quest]
    
    @Binding var selectedQuest: Quest? // MARK: 이렇게 하지 않으면 화면이 잘 업데이트 되지 않았었음.
    
    @Binding var popUp_questStatisticsInDetail: Bool
    
    @State var alert_inTrashCan: Bool = false
    @State var alert_restore: Bool = false
    @State var alert_delete: Bool = false
    @State var alert_sameName: Bool = false
    
    @State var currentPage = 0

    @State var popUp_editQuest = false
    
    @State var keyBoardAppeared = false
    
    var body: some View {
        
        let questNames = quests.filter({!$0.inTrashCan}).map { $0.name }
        
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let contentColor: Color = colorScheme == .light ? colorSchemeColor.adjust(brightness: -0.05) : colorSchemeColor
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let titleHeight = keyBoardAppeared ? geoHeight*0.1 : geoHeight*0.2
            let contentHeight = geoHeight*0.6
            let pickerHeight = geoHeight*0.1
            let menuHeight = geoHeight*0.15
            
            let contentWidth1 = geoWidth*0.9
            let contentWidth2 = geoWidth*0.8
            let contentWidth3 = contentWidth2/7
            
            let tierColor_dark: Color = getDarkTierColorOf(tier: selectedQuest?.tier ?? 0)
            let tierColor_bright: Color = getBrightTierColorOf2(tier: selectedQuest?.tier ?? 0)

            let questTier: Int = selectedQuest?.tier ?? 0
            let nextTier: Int = (questTier/5 + 1)*5
            
            if let quest = selectedQuest {
                VStack(spacing:0.0) {
                    VStack {
                        Group {
                            Text(quest.name)
                                .padding(.horizontal,40)
                                .frame(width: geoWidth)
                                .font(.title)
                                .padding(.top, geoHeight*0.02)
                                .minimumScaleFactor(0.5)
                            if let startDate: Date  = quest.dailyData.keys.sorted().first {
                                if !keyBoardAppeared {
                                    Text("시작일: \(yyyymmddFormatOf(startDate))")
                                }
                            }
                            
                        }.foregroundStyle(tierColor_dark)
                        
                        Spacer()
                            .frame(height:geoHeight*0.02)
                        
                        if quest.inTrashCan {
                            HStack(spacing:geoWidth/4) {
                                Button("되돌리기") {
                                    alert_restore.toggle()
                                }
                                .alert("퀘스트 '\(quest.name)' 를 복구하시겠습니까?", isPresented: $alert_restore) {
                                    Button("복구") {
                                        if questNames.contains(quest.name) {
                                            alert_sameName.toggle()
                                        } else {
                                            quest.inTrashCan = false
                                            popUp_questStatisticsInDetail.toggle()
                                        }
                                        alert_restore.toggle()
                                    }
                                    Button("취소") {
                                        alert_restore.toggle()
                                    }
                                }
                                .alert("같은 이름의 퀘스트가 존재합니다.",isPresented: $alert_sameName) {
                                    Button("확인") {
                                        alert_sameName.toggle()
                                    }
                                    
                                }
                                
                                
                                
                                Button("영구적으로 삭제") {
                                    alert_delete.toggle()
                                }
                                .foregroundStyle(.red)
                                .alert("퀘스트 '\(quest.name)' 를 영구적으로 삭제하시겠습니까?", isPresented: $alert_delete) {
                                    Button("영구적으로 삭제") {
                                        
                                        let targetQuest: Quest = quest
                                        selectedQuest = nil
                                        
                                        popUp_questStatisticsInDetail.toggle()
                                        alert_delete.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            modelContext.delete(targetQuest)
                                        }
                                    }
                                    Button("취소") {
                                        alert_delete.toggle()
                                    }
                                }

                                
                            }
                            .padding(.bottom,geoHeight*0.01)
                            
                            
                        } // 휴지통에 있을 때의 메뉴
                        else if !keyBoardAppeared {
                            let current: Int = {
                                if quest.dataType == DataType.hour.rawValue {
                                    return DataType.cumulative_integratedValueNotation(data: (quest.cumulative()), dataType: dataTypeFrom(quest.dataType))
                                }
                                else {
                                    return quest.dailyData.count
                                }
                            }()
                            let next: Int = DataType.cumulative_integratedValueNotation(data: (quest.getNextTierCondition()), dataType: dataTypeFrom(quest.dataType))
                            HStack(spacing:0.0) {
                                Text("다음 단계")
                                    .font(.title3)
                                
                                //                                QuestTierView(tier: (questTier/5 + 1)*5)
                                //                                    .frame(width: geoHeight*0.035, height: geoHeight*0.035)
                                
                                
                                Text(" : \(current)/\(next)")
                                    .font(.title3)
                                
                                
                                if quest.dataType == DataType.hour.rawValue {
                                    Text("시간")
                                }
                                else {
                                    Text("회 기록")
                                        .font(.title3)
                                    
                                }
                                //                                .background(
                                //                                    QuestTierView(tier: nextTier)
                                //                                )
                            }
                            .frame(width:contentWidth1, height: titleHeight*0.2)
                            .foregroundStyle(getDarkTierColorOf(tier: questTier))
                            .background(
                                
                                HStack(spacing:0.0) {
                                    let ratio: CGFloat = CGFloat(current) / CGFloat(next)
                                    if ratio.isFinite && ratio >= 0 && ratio <= 1 {
                                        //                                    QuestTierView(tier: nextTier)
                                        getTierColorOf(tier: nextTier).colorExpressionIntegration()
                                            .frame(width: contentWidth1*ratio)
//                                            tierColor_dark
                                        getTierColorOf(tier: questTier)
                                            .frame(width: contentWidth1*(1-ratio))
                                    }
                                    

                                }
                                    .frame(width:contentWidth1, height: titleHeight*0.2)
                                    .clipShape(.buttonBorder)
                                    .shadow(color:getDarkTierColorOf(tier: questTier), radius: 0.5)

                            )
                            .padding(.bottom,geoHeight*0.01)
                            
                        }
                        
                        
                        
                    }
                    .frame(height:titleHeight, alignment: .center)
                    
                    Spacer()
                        .frame(width: contentWidth1, height: 1)
                        .background(tierColor_dark.opacity(0.35))
                    
                        
                    if currentPage == 0 {
                        VStack(spacing:0.0) {
//                            Spacer()
//                                .frame(height:contentHeight*0.05)
                            
                            Image(systemName: "calendar")
                                .foregroundStyle(tierColor_dark)
                                .padding(10)
                            VStack {
                                HStack(spacing:0.0) {
                                    Text("일")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("월")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("화")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("수")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("목")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("금")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                    Text("토")
                                        .font(.subheadline)
                                        .frame(width:contentWidth3)
                                } // 요일
                                .padding(.top,geoHeight*0.02)
                                .foregroundStyle(tierColor_bright)
                                //                        .padding(.bottom,geoHeight*0.005)
                                
                                ZStack { // for scroll
                                    ScrollView {
                                        
                                        let elementSize:CGFloat = contentWidth2/7
                                        let (startDate,endDate): (Date,Date) = {
                                            let sorted_dates: [Date] = quest.dailyData.keys.sorted()
                                            
                                            if sorted_dates.isEmpty {
                                                return (.now, .now)
                                            }
                                            else {
                                                return (sorted_dates.first!, sorted_dates.last!)
                                            }
                                            
                                        }()
                                        let numberOfRows:Int = (calculateDaysBetweenTwoDates(from: startDate, to: endDate) + 8) / 7 + 1
                                        
                                        let scrollViewHeight:CGFloat = elementSize * CGFloat(numberOfRows)
                                        
                                        SerialVisualization(data: quest.dailyData, tier: questTier)
                                            .frame(width: contentWidth2, height: scrollViewHeight, alignment: .center)
                                            .padding(.horizontal, (contentWidth1-contentWidth2)/2)
                                        
                                    }
                                    .frame(width:contentWidth1)
                                    .defaultScrollAnchor(.bottom)
                                }
                                
                            } // 달력
                            .frame(width:contentWidth1, height: contentHeight*0.85)
                            .background(tierColor_dark)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: geoWidth*0.05, height: geoWidth*0.05)))
                            
                            
                            
                            
                            
                        }
                        .padding(.vertical)
                        //                        .padding(.top, contentHeight*0.05)
                        .frame(width:geoWidth, height: contentHeight, alignment: .top)
//                        .border(.red)
                        .tabItem {
                            Image(systemName: "calendar")
                        }
                        .background(Color.clear.opacity(0.01))
                    }
                    else if currentPage == 1 {
                        
                        QuestStatistics_inTerm(selectedQuest: quest)
                            .padding(.vertical)
                            .frame(width:geoWidth, height: contentHeight)
                            .scrollTargetLayout()
                        //                            .border(.red)
                            .tabItem {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                            }
                            .background(Color.clear.opacity(0.01))
                        
                    }
                    else { // currentPage == 2
                        QuestMemo(quest:quest,keyBoardAppeared: $keyBoardAppeared)
                            .padding(.vertical)
                            .frame(width:contentWidth1, height: contentHeight)
                    }
                        
                    
                    // TODO: custom picker로 바꿔서 색 적용시키기
                    Picker("",selection: $currentPage) {
                        Image(systemName: "calendar")
//                                .background(tierColor_dark)

//                                .tint(tierColor_dark)
//                                .foregroundStyle(tierColor_dark)
                            .tag(0)

                        if quest.dataType != DataType.ox.rawValue {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .tag(1)
                        }
//                                .background(tierColor_dark)
//                                .foregroundStyle(tierColor_dark)
                        Image(systemName: "note.text")
                            .tag(2)

                    }
                    .frame(width: contentWidth1)
//                        .background(tierColor_dark)
//                        .tint(tierColor_dark)
//                        .foregroundStyle(tierColor_dark)
                    .labelsHidden()
                    .pickerStyle(.palette)


                        
                        
                        
                        
                        
//                        }
//                        .frame(width: geoWidth, height: contentHeight)
                    
//                        .tabViewStyle(PageTabViewStyle())
                    //                    .border(.red)
//                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    
                    if !quest.inTrashCan {
                        VStack(spacing:0.0) {
                            Spacer()
                                .frame(width: contentWidth1, height: 1)
                                .background(tierColor_dark.opacity(0.35))
                            
                            HStack(spacing: geoWidth*0.1) {
                                if !quest.isArchived {
                                    Button("보관",systemImage: "archivebox") {
                                        quest.isArchived = true
                                        quest.isHidden = false
                                    }
                                    .foregroundStyle(tierColor_dark)
                                }
                                else {
                                    Button("되돌리기") {
                                        quest.isArchived = false
                                        quest.isHidden = false
                                    }
                                    .foregroundStyle(tierColor_dark)
                                }
                                if !quest.isHidden {
                                    Button("숨김",systemImage: "eye.slash") {
                                        quest.isArchived = false
                                        quest.isHidden = true
                                    }
                                    .foregroundStyle(tierColor_dark)
                                }
                                else {
                                    Button("되돌리기") {
                                        quest.isArchived = false
                                        quest.isHidden = false
                                    }
                                    .foregroundStyle(tierColor_dark)
                                }
                                Button("휴지통",systemImage: "trash") {
                                    alert_inTrashCan.toggle()
                                }
                                .foregroundStyle(.red)
                            }
                            .frame(height: menuHeight*0.29)
                            .padding(.top, menuHeight*0.2)
                            .padding(.bottom, menuHeight*0.1)
                            .alert("퀘스트 '\(quest.name)' 를 삭제하시겠습니까?", isPresented: $alert_inTrashCan) {
                                Button("휴지통으로 이동") {
                                    alert_inTrashCan.toggle()
                                    popUp_questStatisticsInDetail.toggle()
                                    quest.isArchived = false
                                    quest.isHidden = false
                                    quest.inTrashCan = true
                                }
                                .foregroundStyle(.red)
                                Button("취소") {
                                    alert_inTrashCan.toggle()
                                }
                            } message: {
                                Text("삭제한 퀘스트는 휴지통으로 이동됩니다.")
                            }
                        }
                        .frame(width: geoWidth, height: menuHeight, alignment: .bottom)
                    }
                    
                }
                .frame(width: geoWidth, height: geoHeight, alignment: .top)
                .background(LinearGradient(colors: getGradientColorsOf(tier: quest.tier, type: 1), startPoint: .topLeading, endPoint: .bottomTrailing))
                .fullScreenCover(isPresented: $popUp_editQuest) {
//                    if let quest = selectedQuest {
                    EditQuest(
                        popUp_editQuest: $popUp_editQuest,
                        quest: quest,
                        questName: quest.name,
                        questDataType: DataType(rawValue: quest.dataType) ?? .hour ,
                        customDataTypeNotation:quest.customDataTypeNotation,
                        customDataTypeNotation_textField: quest.customDataTypeNotation ?? "",
                        addSubName: quest.subName != nil,
                        questSubname: quest.subName ?? "",
                        addPastCumulative: quest.pastCumulatve != 0,
                        pastCumulative: quest.pastCumulatve/60,
                        pastCumulative_str: String(quest.pastCumulatve/60)
                    )
//                    }
                }
                .overlay {
//                        if let quest = selectedQuest {
//                            NavigationLink(destination: EditQuest(
//                                popUp_editQuest: $popUp_editQuest,
//                                quest: quest,
//                                questName: quest.name,
//                                questDataType: DataType(rawValue: quest.dataType) ?? .hour ,
//                                customDataTypeNotation:quest.customDataTypeNotation,
//                                customDataTypeNotation_textField: quest.customDataTypeNotation ?? "",
//                                addSubName: quest.subName != nil,
//                                questSubname: quest.subName ?? "",
//                                addPastCumulative: quest.pastCumulatve != 0,
//                                pastCumulative: quest.pastCumulatve,
//                                pastCumulative_str: String(quest.pastCumulatve)
//                            )
//                                .
//                            ) {
//                                Image(systemName: "square.and.pencil")
//                            }
//                            .padding(10)
//                            .frame(width: geoWidth,height: geoHeight, alignment: .topTrailing)
//                            .zIndex(3)
//                            .buttonStyle(.plain)
//                        }
                    if let quest = selectedQuest {
                        
                        if !quest.inTrashCan {
                            Button(action:{popUp_editQuest.toggle()}) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundStyle(tierColor_dark)
                            }
                            .padding(10)
                            .frame(width: geoWidth,height: geoHeight, alignment: .topTrailing)
                            //                        .zIndex(3)
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            else {
                Spacer()
                
            }

        }
    }
}


struct QuestMemo: View {
    @Environment(\.modelContext) var modelContext
    
    @State var quest: Quest
    
    @FocusState var editing: Bool
    
    @Binding var keyBoardAppeared: Bool
    
    var body: some View {
        VStack {
            if editing {
                Button("완료") {
                    editing = false
                }
                .buttonStyle(QuestMemoButtonStyle(quest.tier))
                .padding(.top, 10)
            } else {
                Image(systemName: "note.text")
                    .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                    .padding(.top, 10)
            }
            TextEditor(text: $quest.memo)
                .textEditorStyle(.plain)
                .focused($editing)
            //            .opacity(0.5)
        }
        .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
        .background(.ultraThinMaterial.opacity(0.5))
        .onChange(of: editing) { oldValue, newValue in
            keyBoardAppeared = editing
        }
    }
}

struct QuestMemoButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    var tier:Int

    init(_ tier: Int) {
        self.tier = tier
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal,10)
            .foregroundStyle(getBrightTierColorOf(tier: tier))
            .background(getDarkTierColorOf(tier: tier))
            .clipShape(.buttonBorder)

    }
}

struct QuestStatistics_inTerm: View {
    @Environment(\.modelContext) var modelContext
    
    var selectedQuest: Quest
    
//    @State var start: Date = Date()
//    @State var end: Date = Date()
    @State var maxValue: Int = 0

    
    @State var termOption: Int = 0
    
    @State var rawSelectedDate: String? = nil

//    var selectedDate: Date? {
//      guard let rawSelectedDate else { return nil }
//        return selectedQuest.dailyData.ke.first?.sales.first(where: {
//            let endOfDay = endOfDay(for: $0.day)
//            return ($0.day ... endOfDay).contains(rawSelectedDate)
//        })?.day
//    }
    
    
    let option_int: [Int] = [7,14,30,90,180,365,-1]
//    let option_kor: [String] = ["1주일","2주일","1개월","3개월", "6개월", "1년", "전체"]
    
    @State var selectedOption: Int = 30
    
    
    var body: some View {
        
        let tierColor_dark: Color = getDarkTierColorOf(tier: selectedQuest.tier)
        let tierColor_bright: Color = getBrightTierColorOf2(tier: selectedQuest.tier)
                
        if selectedQuest.dailyData.count == 0 {
            Text("데이터가 존재하지 않습니다.")
                .foregroundStyle(tierColor_dark)
        }
        else {
            
            
            
//            let chartData:[Date:Int] = selectedQuest.dailyData.filter({$0.key >= start && $0.key <= end})
            let chartData:[Date:Int] = selectedQuest.dailyData.filter({selectedOption == -1 ? true : calculateDaysBetweenTwoDates(from: $0.key, to: getStandardDateOfNow())  < selectedOption })
            let maxValue:Int = selectedQuest.dailyData.values.max() ?? 0
            
            
            
            GeometryReader { geometry in
                let geoWidth: CGFloat = geometry.size.width
                let geoHeight: CGFloat = geometry.size.height
                let contentWidth: CGFloat = geoWidth*0.8
                VStack(spacing:0.0) {
                    
//                    Spacer()
//                        .frame(height:geoHeight*0.05)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(tierColor_dark)
                        .padding(10)
                    
                    if selectedQuest.dataType != DataType.ox.rawValue {
                        
                        Chart {
                            ForEach(chartData.sorted(by: <), id:\.key) { item in
                                
                                if chartData.count < 10 {
                                    PointMark(
                                        x: .value("Date", yymmddFormatOf(standardDateToLocalStartOfDay(std: item.key))),
                                        y: .value("Profit A",  item.value)
                                    )
                                    .foregroundStyle(tierColor_dark)
                                }
                                
                                LineMark(
                                    x: .value("Date", yymmddFormatOf(standardDateToLocalStartOfDay(std: item.key))),
                                    //                        x: .value("Date", item.key),
                                    y: .value("Profit A",  item.value),
                                    series: .value("Company", "A")
                                )
                                .foregroundStyle(tierColor_dark)
                                
                            }
                            if let rawSelectedDate {
                                RuleMark(
                                    x: .value("Selected", rawSelectedDate)
                                )
                                .foregroundStyle(tierColor_bright.colorExpressionIntegration())
                                .offset(yStart: -20)
                                .annotation(
                                    position: .automatic, spacing: 0,
                                    overflowResolution: .init(
                                        x: .fit(to: .chart),
                                        y: .disabled
                                    )
                                ) {
                                    VStack {
                                        Text(rawSelectedDate)
                                        Text("\(DataType.string_fullRepresentableNotation(data: chartData[convertToDate(from: rawSelectedDate) ?? .now] ?? 0, dataType: dataTypeFrom(selectedQuest.dataType),customDataTypeNotation:selectedQuest.customDataTypeNotation))")
                                    }
                                    .padding(5)
                                    .foregroundStyle(tierColor_dark)
                                    .background(tierColor_bright.colorExpressionIntegration())
                                    .clipShape(.buttonBorder)
                                }
                            }
                            
                            
                        }
                        .chartYAxis(.visible)
                        .chartXAxis(.visible)
                        .chartXAxis {
                            AxisMarks() { value in
                                AxisTick()
                                    .foregroundStyle(tierColor_dark)
                                //                                .font(tierColor_dark)
                                AxisGridLine()
                                    .foregroundStyle(tierColor_dark)
                            }
                        }
                        .chartYAxis {
                            AxisMarks() { value in
                                if let valueAsInt = value.as(Int.self) {
                                    
                                    AxisValueLabel {
//                                        if selectedQuest.dataType == DataType.hour.rawValue {
//                                            Text("\(DataType.string_fullRepresentableNotation(data: valueAsInt, dataType: DataType.hour) )")
//                                        }
//                                        else {
                                            Text("\(valueAsInt)")
//                                        }
                                        
                                    }
                                    .foregroundStyle(tierColor_bright)
                                    
                                }
                            }
                            
                        }
                        .padding(contentWidth*0.05)
                        .frame(width:contentWidth, height: geoHeight*0.4)
                        .foregroundStyle(tierColor_bright)
                        .background(tierColor_dark)
                        .chartXSelection(value: $rawSelectedDate)
                        
                    }
                    else {
                        Text("해당 퀘스트는 그래프 통계를 제공하지 않습니다.")
                            .frame(width:contentWidth, height: geoHeight*0.35)
                            .foregroundStyle(tierColor_bright)
                            .background(tierColor_dark)

                    }
                    Picker("", selection: $selectedOption) {
                        ForEach(option_int, id:\.self) { value in
                            if value == 7 {
                                Text("최근 1주일")
                            }
                            else if value == 14 {
                                Text("최근 2주일")
                            }
                            else if value == 30 {
                                Text("최근 1개월")
                            }
                            else if value == 90 {
                                Text("최근 3개월")
                            }
                            else if value == 180 {
                                Text("최근 6개월")
                            }
                            else if value == 365 {
                                Text("최근 1년")
                            }
                            else if value == -1{
                                Text("전체")
                            }
                        }
                    }
                    .frame(width:contentWidth)
                    .padding(.top, geoHeight*0.02)
                    VStack {
                        
                        let cumulative_term : Int = sumIntArray(Array(chartData.values))
                        let cumulative_representation: String = {
                            if selectedQuest.dataType == DataType.ox.rawValue {
                                return ""
                            }
                            else {
                                return "(누적 \(DataType.string_fullRepresentableNotation(data: cumulative_term, dataType: dataTypeFrom(selectedQuest.dataType), customDataTypeNotation: selectedQuest.customDataTypeNotation)))"
                            }
                            
                        }()
                        Text("기록 횟수: \(chartData.count) \(cumulative_representation)")
                            .frame(width:contentWidth,alignment:.leading)

                        let term: Int = {
                            if chartData.count == 0 {
                                return 0
                            }
                            else {
                                let start = chartData.keys.sorted().first!
                                let end = chartData.keys.sorted().last!
                                
                                let term_inData:Int = calculateDaysBetweenTwoDates(from: start, to: end) + 1
                                return term_inData
//                                if term_inData < selectedOption {
//                                    return term_inData
//                                }
//                                else {
//                                    return selectedOption
//                                }
                            }
                        }()
                        let average_term: String = {
                            if chartData.count == 0 || selectedQuest.dataType == DataType.ox.rawValue {
                                return ""
                            }
                            
                            else if selectedQuest.dataType == DataType.hour.rawValue {
                                let average: Int = cumulative_term/term
                                return "(\(DataType.string_fullRepresentableNotation(data: average, dataType: DataType.hour)))"
                            }
                            else {
                                let average: CGFloat = CGFloat(cumulative_term)/CGFloat(term)
                                return "(\(String(format: "%.1f", average)) \(DataType.unitNotationOf(dataType: dataTypeFrom(selectedQuest.dataType), customDataTypeNotation: selectedQuest.customDataTypeNotation)  ))"
                            }
                            
                        }()
                        let averageTermToExecute: CGFloat = CGFloat(term)/CGFloat(chartData.count)
                        Text("평균 실행 간격: \(String(format: "%.1f", averageTermToExecute))일 \(average_term)")
                            .frame(width:contentWidth,alignment:.leading)
                    }
                    .padding(.vertical,geoHeight*0.05)
                    .foregroundStyle(tierColor_dark)
                    
                }
                .frame(width:geoWidth, height: geoHeight, alignment: .top)
//                .onAppear() {
//                    start = selectedQuest.dailyData.keys.sorted().first ?? Date()
//                    end = selectedQuest.dailyData.keys.sorted().last ?? Date()
//                    print("chart appeared")
//                    print(chartData)
//                }
                .foregroundStyle(tierColor_dark)
            }
        }

    }
}




struct SerialVisualization:View {
    
    var data: [Date:Int]
    var tier: Int
    
    var body: some View {
            
        // withFirstDate and EndDate in One row -> 말일:오, 1:왼, ~말일-1:아래, 2~:아래
        // 다른 row -> 말일있는 모든 row: 아래 , 시작일있는 모든 row: 위
        
        // 캘린터 형태, 기록한 날은 색칠 되어 있음
        // 일월화수목금토일 정렬
        // 클릭 시에 날짜와 기록수치 나타남
        // 날짜는 시작 날짜와 끝날짜면 조그맣게 나와있음
        
        // TODO: 클릭 시 그 날 날짜와 상세 데이터 출력, 클릭 시 해당 블럭 커짐.
        // TODO: 1달과 1년 구분해서 border 넣기, 미래의 2주정도를 희미하게 넣기

        // MARK: 나중에 오늘 날짜를 end로 잡고 싶으면 바꿔주기
        let date_partition: [[Date]] = data.count != 0 ? partitionByWeek(startDate: data.keys.sorted().first!, endDate: data.keys.sorted().last!) : []
//        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let elementSize: CGFloat = geoWidth/7
            
            VStack(spacing:0.0) {
                                
                let firstRow:[Date]? = date_partition.first
                let lastRow:[Date]? = date_partition.last
                
                

                switch date_partition.count {
                case 0:
                    Spacer()
                case 1:
                        
                    let doneList_firstRow: [Bool] = firstRow!.map{data.keys.contains($0)}
                    RowContent(dates:firstRow!,doneList:doneList_firstRow, isFirst: true, tier: tier)
                        .frame(width:elementSize*7, height: elementSize)
                        .zIndex(containsFirstDateOfMonth(dates: firstRow!) ? 2 : 1)
                    
                default:
                    let middleRows:[[Date]] = {
                        var a = date_partition
                        a.removeFirst()
                        a.removeLast()
                        return a
                    }()
                    
                    
                    let doneList_firstRow: [Bool] = firstRow!.map{data.keys.contains($0)}
                    RowContent(dates:firstRow!,doneList:doneList_firstRow, isFirst: true, tier: tier)
                        .frame(width:elementSize*7, height: elementSize)
                        .zIndex(containsFirstDateOfMonth(dates: firstRow!) ? 2 : 1)



                    ForEach(middleRows, id:\.self) { row in
                        let doneList: [Bool] = row.map{data.keys.contains($0)}
                        RowContent(dates:row,doneList:doneList, tier:tier)
                            .frame(width:elementSize*7, height: elementSize)
                            .zIndex(containsFirstDateOfMonth(dates: row) ? 2 : 1)

                    }
                    
                    let doneList_lastRow: [Bool] = lastRow!.map{data.keys.contains($0)}
                    RowContent(dates:lastRow!,doneList:doneList_lastRow, isLast: true, tier:tier)
                        .frame(width:elementSize*7, height: elementSize)
                        .zIndex(containsFirstDateOfMonth(dates: lastRow!) ? 2 : 1)

                }
                
                
                
                
            }
            .frame(width:geoWidth)
        }
        .onAppear() {
            print(date_partition)
            print(data.sorted(by: { keyval1, keyval2 in
                keyval1.key < keyval2.key
            }))
        }
    }
}



struct RowContent: View {
    
    @Environment(\.colorScheme) var colorScheme

    
    var dates: [Date]
    var doneList: [Bool]
    
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var tier: Int
    


    
    var body: some View {
        let elementCnt: Int = dates.count
        
        let startOfMonthIndex: Int? = dates.firstIndex(where: {$0.isStartOfMonth_local})
        let isMonthChangingRow: Bool = containsFirstDateOfMonth(dates: dates)
        
        let startOfMonthIndexIsNonzero: Bool = {
            if !isMonthChangingRow {
                return false
            }
            else {
                return startOfMonthIndex != 0
            }
        }()
        
        let containsStartAndEnd: Bool = isMonthChangingRow && startOfMonthIndexIsNonzero
        
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let contentColor: Color = colorScheme == .light ? colorSchemeColor.adjust(brightness: -0.05) : colorSchemeColor
        
        let tierColor_dark: Color = getDarkTierColorOf(tier: tier)
        let tierColor_bright: Color = getBrightTierColorOf2(tier: tier)
        let gradiant_done: LinearGradient = LinearGradient(colors: getGradientColorsOf(tier: tier, type: 2), startPoint: .topLeading, endPoint: .bottomTrailing)
        let gradiant_notDone: LinearGradient = LinearGradient(colors: [.gray.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)

        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let elementSize: CGFloat = geoHeight
            let elementsWidth: CGFloat = elementSize * CGFloat(elementCnt)


            ZStack {
                HStack(spacing:0.0) {
                    ForEach(0..<elementCnt, id:\.self) { index in
                        let date = dates[index]
                        let isDone = doneList[index]
                        let monthRepresentaion: Bool = date.isStartOfMonth_local || (isFirst&&index==0)
                        ZStack {
                            Spacer()
                                .background(isDone ? gradiant_done: gradiant_notDone)
                                .blur(radius: 0.5)
                            
                            if monthRepresentaion {
                                Text(yymmFormatOf(date))
                                    .font(.caption2)
                                    .opacity(0.3)
                                    .padding(.bottom, 5)
                                    .frame(width:elementSize, height: elementSize, alignment: .bottom)

                            }
                            Text(ddFormatOf(date))
                                .font(.caption2)
                                .opacity(0.7)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                                .frame(width:elementSize, height: elementSize, alignment: .topLeading)
                                .foregroundStyle(isDone ? tierColor_dark : tierColor_bright)

                        }
                        .frame(width:elementSize, height: elementSize)
//                        .background(isDone ? gradiant_done: gradiant_notDone)
                    }
                }
                .frame(width:geoWidth, height: geoHeight, alignment: isFirst ? .trailing : .leading)
//                .frame(width:geoWidth, height: geoHeight)

                if isMonthChangingRow && containsStartAndEnd {
                    
                    let startPos: CGFloat = isFirst ? geoWidth - elementsWidth : 0
                    let conversionPos: CGFloat = startPos + elementSize * CGFloat(startOfMonthIndex!)
                    let endPos: CGFloat = isLast ? elementsWidth : geoWidth
                    
                    Path { path in
                        path.move(to: CGPoint(x: startPos, y: geoHeight))
                        path.addLine(to: CGPoint(x: conversionPos, y: geoHeight))
                        path.addLine(to: CGPoint(x: conversionPos, y: 0))
                        path.addLine(to: CGPoint(x: endPos, y: 0))
                    }
                    .stroke(tierColor_dark, lineWidth: 3)
                    
                    

                }
                else if isMonthChangingRow && !containsStartAndEnd {
                    let startPos: CGFloat = isFirst ? geoWidth - elementsWidth : 0
                    let endPos: CGFloat = isLast ? elementsWidth : geoWidth

                    Path { path in
                        path.move(to: CGPoint(x: startPos, y: 0))
                        path.addLine(to: CGPoint(x: endPos, y: 0))
                    }
                        .stroke(tierColor_dark, lineWidth: 3)


                }
                
                
            }
            .frame(width:geoWidth, height: geoHeight)
        }

    }
        
}




//let dateExample:Date = Calendar.current.startOfDay(for: Date())
//let calendarCurrent = Calendar.current
//let datesExample:[Date] = [
////    Calendar.current.date(byAdding: .day, value:-30, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-29, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-28, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-27, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-26, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-25, to: dateExample)!,
////    Calendar.current.date(byAdding: .day, value:-24, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-23, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-22, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-21, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-20, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-19, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-18, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-17, to: dateExample)!,
//]
//let doneListExample: [Bool] = [
//    true,
//    false,
//    true,
//    true,
//    false,
//    true,
//    false
//]
//
////#Preview(body: {
////    RowContent(dates: datesExample, doneList: doneListExample, tier:1)
////        .frame(width:210, height: 30)
////})
//


struct EditQuest: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @Query var quests: [Quest]
        
    @Binding var popUp_editQuest: Bool
    // isPlan, popUp
    var quest: Quest
    @State var questName: String
    @State var questDataType: DataType
    @State var customDataTypeNotation: String?
    @State var customDataTypeNotation_textField: String
    @State var addSubName: Bool
    @State var questSubname: String
    @State var addPastCumulative: Bool
    @State var pastCumulative: Int
    @State var pastCumulative_str:String
    @State var showSubnameHelp: Bool = false
    
    @FocusState var focusedTextField: Int?
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let textBoxWidth = geometry.size.width * 0.35
            let textBoxWidth2 = geometry.size.width * 0.3
            let textFieldWidth = geoWidth * 0.4
            let textFieldWidth2 = geoWidth * 0.5
            let textBoxHeight = geometry.size.height * 0.15
            let messageBoxHeight = geometry.size.height * 0.1
            
            let contentHeight = geometry.size.height*0.9
            
            let questNames:[String] = quests.filter({!$0.inTrashCan}).map{$0.name}.filter({$0 != quest.name})
            
//            ZStack {
                                
                VStack(alignment: .leading) {
                    HStack {
                        Button("취소",systemImage: "chevron.left") {
                            popUp_editQuest.toggle()
                        }
                        .padding(20)
                        .frame(width: geoWidth/4, alignment: .leading)
                        Text("퀘스트 정보 수정")
                            .frame(width: geoWidth/2, alignment: .center)
                        Button(action:saveQuestInfo) {
                                Text("저장")
                        }
                        .padding(20)
                        .frame(width: geoWidth/4, alignment: .trailing)
                        .disabled(
                            questNames.contains(questName) ||
                            (questDataType == .custom &&
                            (customDataTypeNotation == "" || customDataTypeNotation == nil)) ||
                            questName == ""
                        )
                        
                    }

                    
                    HStack {
//                        Text("이름:")
//                            .frame(width:textBoxWidth,alignment: .trailing)
//                            .font(.title3)
                        TextField("퀘스트 이름", text:$questName)
                            .tag(0)
                            .font(.title2)
                            .maxLength(30, text: $questName)
                            .multilineTextAlignment(.center)
                            .focused($focusedTextField, equals:0)
                            .textFieldStyle(.roundedBorder)
//                            .shadow(radius: 1)
                        
                    }
                    .padding(.horizontal)
                    .frame(width: geometry.size.width)
                    //                                .frame(height: textBoxHeight)
                    

                        
                    if questName == "" {
                        Text("퀘스트 이름을 입력하세요")
                            .frame(width: geometry.size.width)
                            .foregroundStyle(.red)
                            .font(.caption)
                            
                        }
                    else if questNames.contains(questName) {
                        Text("퀘스트 이름이 이미 존재합니다.")
                            .frame(width: geometry.size.width, height: 20)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    if questDataType == DataType.custom {
                        HStack(spacing:0.0) {
//                            Spacer()
//                                .frame(width:checkBoxWidth)
//                                .border(.yellow)

                            Text("사용자 지정 단위")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width:textBoxWidth,alignment: .leading)
                                .multilineTextAlignment(.leading)
//                                    .padding(.horizontal)

                            TextField("예시: 푸시업 -> n회",text: $customDataTypeNotation_textField)
                                .frame(width: textFieldWidth2)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedTextField, equals:1)
                                .onChange(of: customDataTypeNotation_textField) {
                                    customDataTypeNotation = customDataTypeNotation_textField
                                }
                        }
                        .padding(.horizontal)
                        .frame(alignment: .leading)
//                        .border(.red)

                    }
                    
                    
                    HStack(spacing:0.0) {
                        HStack(spacing:0.0) {

                            Button(action:{
                                addSubName.toggle()
                                focusedTextField = 2
                                
                            }) {
                                Image(systemName: addSubName ? "checkmark.square" : "square")
                            }
                            //                        .border(.yellow)
                            
                            
                            Text("줄임말")
                                .padding(.leading, 3)
                                .padding(.trailing,30)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: textBoxWidth2, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .opacity(addSubName ? 1.0 : 0.5)
                            //                            .border(.blue)
                        }
                        .frame(width: textBoxWidth, alignment: .leading)

//                        .padding(.horizontal)
                        
                        TextField("퀘스트를 요약할 이름", text: $questSubname)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .focused($focusedTextField, equals:2)
                            .disabled(!addSubName)
                            .opacity(addSubName ? 1.0 : 0.2)


                        Button(action:{
                            showSubnameHelp.toggle()
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                        .padding(.leading)
                        .popover(isPresented: $showSubnameHelp, content: {
                            Text("줄임말 설정 시 퀘스트 상세 창을 제외한 모든 화면에서 줄임말로 표시됩니다.")
                                .padding(.horizontal)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .presentationCompactAdaptation(.popover)
                        })


                        

                    }
                    .padding(.horizontal)

//                    .border(.red)


                        
                    HStack(spacing:0.0) {
                        
                        HStack(spacing:0.0) {
                            
                            Button(action:{
                                addPastCumulative.toggle()
                                focusedTextField = 3
                                
                            }) {
                                Image(systemName: addPastCumulative ? "checkmark.square" : "square")
                            }
                            //                        .border(.yellow)
                            
                            
                            Text("과거 누적량")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: textBoxWidth2, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .opacity(addPastCumulative ? 1.0 : 0.5)
                        }
                        .frame(width: textBoxWidth, alignment: .leading)
//                        .padding(.horizontal)

                        TextField("생성 이전의 누적량", text: $pastCumulative_str)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .disabled(!addPastCumulative)
                            .opacity(addPastCumulative ? 1.0 : 0.0)
                            .focused($focusedTextField, equals:3)
                            .keyboardType(.numberPad)
                        if addPastCumulative {
                            Text(DataType.unitNotationOf(dataType: questDataType, customDataTypeNotation: customDataTypeNotation_textField))
                                .opacity(addPastCumulative ? 1.0 : 0.2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.leading)
                        }
                    }
                    .padding(.horizontal)
//                    .border(.red)
                    .frame(width: geoWidth, alignment: .leading)
//                    .border(.yellow)


                    
                    

                    
                    
                } // Vstack
                .padding()
                .frame(width:geometry.size.width, height:contentHeight, alignment: .top)
                
                
                

                
                
//            }// Zstack
//            .frame(width:geometry.size.width, height: contentHeight)
//            .navigationTitle("새로운 퀘스트")
//            .navigationBarTitleDisplayMode(.inline)

            .onAppear() {
                focusedTextField = 0
            }
//            .onChange(of: customDataTypeNotation) { oldValue, newValue in
//                if customDataTypeNotation == DataType.CUSTOM {
//
//                }
//            }
            
        }
    }
    
    func saveQuestInfo() -> Void {
        
        // change related data (dailyQuest, notification, activity(later) )
        
        let oldName = quest.name
        let oldSubName = quest.subName
        let oldGetName = oldSubName ?? oldName
        let newName = questName
        let newSubName = addSubName ? questSubname : nil
        let newGetName = newSubName ?? newName
        
        let predicate = #Predicate<DailyQuest> { dailyQuest in
            dailyQuest.questName == oldName
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        try! modelContext.enumerate(
            descriptor,
            batchSize: 5000,
            allowEscapingMutations: false
        ) { dailyQuest in
            if let alermTime = dailyQuest.notfTime {
                if alermTime > Date() && oldGetName != newGetName {
                    removeNotification(at: alermTime, for: oldGetName)
                    scheduleNotification(at: alermTime, for: newGetName, goal: dailyQuest.dailyGoal, dataType: dailyQuest.dataType, customDataTypeNotation: dailyQuest.customDataTypeNotation)
                }
            }
            dailyQuest.questName = newName
            if addSubName {
                dailyQuest.questSubName = newSubName
            } else {
                dailyQuest.questSubName = nil
            }
            if questDataType == .custom { dailyQuest.customDataTypeNotation = customDataTypeNotation }

        }
        

        
        
        quest.name = newName
        if addSubName { quest.subName = newSubName }
        else { quest.subName = nil }
        if questDataType == .custom { quest.customDataTypeNotation = customDataTypeNotation }
        if addPastCumulative {
            if let pastCumulatve = Int(pastCumulative_str) {
                if questDataType == .hour {
                    quest.pastCumulatve = pastCumulatve * 60
                }
                else {
                    quest.pastCumulatve = pastCumulatve
                }
            }
        }
        quest.updateTier()
        
        
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.questName == oldGetName }) {
            
            let startTime = targetActivity.attributes.startTime
            let containedDate = targetActivity.attributes.containedDate
            let tier = targetActivity.attributes.tier
            let dailyGoal = targetActivity.content.state.goal
            
            let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
            Task {
                await targetActivity.end(ActivityContent(state: targetActivity.content.state, staleDate: nil), dismissalPolicy: dismissalPolicy)
            }
            
            let attributes = RecoraddicActivityAttributes(questName: newGetName, startTime:startTime, containedDate:containedDate, tier: tier)
            let initialContentState = RecoraddicActivityAttributes.ContentState(goal: dailyGoal)
            do {
                let activity = try Activity<RecoraddicActivityAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: initialContentState, staleDate: nil),
                    pushType: nil
                )
            } catch {
                print("Failed to rename activity: \(error.localizedDescription)")
            }
            
        }
     
        
        popUp_editQuest.toggle()
        
    }
    
    
}


