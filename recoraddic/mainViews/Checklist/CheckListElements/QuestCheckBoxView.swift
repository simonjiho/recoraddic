//
//  QuestCheckBoxView.swift
//  recoraddic
//
//  Created by 김지호 on 12/19/23.
//

import Foundation
import SwiftUI
import SwiftData


// TODO: purpose edit
// TODO: RecentPurpose 수정 / RecentData 수정
struct QuestCheckBoxView_OX: View {
    
    @Environment(\.modelContext) var modelContext
    
    var dailyQuest: DailyQuest
    
    var themeSetName: String
    
    @State var checkBoxToggle: Bool

    @Binding var applyDailyQuestRemoval: Bool
    
    @Binding var dailyQuestToDelete: DailyQuest?
    

    
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let checkBoxSize = geometry.size.height * 0.75
            let TextBoxWidth = geometry.size.width*0.95 - checkBoxSize
            let TextBoxHeight = geometry.size.height*0.9
            
//            let color1 =
//            let color2 =
            
            ZStack {
                HStack {
                    Image(systemName: dailyQuest.data == 1 ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: checkBoxSize, height: checkBoxSize)
                        .onTapGesture {
                            checkBoxToggle.toggle()
                            if checkBoxToggle == true {
                                dailyQuest.data = 0
                                
                            }
                            else {
                                dailyQuest.data = 1
                            }
                        }
                    Text(dailyQuest.questName)
//                        .padding(geometry.size.height*0.05)
//                        .background(dailyQuest.data == 1 ? .white : .white.opacity(0.6))
//                        .clipShape(.buttonBorder)
                        .frame(width: TextBoxWidth, height: TextBoxHeight)
                        .foregroundStyle(dailyQuest.data == 1 ? .black : .white)
                        .bold()
//                        .background(dailyQuest.data == 1 ? .white.opacity(0.9) : .white.opacity(0.4))

                } // HStack
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                Menu {
                    Button("delete", action: {
                        dailyQuestToDelete = dailyQuest
                        applyDailyQuestRemoval.toggle()
                    })
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(height:geoHeight*0.4, alignment:.top)

                    
                }
                .frame(width: geoWidth*0.95, height: geoHeight*0.9, alignment: .topTrailing)

            } // ZStack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(dailyQuest.data == 1 ? .white.adjust(brightness:-0.1) : .black.adjust(brightness:0.3))
            .clipShape(.buttonBorder)
            

            
        }


    }
}

// 고쳐야할 점: modelContext의 데이터를 view의 역동적 동작에 바로바로 수정하지 않고, 끝났을 때만 바꾼다.
// state들 전부 computed property로 바꾸기
// TODO: RecentPurpose 수정 / RecentData 수정 ( + purpose 없을 때는?
struct QuestCheckBoxView: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    
    @State var dailyQuest: DailyQuest
    
    var themeSetName: String

    
    @State var value: Int
//    var width: CGFloat
    var range: ClosedRange<CGFloat> {
        return 0.0...CGFloat(dailyQuest.dailyGoal)
    }
    @State var xOffset: CGFloat
//    @State var lastOffset: CGFloat
    @State var previousDragGesturePoint: CGSize = CGSize.zero
    
    @Binding var applyDailyQuestRemoval: Bool
    @Binding var dailyQuestToDelete: DailyQuest?
    
    @State var isDragging: Bool = false
    @State var deleteDailyQuest: Bool = false
    
    @State var isEditingGoal: Bool = false
    @State var goalValueInText: String = ""

    @FocusState var editingGoal: String?
    
    @State var isEditingGoal_hours: Bool = false
    
//    @Binding var isJustCf: Bool = false
    
    var body: some View {

        let questName = dailyQuest.questName
        let dataType = dailyQuest.dataType
        let dailyGoal = dailyQuest.dailyGoal
        let questData:Int = dailyQuest.data

        
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let contentWidth = geometry.size.width*0.95
            
            let dragGestureReducer: CGFloat = 0.7
            let dragGestureAccelerater: CGFloat = 1.5
            
//            let sliderBoxHeight = geometry.size.height*0.5
//            let sliderBoxWidth = contentWidth*0.75
            
            let percentage = CGFloat(value) / CGFloat(dailyGoal)
            let brightness = percentage + 0.1
            
            

//            let thumbSize = geoHeight*1.04

//            let color1 =
//            let color2 =
//            let color3 =
//            let color4 = 

            ZStack(alignment:.leading) {
                Rectangle()
                    .frame(width: (xOffset.isFinite && xOffset >= 0 && xOffset <= geoWidth + 0.1) ? xOffset : 0.0, height: geoHeight)
                    // MARK: 0.1을 넣지 않으면 xOffset이 geoWidth보다 커지는 상황 발생... 왤까?
                    .clipShape(.buttonBorder)
                    .foregroundStyle(.black.adjust(brightness:brightness))
                    .onChange(of:brightness) {
                        print("brightness changed")
                        print(brightness)
                    }
                
                HStack(spacing: 0.0) {
                    Text("\(questName)")
                        .frame(alignment: .trailing)
                        .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)
                        .lineLimit(1)
                        .bold()
                    Text(": ")
                        .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)
                        .bold()
                    HStack(spacing:0.0) { // hstack for values
                        
                        if isEditingGoal {
                            
                            Text("\(DataType.string_unitDataToRepresentableData(data: value, dataType: dataType)) / ")
                                .bold()
                                .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)

                            
                            if dailyQuest.dataType == DataType.HOUR {
                                Text("\(DataType.string_unitDataToRepresentableData(data:dailyQuest.dailyGoal , dataType: dataType))")
                                    .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)

                            }
                            else {
                                TextField("", text:$goalValueInText)
                                    .keyboardType(.numberPad)
                                    .frame(width:80)
                                    .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)
                                    .onAppear() {
                                        goalValueInText = DataType.string_unitDataToRepresentableData(data: dailyQuest.dailyGoal, dataType: dataType)
                                    }
                                    .focused($editingGoal, equals: "editing")
                                // use number pad
                            }
                            
                            Text("\(DataType.unitNotationOf(dataType: dataType, customDataTypeNotation:dailyQuest.customDataTypeNotation))")
                                .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)
                            

                        
                        }
                        else {
                            Text("\(DataType.string_unitDataToRepresentableData(data: value, dataType: dataType)) \(DataType.unitNotationOf(dataType: dataType, customDataTypeNotation:dailyQuest.customDataTypeNotation))")
                                .foregroundStyle(CGFloat(value)/range.upperBound > 0.5 ? .black : .white)
                                .lineLimit(1)
                                .bold()

                        }
                        
                        // 새로운 기록 구조: editingGoal에 따라 뒤에도 바뀜. 뒤에 바뀌면 가운데로, 고정, 당기면 올라감. 직접입력 터치시 textfield로 바뀜.
                        // 디자인적으로 뭔가 완전 편하고 명시적이었으면 좋겠는데, 목표치를 설정하거나 수정한다는.

                    }
                    .frame(alignment: .leading)


                }
                .padding(geoWidth*0.03)
                .frame(width:geoWidth, height: geoHeight, alignment: .center)

                    
                if !isEditingGoal {
                    Menu {
                        Button("목표치 수정", action: {
                            goalValueInText = DataType.string_unitDataToRepresentableData(data: dailyQuest.dailyGoal, dataType: dataType)
                            editingGoal = "editing"
                            isEditingGoal.toggle()
                        })
                        Button("삭제", action: {
                            dailyQuestToDelete = dailyQuest
                            applyDailyQuestRemoval.toggle()
                        })
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .frame(height:geoHeight*0.75, alignment:.top)
                        //                        .border(.red)
                    }
                    .frame(width: geometry.size.width*0.975, height: geometry.size.height*0.9, alignment: .topTrailing)
                    .disabled(isEditingGoal)
                }
                else if dataType != DataType.HOUR {
                    Button("완료") {
//                                dismissingKeyboard()
                        if dailyQuest.dataType == DataType.HOUR {
                            goalValueInText = String(dailyQuest.dailyGoal)
                        }
                        if Int(goalValueInText)! <= dailyQuest.data {
                            dailyQuest.data = Int(goalValueInText)!
                            self.value = dailyQuest.data
                        }
                        if dailyQuest.dataType != DataType.HOUR {
                            dailyQuest.dailyGoal = Int(goalValueInText)!
                        }

//                        editingGoal = nil
                        isEditingGoal.toggle()
                    }
                    .buttonStyle(.bordered)
                    .frame(width: geometry.size.width*0.975, height: geometry.size.height*0.9, alignment: .trailing)

                }
                
                
                
            } // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(.black.adjust(brightness:0.3))
            .clipShape(.buttonBorder)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { draggedValue in

                        let translation = draggedValue.translation
                        
                        let deltaX = translation.width - previousDragGesturePoint.width

                        
                        let dragGestureCoefficient:CGFloat =
                        {
                            let translation_x_abs = abs(translation.width)
                            let deltaX_abs = abs(deltaX)
                            if deltaX_abs > 5 { return dragGestureAccelerater}
                            else if translation_x_abs <= 10 {return dragGestureReducer}
                            else if translation_x_abs >= geoWidth*0.2 {
                                print("accelerated!!")
                                print(deltaX)
                                return dragGestureAccelerater
                            }
                            else if translation_x_abs > 10 && translation_x_abs < geoWidth*0.2 {return 1.0}
                            else if deltaX_abs < 1.5 {return dragGestureReducer}
                            else { return 1.0}
                        }()
                        

                        // geometric position
                        var sliderPos = max(0, min(xOffset + deltaX*dragGestureCoefficient, geoWidth))

                        // actual value (postion -> value:13.51324 -> roundValue:13.0)
                        let sliderVal = sliderPos.map(from: 0...geoWidth, to: range)

                        //TODO: 숫자 크면 5/10/50/100/500/1000/5000/10000 단위로 끊어주기
                        
                        // geometric position for roundValue
                        sliderPos = CGFloat(sliderVal).map(from:range, to: 0...geoWidth)

                        if sliderVal.isNormal || sliderVal.isZero {
                            xOffset = sliderPos
                            self.value = Int(round(sliderVal))
                        }
                        isDragging = true
                        previousDragGesturePoint = translation
                        
                    }
                    .onEnded { _ in
//                        lastOffset = xOffset
                        isDragging = false
                        dailyQuest.data = self.value
                        print("xOffset:\(xOffset)")
                        print("value:\(value)")
                        previousDragGesturePoint = CGSize.zero
                    }
                
            )
            // MARK: This will be used if there's other button or behaviours that changes the value in other way(maybe change the value by textfield for later update)
            .onChange(of: value) {
                if !isDragging { // if changed by checkbox or x2 button.. or undo buttion..
//                    range = 0.0...minimumBoundary(of:dailyQuest.data, byMultiplying:dailyGoal)
                    xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
                }
            }
            .onChange(of: range) {
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
            }
            .onChange(of: isEditingGoal) {
                if isEditingGoal && dataType == DataType.HOUR {
                    isEditingGoal_hours = true
                }
            }
            .onChange(of: isEditingGoal_hours) {
                if isEditingGoal && dataType == DataType.HOUR {
                    isEditingGoal = false
                }
            }
            .sheet(isPresented: $isEditingGoal_hours) {
                // code for on dismiss
            } content: {
                let (naturalPart, firstDecimalPart): (Int, Int) = divideBy10(dailyQuest.dailyGoal)
                DialForHours(
                    questName:questName,
                    value: $dailyQuest.dailyGoal,
                    isEditing: $isEditingGoal_hours,
                    naturalPart: naturalPart,
                    firstDecimalPart: firstDecimalPart
                )
                    .presentationDetents([.height(300)])
                    .presentationCompactAdaptation(.none)
            }

            




        } // geometryReader



    }





}



struct EmptyQuestCheckBoxView: View {

    @Environment(\.colorScheme) var colorScheme

    
    var ratio: CGFloat

    var body: some View {
        
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            var xOffset: CGFloat = max(0.0, min(geoWidth*ratio,geoWidth))
            
            let percentage = xOffset / geoWidth
            let brightness = percentage + 0.1


            ZStack(alignment:.leading) {
                
                Color.red.opacity(0.0)
                
                Rectangle()
                    .frame(width: (xOffset.isFinite && xOffset >= 0 && xOffset <= geoWidth + 0.1) ? xOffset : 0.0, height: geoHeight)
                    // MARK: 0.1을 넣지 않으면 xOffset이 geoWidth보다 커지는 상황 발생... 왤까?
                    .clipShape(.buttonBorder)
                    .foregroundStyle(.black.adjust(brightness:brightness))
                
                

                
            } // zstack
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(.black.adjust(brightness:0.3))
            .clipShape(.buttonBorder)


        } // geometryReader



    }





}


extension CGFloat {
    func map(from source: ClosedRange<CGFloat>, to target: ClosedRange<CGFloat>) -> CGFloat {

        return target.lowerBound + (self - source.lowerBound) * (target.upperBound - target.lowerBound) / (source.upperBound - source.lowerBound)
    }
}


struct DialForHours: View {

    var questName: String
    
    @Binding var value: Int
    @Binding var isEditing: Bool
    
    @State var naturalPart = 0
    @State var firstDecimalPart = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                ZStack {
                    Text(questName)
                        .font(.title3)
                    HStack(spacing:0.0) {
                        Button("취소") {
                            isEditing.toggle()
                        }
                        .padding(.leading, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .leading)
                        Button("완료") {
                            value = naturalPart*10  + firstDecimalPart
                            isEditing.toggle()
                        }
                        .padding(.trailing, 10)
                        .frame(width: (geometry.size.width*0.5), alignment: .trailing)
                    }

                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
//                .border(.red)
                
                HStack {
                    
                    Text("목표:")
                    
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
            }
            .onChange(of: naturalPart) {
                if naturalPart == 24 {
                    withAnimation {
                        firstDecimalPart = 0
                    }
                }
            }
            .onChange(of: firstDecimalPart) {
                if naturalPart == 24 {
                    withAnimation {
                        firstDecimalPart = 0
                    }
                }
            }
            .onDisappear() {
            }
        }
    }
}
