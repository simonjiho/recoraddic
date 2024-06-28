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
    
    @State var isAnimating = false

    
    
    var body: some View {
        let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0)

        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let checkBoxSize = geometry.size.height * 0.75
            let TextBoxWidth = geometry.size.width*0.95 - checkBoxSize
            let TextBoxHeight = geometry.size.height*0.9
            
            let tier: Int = dailyQuest.currentTier
            let tierColor_dark = getDarkTierColorOf(tier: tier)

            
            ZStack {
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                .frame(width:geoWidth, height:geoHeight)
                .opacity(dailyQuest.data == 1 ? 1.0 :0.0)
                .onAppear() {
                    isAnimating = true
                }




                HStack {
                    Image(systemName: dailyQuest.data == 1 ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: checkBoxSize, height: checkBoxSize)
                    Text(dailyQuest.questName)
                        .frame(width: TextBoxWidth, height: TextBoxHeight)
                        .bold()


                } // HStack
                .frame(width: geometry.size.width, height: geometry.size.height)      


                
                Menu {
                    Button("삭제", action: {
                        dailyQuestToDelete = dailyQuest
                        applyDailyQuestRemoval.toggle()
                    })
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(height:geoHeight*0.4, alignment:.top)

                    
                }
                .buttonStyle(.plain)
                .foregroundStyle(.black)
                .frame(width: geoWidth*0.95, height: geoHeight*0.9, alignment: .topTrailing)

            } // ZStack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(getTierColorOf(tier: tier))
            .foregroundStyle(tierColor_dark)
            .clipShape(.buttonBorder)
            .onTapGesture {
                checkBoxToggle.toggle()
                if checkBoxToggle == true {
                    dailyQuest.data = 0
                    
                }
                else {
                    dailyQuest.data = 1
                }
            }
            

            
        }


    }
}

// 고쳐야할 점: modelContext의 데이터를 view의 역동적 동작에 바로바로 수정하지 않고, 끝났을 때만 바꾼다.
// state들 전부 computed property로 바꾸기
// TODO: RecentPurpose 수정 / RecentData 수정 ( + purpose 없을 때는?

struct QuestCheckBoxView_HOUR: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var stopwatch = Stopwatch()

    
    @State var dailyQuest: DailyQuest
    
    var themeSetName: String

    
    @State var value: Int
    @State var dailyGoal: Int?
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
//    var width: CGFloat
    var range: ClosedRange<CGFloat> {
        return 0.0...CGFloat(dailyGoal ?? value)
    }
    @State var xOffset: CGFloat
    
    @Binding var applyDailyQuestRemoval: Bool
    @Binding var dailyQuestToDelete: DailyQuest?
    
    @State var deleteDailyQuest: Bool = false
    
    @FocusState var focusedField: Field?
    enum Field: Int, CaseIterable {
        case value
        case goal
    }
    
    
    @State var isEditing_hours: Bool = false
    
    @State var isAnimating = false
    @State var onTimer: Bool = false

//    @Binding var isJustCf: Bool = false
    
    var body: some View {

        let questName = dailyQuest.questName
        let dataType = dailyQuest.dataType

        let tier: Int = dailyQuest.currentTier
        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height

            let percentage:CGFloat = xOffset / geoWidth
            
            
            let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0)
            
            let a: Path = Path(CGPath(rect: CGRect(x: 0, y: 0, width: (xOffset.isFinite && xOffset >= 0 && xOffset <= geoWidth +  0.1) ? xOffset : geoWidth, height: geoHeight), transform: nil))
            // 0.1 없으면 끝에서 이상해짐


            ZStack(alignment:.leading) {
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                .frame(width:geoWidth, height:geoHeight)
                .mask {
                    a
                }
                .onAppear() {
                    isAnimating = true
                }
                if hasGoal {
                    Spacer()
                        .frame(width:1, height: geoHeight)
                        .background(tierColor_dark)
                        .offset(x:xOffset)
                }
                // MARK: 0.1을 넣지 않으면 xOffset이 geoWidth보다 커지는 상황 발생... 왤까?

                HStack(spacing: 0.0) {
                    if !isEditing_hours {
                        Button("",systemImage:onTimer ? "pause" : "play") {
                            if !onTimer {
                                stopwatch.setTotalSec(value*60)
                                stopwatch.start()
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    onTimer.toggle()
                                }
                            }
                            else {
                                onTimer.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    stopwatch.stop()
                                    value = stopwatch.getTotalSec()/60
                                    stopwatch.setTotalSec(value*60)
                                }
                            }


                        }
                        .foregroundStyle(getDarkTierColorOf(tier: tier))
                        
                        Text("\(questName)")
                            .frame(alignment: .trailing)
                            .lineLimit(1)
                        Text(": ")
                    }
                    
                    if onTimer {
                        Text(stopwatch.timeString)
                    }
                    else {
                        Group {
                            Text("\(DataType.string_fullRepresentableNotation(data: value, dataType: dataType))")
                            if hasGoal && isEditing_hours {
                                Text("/ \(DataType.string_fullRepresentableNotation(data:dailyQuest.dailyGoal ?? 0 , dataType: dataType))")
                            }
                            //                    if !onTimer {
//                            Button("",systemImage: "bell.slash") {
//                                
//                            }
                        }
                        .onTapGesture {
                            isEditing_hours.toggle()
                        }
                    }
                }
                .padding(geoWidth*0.03)
                .frame(width:geoWidth, height: geoHeight, alignment: .center)
                .foregroundStyle(tierColor_dark)
                .bold()

                .sheet(isPresented: $isEditing_hours) {
                    // code for on dismiss
                } content: {
                    DialForHours(
                        questName:questName,
                        dailyGoal: $dailyGoal,
                        value: $value,
                        isEditing: $isEditing_hours,
                        hasGoal_toggle: $hasGoal_toggle,
                        dailyGoal_nonNil: dailyGoal ?? value
                    )
                    .presentationDetents([.height(300)])
                    .presentationCompactAdaptation(.none)
                }
       
                if !isEditing_hours {
                    Menu {
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
                    .buttonStyle(.plain)
                    .foregroundStyle(.black)
                    .frame(width: geometry.size.width*0.975, height: geometry.size.height*0.9, alignment: .topTrailing)
                }

                
            } // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(getTierColorOf(tier: dailyQuest.currentTier))
            .clipShape(.buttonBorder)
            .onChange(of: hasGoal_toggle) {
                
                // 똑같을 때: hasGoal에 따라 hasGoal_toggle을 설정
                if hasGoal_toggle != hasGoal {
                        toggle_hour(hasGoal_toggle)
                }
                
                
            }
            .onChange(of: value) {

                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
                dailyQuest.data = value
                print(xOffset)
            }
            .onChange(of: dailyGoal) {
                dailyQuest.dailyGoal = dailyGoal
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
            }
            .onChange(of: range) {
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
            }
            .onChange(of: hasGoal) {
                hasGoal_toggle = hasGoal
            }
//            .onChange(of: stopwatch.isRunning) {
//                onTimer = stopwatch.isRunning
//            }

        } // geometryReader



    }
    
    func toggle_hour(_ setGoal: Bool) -> Void {
        hasGoal = hasGoal_toggle
        if setGoal {
            dailyGoal = (value/5+1)*5
        }
        else {
            dailyGoal = nil
        }
    }


}

class Stopwatch: ObservableObject {
    @Published var timeString = "00:00:00"
    private var timer: Timer?
    private var totalSec: Int = 0

    var isRunning: Bool {
        timer != nil
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.totalSec += 1
            self.updateTime()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func setTotalSec(_ input: Int) {
        self.totalSec = input
    }
    
    func getTotalSec() -> Int {
        return self.totalSec
    }


    private func updateTime() {
            let hours = totalSec / 3600
            let minutes = (totalSec % 3600) / 60
            let seconds = totalSec % 60
            timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


struct QuestCheckBoxView: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    
    @State var dailyQuest: DailyQuest
    
    var themeSetName: String

    
    @State var value: Int
    @State var dailyGoal: Int?
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
//    var width: CGFloat
    var range: ClosedRange<CGFloat> {
        return 0.0...CGFloat(dailyGoal ?? value)
    }
    @State var xOffset: CGFloat
    
    @Binding var applyDailyQuestRemoval: Bool
    @Binding var dailyQuestToDelete: DailyQuest?
    
    @State var deleteDailyQuest: Bool = false
    
    @State var isEditing: Bool = false
    @State var valueInText: String = ""
    @State var goalValueInText: String = ""

    @FocusState var focusedField: Field?
    enum Field: Int, CaseIterable {
        case value
        case goal
    }
    
        
    @State var isAnimating = false

//    @Binding var isJustCf: Bool = false
    
    var body: some View {

        let questName = dailyQuest.questName
        let dataType = dailyQuest.dataType
//        let questData:Int = dailyQuest.data
//        let customDataTypeNotaion: String? = dailyQuest.customDataTypeNotation

        let tier: Int = dailyQuest.currentTier
        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
//            let contentWidth = geometry.size.width*0.95
            
            
//            let percentage:CGFloat = xOffset / geoWidth
            
            
            let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0)

            
            let a: Path = Path(CGPath(rect: CGRect(x: 0, y: 0, width: (xOffset.isFinite && xOffset >= 0 && xOffset <= geoWidth +  0.1) ? xOffset : geoWidth, height: geoHeight), transform: nil))
            // 0.1 없으면 끝에서 이상해짐


            ZStack(alignment:.leading) {
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                .frame(width:geoWidth, height:geoHeight)
                .mask {
                    a
                }
                .onAppear() {
                    isAnimating = true
                }
                // MARK: 0.1을 넣지 않으면 xOffset이 geoWidth보다 커지는 상황 발생... 왤까?



                if hasGoal && xOffset >= geoWidth {
                    Spacer()
                        .frame(width:1, height: geoHeight)
                        .background(tierColor_dark)
                        .offset(x:xOffset)
                }
                            

                HStack(spacing: 0.0) {
                    
                    if !isEditing {
//                        Button("",systemImage: "bell.slash") {
//                            
//                        }
//                        .foregroundStyle(getDarkTierColorOf(tier: tier))
                        HStack(spacing:0.0) {
                            Text("\(questName)")
                                .frame(alignment: .trailing)
                                .lineLimit(1)
                            //                        .bold()
                            Text(": ")
                            Text("\(value)")
                        }
                        .onTapGesture {
                            edit()
                        }
                    }
                    if isEditing {
                        TextField("", text:$valueInText)
                            .keyboardType(.numberPad)
                            .frame(width:geoWidth/3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .value)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    HStack(spacing:0.0) {
                                        Toggle("목표설정", isOn: $hasGoal_toggle)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .toggleStyle(.switch)
                                            .frame(width:geoWidth*0.4)
                                        Button("완료") {
                                            editDone()
                                        }
                                        .frame(width:geoWidth*0.6, alignment: .trailing)
                                    }
                                }
                            }
                    }
                    if hasGoal && isEditing {
                        Text(" /")
                        TextField("", text:$goalValueInText)
                            .keyboardType(.numberPad)
                            .frame(width:geoWidth/3)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .goal)
                        
                        
                    }
                    
                    Text("\(DataType.unitNotationOf(dataType: dataType, customDataTypeNotation:dailyQuest.customDataTypeNotation))")
                }
                .padding(geoWidth*0.03)
                .frame(width:geoWidth, height: geoHeight, alignment: .center)
                .foregroundStyle(tierColor_dark)
                .bold()




                    
                if !isEditing {
                    Menu {
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
                    .buttonStyle(.plain)
                    .foregroundStyle(.black)
                    .frame(width: geometry.size.width*0.975, height: geometry.size.height*0.9, alignment: .topTrailing)
                }

                
                
                
            } // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(getTierColorOf(tier: tier))
            .clipShape(.buttonBorder)
            .onChange(of: hasGoal_toggle) {
                
                // 똑같을 때: hasGoal에 따라 hasGoal_toggle을 설정
                
                if hasGoal_toggle != hasGoal {
                    toggle(hasGoal_toggle)
                }
                
                
            }
            .onChange(of: value) {
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
                dailyQuest.data = value
            }
            .onChange(of: dailyGoal) {
                dailyQuest.dailyGoal = dailyGoal
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
            }
            .onChange(of: range) {
                xOffset = CGFloat(value).map(from:range, to: 0...geoWidth)
            }
            .onChange(of: hasGoal) {
                hasGoal_toggle = hasGoal
            }


        } // geometryReader



    }
    
    // below functions must contain three steps in proper order of their own functionality:
    // - set focusField
    // - set hasGoal
    func editDone() -> Void { // tranform view -> change&save values
        
        focusedField = nil
        isEditing = false

        if let newValue:Int = Int(valueInText) { value = newValue } // save value
        else { value = 0 }
        
        if let newGoalValue:Int = Int(goalValueInText) { // save dailyGoal
            if newGoalValue == 0 {
                hasGoal = false
                dailyGoal = nil
            }
            else {
                dailyGoal = newGoalValue
            }
        }
        else {
            hasGoal = false
            dailyGoal = nil
        }
    }
    func toggle(_ setGoal: Bool) -> Void {
        if setGoal { // setGoal
            // set dailyQuest.dailyGoal into non-nil, change the focus into goal
            hasGoal = hasGoal_toggle
            focusedField = nil
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                focusedField = .goal
            }

        }
        else { // deleteGoal
            dailyGoal = nil
            goalValueInText = ""
            focusedField = .value
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                hasGoal = hasGoal_toggle
            }

        }
    }
    func edit() -> Void { // set values -> transform view
        if let goalValue = dailyGoal {
            goalValueInText = String(goalValue)
        }
        else { // actually don't need it
            goalValueInText = ""
        }
        
        valueInText = String(value)

        isEditing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            focusedField = .value
        }

    }

}




extension CGFloat {
    func map(from source: ClosedRange<CGFloat>, to target: ClosedRange<CGFloat>) -> CGFloat {

        return target.lowerBound + (self - source.lowerBound) * (target.upperBound - target.lowerBound) / (source.upperBound - source.lowerBound)
    }
}


struct DialForHours: View {

    var questName: String
    
    @Binding var dailyGoal: Int?
    @Binding var value: Int
    @Binding var isEditing: Bool
    @Binding var hasGoal_toggle: Bool

    
//    @State var hour = 0
//    @State var minute = 0
//    @State var hour_goal = 0
//    @State var minute_goal = 0
    @State var dailyGoal_nonNil = 0

    var body: some View {
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            VStack {
                
                ZStack(alignment:.top) {
                    VStack {
                        Text(questName)
                            .font(.title3)
                        Toggle("목표설정",isOn:$hasGoal_toggle)
                            .frame(width:geoWidth/3)
                    }
//                    HStack(spacing:0.0) {
//                        Button("취소") {
//                            isEditing.toggle()
//                        }
//                        .padding(.leading, 10)
//                        .frame(width: (geometry.size.width*0.5), alignment: .leading)
                        Button("완료") {
//                            save()
                            isEditing.toggle()
                        }
                        .padding(.trailing, 10)
                        .frame(width: (geometry.size.width*0.95), alignment: .trailing)
//                    }

                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
//                .border(.red)
                
                HStack {
                    
                    
//                    Picker(selection: $hour, label: Text("First Value")) {
//                        ForEach(0..<25) { i in
//                            Text("\(i)").tag(i)
//                        }
//                    }
//                    .frame(width: 50)
//                    .clipped()
//                    .pickerStyle(.wheel)
                    Picker(selection: $value, label: Text("Second Value")) {
                        ForEach(0..<60*24) { i in
                            Text("\(DataType.string_fullRepresentableNotation(data: i, dataType: DataType.HOUR))").tag(i)
                        }
                    }
                    .frame(width: geoWidth/3)
                    .clipped()
                    .pickerStyle(.wheel)
                    
                    if hasGoal_toggle {
                        
                        if let dailyGoal_nonNil:Int = dailyGoal {
                            Picker(selection: $dailyGoal_nonNil, label: Text("Second Value")) {
                                ForEach(0..<60*24/5) { i in
                                    Text("\(DataType.string_fullRepresentableNotation(data: i*5, dataType: DataType.HOUR))").tag(i*5)
                                }
                            }
                            .frame(width: geoWidth/3)
                            .clipped()
                            .pickerStyle(.wheel)
                        }
//                        Picker(selection: $hour_goal, label: Text("First Value")) {
//                            ForEach(0..<25) { i in
//                                Text("\(i)").tag(i)
//                            }
//                        }
//                        .frame(width: 50)
//                        .clipped()
//                        .pickerStyle(.wheel)
//                        Text("시간  ")
//                        Picker(selection: $minute_goal, label: Text("Second Value")) {
//                            ForEach(0..<60) { i in
//                                Text("\(i)").tag(i)
//                            }
//                        }
//                        .frame(width: 50)
//                        .clipped()
//                        .pickerStyle(.wheel)
//                        Text("분")
                    }
                    
                    
                }
            }

        }        
        .onChange(of: dailyGoal_nonNil) {
            dailyGoal = dailyGoal_nonNil
        }
        .onChange(of: dailyGoal) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                if let nonNil:Int = dailyGoal {
//                    dailyGoal_nonNil = nonNil
//                }
//            }
            if dailyGoal == nil {
                dailyGoal_nonNil = (value/5+1)*5
            }
        }
//        .onChange(of: minute) {
//            value = hour*60 + minute
//        }
//        .onChange(of: hour) {
//            value = hour*60 + minute
//        }
//        .onChange(of: minute_goal) {
//            dailyGoal = hour_goal*60 + minute_goal
//        }
//        .onChange(of: hour_goal) {
//            dailyGoal = hour_goal*60 + minute_goal
//        }
        .onChange(of: hasGoal_toggle) {
//            if hasGoal_toggle {
//                    if let dailyGoal_nonNil: Int = dailyGoal {
//                        hour_goal = dailyGoal_nonNil/60
//                        minute_goal = dailyGoal_nonNil%60
//                    }
//                }
//            }
        }
    }

    
    func save() -> Void {
        //                            dailyGoal = hour*60 + minute
        //                            if dailyGoal <= value {
        //                                value = dailyGoal
        //                            }
    }
}


struct QuestCheckBoxColorPreview: View {

    @State var isAnimating: Bool = false
    var tier: Int
    
    var body: some View {
        

        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            
            let a: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/20, cornerHeight: geoHeight/20, transform: nil))

            
            let percentage:CGFloat = 1.0
            let brightness:CGFloat = percentage * 0.0
            
            
            let gradientColors = getGradientColorsOf(tier: tier, type:0)
            let _: [Color] = {
                var newGradient: [Color] = []
                for idx in 0...(gradientColors.count - 1) {
                    if idx % 2 == 0 {
                        newGradient.append(gradientColors[idx].adjust(brightness: brightness))
                    }
                    else {
                        newGradient.append(gradientColors[idx].adjust(brightness: brightness*0.5))
                    }
                }
                return newGradient
            }()
            


                
            ZStack {
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width:geoWidth, height:geoHeight)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                .frame(width:geoWidth, height:geoHeight)
                .mask{a}
                .onAppear() {
                    isAnimating = true
                }
                
                
                
            }
                    




        }
    }
}

#Preview(body: {
    VStack {
        QuestCheckBoxColorPreview(tier: 0)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 5)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 10)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 15)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 20)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 25)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 30)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 35)
            .frame(width:300, height: 45)
        QuestCheckBoxColorPreview(tier: 40)
            .frame(width:300, height: 45)

    }

})
