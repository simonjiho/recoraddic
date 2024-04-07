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
    
    @Binding var isNewDailyRecordAdded: Bool
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let statusBarHeight:CGFloat = getStatusBarHeight()
        
        let backGroundColor:Color = getColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height

            ZStack {
                
                if !recalculatingVisualValues_themeChanged {
                    
                    if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_0" {
                        StoneTower_0(
                            dailyRecordSet: $selectedDailyRecordSet,
                            selectedDailyRecordSetIndex: $selectedDailyRecordSetIndex,
                            selectedRecord: $selectedRecord,
                            popUp_startNewRecordSet: $popUp_startNewRecordSet,
                            popUp_recordInDetail: $popUp_recordInDetail,
                            dailyRecordSetHidden: $dailyRecordSetHidden,
                            popUp_changeStyle: $popUp_changeStyle
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
                            popUp_changeStyle: $popUp_changeStyle
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
                if popUp_changeStyle {
                    Color.gray.opacity(0.5)
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
//                    dailyRecordHidden: $dailyRecordHidden,
//                    dailyRecordDeleted: $dailyRecordDeleted,
                    record: $selectedRecord

                )
                .background(colorSchemeColor)
                
                //TODO: light모드일 때,  Col
            }

                        
        }
        .onChange(of: selectedDailyRecordSetIndex) {
            updateSelectedDailyRecordSet = true
        }
        .onChange(of: selectedDailyRecordSetIndex) {
            selectedDailyRecordSet = dailyRecordSets_notHidden[selectedDailyRecordSetIndex]
            updateSelectedDailyRecordSet = false // MARK: onChange 클로저 안에서는 본인의 변화를 detect하지 않는 것 같다. 무한 루프가 생성되지 않는다. 바꿔줘도 됨.
            selectedRecord = nil
            
        }
        .onChange(of: dailyRecordSetHidden) {
            if selectedDailyRecordSetIndex > dailyRecordSets_notHidden.count - 1 {
                selectedDailyRecordSetIndex -= 1
            }
            updateSelectedDailyRecordSet = true
        }
        .onChange(of: isNewDailyRecordAdded, {
            
            selectedDailyRecordSetIndex = dailyRecordSets_notHidden.count - 1
        })
//        .onChange(of: dailyRecordHidden) { // visualValue's Modification is done inside ThemeView, not here
////            recalculateVisualValues_hiddenOrDeleted()
////            let hiddenRecord: DailyRecord = selectedRecord!
////            selectedRecord = nil
////            hiddenRecord.isHidden = true
//                recalculateVisualValues_hiddenOrDeleted(isHidden: true)
//
//        }
//        .onChange(of: dailyRecordDeleted) {  // visualValue's Modification is done inside ThemeView, not here
////            recalculateVisualValues_hiddenOrDeleted()
////            let deletedRecord: DailyRecord = selectedRecord!
////            selectedRecord = nil
////            modelContext.delete(deletedRecord)
//            recalculateVisualValues_hiddenOrDeleted(isDeleted: true)
//
//        }
        .onChange(of: selectedDailyRecordSet.dailyRecordThemeName) {
            
            recalculatingVisualValues_themeChanged = true
            recalculateVisualValues_themeChanged()
            recalculatingVisualValues_themeChanged = false
            
        }
        
        // index가 바뀌지 않아도 selectedDailyRecordSet가 바뀌는 경우(ex: 아무것도 안 쌓은 채로 다시 새로 dailyRecordSet 생성)
        // 그런 경우에도 selectedDailyRecordSet를 바꿔주기 위해서 이렇게 단계를 두개로 나눔.

    
                

        
        
    }
    

    
    
}




