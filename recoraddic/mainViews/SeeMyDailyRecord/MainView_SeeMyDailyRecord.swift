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
    
    var dailyRecordSets_visible: [DailyRecordSet] {
        dailyRecordSets.filter({$0.isVisible()})
    }
    
    @State var selectedDailyRecordSetIndex: Int // it does not automatically changes selectedDailyRecordSet. you need to toggle updateSelectedDailyRecordSet to update selectedDailyRecordSet
    @State var selectedDailyRecordSet: DailyRecordSet
    
//    var navigationBarHeight: CGFloat
    
    @Binding var isNewDailyRecordAdded: Bool
    @Binding var selectedView: MainViewName
    
    @State var popUp_startNewRecordSet: Bool = false
    @State var popUp_recordInDetail = false
    @State var popUp_changeStyle = false
    
    @State var selectedRecord: DailyRecord? = nil
    
    @State var updateSelectedDailyRecordSet: Bool = false
    
    @State var dailyRecordHiddenOrDeleted: Bool = false
    @State var alert_drsHidden: Bool = false
    @State var alert_drsInTrashCan: Bool = false
//    @State var dailyRecordDeleted: Bool = false
//    @State var dailyRecordUnhidden: Bool = false
    @State var hiddenOrDeletedIndex: Int = 0
    @State var recalculatingVisualValues_themeChanged: Bool = false // not used yet. Will be used to hide when calculation is on process
    
    @State var dailyRecordSetHiddenOrDeleted: Bool = false
    @State var isEditingTermGoals: Bool = false
    
    @State var newDailyRecordSetAdded: Bool = false
    @State var undoNewDRS: Bool = false
    
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let statusBarHeight:CGFloat = getStatusBarHeight()
        
        let backGroundColor:Color = getColorSchemeColor(colorScheme)
        
        let dailyRecordSetEmpty: Bool = selectedDailyRecordSet.dailyRecords!.filter({$0.isVisible()}).count == 0
        
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
                            dailyRecordSet: $selectedDailyRecordSet,
                            selectedDailyRecordSetIndex: $selectedDailyRecordSetIndex,
                            selectedRecord: $selectedRecord,
                            popUp_startNewRecordSet: $popUp_startNewRecordSet,
                            popUp_recordInDetail: $popUp_recordInDetail,
                            alert_drsHidden: $alert_drsHidden,
                            alert_drsInTrashCan: $alert_drsInTrashCan,
//                            dailyRecordSetHiddenOrDeleted: $dailyRecordSetHiddenOrDeleted,
                            popUp_changeStyle: $popUp_changeStyle,
                            isEditingTermGoals: $isEditingTermGoals,
                            undoNewDRS: $undoNewDRS
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
                
                let noSavedDailyRecords_visible: Bool = selectedDailyRecordSet.dailyRecords?.filter({$0.hasContent}).count == 0
                
                if noSavedDailyRecords_visible && selectedDailyRecordSetIndex == dailyRecordSets_visible.count - 1 && !isEditingTermGoals {
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
                
//                Text("기록의 탑")
//                    .frame(height: geoHeight*0.07)
//                    .position(CGPoint(x:geoWidth/2,y:geoHeight*0.035))
//                    .opacity(0.7)
                
//                if !isEditingTermGoals && selectedDailyRecordSet.termGoals.isEmpty {
//                    Text("나만의 목표를 설정하세요!")
//                        .opacity(0.5)
//                }
                
                
                if popUp_startNewRecordSet {
                    Color.gray.opacity(0.5)
                    StartNewRecordSet(
                        popUp_startNewRecordSet: $popUp_startNewRecordSet,
                        newDailyRecordSetAdded: $newDailyRecordSetAdded
                    )
                        .popUpViewLayout(width: geoWidth*0.9, height: (geoHeight-statusBarHeight)*0.9, color: backGroundColor)
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
                selectedDailyRecordSet = dailyRecordSets_visible[selectedDailyRecordSetIndex]
                updateSelectedDailyRecordSet = false // MARK: 무한 루프가 생성되지 않는다. 바꿔줘도 됨.
                updateStartAndEnd()
                selectedRecord = nil
            }
            
        }
        .onChange(of: dailyRecordSetHiddenOrDeleted) {
            
            if selectedDailyRecordSetIndex > dailyRecordSets_visible.count - 1 {
                selectedDailyRecordSetIndex -= 1
            }
            updateSelectedDailyRecordSet = true
        }

        .onChange(of: isNewDailyRecordAdded) { //
            selectedDailyRecordSetIndex = dailyRecordSets_visible.count - 1
        }
        .onChange(of: selectedView) {
            selectedDailyRecordSetIndex = dailyRecordSets_visible.count - 1
        }
        .onChange(of: newDailyRecordSetAdded) {
            selectedDailyRecordSetIndex = dailyRecordSets_visible.count - 1
        }
        
        
        .onChange(of: selectedDailyRecordSet.dailyRecordThemeName) {
            
            recalculatingVisualValues_themeChanged = true
//            recalculateVisualValues_themeChanged()
            recalculatingVisualValues_themeChanged = false
            
        }

        // index가 바뀌지 않아도 selectedDailyRecordSet가 바뀌는 경우(ex: 아무것도 안 쌓은 채로 다시 새로 dailyRecordSet 생성)
        // 그런 경우에도 selectedDailyRecordSet를 바꿔주기 위해서 이렇게 단계를 두개로 나눔.

    
                

        .alert("비어있는 기록의 탑을 생성 취소하고, 기존의 기록의 탑에 계속 기록하시겠습니까?",isPresented: $undoNewDRS) {
            Button("생성 취소") {
                let targetDRS: DailyRecordSet = selectedDailyRecordSet
                selectedDailyRecordSetIndex -= 1
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    modelContext.delete(targetDRS)
                }

                undoNewDRS.toggle()
            }
            Button("아니오") {
                undoNewDRS.toggle()
            }
        } message: {
            Text("(가장 최근의 기록의 탑은 기록이 없을 때만 삭제 가능합니다.)")
        }
//        .alert("해당 구간기록을 숨기시겠습니까?", isPresented: $alert_drsHidden) {
//            Button("숨기기") {
//                selectedDailyRecordSet.isHidden = true
//                dailyRecordSetHiddenOrDeleted.toggle()
//                alert_drsHidden.toggle()
//            }
//            Button("아니오") {
//                alert_drsHidden.toggle()
//            }
//        }
        .alert("해당 구간기록을 휴지통으로 이동하시겠습니까?", isPresented: $alert_drsInTrashCan) {
            Button("휴지통으로 이동") {
                selectedDailyRecordSet.inTrashCan = true
                dailyRecordSetHiddenOrDeleted.toggle()
                alert_drsInTrashCan.toggle()
            }
            Button("아니오") {
                alert_drsInTrashCan.toggle()
            }
        }
        
        
    }
    
    
    func updateStartAndEnd() -> Void {
        let dates: [Date] = selectedDailyRecordSet.dailyRecords!.compactMap{$0.date}.sorted()
        if let start: Date = dates.first {
            selectedDailyRecordSet.start = start
        }
        if let last: Date = dates.last {
            selectedDailyRecordSet.end = last
        }
    }
    

    
    
}




