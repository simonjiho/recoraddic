////
////  AddQuestView.swift
////  recoraddic
////
////  Created by 김지호 on 12/17/23.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
//// TODO: 달성 버튼 / ox는 바로 추가 / 프리셋 버튼
//
//struct AddDailyQuestView: View {
//    
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.colorScheme) var colorScheme
//
//    
//    @Query var quests: [Quest]
//    var quests_notHidden: [Quest] {
//        quests.filter({$0.isVisible()})
//    }
//    
//    @Query(sort:\Todo_preset.createdTime) var todos_preset: [Todo_preset]
//    
//    
//    var currentDailyRecord: DailyRecord
//    
//    @Binding var popUp_addDailyQuest: Bool
//    @Binding var selectedView: MainViewName
//    var isDone: Bool
//    
//    
//    @State var step: Int = 0
//    
//    @State var loadQuest: Bool = false
//    
//    @State var questNameToAppend = ""
//    @State var questDataTypeToAppend = DataType.OX
//    @State var customDataTypeNotation: String?
//    @State var customDataTypeNotation_textField: String = ""
//    
//    @State var questValueToAppend_String: String = ""
//    @State var questValueToAppend_Int: Int = 0
//    @State var questPurposesToAppend: Set<String> = Set()
//    @State var popUp_choosePurpose: Bool = false
//    
////    var newQuest: Quest = Quest(name: "tmpQuest", dataType: DataType.NONE)
//    @State var selectedQuestNames: [String] = []
//    @State var selectedTodoPresetName: [String] = []
//    @State var isDiarySelected: Bool = false
//    
//    var body: some View {
//        
//        
//        
//        GeometryReader { geometry in
//
//            VStack {
//                Button(action:{popUp_addDailyQuest.toggle()}) {
//                    Image(systemName: "xmark")
//                }
//                .frame(width: geometry.size.width*0.9, height: geometry.size.height*0.06, alignment: .trailing)
//                ZStack {
//                    //                    if step == 0 {
//                    VStack {
//                        Text("추가할 누적 퀘스트를 고르세요")
//
//                        ForEach(quests_notHidden) { quest in
//                            Button(quest.name) {
//                                addDailyQuest(quest)
//                                popUp_addDailyQuest.toggle()
//                            }
//                            .buttonStyle(.plain)
//                        }
//                        
//                        ForEach(todos_preset) { todo_preset in
//                            // 새로운 todo_preset은 어떻게 추가하는 것이 좋을까.....??????
//                        }
//                        
//                        
//                        Text("일기")
//                            
//                        
//
//                    }
//
//
//                    
//                    if quests_notHidden.isEmpty {
//                        Button(action:{
//                            popUp_addDailyQuest.toggle()
//                            selectedView = .gritBoardAndStatistics}){
//                            // TODO: 바로 새로운 퀘스트 누른 것처럼 만들기
//                            Text("새로운 누적 퀘스트 만들기")
//                        }
//
//                    }
//                }
//            }
//        }
//    }
//
//    func addDailyQuest(_ quest: Quest) -> Void {
//        let dailyQuest = DailyQuest(
//            questName: quest.name,
//            data: 0,
//            dataType: quest.dataType,
//            defaultPurposes: quest.recentPurpose
//        )
//        
//        dailyQuest.dailyRecord = currentDailyRecord
//        dailyQuest.currentTier = quest.tier
//        dailyQuest.customDataTypeNotation = quest.customDataTypeNotation
//        modelContext.insert(dailyQuest)
//        
//        
//        
//    }
//    
//    
//    
//
//
//    
//
//}
//
//
//
//
//
//
//
//
//struct DialForHours_addFreeSet: View {
//    @Environment(\.modelContext) private var modelContext
//
//
//    var selectedQuest: Quest
//    @Binding var isEditing: Bool
//    
//
//    @State var value: Int = 0
//    @State var hour = 0
//    @State var minute = 0
//
//    var body: some View {
//        GeometryReader { geometry in
//            let geoWidth: CGFloat = geometry.size.width
//            let geoHeight: CGFloat = geometry.size.height
//            VStack {
//                
//                ZStack {
//                    Text(selectedQuest.name)
//                        .font(.title3)
//                    HStack(spacing:0.0) {
//                        Button("취소") {
//                            value = 0
//                            isEditing.toggle()
//                        }
//                        .padding(.leading, 10)
//                        .frame(width: (geometry.size.width*0.5), alignment: .leading)
//                        Button("추가") {
//                            value = hour*60  + minute
//                            selectedQuest.freeSetDatas.append(value)
//                            isEditing.toggle()
//                        }
//                        .padding(.trailing, 10)
//                        .frame(width: (geometry.size.width*0.5), alignment: .trailing)
//                    }
//                }
//                .frame(width: geometry.size.width)
//                .padding(.top, 10)
////                .border(.red)
//                
//                HStack(spacing:0.0) {
//                    
//                    
//                    Picker(selection: $hour, label: Text("First Value")) {
//                        ForEach(0..<25) { i in
//                            Text("\(i)").tag(i)
//                        }
//                    }
//                    .frame(width: 50)
//                    .clipped()
//                    .pickerStyle(.wheel)
//                    Text("시간  ")
//                    Picker(selection: $minute, label: Text("Second Value")) {
//                        ForEach(0..<60) { i in
//                            Text("\(i)").tag(i)
//                        }
//                    }
//                    .frame(width: 50)
//                    .clipped()
//                    .pickerStyle(.wheel)
//                    Text("분")
//                        .minimumScaleFactor(0.5)
//                        .lineLimit(1)
//                    
//                    
//                }
//            }
////            .onChange(of: hour) {
////                if hour == 24 {
////                    withAnimation {
////                        minute = 0
////                    }
////                }
////                value = hour*10  + minute
////
////            }
////            .onChange(of: minute) {
////                if hour == 24 {
////                    withAnimation {
////                        minute = 0
////                    }
////                }
////                value = hour*10  + minute
////
////            }
//            .frame(height: geoHeight)
//            // hour아닌것도 만들기
//
//        }
//    }
//}
//
//
//struct CheckboxToggleStyle: ToggleStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        GeometryReader { geometry in
//            
//            HStack {
//                configuration.label
//                Spacer()
////                    .frame(width:geometry.size.width)
//                Button(action: { configuration.isOn.toggle() }) {
//                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
//                        .resizable()
//                        .frame(width: geometry.size.height*0.8, height: geometry.size.height*0.8)
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
//            .frame(width:geometry.size.width, height: geometry.size.height)
//        }
//    }
//}
