//
//  EditCheckListView.swift
//  recoraddic
//
//  Created by 김지호 on 7/16/24.
//


import Foundation
import SwiftUI
import SwiftData

// TODO: 달성 버튼 / ox는 바로 추가 / 프리셋 버튼

struct EditCheckListView: View {
    
    //    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(MountainsViewModel.self) var mountainsViewModel
    
    @State var presetsViewModel: PresetsViewModel = .init()
    
    @Binding var dailyRecordsViewModel: DailyRecordsViewModel
    var showHiddenMountains: Bool
    var currentDailyRecord: DailyRecord_fb
    @Binding var popUp_self: Bool
    @Binding var selectedView: MainViewName
    let todoIsEmpty: Bool
    
    
    @State var mountainIds_tmp: [String] = []
    @State var todos_tmp: [String] = []
    @FocusState var focusField: Bool
    @State var createNewPreset: Bool = false
    @State var newTodoPresetName = ""
    
    @State var showHelp:Bool = false
    
    @State var appendOption: AppendOption = .mountain
    
    
    
    var body: some View {
        
        
        let mountains = mountainsViewModel.mountains
        let mountains_visible = mountains.filter({$0.value.isVisible()})
        //        let mountains_visible =  {
        //            if showHiddenMountains {
        //                return mountains.filter({$0.isVisible() || $0.isHidden })
        //            } else {
        //                return mountains.filter({$0.isVisible()})
        //            }
        //        }()
        
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let contentWidth = geoWidth*0.95
            let boxHeight = geoHeight*0.4
            let elmWidth = contentWidth*0.9
            //            let mountainElmHeight = geoHeight*0.05
            let mountainElmHeight:CGFloat = 45.0
            let todoPresetElmHeight:CGFloat = 40.0
            let todoElmHeight:CGFloat = 35.0
            
            
            
            VStack {
                
                ScrollView {
                    if mountains_visible.isEmpty {
                        Button(action:{
                            popUp_self.toggle()
                            selectedView = .gritBoardAndStatistics}){
                                // TODO: 바로 새로운 퀘스트 누른 것처럼 만들기
                                Text("새로운 누적 기록 만들기")
                                    .padding()
                            }
                            .padding()
                        
                    }
                    else {
                        let mountainIdsNowAndWill: [String] = dailyRecordsViewModel.currentDailyRecord.ascentData.keys + mountainIds_tmp
                        let mountains_notAdded: [Mountain_fb] = mountains_visible
                            .filter({
                                mountain in !(mountainIdsNowAndWill.contains(mountain.id))
                            })
                            .sorted(by:{
                                if $0.momentumLevel != $1.momentumLevel {
                                    return $0.momentumLevel > $1.momentumLevel
                                } else if $0.tier != $1.tier {
                                    return $0.tier > $1.tier
                                }
                                else if $0.dataType != $1.dataType {
                                    return $0.dataType < $1.dataType  // Sort by Age in ascending order
                                }
                                //                                    else if $0.name != $1.name {
                                //                                        return $0.name < $1.name  // Sort by Age in ascending order
                                //                                    }
                                else {
                                    return $0.createdTime > $0.createdTime
                                }
                                
                            })
                        //                                ForEach(mountains_notHidden) { mountain in
                        //                                ForEach(mountains_notAdded, id:\.id) { mountain in
                        ForEach(mountains_notAdded, id:\.name) { mountain in
                            Button(action:{
                                mountainIds_tmp.append(mountain.id)
                            }) {
                                
                                HStack(spacing:0.0) {
                                    Image(systemName: "plus")
                                        .frame(width:elmWidth*0.09)
                                    
                                    Text(mountain.getName())
                                        .frame(width:elmWidth*0.75)
                                    
                                    
                                    FireView(momentumLevel: mountain.momentumLevel)
                                        .frame(width:elmWidth*0.09,height:mountainElmHeight*0.9)
                                    
                                    
                                }
                                .padding()
                                .frame(width:elmWidth, height:mountainElmHeight)
                                .foregroundStyle(getDarkTierColorOf(tier: mountain.tier))
                                .bold()
                                //                                    .background(getBrightTierColorOf(tier: mountain.tier))
                                .background(
                                    Rectangle()
                                        .fill(getTierColorOf(tier: mountain.tier))
                                )
                                .clipShape(.buttonBorder)
                            }
                            .buttonStyle(.plain)
                            
                        }
                    }
                }
                .scrollIndicators(.visible)
                .padding()
                .frame(width: geoWidth*0.95, height: geoHeight*0.4, alignment: .top)
                .background(.gray.opacity(0.3))
                .clipShape(.rect(cornerRadius: geoWidth*0.05))
                
                Image(systemName: "arrow.down")
                    .bold()
                    .padding()
                
                
                VStack {
                    ScrollView {
                        ForEach(mountainIds_tmp) { mountainId in
                            let mountainName = mountainsViewModel.nameOf(mountainId)
                            let mountainTier = mountainsViewModel.tierOf(mountainId)
                            
                            HStack(spacing:0.0) {
                                Text(mountainName)
                                    .padding()
                                    .frame(width:elmWidth*0.9, height:mountainElmHeight)
                                    .foregroundStyle(getDarkTierColorOf(tier: mountainTier))
                                    .bold()
                                    .background(
                                        Rectangle()
                                            .fill(getTierColorOf(tier: mountainTier))
                                    )
                                    .clipShape(.buttonBorder)
                                Button (action: {
                                    if let idx = mountainIds_tmp.firstIndex(where: {$0 == mountainId}) {
                                        mountainIds_tmp.remove(at: idx)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .frame(width:elmWidth*0.1)
                                
                                
                            }
                            .frame(width:elmWidth, height:mountainElmHeight)
                            
                        }
                        
                        
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Button(action:{popUp_self.toggle()}) {
                            Text("취소")
                        }
                        .frame(width: geoWidth*0.4, alignment: .leading)
                        Button(action:{
                            addAll()
                            try? modelContext.save()
                            popUp_self.toggle()
                        }) {
                            Text("추가")
                        }
                        .frame(width: geoWidth*0.4, alignment: .trailing)
                        .disabled(mountainIds_tmp.isEmpty)
                    }
                    
                }
                .padding()
                .frame(width: geoWidth*0.95, height: geoHeight*0.4)
                .background(.gray.opacity(0.3))
                .clipShape(.rect(cornerRadius: geoWidth*0.05))
                
                
                
            }
            .frame(width: geoWidth, height: geoHeight)
        }
    }
        
    func addAll() -> Void {
        dailyRecordsViewModel.createAscentData(mountainIds_tmp)
    }
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
