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
struct MainView_SeeMyDailyRecord: View { //MARK: selectedDailyRecordSet은 selectedDailyRecordSetIndex로 컨트롤한다. selectedDailyRecordSet은 직접 건드리지 않는다.
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    
    var dailyRecordSets_notHidden: [DailyRecordSet] {
        dailyRecordSets.filter({!$0.isHidden})
    }
    
    @State var selectedDailyRecordSetIndex: Int // it does not automatically changes selectedDailyRecordSet. you need to toggle updateSelectedDailyRecordSet to update selectedDailyRecordSet
    @State var selectedDailyRecordSet: DailyRecordSet
    
//    var navigationBarHeight: CGFloat
    
    
    @State var popUp_startNewRecordSet: Bool = false
    @State var popUp_recordInDetail = false
    @State var popUp_changeStyle = false
    
    @State var selectedRecord: DailyRecord? = nil
    
    @State var updateSelectedDailyRecordSet: Bool = false
    
    @State var dailyRecordHiddenOrDeleted: Bool = false
    @State var dailyRecordHidden: Bool = false
//    @State var dailyRecordDeleted: Bool = false
//    @State var dailyRecordUnhidden: Bool = false
    @State var hiddenOrDeletedIndex: Int = 0
    @State var recalculatingVisualValues_themeChanged: Bool = false // not used yet. Will be used to hide when calculation is on process
    
    @State var dailyRecordSetHidden: Bool = false
    @State var isEditingTermGoals: Bool = false
    
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView: MainViewName
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let statusBarHeight:CGFloat = getStatusBarHeight()
        
        let backGroundColor:Color = getColorSchemeColor(colorScheme)
        
        let dailyRecordSetEmpty: Bool = selectedDailyRecordSet.dailyRecords!.filter({!$0.hide}).count == 0
        
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
                    else if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_0" {
                        StoneTower_0(
                            dailyRecordSet: $selectedDailyRecordSet,
                            selectedDailyRecordSetIndex: $selectedDailyRecordSetIndex,
                            selectedRecord: $selectedRecord,
                            popUp_startNewRecordSet: $popUp_startNewRecordSet,
                            popUp_recordInDetail: $popUp_recordInDetail,
                            dailyRecordSetHidden: $dailyRecordSetHidden,
                            popUp_changeStyle: $popUp_changeStyle,
                            isEditingTermGoals: $isEditingTermGoals
                        )
                        .frame(width:geoWidth, height: geoHeight)
                    }
                    else if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
                        StoneTower_1(
                            dailyRecordSet: $selectedDailyRecordSet,
                            selectedDailyRecordSetIndex: $selectedDailyRecordSetIndex,
                            selectedRecord: $selectedRecord,
                            popUp_startNewRecordSet: $popUp_startNewRecordSet,
                            popUp_recordInDetail: $popUp_recordInDetail,
                            dailyRecordSetHidden: $dailyRecordSetHidden, 
                            popUp_changeStyle: $popUp_changeStyle,
                            isEditingTermGoals: $isEditingTermGoals
                        )
                        .frame(width:geoWidth, height: geoHeight)
                    }
                    
                    else {
                        
                        Text("can't find theme")
                    }
                    
                }
                else {
                    Text("변경하는 중..")
                }
                
                let noSavedDailyRecords_notHidden: Bool = selectedDailyRecordSet.dailyRecords?.filter({$0.visualValue1 != nil && !$0.hide}).count == 0
                
                if noSavedDailyRecords_notHidden && selectedDailyRecordSetIndex == dailyRecordSets_notHidden.count - 1 && !isEditingTermGoals {
                    VStack {
                        HStack {
                            Text("매일매일의 기록을 저장하세요!")
                        }
                        .foregroundStyle(.opacity(0.5))

                        Button(action:{
                            selectedView = .checkList
                        }) {
                            Text("저장하러 가기")
                                .font(.caption)
                        }
                    }
                    
                }
                
//                if !isEditingTermGoals && selectedDailyRecordSet.termGoals.isEmpty {
//                    Text("나만의 목표를 설정하세요!")
//                        .opacity(0.5)
//                }
                
                
                if popUp_startNewRecordSet {
                    Color.gray.opacity(0.5)
                    StartNewRecordSet(
                        popUp_startNewRecordSet: $popUp_startNewRecordSet,
                        selectedDailyRecordSetIndex: $selectedDailyRecordSetIndex,
                        updateSelectedDailyRecordSet: $updateSelectedDailyRecordSet
                    )
                        .popUpViewLayout(width: geoWidth*0.9, height: (geoHeight-statusBarHeight)*0.9, color: backGroundColor)
                        .position(x:geoWidth/2,y: statusBarHeight + (geoHeight-statusBarHeight)/2 )
                }
                
                if popUp_changeStyle { //TODO: 나중에는 theme에 관계없이 통일된 popup창 -> 동일한 theme내에서 색만 변경 가능, 질문 있는 theme -> 질문없는 theme으로 변경 가능(경고메시지), 질문 있는 theme -> 질문 있는 theme, 질문 없는 theme -> 질문 없는 theme 기능 제공
                    Color.gray.opacity(0.5)
                        .onTapGesture {
                            popUp_changeStyle.toggle()
                        }
                    if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_0" {
                        StoneTower_0_popUp_ChangeStyleView(
                            popUp_changeStyle:$popUp_changeStyle,
                            defaultColorIndex_tmp: $selectedDailyRecordSet.dailyRecordColorIndex
                        )
                        .frame(width: geoWidth*0.8, height: geoHeight*0.7)
                        .background(.background)
                        .clipShape(.rect(cornerSize: CGSize(width: geoWidth*0.8*0.1, height: geoHeight*0.7*0.1)))
                    }
                    if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
                        StoneTower_1_popUp_ChangeStyleView(
                            popUp_changeStyle:$popUp_changeStyle,
                            defaultColorIndex_tmp: $selectedDailyRecordSet.dailyRecordColorIndex
                        )
                        .frame(width: geoWidth*0.8, height: geoHeight*0.7)
                        .background(.background)
                        .clipShape(.rect(cornerSize: CGSize(width: geoWidth*0.8*0.1, height: geoHeight*0.7*0.1)))
                    }
                }
                
                
            }
            .sheet(isPresented: $popUp_recordInDetail) {
                RecordInDetailView_optional(
                    popUp_recordInDetail: $popUp_recordInDetail,
                    record: $selectedRecord

                )
                .background(colorSchemeColor)
                
                //TODO: light모드일 때,  Col
            }
            .scrollDisabled(dailyRecordSetEmpty)
        }
        .onChange(of: selectedDailyRecordSetIndex) {
            updateSelectedDailyRecordSet = true
        }
        .onChange(of: updateSelectedDailyRecordSet) {
            if updateSelectedDailyRecordSet {
                selectedDailyRecordSet = dailyRecordSets_notHidden[selectedDailyRecordSetIndex]
                updateSelectedDailyRecordSet = false // MARK: onChange 클로저 안에서는 본인의 변화를 detect하지 않는 것 같다. 무한 루프가 생성되지 않는다. 바꿔줘도 됨.
                selectedRecord = nil
            }
            
        }
        .onChange(of: dailyRecordSetHidden) {
            if selectedDailyRecordSetIndex > dailyRecordSets_notHidden.count - 1 {
                selectedDailyRecordSetIndex -= 1
            }
            updateSelectedDailyRecordSet = true
        }

        .onChange(of: isNewDailyRecordAdded, { // 
            
            selectedDailyRecordSetIndex = dailyRecordSets_notHidden.count - 1
        })

        .onChange(of: selectedDailyRecordSet.dailyRecordThemeName) {
            
            recalculatingVisualValues_themeChanged = true
            recalculateVisualValues_themeChanged()
            recalculatingVisualValues_themeChanged = false
            
        }
        
        // index가 바뀌지 않아도 selectedDailyRecordSet가 바뀌는 경우(ex: 아무것도 안 쌓은 채로 다시 새로 dailyRecordSet 생성)
        // 그런 경우에도 selectedDailyRecordSet를 바꿔주기 위해서 이렇게 단계를 두개로 나눔.

    
                

        
        
    }
    

    
    
}




