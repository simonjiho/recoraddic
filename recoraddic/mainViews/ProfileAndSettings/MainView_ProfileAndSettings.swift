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
            
            
            ZStack {
                
                FilteredQuests(
                    filteredOption: filteredOption,
                    selectedQuest: $selectedQuest,
                    selectedQuestName: $selectedQuestName,
                    popUp_quest: $popUp_quest,
                    popUp_deleteQuest: $popUp_deleteQuest
                )
                .frame(width: geoWidth, height: geoHeight, alignment: .top)
                
                if popUp_deleteQuest {
                    Color.gray
                        .opacity(0.1)
                        .onTapGesture {
                            popUp_deleteQuest.toggle()
                        }
                    VStack(spacing:0.0) {
                        
                        
                        Text("퀘스트 \"\(selectedQuestName)\"를")
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.bottom, confirmationPopUp_height*0.1)
                        Text("정말로 삭제하시겠습니까?")
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.bottom, confirmationPopUp_height*0.2)
                            

                        
                        HStack {
                            Button("예") {
                                modelContext.delete(selectedQuest!)
                                selectedQuest = nil
                                selectedQuestName = ""
                                popUp_deleteQuest.toggle()
                            }
                            .frame(width: confirmationPopUp_width*0.5)
                            Button("아니오") {
                                selectedQuest = nil
                                selectedQuestName = ""
                                popUp_deleteQuest.toggle()
                            }
                            .frame(width: confirmationPopUp_width*0.5)
                        }
                

                    }
                        .frame(width: confirmationPopUp_width, height: confirmationPopUp_width*0.65)
                        .background(.background)
                        .clipShape(.rect(cornerSize: CGSize(width: confirmationPopUp_width*0.1, height: confirmationPopUp_width*0.65*0.1)))
                        .shadow(color:reversedcolorSchemeColor,radius: 5)
                }
                
                
            }
            .frame(width: geoWidth, height: geoHeight)
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
    @Binding var popUp_deleteQuest: Bool
    
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
        
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
        
            let gridItemSize = geoWidth*0.26
            let gridItemSpacing = gridItemSize/5
        
            if quests_filtered.count == 0 {
                Text("퀘스트 없음")
                    .frame(width:geoWidth, height: geoHeight)
            }
            else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:gridItemSize))], spacing: gridItemSpacing) {
                        
                        ForEach(quests_filtered, id: \.createdTime) { quest in
                            //            GeometryReader { geometry in
                            Button(action:{
                                selectedQuest = quest
                                popUp_quest.toggle()
                            })
                            {
                                QuestThumbnailView(quest: quest)
                                    .frame(width:gridItemSize, height: gridItemSize)
                                
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button("되돌리기") {
                                    quest.isHidden = false
                                }
                                
                                Button("삭제") {
                                    selectedQuest = quest
                                    selectedQuestName = selectedQuest!.name
                                    popUp_deleteQuest.toggle()
                                    
                                }
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
                    .padding(.top, gridItemSize*0.1)
                    
                    
                    
                }
                .frame(width:geoWidth, height: geoHeight)

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
