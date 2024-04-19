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
                            HiddenDatas()
//                            .frame(width:geometry.size.width, height: geoHeight) //MARK: potential problem caused by the frame size.
                            // MARK: frame을 지정한 이유 -> destination의 기본 frame의 height 값이 좀 작음. 그래서 크게 만들었다.
                            // 크기 지정하니까 작동 안하네?! ㅅㅂ
//                            .border(.red)
//                            .background(.white)
                    ) {
                        Text("숨긴 데이터")
                    }
                }
                .navigationTitle("설정")
            
                
            }
        }
            

    }
}


// tap -> detailView / slide right -> unhide / slide left -> delete ?
// MARK: List View 안의 section 이용

struct HiddenDatas: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
//    @Query(sort:\DailyRecord.date) var dailyRecords:[DailyRecord]
    @Query(sort:\DailyRecordSet.createdTime) var dailyRecordSets:[DailyRecordSet]
//    @Query(sort:\Quest.createdTime) var quests:[Quest]
    
    @State var popUp_quest: Bool = false
    @State var popUp_dailyRecord: Bool = false
    @State var popUp_dailyRecordSet: Bool = false
    @State var popUp_deleteQuest: Bool = false
    
    
    @State var selectedDailyRecord: DailyRecord? = nil
    @State var selectedQuest: Quest? = nil
    @State var selectedDailyRecordSet: DailyRecordSet? = nil
    
    @State var selectedData: String = "quest"
    
    @State var selectedQuestName: String = ""
    
    
//    var dailyRecords_hidden: [DailyRecord] {
//        dailyRecords.filter({$0.hide})
//    }
    var dailyRecordSets_hidden: [DailyRecordSet] {
        dailyRecordSets.filter({$0.isHidden})
    }
//    var dailyRecords_saved: [DailyRecord] {
//        dailyRecords.filter({$0.visualValue1 != nil})
//    }
    
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

                    Picker("wow", selection: $selectedData) {
                        Text("숨긴 퀘스트").tag("quest")
                        Text("숨긴 일일기록").tag("dailyRecord")
                        Text("숨긴 구간기록").tag("dailyRecordSet")
                    }
                    .foregroundStyle(.foreground)
                    .pickerStyle(.menu)
                    .padding(.horizontal,10)
                    .frame(width: geoWidth, alignment: .trailing)
//                    .border(.red)
                    switch selectedData {
                    case "quest":
                        HiddenQuests(
                            selectedQuest: $selectedQuest,
                            selectedQuestName: $selectedQuestName,
                            popUp_quest: $popUp_quest,
                            popUp_deleteQuest: $popUp_deleteQuest
                        )
                            .frame(width: geoWidth)
                    case "dailyRecord":
                        HiddenDailyRecords(
                            selectedDailyRecord: $selectedDailyRecord,
                            popUp_dailyRecord: $popUp_dailyRecord
                        )
                        .frame(width: geoWidth)


                    case "dailyRecordSet":
                        List {
                            ForEach(dailyRecordSets_hidden, id: \.createdTime) { dailyRecordSet in
                                //            GeometryReader { geometry in
                                Button(action:{
                                    selectedDailyRecordSet = dailyRecordSet
                                    popUp_dailyRecordSet.toggle()
                                })
                                {
                                    Text("\(yyyymmddFormatOf(dailyRecordSet.start)) ~ \(yyyymmddFormatOf(dailyRecordSet.end!)) ")
                                    
                                }
                                .sheet(
                                    isPresented: $popUp_dailyRecordSet,
                                    content: {
                                        // DailyRecordStatistics
                                    }
                                )
                                
                            }
                        }
                        
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
    
    @Binding var selectedQuest: Quest?
    @Binding var selectedQuestName: String
    @Binding var popUp_quest: Bool
    @Binding var popUp_deleteQuest: Bool
    
    var body: some View {
        
        let quests_hidden: [Quest] = quests.filter({$0.isHidden})
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
        
            let gridItemSize = geoWidth*0.26
            let gridItemSpacing = gridItemSize/5
        
            if quests_hidden.count == 0 {
                Text("숨긴 퀘스트 없음")
                    .frame(width:geoWidth, height: geoHeight)
            }
            else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:gridItemSize))], spacing: gridItemSpacing) {
                        
                        ForEach(quests_hidden, id: \.createdTime) { quest in
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
                                    QuestStatisticsInDetail(selectedQuest: $selectedQuest, popUp_questStatisticsInDetail: $popUp_quest)
                                }
                            )
                            
                            
                        }
                        
                    }
                    
                    
                    
                }
                .frame(width:geoWidth, height: geoHeight)

            }
            
        }

    }
}


struct HiddenDailyRecords: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort:\DailyRecord.date) var dailyRecords:[DailyRecord]

    @Binding var selectedDailyRecord: DailyRecord?
    @Binding var popUp_dailyRecord: Bool
    
    var body: some View {
        
        let dailyRecords_hidden: [DailyRecord] = dailyRecords.filter({$0.hide})
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            if dailyRecords_hidden.count == 0 {
                Text("숨긴 일일기록 없음")
                    .frame(width:geoWidth, height: geoHeight)

            }
            else {
                List {
                    ForEach(dailyRecords_hidden, id: \.createdTime) { dr in
                        //            GeometryReader { geometry in
                        Button(action:{
                            selectedDailyRecord = dr
                            popUp_dailyRecord.toggle()
                        })
                        {
                            Text("\(yyyymmddFormatOf(dr.date!))")
                            
                        }
                        
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
