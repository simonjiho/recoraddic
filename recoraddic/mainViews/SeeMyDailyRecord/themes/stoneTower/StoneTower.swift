//
//  Records_StoneTower.swift
//  recoraddic
//
//  Created by 김지호 on 1/25/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: debugger 연결되어있으면 렉 발생, debugger 끊기면 렉없이 잘됨(23.03.09, ios17.4, xcode15.3 기준)
// Don't put variable, 최대한 let으로 이용하기, 특히 computed property 이용 금지 (너무 무거움)


// TODO: 글씨 색도 stonecolor에 맞춰서.
struct StoneTower: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    
    @Binding var dailyRecordSet:DailyRecordSet
//    @Binding var dailyRecordSet:DailyRecordSet
    @Binding var selectedDailyRecordSetIndex: Int
    @Binding var selectedRecord: DailyRecord?
    @Binding var popUp_startNewRecordSet: Bool
    @Binding var popUp_recordInDetail: Bool
    @Binding var popUp_changeStyle: Bool
    @Binding var isEditingTermGoals: Bool
    @Binding var undoNewDRS: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    
    let prevDRS_start: Date?
    let nextDRS_start: Date?
    let startRange: ClosedRange<Date>
    let endRange: ClosedRange<Date>
    
//    let selectedDailyRecordSetIndex: Int
    
    
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
    
    
    var body: some View {

        let dailyRecords_visible: [DailyRecord] = dailyRecordSet.visibleDailyRecords()
        
        let numberOfStones: Int  = dailyRecords_visible.count
        



        
        let defaultColorIndex:Int = dailyRecordSet.dailyRecordColorIndex



        let lastIndexOfRecordStone:Int = numberOfStones == 0 ? 0 : numberOfStones - 1
        
//        let statusBarHeight:CGFloat = getStatusBarHeight()

        let shadowColor: Color = getShadowColor(colorScheme)

        GeometryReader { geometry in
            
            let haveSelectedRecord: Bool = {
                if selectedRecord == nil {
                    return false
                }
                else {
                    return dailyRecords_visible.contains(selectedRecord!)
                }
            }() //MARK: 다른기기에서 selectedRecord에 할당된 데이터를 지워 cloud상에서 삭제되었음에도, view의 selectedRecord에 할당되어 있을 때
            
            let geoWidth:CGFloat = geometry.size.width
            let geoHeight:CGFloat = geometry.size.height
            
            let stoneWidth:CGFloat = geoWidth*0.22
            let stoneHeight:CGFloat = stoneWidth*0.67
            let selectedStoneHeight:CGFloat = stoneHeight*1.4
            let selectedStoneWidth:CGFloat = stoneWidth*1.4
            let heightGap:CGFloat = haveSelectedRecord ? (selectedStoneHeight - stoneHeight) : 0.0
            let horizontalUnitWidth:CGFloat = stoneWidth*0.07 // 최대 *9번 갈 수 있음( calculateVisualValue3() 에서)
            let questionMarkSize: CGFloat = geoWidth*0.05
            
            let groundHeight:CGFloat = geoHeight/2 - stoneHeight/2
            let towerHeight:CGFloat = stoneHeight*CGFloat(numberOfStones) + heightGap
            let groundAndTowerHeight:CGFloat = groundHeight + towerHeight
            let aboveSkyHeight:CGFloat = (groundAndTowerHeight-stoneHeight/2 > geoHeight/2 ? (geoHeight/2 - stoneHeight/2) : geoHeight - groundAndTowerHeight) - heightGap
            let totalSkyHeight:CGFloat = aboveSkyHeight + towerHeight

            let buttonWidth:CGFloat = geoWidth*0.25
            let buttonWidth2:CGFloat = geoWidth*0.1
            
            let detailTextBoxSize: CGFloat = geoWidth*0.25
            
            let scrollViewCenter_bottom:CGFloat = scrollViewCenterY + stoneHeight
            let scrollViewCenter_above:CGFloat = scrollViewCenterY - stoneHeight
            
            let isLatestDailyRecordSet: Bool = dailyRecordSet == dailyRecordSets.last
            
            let goalEditButtonSize:CGFloat = groundHeight/10
            let plusMinusButtonSize:CGFloat = groundHeight/12
            
            
            ScrollViewReader { scrollProxy in
                
                ScrollView {
                    
                    GeometryReader { geometry2 in // for preferenceKey
                        ZStack {
                            StoneTowerBackground(
                                backgroundThemeName: dailyRecordSet.backgroundThemeName,
                                totalSkyHeight: totalSkyHeight,
                                groundHeight: groundHeight + keyboardHeight,
                                displayHeight: geoHeight
                            )
                            .frame(height: totalSkyHeight + groundHeight + keyboardHeight)
                            .onTapGesture {
                                selectedRecord = nil
                            }

                                
                                // stone
                            VStack(spacing:0) { // -> 얘를 다 주석처리해도 compiler type-check error 남. 다른 바깥 부분의 문제일지도
                                Spacer()
                                    .frame(width:geoWidth, height: aboveSkyHeight)
                                if numberOfStones != 0 {
                                    
                                    ForEach((0...lastIndexOfRecordStone).reversed(), id:\.self) { index in
                                        
                                        
                                        let record:DailyRecord = dailyRecords_visible[index]
                                        
                                        let isSelectedRecord:Bool = {
                                            if selectedRecord == nil { return false }
                                            else {
                                                if selectedRecord == record { return true }
                                                else { return false}
                                            }
                                        }()
                                        
                                        let width:CGFloat = isSelectedRecord ? selectedStoneWidth : stoneWidth
                                        let height:CGFloat = isSelectedRecord ? selectedStoneHeight : stoneHeight
                                        
                                        
                                        //MARK: 세번째 geometryreader -> 너무 많이 메모리 잡아먹으면 그냥 위에거처럼 계산해서 쓰자
                                        GeometryReader { geometry3 in
                                            
                                            let centerY:CGFloat = geometry3.frame(in: .named("ZStack")).midY
                                            let lowerBound:CGFloat = centerY - height/2
                                            let upperBound:CGFloat = centerY + height/2
                                            
                                            
                                            let isOnCenter:Bool = scrollViewCenterY > lowerBound && scrollViewCenterY < upperBound
                                            let isNearCenter:Bool = (scrollViewCenter_above > lowerBound && scrollViewCenter_above < upperBound) || (scrollViewCenter_bottom > lowerBound && scrollViewCenter_bottom < upperBound)
                                            
                                            let shapeNum:Int = shapeNum(record.recordedMinutes)
                                            let brightness:Int = brightness(record.recordedAmount)
                                            

                                            let misalignment:Int = misalignment(record.absence, index)
                                            let heat:Int = heatNum(record.streak)
                                            
                                            ZStack {
                                                StoneTower_stone(
                                                    shapeNum: shapeNum,
                                                    brightness: brightness,
                                                    defaultColorIndex: defaultColorIndex,
                                                    facialExpressionNum: record.mood,
                                                    selected: isSelectedRecord
                                                )
                                                .frame(width: width, height: height)
                                                .padding(.leading, geoWidth/2 - width/2 + CGFloat(misalignment)*horizontalUnitWidth)
                                                .padding(.trailing, geoWidth/2 - width/2 - CGFloat(misalignment)*horizontalUnitWidth)
                                                .padding(.vertical, 0)
                                                .onTapGesture {
                                                    if isSelectedRecord {
                                                        popUp_recordInDetail.toggle()
                                                    }
                                                    else {
                                                        selectedRecord = dailyRecords_visible[index]
                                                        withAnimation {
                                                            scrollProxy.scrollTo(record.getLocalDate(), anchor:.center)
                                                        }
                                                    }
                                                }
                                                
                                                Text(yyyymmddFormatOf(record.getLocalDate()!))
                                                    .bold(isSelectedRecord)
                                                    .font(.caption)
                                                    .opacity(isOnCenter ? 1.0 : (isNearCenter ? 0.3 : 0.0))
                                                    .position(x: misalignment <= 0 ? geoWidth*0.77 : geoWidth*0.23, y: height/2)
                                                
                                                VStack {
                                                    if record.dailyText != nil {
                                                        Image(systemName: "book.closed.fill")
                                                    }
                                                    Text_hours(value: record.recordedMinutes)
                                                    Text("\(record.recordedAmount) 개의 기록")
                                                }
                                                .frame(width:detailTextBoxSize, alignment: misalignment <= 0 ? .trailing : .leading)
//                                                .border(.red)
                                                .bold(isSelectedRecord)
                                                .font(.caption)
                                                .opacity(isSelectedRecord ? 1.0 : 0.0)
//                                                .opacity(isOnCenter ? (isSelectedRecord ? 1.0 : 0.5) : 0.0)
                                                .position(x: geoWidth*0.5 + (misalignment <= 0 ? -1.0 : 1.0) * (selectedStoneWidth*0.5 + geoWidth*0.00 + detailTextBoxSize*0.5) + CGFloat(misalignment)*horizontalUnitWidth, y: height/2)
//                                                .position(x: misalignment <= 0 ? geoWidth*0.23 : geoWidth*0.77, y: height/2)

                                                
                                                
                                            }
                                            .frame(height:height)
                                            
                                        }
                                        .frame(height:height)
                                        .id(record.getLocalDate())
                                        
                                        
                                        
                                    }
                                }
                                
                                
                                VStack(spacing:0.0) {
                                    
                                    HStack {
                                        Button(action:{
                                            
                                            selectedDailyRecordSetIndex -= 1
                                            isEditingTermGoals = false
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:geoWidth*0.12,height: groundHeight*0.1)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(selectedDailyRecordSetIndex == 0 || isEditingTermGoals)
                                        

                                        HStack {
                                            if dailyRecordSet.end != nil {
                                                DatePicker(
                                                    "",
                                                    selection: $startDate,
                                                    in: startRange,
                                                    displayedComponents: [.date]
                                                )
                                                .labelsHidden()
                                                .frame(width:geoWidth*0.25)
                                                
                                                Text("~")
                                                    .padding(.horizontal,5)
                                                DatePicker(
                                                    "",
                                                    selection: $endDate,
                                                    in: endRange,
                                                    displayedComponents: [.date]
                                                )
                                                .labelsHidden()
                                                .frame(width:geoWidth*0.25)
                                            }
                                            else {
                                                DatePicker(
                                                    "",
                                                    selection: $startDate,
                                                    in: startRange,
                                                    displayedComponents: [.date]
                                                )
                                                .labelsHidden()
                                                .frame(width:geoWidth*0.25)
                                                
                                                Text("~")
                                                    .padding(.horizontal,5)

                                            }

                                        }
                                        .frame(width:geoWidth*0.7, height:groundHeight*0.15, alignment: .center)
                                        Button(action:{
                                            selectedDailyRecordSetIndex += 1
                                        }) {
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:geoWidth*0.12, height: groundHeight*0.1)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(isLatestDailyRecordSet || isEditingTermGoals)

                                    }
                                    .frame(width:geoWidth, height:groundHeight*0.23)
                                    .padding(.bottom, groundHeight*0.07)


                                    VStack {
                                        if isEditingTermGoals {
                                            if editText.count != 0 {
                                                ForEach(0...editText.count - 1, id:\.self) { index in
                                                    HStack {
                                                        Text("\(index+1). ")
                                                        TextField("",text:$editText[index])
                                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                                            .frame(width:geoWidth*0.7, alignment:.leading)
                                                            .focused($editTermGoals, equals:index)
                                                            .onSubmit {
                                                                dailyRecordSet.termGoals = editText.filter({$0 != ""})
                                                                editTermGoals = nil
                                                                isEditingTermGoals.toggle()
                                                            }
                                                        
                                                        if index != 0 {
                                                            Button(action: {
                                                                if editTermGoals == index {
                                                                    if editTermGoals != 0 {
                                                                        editTermGoals = index - 1
                                                                    }
                                                                }
                                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { // if done just right after, it will lead index out of range error.
                                                                    editText.remove(at: index)
                                                                }
                                                                
                                                            }) {
                                                                Image(systemName: "x.circle")
                                                            }
                                                            .frame(width:plusMinusButtonSize, height:plusMinusButtonSize)
                                                            .buttonStyle(MainButtonStyle2(width: plusMinusButtonSize, height: plusMinusButtonSize))
                                                        }
                                                        else {
                                                            Spacer()
                                                            .frame(width:plusMinusButtonSize, height:plusMinusButtonSize)

                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        else {
                                            Group {
                                                if dailyRecordSet.termGoals.count != 0 {
                                                    ForEach(0...dailyRecordSet.termGoals.count-1, id:\.self) { index in
                                                        HStack {
                                                            Text("\(index+1). ")
                                                            Text(dailyRecordSet.termGoals[index])
                                                                .frame(width:geoWidth*0.7, alignment:.leading)
                                                            
                                                        }
                                                        .opacity(0.8)
                                                        .padding(.vertical,3)
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                else {
                                                    Text("목표를 적어보세요")
                                                        .opacity(0.3)
                                                }
                                            }
                                            .onTapGesture {
                                                editText = dailyRecordSet.termGoals
                                                if dailyRecordSet.termGoals.count == 0 {
                                                    editText.append("")
                                                }
                                                editTermGoals = editText.count - 1
                                                isEditingTermGoals.toggle()
                                            }
                                        
                                        }
                                        
                                        
                                        if isEditingTermGoals && editText.count <= 2 {
                                            Button(action:{
                                                editText.append("")
                                                editTermGoals? += 1
                                            }) {
                                                Image(systemName: "plus.circle")
                                            }
                                            .frame(width:plusMinusButtonSize, height:plusMinusButtonSize)
                                            .buttonStyle(MainButtonStyle2(width: plusMinusButtonSize, height: plusMinusButtonSize))
                                        }
                                    }
                                    .frame(height:groundHeight*0.55, alignment: .top)
                                    
                                    // 나중에 얘 ZStack으로 옮겨서 SeeMyRecord로 옮기고, viewModifier로 넣기?
                                
//                                        HStack(spacing:0.0) {
                                    Menu {
                                        Button("스타일 변경") { // 나중에 theme, theme별 선택 가능 요소(색,배경 등등들 다 바꿀 수 있게 하기
                                            popUp_changeStyle.toggle()
                                        }
                                        
//                                        Button (action:{
//                                            editText = dailyRecordSet.termGoals
//                                            if editText.isEmpty {
//                                                editText.append("")
//                                            }
//                                            isEditingTermGoals.toggle()
//                                            editTermGoals = editText.count - 1
//                                            
//                                        }) {
//                                            let noTermGoals = dailyRecordSet.termGoals.count == 0
//                                            Text("목표 \(noTermGoals ? "설정" : "편집")")
//                                        }
//                                        .disabled(isEditingTermGoals)
                                        

                                        if isLatestDailyRecordSet {
                                            Button(action: {
                                                popUp_startNewRecordSet.toggle()
                                            }) {
                                                Text("새로운 기록의 탑 생성")
//                                                            .minimumScaleFactor(0.5)
                                            }


                                        }
                                        
                                    } label: {
                                        Button(action:{}) {
                                            Image(systemName:"line.3.horizontal")

                                        }
                                        .buttonStyle(MainButtonStyle2(width: buttonWidth2, height: buttonWidth2))
                                        .shadow(color:shadowColor ,radius: 1.0)
                                }
                                    .padding(.bottom,10)
                                    .padding(.trailing,10)
                                    .frame(width: geoWidth, height:groundHeight*0.15, alignment:.bottomTrailing)

//                                        .frame(width: geoWidth, height:groundHeight*0.15, alignment:.leading)


                                }
                                .frame(width:geoWidth, height:groundHeight + keyboardHeight, alignment:.top)
                            } // vstack
                                
                                
                            
//                            if numberOfStones == 0 {
//                                VStack(spacing:0) {
//
//                                    StoneTower_stone(
//                                        shapeNum: 3,
//                                        brightness: 0,
//                                        defaultColorIndex: defaultColorIndex,
//                                        facialExpressionNum: 3,
//                                        selected: false
//                                    )
//                                    .frame(width: stoneWidth, height: stoneHeight)
//                                    .opacity(0.2)
//                                    StoneTower_stone(
//                                        shapeNum: 1,
//                                        brightness: 2,
//                                        defaultColorIndex: defaultColorIndex,
//                                        facialExpressionNum: 2,
//                                        selected: false
//                                    )
//                                    .frame(width: stoneWidth, height: stoneHeight)
//                                    .opacity(0.3)
//                                    StoneTower_stone(
//                                        shapeNum: 2,
//                                        brightness: 1,
//                                        defaultColorIndex: defaultColorIndex,
//                                        facialExpressionNum: 1,
//                                        selected: false
//                                    )
//                                    .frame(width: stoneWidth, height: stoneHeight)
//                                    .opacity(0.4)
//                                }
//                                .position(x:geoWidth/2, y:aboveSkyHeight-stoneHeight*1.5)
//                                let noSavedDailyRecords_visible: Bool = dailyRecordSet.dailyRecords?.filter({$0.hasContent}).count == 0
//                                
//                                if noSavedDailyRecords_visible && selectedDailyRecordSetIndex == dailyRecordSets.count - 1 && !isEditingTermGoals {
//                                    Text("매일매일의 기록을 저장하세요!")
//                                        .opacity(0.5)
//                                        .position(x:geoWidth/2, y:aboveSkyHeight-stoneHeight*1.5)
//                                }
//                            }

                            

//                            let dailyQuestionStatisticsButtonPosition: CGPoint = CGPoint(x:questionMarkSize/2+geoWidth*0.05,y:totalSkyHeight-questionMarkSize/2-10)
//                            Button(action:{
//                                showDailyQuestionStatistics.toggle()
//                            }) {
//                                Image(systemName: "questionmark")
//                                    .resizable()
//                                    .frame(width:questionMarkSize, height:questionMarkSize)
//                            }
//                            .buttonStyle(.plain)
//                            .position(x:questionMarkSize/2+geoWidth*0.05,y:totalSkyHeight-questionMarkSize/2-10)

                            




                            
                        } // zstack
                        .coordinateSpace(.named("ZStack"))
                        .preference(key:ViewFrameKey.self, value: geometry2.frame(in: .global))
                        .id("wholeScrollView")

                        
                    } // GeometryReader(2)
                    .frame(width:geoWidth, height:totalSkyHeight+groundHeight+keyboardHeight)

                    

                    
                    
                }// scrollView
                .frame(width:geoWidth, height: geoHeight,alignment: .top)
                .onPreferenceChange(ViewFrameKey.self) { zStackFrame in
                    let scrollViewFrameOriginY = geometry.frame(in: .global).origin.y // 0 188
                    let scrollViewFrameCenterY = geoHeight/2
                    let zStackViewFrameOriginY = zStackFrame.origin.y // 188 188
                    
                    scrollViewCenterY = scrollViewFrameOriginY - zStackViewFrameOriginY + scrollViewFrameCenterY
                    //                print(scrollViewFrameOriginY)
                    //                print(scrollViewCenterY)
                }

                .scrollDisabled(popUp_recordInDetail)
                .defaultScrollAnchor(isLatestDailyRecordSet ? .top : .bottom)
                .onReceive(keyboardHeightPublisher) { value in

                    if keyboardAppeared {
                        self.keyboardHeight = value*0.75 //MARK: navigationBarHeight does not contain the bottom safeArea of display, so it is less than actual navigationBarHeight that is displayed
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                            withAnimation {
                                scrollProxy.scrollTo("wholeScrollView",anchor:.bottom)
                            }
                        }

                    }
                    else {
                        withAnimation { //MARK: debuger message: Bound preference ViewFrameKey tried to update multiple times per frame. May cause problem later.
                            scrollProxy.scrollTo("wholeScrollView",anchor:.bottom)
                            self.keyboardHeight = value
                        }


                    }

                }
                .scrollDisabled(keyboardAppeared)
                


            }


        } // geometryReader
        .onAppear() {
            
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
            
//            for dr in dailyRecords_savedAndNotHidden_withVisualValues {
//                print(dr.questionValue3!)
//            }
//
//            for dr in dailyRecords_savedAndNotHidden_withVisualValues {
//                print(dr.visualValue3!)
//            }
        }
        .onChange(of: selectedDailyRecordSetIndex) { oldValue, newValue in
//            isEditingTermGoals = false
        }

        





    }
    
    func shapeNum(_ input: Int) -> Int { // 기록 시간 -> 모양 (0~3시간 / 3시간~6시간 / 6시간 이상)
        
        switch input {
        case 0...179: return 1
        case 180...359: return 2
        case 360...: return 3
        default: return 0
        }
    
    }
    
    func brightness(_ input: Int) -> Int { // 기록 갯수(색) 1~2 / 3~5 / 6~10 / 10개 이상

        switch input {
        case 1...2: return 1
        case 3...5: return 2
        case 6...10: return 3
        case 10...: return 4
        default: return 0
        }
        
    }
    
    func misalignment(_ input: Int, _ idx: Int) -> Int { // 기록 연속성(오랜만에 쌓을 수록 비뚤어짐) 0일 -> 0 / -1~-3일 -> +-1~3

//        let plusOrMinus:Int = Int.random(in: 0...1) == 1 ? 1 : -1
        let plusOrMinus:Int = idx % 2 * 2 - 1
        
        if idx  == 0 { return 0 }
        
        switch input {
        case ...1: return 0
        case 2...4: return (input-1) * plusOrMinus
        default: return 3 * plusOrMinus
        }
        
    }
    
    func heatNum(_ input: Int) -> Int { //기록 연속성2(오래 쌓을 수록 달궈짐) ->  2일 /  3일 / 4~5일 / 6~8일 / 9~11일 / 12~15일 / 16일~ /  20일~ / 25일~ / 30일~
        
        switch input {
        case ...1: return 0
        case 2: return 1
        case 3: return 2
        case 4...5: return 3
        case 6...8: return 4
        case 9...11: return 5
        case 12...15: return 6
        case 16...20: return 7
        case 21...25: return 8
        case 26...30: return 9
        default: return 10
        }
    }
    
    
    static func getDailyRecordColor(index:Int) -> Color {
        if index == 0 {
            return Color.white // almost zero
        }
        else if index == 1 {
            return Color.pink.adjust(saturation:-0.45, brightness: 0.4) // 0.14(o) 0.068(x)
        }
        else if index == 2 {
            return Color.blue.adjust(hue:0.05, saturation:-0.5, brightness: 0.4) // 0.475(o) 0.36(x)
        }
        else if index == 3 {
            return Color.green.adjust(hue:-0.1, saturation:-0.45, brightness: 0.3) // 0.354(o)   0.35(x)
        }
        else if index == 4 {
            return Color.purple.adjust(hue:-0.05, saturation:-0.4, brightness: 0.3) // 0.1(o)  0.03(not that good)
        }
        else if index == 5 {
            return Color.orange.adjust(hue:-0.04, saturation:-0.4, brightness: 0.5) //      0.37
        }
        else {
            return Color.white
        }
    }
    
    
    static func getIntegratedDailyRecordColor(index:Int, colorScheme:ColorScheme) -> Color {
        return getDailyRecordColor(index: index).adjust(brightness: colorScheme == .light ? -0.02 : -0.25).colorExpressionIntegration()
    }
    
    
}





struct StoneTower_popUp_ChangeStyleView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var popUp_changeStyle: Bool
    @Binding var defaultColorIndex_tmp: Int
    
    var body: some View {
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth*0.2

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 60))]) {
                ForEach(0...5,id:\.self) { index in
                    Circle()
                        .fill(StoneTower.getIntegratedDailyRecordColor(index: index,colorScheme: colorScheme))
                        .stroke(getReversedColorSchemeColor(colorScheme), style: StrokeStyle(lineWidth: index == defaultColorIndex_tmp ? 5.0 : 1.0))
                        .padding(10)
                        .frame(width:gridSize, height: gridSize)
                        .onTapGesture {
                            defaultColorIndex_tmp = index
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                                popUp_changeStyle.toggle()
                            }
                        }
                }

            }
            .padding(50)

                    

            
        }
    }
    
}



//
//  StoneTower1_stones.swift
//  recoraddic
//
//  Created by 김지호 on 3/26/24.
//

// MARK: Path rules: start from top left, clockwise

import Foundation
import SwiftUI

struct StoneTower_stone: View {
    
    @Environment(\.colorScheme) var colorScheme
    // themeName, visualValue1, visualValue2
    var shapeNum: Int
    var brightness: Int
    var facialExpressionNum: Int
    
    var defaultColor:Color
    
    var selected: Bool

    
    init(shapeNum: Int, brightness: Int, defaultColorIndex: Int, facialExpressionNum: Int, selected:Bool) {
        self.shapeNum = shapeNum
        self.brightness = brightness
        self.facialExpressionNum = facialExpressionNum
        self.defaultColor = StoneTower.getDailyRecordColor(index: defaultColorIndex)
        self.selected = selected
    }


    
    var body: some View {

        let stoneColor: Color = {
            // later control saturation
            let mainColorDarkness: CGFloat = {
                let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = defaultColor.getRGBA()
    //            print("0: ",mainColor_rgba.0)
    //            print("1: ",mainColor_rgba.1)
    //            print("2: ",mainColor_rgba.2)
                print(3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2)
                return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
            }()
            
            let shouldBeDarkerInDarkStoneInDarkMode: Bool = mainColorDarkness > 0.001 && colorScheme == .dark
            
            switch brightness {
            case 3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.25)
            case 2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.08 : -0.38)
            case 1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.14 : -0.51)
            case 0: return defaultColor.adjust(brightness: colorScheme == .light ? -0.27 : -0.64)
            case -1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.39 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.8 : -0.70))
            case -2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.47 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.9 : -0.75))
            case -3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.55 : (shouldBeDarkerInDarkStoneInDarkMode ? -1.0 : -0.80))

            default: return Color.red
            }
        }()


        
        GeometryReader { geometry in
            
            
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height

            
            ZStack {
                // TODO: 그림자를 그 다음 stone과의 visualValue3 차이만큼 받아서 적용, nil이면 그림자 없음

                switch shapeNum {
                case 0:
                    StoneShape0(mainColor: stoneColor)
                        .opacity(0.85)
                case 1:
                    StoneShape1(mainColor: stoneColor)
                        .opacity(0.85)
                case 2:
                    StoneShape2(mainColor: stoneColor)
                        .opacity(0.85)
                case 3:
                    StoneShape3(mainColor: stoneColor)
                        .opacity(0.85)
                default:
                    Text("ERROR")
                }
//                if shapeNum == 0 {
//                    StoneShape0(mainColor: stoneColor)
//                }

                
                if facialExpressionNum != 0 {

                    /*toneColor.adjust(brightness: -0.15)*/
                    Color.black
                        .mask {
                            Image("facialExpression_\(facialExpressionNum)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
        //                        .frame(height: geometry.size.height*0.8)
                                .frame(height: geometry.size.height*0.6)
                        }
                        .opacity(selected ? 0.7 : 0.3)




                }
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
        
    
    
    

    

    
    
    
    
    
        
}


struct RecordStoneShadowView: View {
    var adjustedThemeSet: ThemeSet
    var dailyRecordThemeNum: Int
    
    
    var body: some View {
        
        GeometryReader { geometry in
            let shapeNum = dailyRecordThemeNum >= 0 ? dailyRecordThemeNum : 0
            
            let shape: Path = {
                var returnShape: Path? = nil
                if shapeNum <= 2 {
                    returnShape = Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        path.addLines(
                            {
                                var returnList:[CGPoint] = []
                                for ratio in adjustedThemeSet.shapes[shapeNum]!  {
                                    returnList.append(CGPoint(x: ratio.x * width, y: ratio.y * height))
                                }
                                return returnList
                            }()
                        )
                        path.closeSubpath()
                    }
                    
                }
                else {
                    returnShape = Path(roundedRect: CGRect(x:0, y:0,width: geometry.size.width, height: geometry.size.height), cornerSize: CGSize(width: geometry.size.width*0.1, height:geometry.size.height*0.1))
                    
                }
                
                return returnShape!
                
                
            }()
            
            
            
            
            ZStack {

                
                Color.white
                    .clipShape(shape)
                    .shadow(radius: 7)
                
                
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
}






struct StoneShape0: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.30, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.70, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.90, y: 0.55)
    let point4:CGPoint = CGPoint(x: 0.70, y: 1.00)
    let point5:CGPoint = CGPoint(x: 0.30, y: 1.00)
    let point6:CGPoint = CGPoint(x: 0.10, y: 0.55)
    // outer point (order: topLeft, clockwise)

    
    let point7:CGPoint = CGPoint(x: 0.35, y: 0.15)
    let point8:CGPoint = CGPoint(x: 0.65, y: 0.15)
    let point9: CGPoint = CGPoint(x: 0.75, y: 0.60)
    let point10:CGPoint = CGPoint(x: 0.65, y: 0.90)
    let point11:CGPoint = CGPoint(x: 0.35, y: 0.90)
    let point12:CGPoint = CGPoint(x: 0.25, y: 0.60)

    
    // inner point (order: topLeft, clockwise)
    
    /*
            1 ------------- 2
          /   \           /   \
         /     7 ------- 8     \
        /     /           \     \
       6 --- 12            9 --- 3
        \     \           /     /
         \     11 ----- 10     /
          \   /            \  /
            5 -------------- 4
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.02, brightness: colorScheme == .light ? 0.015 : 0.05)
        let color3 = mainColor
        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.06 : -0.10)

        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point8, point7
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point7, point12, point6
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point9, point8
        ]
        let bottomCenterPoints: [CGPoint] = [
            point11, point10, point4, point5
        ]
        let bottomLeftPoints: [CGPoint] = [
            point6, point12, point11, point5, point6
        ]
        let bottomRightPoints: [CGPoint] = [
            point9, point3, point4, point10
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            
            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))

            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(bottomSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(bottomCenter,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))

            
        }
        


    }

}


struct StoneShape1: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.27, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.73, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.88, y: 0.30)
    let point4:CGPoint = CGPoint(x: 0.88, y: 0.80)
    let point5:CGPoint = CGPoint(x: 0.77, y: 1.00)
    let point6:CGPoint = CGPoint(x: 0.23, y: 1.00)
    let point7:CGPoint = CGPoint(x: 0.12, y: 0.80)
    let point8:CGPoint = CGPoint(x: 0.12, y: 0.30)
    // outer point (order: topLeft, clockwise)

    
    let point9: CGPoint = CGPoint(x: 0.32, y: 0.10)
    let point10:CGPoint = CGPoint(x: 0.68, y: 0.10)
    let point11:CGPoint = CGPoint(x: 0.82, y: 0.40)
    let point12:CGPoint = CGPoint(x: 0.82, y: 0.70)
    let point13:CGPoint = CGPoint(x: 0.70, y: 0.88)
    let point14:CGPoint = CGPoint(x: 0.30, y: 0.88)
    let point15:CGPoint = CGPoint(x: 0.18, y: 0.70)
    let point16:CGPoint = CGPoint(x: 0.18, y: 0.40)


    
    // inner point (order: topLeft, clockwise)
    
    /*
                 1       2
                  9    10
            8                 3
               16         11
                         
               15         12
            7    14     13    4
                6         5
    
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        
        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.03, brightness: colorScheme == .light ? 0.015 : 0.05)
        let color3 = mainColor
        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.06 : -0.10)
        let color6 = mainColor.adjust(brightness: colorScheme == .light ? -0.09 : -0.13)


        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        let color6_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color6.getRGBA()

        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6, point7, point8]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point10, point9
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point9, point16, point8
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point11, point10
        ]
        let centerLeftPoints: [CGPoint] = [ point8, point16, point15, point7 ]
        let centerRightPoints: [CGPoint] = [ point11, point3, point4, point12 ]
        let bottomCenterPoints: [CGPoint] = [
            point14, point13, point5, point6
        ]
        let bottomLeftPoints: [CGPoint] = [
            point15, point14, point6, point7
        ]
        let bottomRightPoints: [CGPoint] = [
            point12, point4, point5, point13
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let centerSides: Path = Path { path in
                path.addLines(centerLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(centerRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            
            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(centerSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(bottomSides,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
            context.fill(bottomCenter,with: .color(red:color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2))

            
        }
        


    }

}


//#Preview(body: {
//    ZStack {
//        StoneShape2(mainColor:Color.white.adjust(brightness: -0.03))
//            .frame(width:210, height:140)
//    }
//    .padding(20)
//    .background(.gray)
//})

struct StoneShape2: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.24, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.76, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.85, y: 0.10)
    let point4:CGPoint = CGPoint(x: 0.93, y: 0.35)
    let point5:CGPoint = CGPoint(x: 0.93, y: 0.65)
    let point6:CGPoint = CGPoint(x: 0.85, y: 0.93)
    let point7:CGPoint = CGPoint(x: 0.76, y: 1.00)
    let point8:CGPoint = CGPoint(x: 0.24, y: 1.00)
    let point9:CGPoint = CGPoint(x: 0.15, y: 0.93)
    let point10:CGPoint = CGPoint(x: 0.07, y: 0.65)
    let point11:CGPoint = CGPoint(x: 0.07, y: 0.35)
    let point12:CGPoint = CGPoint(x: 0.15, y: 0.10)

    
    
//    let point13:CGPoint = CGPoint(x: 0.27, y: 0.08)
//    let point14:CGPoint = CGPoint(x: 0.73, y: 0.08)
//    let point15:CGPoint = CGPoint(x: 0.79, y: 0.15)
//    let point16:CGPoint = CGPoint(x: 0.85, y: 0.33)
//    let point17:CGPoint = CGPoint(x: 0.85, y: 0.67)
//    let point18:CGPoint = CGPoint(x: 0.79, y: 0.85)
    let point13:CGPoint = CGPoint(x: 0.31, y: 0.10)
    let point14:CGPoint = CGPoint(x: 0.69, y: 0.10)
    let point15:CGPoint = CGPoint(x: 0.78, y: 0.18)
    let point16:CGPoint = CGPoint(x: 0.85, y: 0.36)
    let point17:CGPoint = CGPoint(x: 0.85, y: 0.64)
    let point18:CGPoint = CGPoint(x: 0.80, y: 0.82)

//    let point19:CGPoint = CGPoint(x: 0.70, y: 0.95)
//    let point20:CGPoint = CGPoint(x: 0.30, y: 0.95)
//    let point21:CGPoint = CGPoint(x: 0.21, y: 0.85)
//    let point22:CGPoint = CGPoint(x: 0.15, y: 0.67)
//    let point23:CGPoint = CGPoint(x: 0.15, y: 0.33)
//    let point24:CGPoint = CGPoint(x: 0.21, y: 0.15)
    let point19:CGPoint = CGPoint(x: 0.71, y: 0.94)
    let point20:CGPoint = CGPoint(x: 0.29, y: 0.94)
    let point21:CGPoint = CGPoint(x: 0.20, y: 0.82)
    let point22:CGPoint = CGPoint(x: 0.15, y: 0.64)
    let point23:CGPoint = CGPoint(x: 0.15, y: 0.36)
    let point24:CGPoint = CGPoint(x: 0.22, y: 0.18)

    
    // inner point (order: topLeft, clockwise)
    
    /*
             1         2
             13       14
      12  24              15 3
      
    11  23                  16  4
     
    10  22                  17  5
          21              18
       9       20    19      6
             8          7
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        let color1 = mainColor.adjust(saturation:-0.07, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.02 : 0.07)
        let color3 = mainColor.adjust(saturation:-0.03, brightness: colorScheme == .light ? 0.01 : 0.035)
        let color4 = mainColor
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.03)
        let color6 = mainColor.adjust(brightness: colorScheme == .light ? -0.04 : -0.06)
        let color7 = mainColor.adjust(brightness: colorScheme == .light ? -0.065 : -0.09)
        let color8 = mainColor.adjust(brightness: colorScheme == .light ? -0.09 : -0.12)

        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        let color6_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color6.getRGBA()
        let color7_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color7.getRGBA()
        let color8_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color8.getRGBA()

        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point14, point13
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point13, point24, point12
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point15, point14
        ]
        let topLeftPoints2: [CGPoint] = [
            point12, point24, point23, point11
        ]
        let topRightPoints2: [CGPoint] = [
            point15, point3, point4, point16
        ]
        let centerLeftPoints: [CGPoint] = [
            point11, point23, point22, point10
        ]
        let centerRightPoints: [CGPoint] = [
            point16, point4, point5, point17
        ]
        let bottomLeftPoints: [CGPoint] = [
            point10, point22, point21, point9
        ]
        let bottomRightPoints: [CGPoint] = [
            point17, point5, point6, point18
        ]
        let bottomLeftPoints2: [CGPoint] = [
            point21, point20, point8, point9
        ]
        let bottomRightPoints2: [CGPoint] = [
            point18, point6, point7, point19
        ]
        let bottomCenterPoints: [CGPoint] = [
            point20, point19, point7, point8
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides2:Path = Path { path in
                path.addLines(topLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let centerSides:Path = Path { path in
                path.addLines(centerLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(centerRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides2:Path = Path { path in
                path.addLines(bottomLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),

            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.09), endPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.93)))

//            context.fill(outLine, with: .radialGradient(Gradient(colors: [
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),
//
//            ]), center: CGPoint(x: frameWidth/2, y: frameHeight/5), startRadius: 0, endRadius: frameWidth/2))

//            context.fill(outLine,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(topSides2,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(centerSides,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
            context.fill(bottomSides,with: .color(red:color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2))
            context.fill(bottomSides2,with: .color(red:color7_rgba.0, green: color7_rgba.1, blue: color7_rgba.2))
            context.fill(bottomCenter,with: .color(red:color8_rgba.0, green: color8_rgba.1, blue: color8_rgba.2))

            
        }
        


    }

}


struct StoneShape3: View {
    
    @Environment(\.colorScheme) var colorScheme
    



    
    var mainColor: Color
    
    var body: some View {
        
        let mainColorDarkness: CGFloat = {
            let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()
//            print("0: ",mainColor_rgba.0)
//            print("1: ",mainColor_rgba.1)
//            print("2: ",mainColor_rgba.2)
//            print(3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2)
            return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
        }()

        
        let color1 = {
            if mainColorDarkness > 0.2 {
                return mainColor.adjust(saturation:-0.06, brightness: colorScheme == .light ? 0.08 : 0.07)
            }
            else {
//                return mainColor.adjust(saturation:-0.04, brightness: 0.03)
//                print("hoho")
                return mainColor.adjust(saturation:-0.045, brightness: colorScheme == .light ? 0.08 : 0.07)

            }
        }()
//        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.08 : 0.07)

//        let color2 = mainColor.adjust(brightness: colorScheme == .light ? 0.015 : 0.05)
//        let color3 = mainColor
        let color3 = {
            if mainColorDarkness > 0.1 || colorScheme == .dark {
                return mainColor
            }
            else {
//                return mainColor.adjust(saturation:-0.04, brightness: 0.03)
//                print("hoho")
                return mainColor.adjust(brightness: -0.03)

            }
        }()

        
//        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.1 : -0.13)

        
        // MARK: Canvas does not apply color in the same process as the normal SwiftUI views. Even it's the same Color object(by SwiftUI), the display will return the unusual different color. So it should be substracted as rgb component to apply the same color. (24.03.29)
        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
//        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
//        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        
        

        Canvas { context, size in
            let frameWidth = size.width*0.85
            let frameHeight = size.height
            context.blendMode = .lighten
            context.opacity = 1.0
            let xOrigin: CGFloat = size.width*0.075

//            let gradient:LinearGradient = LinearGradient(colors: [color1,color2,color3,color4,color5], startPoint: .top, endPoint: .bottom)
//            let gradient:Gradient = Gradient(colors: [color1,color2,color3,color3,color3,color3,color3,color4,color5])
            
//            let outLine:Path = Path(roundedRect: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight), cornerRadius: frameWidth*0.1, style: .circular)
            let outLine:Path = Path(roundedRect: CGRect(x: xOrigin, y: 0, width: frameWidth, height: frameHeight), cornerSize:CGSize(width: frameWidth*0.09, height: frameHeight*0.1), style: .circular)

//            context.fill(outLine, with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: frameWidth, y: frameHeight)))
//            context.fill(outLine, with: .color(color3))
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2),

            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))

            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),

            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))

            
//            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
//            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
//
//            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
//            context.fill(bottomSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
//            context.fill(bottomCenter,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
//
//
        }
        


    }

}





















//let color_example: Color = Color.white.adjust(brightness: -0.4)
//let color_example2: Color = Color.white.adjust(brightness: -0.1)
//
//let color_ex_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color_example.getRGBA()
//
////#Preview(body: {
////    VStack {
////        Color.white
////        Color.white.adjust(brightness: -0.1).adjust(brightness: 0.1)
////        color_example2.adjust(brightness: 0.1)
////        Canvas { context, size in
////            context.blendMode = .copy
////            context.opacity = 1.0
////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(red: color_ex_rgba.0, green: color_ex_rgba.1, blue: color_ex_rgba.2))
//////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(.blue.opacity(0.5)))
////        }
//////        Color.blue.opacity(0.5)
////        color_example
////        Color.white.adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.05).adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.1)
////        Color.white.adjust(brightness: -0.35).adjust(brightness: -0.35)
////        Color.white.adjust(brightness: -0.7)
////
////
////
////    }
////    .border(.red)
////})

struct MainButtonStyle2: ButtonStyle {
    
    @Environment(\.colorScheme) var colorScheme

    
    var width:CGFloat
    var height:CGFloat
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, height/8)
            .padding(.horizontal, width/8)
            .frame(width: width, height: height)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
            .background(getColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)

    }
}

struct MainButtonStyle3: ButtonStyle {
    

    @Environment(\.colorScheme) var colorScheme


    
    func makeBody(configuration: Configuration) -> some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let goeHeight = geometry.size.height
            
            configuration.label
                .padding(.vertical, goeHeight/8)
                .padding(.horizontal, geoWidth/8)
                .frame(width: geoWidth, height: goeHeight)
                .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                .background(getReversedColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
                .cornerRadius(8)
        }

    }
}
