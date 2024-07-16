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
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    @Query var quests: [Quest]
    var quests_notHidden: [Quest] {
        quests.filter({$0.isVisible()})
    }
    @Query(sort:\Todo_preset.createdTime) var todos_preset: [Todo_preset]
    
    
    var currentDailyRecord: DailyRecord
    @Binding var popUp_self: Bool
    @Binding var selectedView: MainViewName
    let todoIsEmpty: Bool
    
    
    @State var dailyQuests_tmp: [DailyQuest] = []
    @State var todos_tmp: [Todo] = []
    @FocusState var focusField: Bool
    @State var createNewPreset: Bool = false
    @State var newTodoPresetName = ""
    
    @State var showHelp:Bool = false
    
    enum AppendOption :String, CaseIterable, Identifiable  {
        case quest
        case todo
        var id: String { self.rawValue }
        static let appendOption_kor:[AppendOption:String] = [.quest:"누적퀘스트",.todo:"일반퀘스트"]

    }

    @State var appendOption: AppendOption = .quest
    
    @State var addEmptyTodo: Bool = false
    
    
    var body: some View {
        
        
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let contentWidth = geoWidth*0.95
            let boxHeight = geoHeight*0.4
            let elmWidth = contentWidth*0.9
            let questElmHeight = geoHeight*0.05
            let todoPresetElmHeight = geoHeight*0.04
            let todoElmHeight = geoHeight*0.03

            
            VStack {
                
                VStack {
                    Picker("", selection: $appendOption, content: {
                        ForEach(AppendOption.allCases) { option in
                            Text(AppendOption.appendOption_kor[option] ?? "")
                                .tag(option)
                        }
                    })
                        .labelsHidden()
                        .pickerStyle(.segmented)

                        
                    
                    ScrollView {
                        if appendOption == .quest {
                            if quests_notHidden.isEmpty {
                                Button(action:{
                                    popUp_self.toggle()
                                    selectedView = .gritBoardAndStatistics}){
                                    // TODO: 바로 새로운 퀘스트 누른 것처럼 만들기
                                    Text("새로운 누적 퀘스트 만들기")
                                            .padding()
                                }
                                    .padding()

                            }
                            else {
                                
                                ForEach(quests_notHidden) { quest in
                                    
                                    Button(action:{
                                        let newDailyQuest_tmp = DailyQuest(questName: quest.name, data: 0, dataType: quest.dataType, defaultPurposes: quest.recentPurpose, customDataTypeNotation: quest.customDataTypeNotation)
                                        newDailyQuest_tmp.dailyRecord = currentDailyRecord
                                        newDailyQuest_tmp.currentTier = quest.tier
                                        dailyQuests_tmp.append(newDailyQuest_tmp)
                                    }) {
                                        
                                        HStack(spacing:0.0) {
                                            //                                        FireView(momentumLevel: quest.momentumLevel)
                                            FireView(momentumLevel: quest.momentumLevel)
                                                .frame(width:elmWidth*0.09, height: elmWidth*0.85)
                                            Text(quest.name)
                                                .frame(width:elmWidth*0.75)
                                            Image(systemName: "plus")
                                                .frame(width:elmWidth*0.09)
                                        }
                                        .padding()
                                        .frame(width:elmWidth, height:questElmHeight)
                                        .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                                        .bold()
                                        //                                    .background(getBrightTierColorOf(tier: quest.tier))
                                        .background(
                                            Rectangle()
                                                .fill (LinearGradient(colors: getGradientColorsOf(tier: quest.tier), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                      )
                                        )
                                        .clipShape(.buttonBorder)
                                    }
                                    .buttonStyle(.plain)
                                    
                                }
                            }
                        }
                        else if appendOption == .todo {
                            Group {
                                
                                Group {
                                    ZStack {
                                        Button(action:{
                                            addEmptyTodo = true
                                            todos_tmp = []
                                        }) {
                                            Text("비어있는 일반 퀘스트")
                                                .frame(width:elmWidth, height: todoPresetElmHeight)
                                                .background(.gray.opacity(0.5))
                                                .clipShape(.buttonBorder)
                                            
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!todoIsEmpty)
                                        
                                        Button(action:{
                                            showHelp.toggle()
                                        }) {
                                            Image(systemName:"questionmark.circle")
                                        }
                                        .padding()
                                        .frame(width:elmWidth, height: todoPresetElmHeight, alignment:.trailing)
                                        .popover(isPresented: $showHelp) {
                                            Text("일반 퀘스트가 하나 이상 존재하면 이 버튼을 사용할 수 없습니다. 이미 존재하는 일반 퀘스트를 클릭한 후 엔터키를 입력해보세요.")
                                                .padding()
                                                .font(.caption)
                                                .presentationCompactAdaptation(.popover)
                                        }
                                        
                                        
                                        
                                        
                                        
                                    }
                                    .frame(width:elmWidth, height: todoPresetElmHeight)
                                    
                                    
                                    
                                    ForEach(todos_preset) { todo_preset in
                                        HStack(spacing:0.0) {
                                            Button(action:{
                                                let newTodo_tmp = Todo(content: todo_preset.content)
                                                newTodo_tmp.purpose = todo_preset.purpose
                                                todos_tmp.append(newTodo_tmp)
                                            }) {
                                                
                                                HStack(spacing:0.0) {
                                                    Text(todo_preset.content)
                                                        .padding()
                                                        .frame(width:elmWidth*0.8, alignment:.leading)
                                                        .multilineTextAlignment(.leading)
                                                    Image(systemName: "plus")
                                                        .frame(width:elmWidth*0.07)
                                                    
                                                }
                                                .frame(width:elmWidth*0.9, height:todoPresetElmHeight)
                                                .background(.gray.opacity(0.5))
                                                .clipShape(.buttonBorder)
                                                
                                            }
                                            .buttonStyle(.plain)
                                            
                                            Button (action: {
                                                modelContext.delete(todo_preset)
                                            }) {
                                                Image(systemName: "xmark")
                                            }
                                            .frame(width:elmWidth*0.1)
                                            
                                        }
                                        
                                        .frame(width:elmWidth, height:todoPresetElmHeight)
                                        
                                        
                                        
                                    }
                                }
                                .disabled(createNewPreset)
                                if createNewPreset {
                                    TextField("자주 사용하는 일일퀘스트를 생성하세요.", text: $newTodoPresetName)
                                        .padding()
                                        .frame(width:elmWidth, height:todoPresetElmHeight)
                                        .onSubmit {
                                            focusField.toggle()
                                            if newTodoPresetName != "" {
                                                modelContext.insert(Todo_preset(content: newTodoPresetName))
                                                newTodoPresetName = ""
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                }
                                            }
                                            createNewPreset.toggle()
                                            
                                        }
                                        .focused($focusField)
                                        .keyboardShortcut(.end)
                                    
                                }
                                else {
                                    
                                    Button(action:{
                                        createNewPreset.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            focusField = true
                                        }
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                    .padding()
                                }
                            }
                            .disabled(addEmptyTodo)
                            
                        }
                        else {
                            // later, add dailyPreset
                        }
                    }
                    
                }
                .padding()
                .frame(width: geoWidth*0.95, height: geoHeight*0.4, alignment: .top)
                .background(.gray.opacity(0.3))
                .clipShape(.rect(cornerRadius: geoWidth*0.05))
                
                
                Image(systemName: "arrow.down")
                    .bold()
                    .padding()
                
                
                VStack {
                    ScrollView {
                        ForEach(dailyQuests_tmp) { dailyQuest in

                            
                            HStack(spacing:0.0) {
                                Text(dailyQuest.questName)
                                    .padding()
                                    .frame(width:elmWidth*0.9, height:questElmHeight)
                                    .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))
                                    .bold()
                                    .background(
                                        Rectangle()
                                            .fill (LinearGradient(colors: getGradientColorsOf(tier: dailyQuest.currentTier), startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                        )
                                    .clipShape(.buttonBorder)
                                Button (action: {
                                    if let idx = dailyQuests_tmp.firstIndex(where: {$0 == dailyQuest}) {
                                        modelContext.delete(dailyQuest)
                                        dailyQuests_tmp.remove(at: idx)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .frame(width:elmWidth*0.1)

                                    
                            }
                            .frame(width:elmWidth, height:questElmHeight)

                        }
                        
                        if addEmptyTodo {
                            HStack(spacing:0.0) {
                                Image(systemName: "circle")
                                    .frame(width:elmWidth*0.1)
                                Text("비어있는 일반 퀘스트")
                                    .frame(width:elmWidth*0.8, alignment:.leading)
                                    .multilineTextAlignment(.leading)
                                Button (action: {
                                    addEmptyTodo.toggle()
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .frame(width:elmWidth*0.1)

                            }
                        }
                        
                        ForEach(todos_tmp) { todo in
                            HStack(spacing:0.0) {
                                Image(systemName: "circle")
                                    .frame(width:elmWidth*0.1)
                                Text(todo.content)
                                    .frame(width:elmWidth*0.8, alignment:.leading)
                                    .multilineTextAlignment(.leading)
                                Button (action: {
                                    if let idx = todos_tmp.firstIndex(where: {$0 == todo}) {
                                        modelContext.delete(todo)
                                        todos_tmp.remove(at: idx)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .frame(width:elmWidth*0.1)
                            }
                            .frame(width:elmWidth)
                            .padding(.bottom, 3)
                            // 새로운 todo_preset은 어떻게 추가하는 것이 좋을까.....??????
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
                            popUp_self.toggle()
                        }) {
                            Text("추가")
                        }
                        .frame(width: geoWidth*0.4, alignment: .trailing)
                        .disabled(dailyQuests_tmp.isEmpty && todos_tmp.isEmpty && !addEmptyTodo)
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
        for dailyQuest in dailyQuests_tmp {
            dailyQuest.dailyRecord = currentDailyRecord
            modelContext.insert(dailyQuest)
        }
        
        if addEmptyTodo {
            let emptyTodo = Todo(dailyRecord: currentDailyRecord, index: 0)
            emptyTodo.dailyRecord = currentDailyRecord
            modelContext.insert(emptyTodo)
        }
        else {
            var lastIdx = currentDailyRecord.todoList!.map({$0.index}).sorted().first ?? 0 // if empty -> 0
            for todo in todos_tmp {
                lastIdx += 1
                todo.index = lastIdx
                todo.dailyRecord = currentDailyRecord
                modelContext.insert(todo)
            }
        }
    }
    
    func addDailyQuest(_ quest: Quest) -> Void {
        let dailyQuest = DailyQuest(
            questName: quest.name,
            data: 0,
            dataType: quest.dataType,
            defaultPurposes: quest.recentPurpose
        )
        
        dailyQuest.customDataTypeNotation = quest.customDataTypeNotation
        modelContext.insert(dailyQuest)
        
        
        
    }
    
    
    


    

}










