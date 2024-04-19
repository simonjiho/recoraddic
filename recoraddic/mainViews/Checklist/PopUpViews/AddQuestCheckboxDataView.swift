//
//  AddQuestView.swift
//  recoraddic
//
//  Created by 김지호 on 12/17/23.
//

import Foundation
import SwiftUI
import SwiftData

// TODO: 달성 버튼 / ox는 바로 추가 / 프리셋 버튼

struct AddDailyQuestView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    @Query var quests: [Quest]
    var quests_notHidden: [Quest] {
        quests.filter({!$0.isHidden})
    }
    
    var currentDailyRecord: DailyRecord
    
    @Binding var popUp_addDailyQuest: Bool
    @Binding var selectedView: MainViewName
    var isDone: Bool
    
    
    @State var path: [Quest] = []
    @State var step: Int = 0
    
    @State var loadQuest: Bool = false
    
    @State var questNameToAppend = ""
    @State var questDataTypeToAppend = DataType.OX
    @State var customDataTypeNotation: String?
    @State var customDataTypeNotation_textField: String = ""
    
    @State var questValueToAppend_String: String = ""
    @State var questValueToAppend_Int: Int = 0
    @State var questPurposesToAppend: Set<String> = Set()
    @State var popUp_choosePurpose: Bool = false
    
//    var newQuest: Quest = Quest(name: "tmpQuest", dataType: DataType.NONE)
    
    var body: some View {
        
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            
//            let textBoxWidth = geometry.size.width * 0.2
//            let textBoxHeight = geometry.size.height * 0.15
//            let messageBoxHeight = geometry.size.height * 0.1
//            
//            let contentHeight = geometry.size.height*0.9
            
            // 2개의 buffer 기록 -> 어제:
            VStack {
                Button(action:{popUp_addDailyQuest.toggle()}) {
                    Image(systemName: "xmark")
                }
                .frame(width: geometry.size.width*0.9, height: geometry.size.height*0.06, alignment: .trailing)
                ZStack {
                    //                    if step == 0 {
                    VStack {
                        Text("추가할 누적 퀘스트를 고르세요")
                        NavigationStack(path: $path ) {
                            List {
                                Section {
                                    ForEach(quests_notHidden) { quest in
                                        if quest.dataType == DataType.OX {
                                            Button(quest.name) {
                                                addDailyQuest_OX(quest)
                                                popUp_addDailyQuest.toggle()
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        else {
                                            NavigationLink(quest.name, value: quest)
                                        }
                                    }
                                }

//                                NavigationLink("새로운 퀘스트", value:newQuest)
                            }
                            .navigationDestination(for: Quest.self) { quest in
                                SetValueForDailyQuest(recordOfToday: currentDailyRecord, selectedQuest: quest, popUp_addDailyQuest: $popUp_addDailyQuest, isDone: isDone)
                            }

                        }
                    }
                    if quests_notHidden.isEmpty {
                        Button(action:{
                            popUp_addDailyQuest.toggle()
                            selectedView = .gritBoardAndStatistics}){
                            // TODO: 바로 새로운 퀘스트 누른 것처럼 만들기
                            Text("새로운 퀘스트 만들기")
                        }

                    }
                }
            }
        }
    }

    func addDailyQuest_OX(_ quest: Quest) -> Void {
        let dailyQuest = DailyQuest(
            questName: quest.name,
            data: 0,
            dataType: quest.dataType,
            defaultPurposes: quest.recentPurpose,
            dailyGoal: 1
        )
        
        dailyQuest.dailyRecord = currentDailyRecord
        dailyQuest.currentTier = quest.tier
        modelContext.insert(dailyQuest)
    }
    


    

}



struct SetValueForDailyQuest: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests:[Quest]
    var freeSetDatas: [Int] {
        selectedQuest.freeSetDatas
    }

    var recordOfToday: DailyRecord
    var selectedQuest: Quest
    
    @Binding var popUp_addDailyQuest: Bool
    

    @State var isDone: Bool
    @State var popUp_newFreeSet: Bool = false
    @State var popUp_newFreeSet_Hours: Bool = false
    @State var popUp_newFreeSet_notHours: Bool = false
    
    @State var freeSetValueToAppend: Int = 0
    @State var inputValue: String = ""
    
    @State var useFreeSets:Bool = false
    
    @State var value:Int = 0
    @State var value_String: String = ""
    
    @State var selectedFreeSetIndex: Int?
    
    @FocusState var focusState_setValue: Bool
    @FocusState var focusState_newFreeSet: Bool
    
    var body: some View {
        //        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let questNameHeight: CGFloat = geoHeight*0.2
            let questNameWidth: CGFloat = geoWidth*0.65
//            let textFieldSize: CGFloat = min( CGFloat(inputValue.count) * 20, geoWidth*0.7)
            VStack {
                Text(selectedQuest.name)
                    .foregroundStyle(!isDone ? .white : .black)
                    .font(.title3)
//                    .padding(.horizontal,25)
                    .padding(.vertical,15)
//                    .frame(width:questNameWidth, height: questNameHeight)
                    .frame(width: questNameWidth, alignment: .center)
                    .background(isDone ? .white : .black.adjust(brightness:0.3))
                    .clipShape(.rect(cornerSize: CGSize(width: questNameWidth*0.05, height: questNameHeight*0.05)))
                    .shadow(radius: 3)

                
                HStack(spacing: 0.0) {
                    Toggle(isOn: $useFreeSets, label: {
                        Text("프리셋 사용")
                            .font(.caption)
                    })
                    .frame(width:questNameWidth*0.4, height:geoWidth*0.07)
                    .toggleStyle(CheckboxToggleStyle())
                    Spacer()
                        .frame(width:1, height: geoWidth*0.05)
                        .background(.gray.opacity(0.45))
                        .padding(.horizontal,questNameWidth*0.1)
                    
                    Toggle(isOn: $isDone) {
                        Text("달성")
                            .font(.caption)
                    }
                    .frame(width:questNameWidth*0.4, height:geoWidth*0.07)
                    .toggleStyle(CheckboxToggleStyle())
                }
                .frame(width:questNameWidth, height:geoWidth*0.07)
                .padding(.horizontal,geoWidth*0.1)
//                .padding(.bottom,geoHeight*0.15)
                
            
                if !useFreeSets {
                    HStack {
//                        Text("목표:")
                        if selectedQuest.dataType == DataType.HOUR {
                            DialForHours_setValue(value: $value)
                            //                                .frame()
                        }
                        else {
                            TextField("", text: $value_String)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusState_setValue)
                                .onAppear() {
                                    focusState_setValue = true
                                }
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: value_String) {value = Int(value_String) ?? 0}
                                
                            Text(DataType.unitNotationOf(dataType: selectedQuest.dataType, customDataTypeNotation: selectedQuest.customDataTypeNotation))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                                
                        }
                    }
//                    .foregroundStyle(!isPlan ? .white : .black)
                    .padding(.horizontal,geoWidth*0.1)
                    .padding(.top, geoHeight*0.2)
                    .padding(.bottom, geoHeight*0.2)
//                    .background(isPlan ? .white : .black.adjust(brightness:0.3))
//                    .clipShape(.rect(cornerSize: CGSize(width: questNameWidth*0.05, height: questNameHeight*0.05)))


                }
                else {
                    List {  // TODO: 옆으로 밀어서 삭제 가능한거 도움말로.알려주기
                        
                        if popUp_newFreeSet_notHours {
                            //                            ZStack {
                            HStack {
                                TextField("", text: $inputValue)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusState_newFreeSet, equals: true)
                                //                                        .frame(width:textFieldSize)
                                Text("\(DataType.unitNotationOf(dataType: selectedQuest.dataType, customDataTypeNotation: selectedQuest.customDataTypeNotation))")
                                Button(inputValue == "" ? "취소" : "완료") {
                                    popUp_newFreeSet_notHours = false
                                    if inputValue != "" {
                                        selectedQuest.freeSetDatas.append(Int(inputValue) ?? 0)
                                        inputValue = ""
                                    }
                                }
                                .padding(.leading, 10)
//                                .disabled()
                            }
                            
                        }
                        
                        ForEach(0..<selectedQuest.freeSetDatas.count, id:\.self) { index in
                            Button(action: {
                                if selectedFreeSetIndex == index {
                                    selectedFreeSetIndex = nil
                                }
                                else { selectedFreeSetIndex = index}
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .opacity(selectedFreeSetIndex == index ? 1.0 : 0.0)
                                    Text("\(DataType.string_unitDataToRepresentableData(data: selectedQuest.freeSetDatas[index], dataType: selectedQuest.dataType)) \(DataType.unitNotationOf(dataType: selectedQuest.dataType, customDataTypeNotation: selectedQuest.customDataTypeNotation))")
                                        .bold(selectedFreeSetIndex == index)
//                                        .font(selectedFreeSetIndex == index ? .callout : .subheadline)
                                }
                            }
//                            .border(.red)
//                            .foregroundStyle(Color.white.opacity(selectedFreeSetIndex == index ? 1.0 : 0.0))


                        }
                        .onDelete { indexSet in
                            selectedFreeSetIndex = nil
                            selectedQuest.freeSetDatas.remove(atOffsets: indexSet)
                        }
                        
                        if selectedQuest.recentData != 0 {
                            Button(action: {
                                if selectedFreeSetIndex == selectedQuest.freeSetDatas.count {
                                    selectedFreeSetIndex = nil
                                }
                                else { selectedFreeSetIndex = selectedQuest.freeSetDatas.count}
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .opacity(selectedFreeSetIndex == selectedQuest.freeSetDatas.count ? 1.0 : 0.0)
                                    
                                    Text("가장 최근 달성: \(DataType.string_unitDataToRepresentableData(data: selectedQuest.recentData, dataType: selectedQuest.dataType)) \(DataType.unitNotationOf(dataType: selectedQuest.dataType, customDataTypeNotation: selectedQuest.customDataTypeNotation))")
                                        .bold(selectedFreeSetIndex == selectedQuest.freeSetDatas.count)
    //                                        .font(selectedFreeSetIndex == index ? .callout : .subheadline)
                                }
                                
                            }
                        }


                        
                        
                        Button("새로운 프리셋 추가", systemImage: "plus.circle") {
                            popUp_newFreeSet.toggle()
                            // 창 띄우기
                        }
                        
                        
                        
                    }
                    .onChange(of: popUp_newFreeSet) {
                        if popUp_newFreeSet {
                            if selectedQuest.dataType == DataType.HOUR {
                                popUp_newFreeSet_Hours = true
                            }
                            else {
                                popUp_newFreeSet_notHours = true
                                focusState_newFreeSet = true
                            }
                        }
                    }
                    .onChange(of: popUp_newFreeSet_Hours) {
                        if !popUp_newFreeSet_Hours {
                            popUp_newFreeSet = false
                        }
                    }
                    .onChange(of: popUp_newFreeSet_notHours) {
                        if !popUp_newFreeSet_notHours {
                            popUp_newFreeSet = false
                            focusState_newFreeSet = false
                        }
                    }
                    .onDisappear() {
                        selectedFreeSetIndex = nil
                    }

//                    .padding(.vertical,10)
                    .sheet(isPresented: $popUp_newFreeSet_Hours, content: {
                        DialForHours_addFreeSet(selectedQuest: selectedQuest, isEditing: $popUp_newFreeSet_Hours)
                            .presentationDetents([.height(300)]) // TODO: 300 대신 전체 디스플레이비율로
                            .presentationCompactAdaptation(.none)
                        
                    })
                }

                Button("생성") {
                    
                    if useFreeSets {
                        if selectedFreeSetIndex == selectedQuest.freeSetDatas.count {
                            addNewDailyQuest(data: selectedQuest.recentData)
                        }
                        else {
                            addNewDailyQuest(data: selectedQuest.freeSetDatas[selectedFreeSetIndex ?? 0])
                        }
                    }
                    else {
                        addNewDailyQuest(data: value)
                    }
                    popUp_addDailyQuest.toggle()
                }
                .padding(.vertical,10)
                .disabled( (useFreeSets && selectedFreeSetIndex == nil) || (!useFreeSets && value == 0))

                
            }
            .frame(width: geoWidth, height: geoHeight, alignment: .top)
                
        }
    }
    

    
    func addNewDailyQuest(data: Int) -> Void {
//        customDataTypeNotation??
        
        let dailyQuest = DailyQuest(
            questName: selectedQuest.name,
            data: isDone ? data : 0,
            dataType: selectedQuest.dataType,
            defaultPurposes: selectedQuest.recentPurpose,
            dailyGoal: data
        )
        
        if selectedQuest.dataType == DataType.CUSTOM {
            dailyQuest.customDataTypeNotation = selectedQuest.customDataTypeNotation
        }
        dailyQuest.dailyRecord = recordOfToday
        dailyQuest.currentTier = selectedQuest.tier
        modelContext.insert(dailyQuest)
    }
}


struct TextField_addFreeSet: View {
    @Environment(\.modelContext) private var modelContext
    var selectedQuest: Quest
    
    @Binding var isEditing: Bool
    
    @State var value: Int = 0
    @FocusState var editingGoal: String?
    @State var valueInText: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Text(selectedQuest.name)
                    HStack(spacing:0.0) {
                        Button("취소") {
                            value = 0
                            isEditing.toggle()
                        }
                        .padding(.leading, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .leading)
                        Button("추가") {
                            value = Int(valueInText) ?? 0
                            selectedQuest.freeSetDatas.append(value)
                            value = 0
                            isEditing.toggle()
                        }
                        .padding(.trailing, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .trailing)
                    }
                }
                .padding(.top,15)
                HStack {
                    TextField("", text: $valueInText)
                        .keyboardType(.numberPad)
                        .focused($editingGoal, equals: "editing")
                    Text(DataType.unitNotationOf(dataType: selectedQuest.dataType, customDataTypeNotation: selectedQuest.customDataTypeNotation))
                    
                }
                // 단위, 행간 여백, 크기 키우기, 정렬
            
            }
            .frame(alignment: .top)
            .onAppear() {
                editingGoal = "editing"
            }
        }
        
    }
}


struct DialForHours_setValue:View {
    
    @Binding var value: Int
    @State var naturalPart = 0
    @State var firstDecimalPart = 0
    
    
    
    var body: some View {
        HStack {
            
//            Text("목표:")
            
            Picker(selection: $naturalPart, label: Text("First Value")) {
                ForEach(0..<25) { i in
                    Text("\(i)").tag(i)
                }
            }
            .frame(width: 50)
            .clipped()
            .pickerStyle(.wheel)
            Text(".")
            Picker(selection: $firstDecimalPart, label: Text("Second Value")) {
                ForEach(0..<10) { i in
                    Text("\(i)").tag(i)
                }
            }
            .frame(width: 50)
            .clipped()
            .pickerStyle(.wheel)
            Text("시간")
            
        }
        .onChange(of: naturalPart) {
            if naturalPart == 24 {
                withAnimation {
                    firstDecimalPart = 0
                }
            }
            value = naturalPart*10  + firstDecimalPart

        }
        .onChange(of: firstDecimalPart) {
            if naturalPart == 24 {
                withAnimation {
                    firstDecimalPart = 0
                }
            }
            value = naturalPart*10  + firstDecimalPart

        }
    }
}

struct DialForHours_addFreeSet: View {
    @Environment(\.modelContext) private var modelContext


    var selectedQuest: Quest
    @Binding var isEditing: Bool
    

    @State var value: Int = 0
    @State var naturalPart = 0
    @State var firstDecimalPart = 0

    var body: some View {
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            VStack {
                
                ZStack {
                    Text(selectedQuest.name)
                        .font(.title3)
                    HStack(spacing:0.0) {
                        Button("취소") {
                            value = 0
                            isEditing.toggle()
                        }
                        .padding(.leading, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .leading)
                        Button("추가") {
                            value = naturalPart*10  + firstDecimalPart
                            selectedQuest.freeSetDatas.append(value)
                            isEditing.toggle()
                        }
                        .padding(.trailing, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .trailing)
                    }
                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
//                .border(.red)
                
                HStack(spacing:0.0) {
                    
                    
                    Picker(selection: $naturalPart, label: Text("First Value")) {
                        ForEach(0..<25) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .frame(width: 50)
                    .clipped()
                    .pickerStyle(.wheel)
                    Text(".")
                    Picker(selection: $firstDecimalPart, label: Text("Second Value")) {
                        ForEach(0..<10) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .frame(width: 50)
                    .clipped()
                    .pickerStyle(.wheel)
                    Text("시간")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    
                }
            }
            .onChange(of: naturalPart) {
                if naturalPart == 24 {
                    withAnimation {
                        firstDecimalPart = 0
                    }
                }
                value = naturalPart*10  + firstDecimalPart

            }
            .onChange(of: firstDecimalPart) {
                if naturalPart == 24 {
                    withAnimation {
                        firstDecimalPart = 0
                    }
                }
                value = naturalPart*10  + firstDecimalPart

            }
            .frame(height: geoHeight)
            // hour아닌것도 만들기

        }
    }
}


struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            
            HStack {
                configuration.label
                Spacer()
//                    .frame(width:geometry.size.width)
                Button(action: { configuration.isOn.toggle() }) {
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: geometry.size.height*0.8, height: geometry.size.height*0.8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width:geometry.size.width, height: geometry.size.height)
        }
    }
}
