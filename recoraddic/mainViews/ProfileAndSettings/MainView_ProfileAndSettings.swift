//
//  mainView.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

// 다양한 편의 기능 제공 -> 선택 -> 삭제/복구

// 처음부터 통째로 navigationStack으로 만들기

import SwiftUI
import SwiftData

struct MainView_ProfileAndSettings: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    
    @State var profile: Profile
//    @State var showHiddenQuests: Bool
    
    var body: some View {
        
//        let profile = profiles.first ?? Profile()
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let backButtonHeight = geoHeight*0.1
            
            
            NavigationView {
                List {
                    Section {
                        NavigationLink(
                            destination:
                                FilteredDatas(
                                    filteredOption: "isArchived"
                                    //                                selectedData: "quest"
                                )
                                .navigationTitle("보관한 퀘스트")
                                .navigationBarTitleDisplayMode(.inline)
                            
                            //                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
                        ) {
                            Text("보관한 퀘스트")
                        }
                        NavigationLink(
                            destination:
                                FilteredDatas(
                                    filteredOption: "isHidden"
                                    //                                selectedData: "dailyRecord"
                                )
                                .navigationTitle("숨긴 퀘스트")
                                .navigationBarTitleDisplayMode(.inline)
                            
                            //                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
                        ) {
                            Text("숨긴 퀘스트")
                        }
                        NavigationLink(
                            destination:
                                FilteredDatas(
                                    filteredOption: "inTrashCan"
                                    //                                selectedData: "dailyRecord"
                                )
                                .navigationTitle("삭제한 퀘스트")
                                .navigationBarTitleDisplayMode(.inline)
                            //                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
                        ) {
                            Text("삭제한 퀘스트")
                        }
                    }
                    
                    Toggle(isOn: $profile.showHiddenQuests) {
                        Text("숨긴 퀘스트 보기")
                    }
                    
                }
                .navigationTitle("설정")
            
                
            }
        }
            

    }
}


// tap -> detailView / slide right -> unhide / slide left -> delete ?
// MARK: List View 안의 section 이용

struct FilteredDatas: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    
    let filteredOption: String
    
    @State var popUp_quest: Bool = false
    @State var popUp_dailyRecord: Bool = false
    @State var popUp_dailyRecordSet: Bool = false
    @State var popUp_deleteQuest: Bool = false
    
    
    @State var selectedDailyRecord: DailyRecord? = nil
    @State var selectedQuest: Quest? = nil
    @State var selectedDailyRecordSet: DailyRecordSet? = nil
    
    
    @State var selectedQuestName: String = ""

    

    
    var body: some View {
        


        

        
        
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            

            let confirmationPopUp_width = geoWidth*0.7
            let confirmationPopUp_height = confirmationPopUp_width*0.7

            let reversedcolorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
            
            
                
            FilteredQuests(
                filteredOption: filteredOption,
                selectedQuest: $selectedQuest,
                selectedQuestName: $selectedQuestName,
                popUp_quest: $popUp_quest,
                alert_delete: $popUp_deleteQuest
            )
            .frame(width: geoWidth, height: geoHeight, alignment: .top)

//            .border(.gray)
//            .background(.red)

            
        }
        
    }
}
            

struct FilteredQuests: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort:\Quest.createdTime) var quests:[Quest]
    
    let filteredOption: String
    
    @Binding var selectedQuest: Quest?
    @Binding var selectedQuestName: String
    @Binding var popUp_quest: Bool
    @Binding var alert_delete: Bool
    
    @State var alert_sameName:Bool = false
    
    var body: some View {
        
        let quests_filtered:[Quest] = {
            if filteredOption == "isArchived" {
                return quests.filter({$0.isArchived})
            }
            else if filteredOption == "isHidden" {
                return quests.filter({$0.isHidden})
            }
            else if filteredOption == "inTrashCan" {
                return quests.filter({$0.inTrashCan})
            }
            else {
                return []
            }
        }()
        
        let questNames = quests.filter({!$0.inTrashCan}).map { $0.name }

        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
        
            let gridWidth = geoWidth*0.4
            let gridHeight = gridWidth / 1.618
            let gridItemSpacing = gridWidth/5
        
            if quests_filtered.count == 0 {
                Text("퀘스트 없음")
                    .frame(width:geoWidth, height: geoHeight)
            }
            else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:gridWidth))], spacing: gridItemSpacing) {
                        
                        ForEach(quests_filtered, id: \.createdTime) { quest in
                            //            GeometryReader { geometry in
                            Button(action:{
                                selectedQuest = quest
                                popUp_quest.toggle()
                            })
                            {
                                QuestThumbnailView(quest: quest)
                                    .frame(width:gridWidth, height: gridHeight)
                                
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button("되돌리기") {
                                    if quest.inTrashCan && questNames.contains(quest.name) {
                                        alert_sameName.toggle()
                                        return
                                    }
                                    quest.isArchived = false
                                    quest.isHidden = false
                                    quest.inTrashCan = false
                                    quest.deletedTime = nil
                                }
                                if filteredOption != "isArchived" {
                                    Button("보관") {
                                        quest.isArchived = true
                                        quest.isHidden = false
                                        quest.inTrashCan = false
                                        quest.deletedTime = nil
                                    }
                                }
                                if filteredOption != "isHidden" {
                                    Button("숨기기") {
                                        quest.isArchived = false
                                        quest.isHidden = true
                                        quest.inTrashCan = false
                                        quest.deletedTime = nil
                                    }
                                }
                                if filteredOption != "inTrashCan" {
                                    Button("휴지통으로 이동") {
                                        quest.isArchived = false
                                        quest.isHidden = false
                                        quest.inTrashCan = true
                                        quest.deletedTime = Date()
                                    }
                                }
                                if filteredOption == "inTrashCan" {
                                    Button("영구적으로 삭제") {
                                        selectedQuest = quest
                                        selectedQuestName = selectedQuest!.name
                                        alert_delete.toggle()
                                    }
                                }
//                                Button("삭제") {
//                                    selectedQuest = quest
//                                    selectedQuestName = selectedQuest!.name
//                                    popUp_deleteQuest.toggle()
//                                    
//                                }
                            }))
                            
                            .sheet(
                                isPresented: $popUp_quest,
                                content: {
                                    //
                                    QuestInDetail(selectedQuest: $selectedQuest, popUp_questStatisticsInDetail: $popUp_quest)
                                }
                            )
                            
                            
                        }
                        
                    }
                    .padding(.top, gridHeight*0.1)
                    
                    
                    
                }
                .frame(width:geoWidth, height: geoHeight)
                .alert("퀘스트 '\(selectedQuest?.name ?? "")' 를 영구적으로 삭제하시겠습니까?", isPresented: $alert_delete) {
                    Button("영구적으로 삭제") {
                        
                        let targetQuest: Quest = selectedQuest ?? Quest(name: "tmp", dataType: 0)
                        selectedQuest = nil
                        
                        alert_delete.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            modelContext.delete(targetQuest)
                        }
                    }
                    Button("취소") {
                        alert_delete.toggle()
                    }
                }
                .alert("같은 이름의 퀘스트가 존재합니다.",isPresented: $alert_sameName) {
                    Button("확인") {
                        alert_sameName.toggle()
                    }
                }

            }
            
        }

    }
}




struct PlainButtonStyleForList: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            configuration.label
                .frame(width: geometry.size.width, height: geometry.size.height)
                .foregroundStyle(getColorSchemeColor(colorScheme))

            
        }
    }

}
