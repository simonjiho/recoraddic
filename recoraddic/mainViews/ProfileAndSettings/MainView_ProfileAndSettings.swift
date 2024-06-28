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



    
    var body: some View {
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
                            .navigationTitle("숨김")
                            .navigationBarTitleDisplayMode(.inline)

//                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
                    ) {
                        Text("숨김")
                    }
                    NavigationLink(
                        destination:
                            FilteredDatas(
                                filteredOption: "inTrashCan"
//                                selectedData: "dailyRecord"
                            )
                            .navigationTitle("휴지통")
                            .navigationBarTitleDisplayMode(.inline)
//                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
                    ) {
                        Text("휴지통")
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
    @State var selectedData: String = "quest"

    

    
    var body: some View {
        


        

        
        
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            

            let confirmationPopUp_width = geoWidth*0.7
            let confirmationPopUp_height = confirmationPopUp_width*0.7

            let reversedcolorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
            
            
            ZStack {
                VStack {
//                    Text("숨겨진 \()")

                    if filteredOption != "isArchived" {
                        
                        Picker("wow", selection: $selectedData) {
                            Text("퀘스트").tag("quest")
                            Text("일일기록").tag("dailyRecord")
                            Text("구간기록").tag("dailyRecordSet")
                            
                        }
                        .foregroundStyle(.foreground)
                        .pickerStyle(.menu)
                        .padding(.horizontal,10)
                        .frame(width: geoWidth, alignment: .trailing)
                    }
//                    .border(.red)
                    switch selectedData {
                    case "quest":
                        HiddenQuests(
                            filteredOption: filteredOption,
                            selectedQuest: $selectedQuest,
                            selectedQuestName: $selectedQuestName,
                            popUp_quest: $popUp_quest,
                            popUp_deleteQuest: $popUp_deleteQuest
                        )
                            .frame(width: geoWidth)
                    case "dailyRecord":
                        HiddenDailyRecords(
                            filteredOption: filteredOption,
                            selectedDailyRecord: $selectedDailyRecord,
                            popUp_dailyRecord: $popUp_dailyRecord
                        )
                        .frame(width: geoWidth)


                    case "dailyRecordSet":
                        HiddenDailyRecordSets(filteredOption: filteredOption)
                            .frame(width: geoWidth)

                        
                    default:
                        Text("undefined")
                    }
                }
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
            

struct HiddenQuests: View {
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


struct HiddenDailyRecords: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort:\DailyRecord.date) var dailyRecords:[DailyRecord]

    let filteredOption: String

    
    @Binding var selectedDailyRecord: DailyRecord?
    @Binding var popUp_dailyRecord: Bool
    
    var body: some View {
        
        let dailyRecords_filtered: [DailyRecord] = {
            if filteredOption == "isHidden" {
                return dailyRecords.filter({$0.isHidden})
            }
            else if filteredOption == "inTrashCan" {
                return dailyRecords.filter({$0.inTrashCan})

            }
            else {
                return []
            }
            
        }()
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            if dailyRecords_filtered.count == 0 {
                Text("일일기록 없음")
                    .frame(width:geoWidth, height: geoHeight)

            }
            else {
                List {
                    ForEach(dailyRecords_filtered, id: \.createdTime) { dr in
                        //            GeometryReader { geometry in
                        Button(action:{
                            selectedDailyRecord = dr
                            popUp_dailyRecord.toggle()
                        })
                        {
                            Text("\(yyyymmddFormatOf(dr.date!))")
                            
                        }
                        
                    }
                }
                .frame(width:geoWidth, height: geoHeight)
                .sheet(
                    isPresented: $popUp_dailyRecord,
                    content: {
                        
                        RecordInDetailView_optional(
                            popUp_recordInDetail: $popUp_dailyRecord,
                            record: $selectedDailyRecord
                        )
                        
                    }
                )


            }
            
        }
        
        

    }
}

struct HiddenDailyRecordSets: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort:\DailyRecordSet.createdTime) var dailyRecordSets:[DailyRecordSet]
    
    @State var showingAlert: Bool = false
    @State var selectedDrs: DailyRecordSet? = nil

    let filteredOption: String

    var body: some View {
        
        let dailyRecordSets_filtered: [DailyRecordSet] = {
            if filteredOption == "isHidden" {
                return dailyRecordSets.filter({$0.isHidden})
            }
            else if filteredOption == "inTrashCan" {
                return dailyRecordSets.filter({$0.inTrashCan})
            }
            else {
                return []
            }
            
        }()
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            if dailyRecordSets_filtered.count == 0 {
                Text("구간기록 없음")
                    .frame(width:geoWidth, height: geoHeight)
            }
            else {
                List {
                    ForEach(dailyRecordSets_filtered, id: \.createdTime) { dailyRecordSet in
                        //            GeometryReader { geometry in
                        Menu {
                            Button("되돌리기") {
                                dailyRecordSet.isHidden = false
                                dailyRecordSet.inTrashCan = false
                            }
                            
                            if filteredOption == "isHidden" {
                                Button("휴지통으로 이동") {
                                    dailyRecordSet.isHidden = false
                                    dailyRecordSet.inTrashCan = true
                                }
                            }
                            if filteredOption == "inTrashCan" {
                                Button("영구 삭제") {
//
                                    selectedDrs = dailyRecordSet
                                    showingAlert.toggle()
                                }
                            }
                            
                        } label: {
                            
                            Text("\(yyyymmddFormatOf(dailyRecordSet.start)) ~ \(yyyymmddFormatOf(dailyRecordSet.end!)) ")
                            
                        }

                    }
                }
                .alert("해당 구간기록을 영구적으로 삭제하시겠습니까?", isPresented: $showingAlert) {
                    Button("Ok") {
                        let targetDrs: DailyRecordSet = selectedDrs!
                        modelContext.delete(targetDrs)
                        selectedDrs = nil
                        showingAlert.toggle()}
                    Button("no..") {showingAlert.toggle()}
                } message: {
                    Text("(당일, 전날의 일일기록을 제외하고는 퀘스트의 기록에 영향을 끼치지 않습니다.)")
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
