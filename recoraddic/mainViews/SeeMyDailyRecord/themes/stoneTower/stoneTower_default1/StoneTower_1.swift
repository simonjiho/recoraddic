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
struct StoneTower_1: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    
//    var dailyRecordSets_notHidden: [DailyRecordSet] { // why needed? should remove and restruct it later.
//        dailyRecordSets.filter({!$0.isHidden})
//    }
    
    @Binding var dailyRecordSet:DailyRecordSet
    
    @Binding var selectedDailyRecordSetIndex: Int
    @Binding var selectedRecord: DailyRecord?
    @Binding var popUp_startNewRecordSet: Bool
    @Binding var popUp_recordInDetail: Bool
    @Binding var dailyRecordSetHidden: Bool
//    var navigationBarHeight: CGFloat
//    @Binding var dailyRecordHidden: Bool
//    @Binding var dailyRecordUnhidden: Bool
//    @Binding var editedIndex: Int

    @Binding var popUp_changeStyle: Bool
    
    
//    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]

    
    @State var scrollViewCenterY: CGFloat = 0
    
    @State var canEdit: Bool = false
    
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
    
    
    var body: some View {
        
        let dailyRecordSet_notHidden_count: Int = dailyRecordSets.filter({!$0.isHidden}).count
        
        let dailyRecords_savedAndNotHidden: [DailyRecord] = dailyRecordSet.dailyRecords!.sorted(by: {$0.date < $1.date}).filter({$0.questionValue1 != nil && !$0.hide})
        
        let dailyRecords_savedAndNotHidden_withVisualValues: [DailyRecord] = dailyRecords_savedAndNotHidden.filter({$0.visualValue3 != nil})
        
        let numberOfStones: Int  = dailyRecords_savedAndNotHidden_withVisualValues.count
        



        
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
                    return dailyRecords_savedAndNotHidden_withVisualValues.contains(selectedRecord!)
                }
            }() //MARK: 다른기기에서 selectedRecord에 할당된 데이터를 지워 cloud상에서 삭제되었음에도, view의 selectedRecord에 할당되어 있을 때
            
            let geoWidth:CGFloat = geometry.size.width
            let geoHeight:CGFloat = geometry.size.height
            
            let stoneWidth:CGFloat = geoWidth*0.22
            let stoneHeight:CGFloat = stoneWidth*0.67
            let selectedStoneHeight:CGFloat = stoneHeight*1.4
            let selectedStoneWidth:CGFloat = stoneWidth*1.4
            let heightGap:CGFloat = haveSelectedRecord ? (selectedStoneHeight - stoneHeight) : 0.0
            let horizontalUnitWidth:CGFloat = stoneWidth*0.115 // 최대 *9번 갈 수 있음( calculateVisualValue3() 에서)
            let questionMarkSize: CGFloat = geoWidth*0.05
            
            let groundHeight:CGFloat = geoHeight/2 - stoneHeight/2
            let towerHeight:CGFloat = stoneHeight*CGFloat(numberOfStones) + heightGap
            let groundAndTowerHeight:CGFloat = groundHeight + towerHeight
            let aboveSkyHeight:CGFloat = (groundAndTowerHeight-stoneHeight/2 > geoHeight/2 ? (geoHeight/2 - stoneHeight/2) : geoHeight - groundAndTowerHeight) - heightGap
            let totalSkyHeight:CGFloat = aboveSkyHeight + towerHeight

            let buttonWidth:CGFloat = geoWidth*0.25
            let buttonWidth2:CGFloat = geoWidth*0.1
            
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
                                        
                                        
                                        let record:DailyRecord = dailyRecords_savedAndNotHidden_withVisualValues[index]
                                        
                                        
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
                                            
                                            let shapeNum:Int = record.visualValue1!
                                            let brightness:Int = record.visualValue2!
                                            let position:Int = record.visualValue3!
                                            
                                            ZStack {
                                                StoneTower_1_stone(
                                                    shapeNum: shapeNum,
                                                    brightness: brightness,
                                                    defaultColorIndex: defaultColorIndex,
                                                    facialExpressionNum: record.mood
                                                )
                                                .frame(width: width, height: height)
                                                .padding(.leading, geoWidth/2 - width/2 + CGFloat(position)*horizontalUnitWidth)
                                                .padding(.trailing, geoWidth/2 - width/2 - CGFloat(position)*horizontalUnitWidth)
                                                .padding(.vertical, 0)
//                                                .opacity(0.8)
                                                .onTapGesture {
                                                    if isSelectedRecord {
                                                        popUp_recordInDetail.toggle()
                                                    }
                                                    else {
                                                        selectedRecord = dailyRecords_savedAndNotHidden_withVisualValues[index]
                                                        withAnimation {
                                                            scrollProxy.scrollTo(record.date, anchor:.center)
                                                        }
                                                    }
                                                }
                                                
                                                
                                                Text(yyyymmddFormatOf(record.date))
                                                    .bold(isSelectedRecord)
                                                    .font(.caption)
                                                //                                                    .font(isOnCenter ? .footnote : .subheadline)
                                                    .opacity(isOnCenter ? 1.0 : (isNearCenter ? 0.3 : 0.0))
                                                    .position(x: position <= 0 ? geoWidth*0.77 : geoWidth*0.23, y: height/2)
                                                
                                            }
                                            .frame(height:height)
                                            
                                        }
                                        .frame(height:height)
                                        .id(record.date)
                                        
                                        
                                        
                                    }
                                }
                                
                                
                                VStack(spacing:0.0) {
                                    
                                    HStack {
                                        Button(action:{
                                            
                                            selectedDailyRecordSetIndex -= 1
                                            
                                            
                                            
                                            canEdit = false
                                        }) {
                                            Image(systemName: "arrowshape.left")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:geoWidth*0.12,height: groundHeight*0.1)
                                        }
                                        .disabled(selectedDailyRecordSetIndex == 0)
                                        
                                        ZStack {
                                            HStack(spacing:0.0) {
                                                if canEdit || dailyRecordSet.termGoals.count != 0 {
                                                    Text("목표")
                                                        .bold()
                                                        .font(.title3)
                                                        .frame(width: geoWidth/5)
                                                        .opacity(0.6)
                                                }
                                                else {
                                                    Spacer()
                                                        .frame(width: geoWidth/5)
                                                }

//                                                    .border(.red)

                                                if canEdit {
                                                    Button (action:{
                                                        dailyRecordSet.termGoals = editText
                                                        canEdit.toggle()
                                                    }) {
                                                        Text("저장")
//                                                                .frame(width:goalEditButtonSize*0.8, height: goalEditButtonSize*0.8)
                                                            .minimumScaleFactor(0.7)
                                                    }
                                                    .buttonStyle(MainButtonStyle2(colorScheme: _colorScheme, width: goalEditButtonSize, height: goalEditButtonSize))
                                                    


                                                }

                                            }
                                            .frame(width:geoWidth/2,height: groundHeight*0.15)
                                            .offset(x:canEdit ? goalEditButtonSize/2 : 0.0)
//                                            .frame(alignment:.center)
//                                            .border(.black)
                                            
                                        }
                                        .frame(width:geoWidth*0.7, height:groundHeight*0.15, alignment: .center)
                                        Button(action:{
                                            selectedDailyRecordSetIndex += 1
                                        }) {
                                            Image(systemName: "arrowshape.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:geoWidth*0.12, height: groundHeight*0.1)
                                        }
                                        .disabled(isLatestDailyRecordSet)

                                    }
                                    .frame(width:geoWidth, height:groundHeight*0.23)
                                    .padding(.bottom, groundHeight*0.07)


                                    VStack {
                                        if canEdit {
                                            if editText.count != 0 {
                                                ForEach(0...editText.count - 1, id:\.self) { index in
                                                    HStack {
                                                        Text("\(index+1). ")
                                                        TextField("",text:$editText[index])
                                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                                            .frame(width:geoWidth*0.7, alignment:.leading)
                                                        Button(action: {
                                                            editText.remove(at: index)
                                                        }) {
                                                            Image(systemName: "x.circle")
                                                        }
                                                        .frame(width:plusMinusButtonSize, height:plusMinusButtonSize)
                                                        .buttonStyle(MainButtonStyle3(colorScheme: _colorScheme))
                                                    }
                                                }
                                            }
                                        }

                                        else {
                                            if dailyRecordSet.termGoals.count != 0 {
                                                ForEach(0...dailyRecordSet.termGoals.count-1, id:\.self) { index in
                                                    HStack {
                                                        Text("\(index+1). ")
                                                        Text(dailyRecordSet.termGoals[index])
                                                            .frame(width:geoWidth*0.7, alignment:.leading)
                                                            
                                                    }
                                                    .opacity(0.6)
                                                    .padding(.vertical,3)
                                                    
                                                    
                                                }
                                                
                                            }
                                        }
                                        if canEdit && editText.count <= 2 {
                                            Button(action:{editText.append("")}) {
                                                Image(systemName: "plus.circle")
                                            }
                                            .frame(width:plusMinusButtonSize, height:plusMinusButtonSize)
                                            .buttonStyle(MainButtonStyle3(colorScheme: _colorScheme))

                                        }
                                    }
                                    .frame(height:groundHeight*0.55, alignment: .top)
                                    
                                    // 나중에 얘 ZStack으로 옮겨서 SeeMyRecord로 옮기고, viewModifier로 넣기?
                                
//                                        HStack(spacing:0.0) {
                                        Menu {
                                            Text("통계")
//                                            Text("스타일 변경") // DRtheme, background, DRColor변경
                                            Button("색 변경") { // 나중에 스타일 변경에 통합
                                                popUp_changeStyle.toggle()
                                            }
                                            Button("숨기기") {
                                                dailyRecordSet.isHidden = true
                                                dailyRecordSetHidden.toggle()
                                            }
                                            .disabled(isLatestDailyRecordSet || dailyRecordSet_notHidden_count <= 1)
                                            if isLatestDailyRecordSet {
                                                Button(action: {
                                                    popUp_startNewRecordSet.toggle()
                                                }) {
                                                    Text("새로 만들기")
//                                                            .minimumScaleFactor(0.5)
                                                }
                                                Button (action:{
                                                    editText = dailyRecordSet.termGoals
                                                    canEdit.toggle()
                                                }) {
                                                    Text("목표 편집")
                                                }
                                                .disabled(canEdit)

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
                                
                                
                            


                            Menu {
                                ForEach(0...dailyRecordSet.dailyQuestions.count-1, id:\.self) { qIndex in
                                    Text("질문\(qIndex+1). \(dailyRecordSet.dailyQuestions[qIndex])")
                                    //TODO: 질문 뒤에 결정 변수 적어주기
                                }
                            } label: {
                                Button(action:{presentQuestions.toggle()}) {
                                    Image(systemName: "questionmark")
                                        .resizable()
                                        .frame(width:questionMarkSize, height:questionMarkSize)
                                }
                                .buttonStyle(.plain)

                            }
                            .position(x:questionMarkSize/2+geoWidth*0.05,y:totalSkyHeight-questionMarkSize/2-10)


                            
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
    
        }




    }
    
}





struct StoneTower_1_popUp_ChangeStyleView: View {
    
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
                        .fill(StoneTower_1.getDailyRecordColor(index: index))
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

