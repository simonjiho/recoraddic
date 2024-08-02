//
//  QuestCheckBoxView.swift
//  recoraddic
//
//  Created by 김지호 on 12/19/23.
// TODO: 공통 요소들 extract해서 이용하기

import Foundation
import SwiftUI
import SwiftData
import ActivityKit

enum DayOption: String, CaseIterable, Identifiable {
    
    case today
    case tomorrow
    case dayAfterTomorrow
    
    var id: String { self.rawValue }
    
    
    static let dayOption_kor:[DayOption:String] = [.today:"오늘",.tomorrow:"내일",.dayAfterTomorrow:"모레"]

}
func getDayOption(at date: Date) -> DayOption {
    let today = Date()
    let tomorrow = getTomorrowOf(today)
    let dayAfterTomorrow = getTomorrowOf(getTomorrowOf(today))
    if date < tomorrow {
        return .today
    }
    else if date < dayAfterTomorrow {
        return .tomorrow
    }
    else {
        return .dayAfterTomorrow
    }

}

func getNotificationTimeString(from date: Date?) -> String {
    if let date_nonNil = date {
        let dayOption: DayOption = getDayOption(at: date_nonNil)
        return (DayOption.dayOption_kor[dayOption] ?? "unexpectedValue") + " " + date_nonNil.hhmmTimeString_local
    } else {
        return "no alermTime"
    }
    
}


// TODO: purpose edit
// TODO: RecentPurpose 수정 / RecentData 수정



struct QuestCheckBoxView: View {
    @Environment(\.modelContext) var modelContext
    @Query var quests: [Quest]
    var dailyQuest: DailyQuest
    
    
    @Binding var targetDailyQuest: DailyQuest?
    @Binding var deleteTarget: Bool
    
    @State var value: Int
    @State var dailyGoal: Int?
    var range: ClosedRange<CGFloat> {
        return 0.0...CGFloat(dailyGoal ?? value)
    }
    @State var xOffset: CGFloat

    let width: CGFloat
    
    @StateObject var stopwatch = Stopwatch()
    @State var showMenu: Bool = false
//    @State var isDragging: Bool = false
    @State var isAnimating: Bool = false

    
//    let menuSize:CGFloat = UIScreen.main.bounds.width * 0.2
    @State private var offset: CGFloat = 0

    
    var body: some View {
        
        let height:CGFloat = stopwatch.isRunning ? 75.0 : 60.0
        let sheetHeight:CGFloat = UIScreen.main.bounds.height * 0.4
        //            let geoHeight = geometry.size.height
        let menuSize:CGFloat = width * 0.2
        
        let a: Path = Path(CGPath(rect: CGRect(x: 0, y: 0, width: (xOffset.isFinite && xOffset >= 0 && xOffset <= width +  0.1) ? xOffset : width, height: height), transform: nil))
        let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0)
        
        let isRecent: Bool = getStartDateOfYesterday() <= dailyQuest.dailyRecord!.date!
        
        HStack(spacing:0.0) {
            
            HStack(spacing:0.0) {
                QuestCheckBoxContentView(
                    dailyQuest: dailyQuest,
                    value: $value,
                    dailyGoal: $dailyGoal,
                    stopwatch: stopwatch
                )
                .frame(width:width*7/8, height: height)
                .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))
                .bold()
                
                NotificationButton(
                    dailyQuest: dailyQuest,
                    popOverWidth: width,
                    popOverHeight: height
                )
                .frame(width: width*1/8, height: height)
                .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))
                .disabled(!isRecent)
                .opacity( isRecent ? 1.0 : 0.0)
//                .border(.red)
            }
            .frame(width:width, height: height)
            .background(
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * width)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * width)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                    .frame(width:width, height:height)
                    .mask {
                        a
                    }
                    .background(getTierColorOf(tier: dailyQuest.currentTier))
                    .blur(radius: 1)
                    .opacity(0.9)
                
            )
            .disabled(offset < -menuSize*0.5)
            .offset(x: offset, y:0)
            .onAppear() {
                isAnimating = true
            }
            
            HStack(spacing:0.0) {
                Image(systemName: "xmark")
                    .frame(width: menuSize, height:height)
                Spacer()
                    .frame(width: menuSize*2, height:height)
            }
            .frame(width: menuSize*3, height:height)
            .background(Color.red.blur(radius: 1))
            .offset(x: offset, y:0)
            .disabled(offset > -menuSize*0.5)
            .onTapGesture {
                deleteTarget.toggle()
            }
            
            
        }
        .frame(width:width, height: height, alignment: .leading)
        .clipShape(.buttonBorder)
        .clipped()
        
        .gesture(
            DragGesture()
                .onChanged { value in
                    
                    targetDailyQuest = nil
                    
                    if showMenu {
                        if value.translation.width < 0 {
                            let delta = log10(10 - value.translation.width*0.1)
                            offset = (-menuSize) * (delta)
                        }
                        else if value.translation.width > menuSize {
                            let delta = log10(1 + (value.translation.width - menuSize)*0.01)
                            offset = (menuSize) * (delta)
                        }
                        else {
                            offset = -menuSize + value.translation.width
                            
                        }
                    } else {
                        if value.translation.width < -menuSize {
                            let delta = log10(10 - (value.translation.width + menuSize)*0.1)
                            offset = (-menuSize) * (delta)
                        }
                        else if value.translation.width > 0 {
                        }
                        else {
                            offset = value.translation.width
                        }
                        
                    }
                    
                    
                }
                .onEnded { value in
                    if !(value.translation.width > 0 && !showMenu) {
                        if value.translation.width < -width*0.05 {
                            targetDailyQuest = dailyQuest
                            withAnimation {
                                offset = -menuSize
                            }
                            showMenu = true
                            
                        } else {
                            targetDailyQuest = nil
                            showMenu = false
                            withAnimation {
                                offset = 0
                            }
                        }
                    }
                    
                }
        )
        .onChange(of: targetDailyQuest) { oldValue, newValue in
            //                let selfToNil = oldValue == idx && newValue == nil
            let nilToSelf = oldValue == nil && newValue == dailyQuest
            //                let nilToOther = oldValue == nil && newValue != idx
            //                let OtherToNil = oldValue != idx && newValue == nil
            //                let selfToSelf = oldValue == idx && newValue == idx
            
            if nilToSelf {
                withAnimation {
                    offset = -menuSize
                }
            }
            //                else if selfToSelf {
            //                }
            else {
                withAnimation {
                    offset = 0
                }
            }
            
        }
        .onChange(of: value) { oldValue, newValue in
            
            xOffset = CGFloat(value).map(from:range, to: 0...width)
            dailyQuest.data = value
            updateQuest(for: dailyQuest)
            
            if let dailyRecord = dailyQuest.dailyRecord {
                if oldValue != 0 && newValue == 0 && !dailyRecord.hasContent {
                    dailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
                }
                else if oldValue == 0 && newValue != 0 && dailyRecord.singleElm_dailyQuestOrTodo {
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
    //                }
                }
            }
            


            
            
        }
        .onChange(of: dailyGoal) {
            dailyQuest.dailyGoal = dailyGoal
            xOffset = CGFloat(value).map(from:range, to: 0...width)
        }
        .onChange(of: range) {
            xOffset = CGFloat(value).map(from:range, to: 0...width)
        }
        //        }
    }
    func calculateOffset(dragAmount: CGFloat, lastOffset: CGFloat, boundary: CGFloat) -> CGFloat {
//        let boundary: CGFloat = 100.0
        let scalingFactor: CGFloat = 0.1
        
        let newOffset = lastOffset + dragAmount
        
        if newOffset > boundary {
            return boundary + log(newOffset - boundary + 1) / scalingFactor
//            return lastOffset
            
        } else if newOffset < -boundary {
            return -boundary - log(-newOffset - boundary + 1) / scalingFactor
//            return lastOffset
        } else {
            return newOffset
        }
    }
    
    func updateQuest(for dailyQuest: DailyQuest) -> Void {
        if let date = dailyQuest.dailyRecord?.date {
            if let targetQuest = findQuest(dailyQuest.questName) {
                if dailyQuest.data != 0 {
                    if targetQuest.dailyData[date] == nil {
                        targetQuest.dailyData[date] = dailyQuest.data
                        targetQuest.updateTier()
                        targetQuest.updateMomentumLevel()
                    }
                    else {
                        targetQuest.dailyData[date] = dailyQuest.data
                    }
                }
                else {
                    targetQuest.dailyData.removeValue(forKey: date)
                }

            }
        }
    }
    
    func findQuest(_ name: String) -> Quest? {
        return quests.first(where: {$0.name == name})
    }


}


struct QuestCheckBoxContentView: View {
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    @Binding var value: Int
    @Binding var dailyGoal: Int?
    @ObservedObject var stopwatch: Stopwatch


    var body: some View {
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let height:CGFloat = stopwatch.isRunning ? 75.0 : 60.0

            if dailyQuest.dataType == DataType.ox.rawValue {
                QuestCheckBoxContent_OX(
                    dailyQuest:dailyQuest,
                    value: $value
                )
                .frame(width: geoWidth,height: height)

            } else if dailyQuest.dataType == DataType.hour.rawValue {
                QuestCheckBoxContent_HOUR(
                    dailyQuest:dailyQuest,
                    value: $value,
                    dailyGoal: $dailyGoal,
                    hasGoal: dailyQuest.dailyGoal != nil,
                    hasGoal_toggle: dailyQuest.dailyGoal != nil,
                    stopwatch: stopwatch
                )
                .frame(width: geoWidth,height: height)

            } else {
                QuestCheckBoxContent_CUSTOM(
                    dailyQuest:dailyQuest,
                    value: $value,
                    dailyGoal: $dailyGoal,
                    hasGoal: dailyQuest.dailyGoal != nil,
                    hasGoal_toggle: dailyQuest.dailyGoal != nil
                )
                .frame(width: geoWidth,height: height)

            }
        }
    }
}

struct QuestCheckBoxContent_OX:View {
    
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    @Binding var value: Int

    
    var body: some View {
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            HStack(spacing:0.0) {
                Button(action:{dailyQuest.data = dailyQuest.data == 1 ? 0 : 1}) {
                    Image(systemName: dailyQuest.data == 1 ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: geoWidth*1/7*0.67, height: geoWidth*1/7*0.67)
                }
                .frame(width: geoWidth*1/7, height: geoHeight)
//                .border(.red)
                .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))


                Text(dailyQuest.getName())
                    .frame(width: geoWidth*6/7, height: geoHeight)
                    .bold()
            }
            .frame(width: geoWidth,height: geoHeight)
        }
    }
}



struct QuestCheckBoxContent_HOUR:View {
    @Environment(\.modelContext) var modelContext
//    @EnvironmentObject var activityManager: ActivityManager

    var dailyQuest: DailyQuest

    
    @Binding var value: Int
    @Binding var dailyGoal: Int?

    
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
    @ObservedObject var stopwatch: Stopwatch

    
//    @ObservedObject var activityManager: ActivityManager
    @State var onTimer: Bool = false
    @State var isEditing_hours: Bool = false
    @State var showQuestName: Bool = false
    @State var showValue: Bool = false
    @State private var activity: Activity<RecoraddicWidgetAttributes>? = nil

    @State var highlightValue: Bool = false
    @State var highlightValue2: Int = 1
    
    @State var lastTapTime: Date = Date()
    
    let sheetHeight:CGFloat = UIScreen.main.bounds.height * 0.4

    
    var body: some View {
        
        let questName = dailyQuest.getName()

        let dataType = dailyQuest.dataType
        let customDataTypeNotation = dailyQuest.customDataTypeNotation

        let tier: Int = dailyQuest.currentTier
        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let height:CGFloat = stopwatch.isRunning ? 75.0 : 60.0

            HStack(spacing:0.0) {
                
                let isRecent: Bool = getStandardDateOfYesterday() <= dailyQuest.dailyRecord!.date!

                if onTimer {
                    Button(action: {
                        onTimer.toggle()
                        guard let activity_activated = activity else {
                            return
                        }
                        let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                        Task {
                            await activity_activated.end(ActivityContent(state: activity_activated.content.state, staleDate: nil), dismissalPolicy: dismissalPolicy)

                        }
                        activity = nil

                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            withAnimation(.easeInOut(duration:0.2)) {
                                stopwatch.stop()
                            }
                            value = stopwatch.getTotalSec()/60
                            stopwatch.setTotalSec(value*60)
                        }
                    }) {
                        Image(systemName: "pause")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geoWidth*1/9*0.75, height: geoWidth*1/9*0.75)
                            
                    }
                    .frame(width: geoWidth*1/7, alignment: .center)
                    .disabled(!isRecent)
                    .opacity( isRecent ? 1.0 : 0.0)

                    
                    let HeightOnTimer:CGFloat = 75.0
                    VStack {
                        Text("\(questName)")
                            .lineLimit(1)
                            .font(.system(size: highlightValue2 == 0 ? HeightOnTimer*0.35 : HeightOnTimer*0.2))
//                            .minimumScaleFactor(0.5)
                        
//                            .font(.caption2)
                        Text(stopwatch.timeString)
                            .font(.system(size: highlightValue2 == 1 ? HeightOnTimer*0.35 : HeightOnTimer*0.2))

                        if hasGoal {
                            Text_hours2(prefix: "목표: ",value: dailyQuest.dailyGoal ?? 0)
                                .font(.system(size: highlightValue2 == 2 ? HeightOnTimer*0.35 : HeightOnTimer*0.2))
//                                .font(.caption2)
                        }

                    }
                    .padding(.horizontal,10)
                    .frame(width:geoWidth*6/7)
                        .onTapGesture {
                            lastTapTime = Date()
                            highlightValue2 = (highlightValue2 + 1) % 3
                            if highlightValue2 != 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    if Date().timeIntervalSince(lastTapTime) > 4.0 {
                                        highlightValue2 = 1
                                    }
                                }
                            }
                        }
                        .popover(isPresented: $showQuestName) {
                            Text("\(questName)")
                                .padding()
                                .frame(width:geoWidth*8/7)
                                .foregroundStyle(getBrightTierColorOf(tier: tier))
                                .background(getDarkTierColorOf(tier: dailyQuest.currentTier)) // 크기 유지를 위해(없으면 자동 조정됨)
                                .presentationCompactAdaptation(.popover)
                                .presentationBackground(getDarkTierColorOf(tier: dailyQuest.currentTier))
                        }


                }
                else {
                    let height:CGFloat = 60.0
                    Button(action: {
                        
                        stopwatch.setTotalSec(value*60)
                        let calendar = Calendar.current
                        let startTime: Date = calendar.date(byAdding: .minute, value: -(value), to: .now)!
                        
                        withAnimation(.easeInOut(duration:0.2)) {
                            stopwatch.start(startTime:startTime)
                        }
                        let attributes = RecoraddicWidgetAttributes(questName: questName, startTime:startTime, tier: tier)
                        let initialContentState = RecoraddicWidgetAttributes.ContentState(goal: dailyGoal)
                        do {
                            let activity = try Activity<RecoraddicWidgetAttributes>.request(
                                attributes: attributes,
                                content: ActivityContent(state: initialContentState, staleDate: nil),
                                pushType: nil
                            )
                            self.activity = activity
                        } catch {
                            print("Failed to start activity: \(error.localizedDescription)")
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            onTimer.toggle()
                        }
                        
                    }) {
                        Image(systemName: "play")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geoWidth*1/9*0.75, height: geoWidth*1/9*0.75)
//                            .bold(false)

                    }
                    .frame(width: geoWidth*1/7, alignment: .center)
                    .disabled(!isRecent)
                    .opacity( isRecent ? 1.0 : 0.0)

                    
                    HStack {
                        VStack {
                            Text("\(questName)")
                                .lineLimit(1)
                                .font(.system(size: highlightValue ? height*0.25 : height*0.4))
                                .minimumScaleFactor(0.85)
                                .popover(isPresented: $showQuestName) {
                                    Text("\(questName)")
                                        .padding()
                                        .frame(width:geoWidth*8/7)
                                        .foregroundStyle(getBrightTierColorOf(tier: tier))
                                        .background(getDarkTierColorOf(tier: dailyQuest.currentTier)) // 크기 유지를 위해(없으면 자동 조정됨)
                                        .presentationCompactAdaptation(.popover)
                                        .presentationBackground(getDarkTierColorOf(tier: dailyQuest.currentTier))
                                }
//                            Text("\(stopwatch.timeString)")
                            HStack {
                                Text_hours(value: value)
                                    .lineLimit(1)
                                if hasGoal {
                                    Text("/")
                                        .lineLimit(1)
                                    Text_hours(value: dailyQuest.dailyGoal ?? 0)
                                        .lineLimit(1)
                                }
                                
                                if !isEditing_hours {
                                    Button(action:{
                                        highlightValue = true
                                        isEditing_hours.toggle()
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                    }
                                    .lineLimit(1)
                                }
                            }
                            .font(.system(size: !highlightValue ? height*0.25 : height*0.4))
                            .minimumScaleFactor(0.6)

//                            .font(!highlightValue ? .caption :.body)
//                            .bold(highlightValue)
                            
                                
                        }

                        
                    }
                    .padding(.horizontal,10)
                    .frame(width:geoWidth*6/7)
                    .onTapGesture {
                        lastTapTime = Date()
                        highlightValue.toggle()
                        if highlightValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                if !isEditing_hours && (Date().timeIntervalSince(lastTapTime) > 4.0) {
                                    highlightValue = false
     
                                }
                            }
                        }
                    }
//                    Text("\(questName)")
//                        .frame(width: geoWidth*6/7, height: geoHeight)
//                        .lineLimit(1)
//                        .onTapGesture {
//                            showValue.toggle()
//                        }
                }
            }

            .frame(width: geoWidth,height: height)
            .foregroundStyle(getDarkTierColorOf(tier: tier))
            .sheet(isPresented: $isEditing_hours) {
                // code for on dismiss
            } content: {
                DialForHours(
                    questName:questName,
                    dailyGoal: $dailyGoal,
                    value: $value,
                    isEditing: $isEditing_hours,
                    hasGoal_toggle: $hasGoal_toggle,
                    tier: tier,
                    dailyGoal_nonNil: dailyGoal ?? value
                )
                .presentationDetents([.height(sheetHeight)])
                .presentationCompactAdaptation(.none)
                .presentationBackground(getDarkTierColorOf(tier: tier))

            }
            .onChange(of: hasGoal_toggle) {

                // 똑같을 때: hasGoal에 따라 hasGoal_toggle을 설정
                if hasGoal_toggle != hasGoal {
                        toggle_hour(hasGoal_toggle)
                }


            }

            .onChange(of: hasGoal) {
                hasGoal_toggle = hasGoal
            }
            .onChange(of:isEditing_hours) {
                if !isEditing_hours {
                    highlightValue = false
                }
            }
            .onChange(of: value) {
                dailyQuest.dailyRecord?.updateRecordedMinutes()
            }

        }
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


struct Text_hours: View {
    var value: Int
    var body: some View {
        let (hours,minutes) = DataType.string_unitDataToRepresentableData_hours(data: value)
        Text("\(hours == "0" ? "" : hours)")
            .bold(true) +
        Text("\(hours == "0" ? "" : (minutes == "0" ? "hr" : "h"))")
            .bold(false) +
        Text(" \( (hours == "0" || minutes != "0") ? minutes : "" )")
            .bold(true) +
        Text("\(hours == "0" ? "min" : (minutes == "0" ? "" : "m"))")
            .bold(false)
            
    }

}

struct Text_hours2: View {
    var prefix: String = ""
    var value: Int
    var suffix: String = ""
    var body: some View {
        let (hours,minutes) = DataType.string_unitDataToRepresentableData_hours(data: value)
        Text(prefix)
            .bold(true) +
        Text("\(hours == "0" ? "" : "\(hours)")")
            .bold(true) +
        Text("\(hours == "0" ? "" : (minutes == "0" ? "hr" : "h"))")
            .bold(false) +
        Text(" \(minutes)")
            .bold(true) +
        Text("\(hours == "0" ? "min" : "m")")
            .bold(false) +
        Text(suffix)
            .bold(true)
            
    }

}




struct QuestCheckBoxContent_CUSTOM:View {
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    
    @Binding var value: Int
    @Binding var dailyGoal: Int?
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
    
    @State var isEditing: Bool = false
    @State var valueInText: String = ""
    @State var goalValueInText: String = ""

    @FocusState var focusedField: Field?
    enum Field: Int, CaseIterable {
        case value
        case goal
    }
    
    @State var showValue: Bool = false
    @State var highlightValue: Bool = false
    @State var onToggleModification: Bool = false
    @State var lastTapTime: Date = Date()

    var body: some View {
        
        let questName = dailyQuest.getName()
        let dataType = dailyQuest.dataType
        let tier: Int = dailyQuest.currentTier
        let customDataTypeNotation = dailyQuest.customDataTypeNotation
        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        GeometryReader { geometry in
            
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            HStack(spacing:0.0) {
                Spacer()
                    .frame(width: geoWidth*1/7, height: geoWidth*0.1)
                VStack {
                    Text(questName)
                        .frame(width: geoWidth*4.5/7)
                        .font(.system(size: highlightValue ? geoHeight*0.25 : geoHeight*0.4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .bold()

                    HStack {
//                    HStack(spacing:0.0) {
                        if isEditing {
                            TextField("", text:$valueInText)
                                .keyboardType(.numberPad)
                                .frame(width: geoWidth*((focusedField == .value || focusedField == nil) ? 3.0 : 0.5)/7, height: geoHeight*0.4)
                                .textFieldStyle(.roundedBorder)
                                .clipShape(.buttonBorder)
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
                                                .foregroundStyle(.blue)
                                            Button("완료") {
                                                editDone()
                                            }
                                            .frame(width:geoWidth*0.6, alignment: .trailing)
                                            .foregroundStyle(.blue)
                                        }
                                    }
                                }
                            if hasGoal  {
                                Text(" / ")
                                TextField("", text:$goalValueInText)
                                    .keyboardType(.numberPad)
                                    .frame(width:geoWidth*(focusedField == .goal ? 3.0 : 0.5)/7, height: geoHeight*0.4)
                                    .textFieldStyle(.roundedBorder)
                                    .clipShape(.buttonBorder)
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .goal)
                            }
                            Text(DataType.unitNotationOf(dataType: dataTypeFrom(dataType), customDataTypeNotation: customDataTypeNotation))
                                .bold(false)

                                
                            
                        }
                        else {
                            Text("\(value)")
                                .bold() +
                            Text(customDataTypeNotation ?? "")
                                .bold(false) +
                            Text(!hasGoal ? "" : " / ")
                                .bold(false) +
                            Text(!hasGoal ? "" : "\(dailyGoal ?? 0)")
                                .bold() +
                            Text(!hasGoal ? "" : "\(customDataTypeNotation ?? "")")
                                .bold(false)

                            Button(action:{
                                edit()
                                highlightValue = true
                            }) {
                                Image(systemName: "square.and.pencil")
                            }

                        }

                    }
                    .font(.system(size: !highlightValue ? geoHeight*0.25 : geoHeight*0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                }
                .padding(.horizontal,10)
                .frame(width: geoWidth*6/7)
                .onTapGesture {
                    lastTapTime = Date()
                    if !isEditing {
                        highlightValue.toggle()
                        if highlightValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                if !isEditing && (Date().timeIntervalSince(lastTapTime) > 4.0) {
                                    highlightValue = false
                                }
                            }
                        }
                    }
                }


            }
            .frame(width: geoWidth,height: geoHeight)
            .onChange(of: hasGoal_toggle) {
                // 똑같을 때: hasGoal에 따라 hasGoal_toggle을 설정
                if hasGoal_toggle != hasGoal {
                    toggle(hasGoal_toggle)
                }
            }
            .onChange(of: hasGoal) {
                hasGoal_toggle = hasGoal
            }
            .onChange(of: focusedField) {
                
                if focusedField == nil && !onToggleModification {
                    editDone()
                }
            }
            .onChange(of: isEditing) {
                if !isEditing {highlightValue = false}
            }

            
        }
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
        onToggleModification = true
        if setGoal { // setGoal
            // set dailyQuest.dailyGoal into non-nil, change the focus into goal
            hasGoal = hasGoal_toggle
            focusedField = nil
            goalValueInText = String(format: "%d", value)
            dailyGoal = value
            
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
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            onToggleModification = false
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


class Stopwatch: ObservableObject {
    var startTime: Date?
    @Published var timeString = "00:00:00"
    private var timer: Timer?
    private var totalSec: Int = 0
    @Published var publish = Timer.publish(every: 1, on: .main, in: .default).autoconnect()

    var isRunning: Bool {
        timer != nil
    }

    func start(startTime: Date) {
        self.startTime = startTime
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.totalSec = Int(Date().timeIntervalSince(startTime))
            self.updateTime()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }

    func setTotalSec(_ input: Int) {
        self.totalSec = input
        updateTime()
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







struct DialForHours: View {

    @Environment(\.colorScheme) var colorScheme
    
    var questName: String
    
    @Binding var dailyGoal: Int?
    @Binding var value: Int
    @Binding var isEditing: Bool
    @Binding var hasGoal_toggle: Bool
    var tier: Int

    
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
                            .font(.title2)
                            .frame(width:geoWidth*0.6)
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                            .bold()
                        Toggle("목표설정",isOn:$hasGoal_toggle)
                            .frame(width:geoWidth/3)
                            .buttonBorderShape(.automatic)
                    }
                    Button("완료") {
                        isEditing.toggle()
                    }
                    .padding(.trailing, 10)
                    .frame(width: (geometry.size.width*0.95), alignment: .trailing)
//

                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
                .padding(.bottom, geoHeight*0.1)

                HStack(spacing:0.0) {
                    
                    
//                    Picker(selection: $hour, label: Text("First Value")) {
//                        ForEach(0..<25) { i in
//                            Text("\(i)").tag(i)
//                        }
//                    }
//                    .frame(width: 50)
//                    .clipped()
//                    .pickerStyle(.wheel)
                    VStack {
                        Text("달성")
                            .bold()
                        Picker(selection: $value, label: Text("Second Value")) {
                            ForEach(0..<60*24) { i in
                                Text("\(DataType.string_fullRepresentableNotation(data: i, dataType: DataType.hour))")
                                    .foregroundStyle(getDarkTierColorOf(tier: tier))

                            }
                        }
                        
                        .frame(width: hasGoal_toggle ? geoWidth/3 : geoWidth*0.5)
                        .clipped()
                        .pickerStyle(.wheel)
                        .background(getBrightTierColorOf(tier: tier))
                        .clipShape(.buttonBorder)
                    }
                    .frame(width: geoWidth/2)


                    
                    
                    
                    if hasGoal_toggle {
                        VStack {
                            Text("목표")
                                .bold()
                            Picker(selection: $dailyGoal_nonNil, label: Text("Second Value")) {
                                ForEach(0..<60*24/5) { i in
                                    Text("\(DataType.string_fullRepresentableNotation(data: (i+1)*5, dataType: DataType.hour))")
                                        .tag((i+1)*5)
                                        .foregroundStyle(getDarkTierColorOf(tier: tier))
                                }
                            }
                            .frame(width: geoWidth/3)
                            .clipped()
                            .pickerStyle(.wheel)
                            .background(getBrightTierColorOf(tier: tier))
                            .clipShape(.buttonBorder)
                            
                        }
                        .frame(width: geoWidth/2)


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
            .foregroundStyle(getBrightTierColorOf(tier: tier))


        }
        .onChange(of: dailyGoal_nonNil) {
            if hasGoal_toggle {
                dailyGoal = dailyGoal_nonNil
            }
        }
        .onChange(of: dailyGoal) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let nonNil:Int = dailyGoal {
                    dailyGoal_nonNil = nonNil
                }
            }
            if dailyGoal == nil {
                dailyGoal_nonNil = (value/5+1)*5
            }
        }


//        .onChange(of: hasGoal_toggle) {
//            if hasGoal_toggle {
//                dailyGoal_nonNil = (value/5+1)*5
//            }
//        }
        
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



struct NotificationButton: View {
    
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    var popOverWidth: CGFloat
    var popOverHeight: CGFloat

    let sheetHeight:CGFloat = UIScreen.main.bounds.height * 0.4
    
    @State var showNotficationTime: Bool = false
    @State var editNotificationTime: Bool = false
//    @State var
    
//    let popOverWidth2:CGFloat = UIScreen.main.bounds.width
    let popOverWidth2:CGFloat = UIScreen.main.bounds.width*2
    
    
    var body: some View {

        let questName = dailyQuest.getName()

        let setAlready:Bool = dailyQuest.alermTime != nil
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let size = min(geoWidth, geoHeight)
//            Button("",systemImage: setAlready ? "bell" : "bell.slash") {
//                if setAlready {
//                    showNotficationTime.toggle()
//                } else {
//                    editNotificationTime.toggle()
//                }
//            }
            Button(action: {
                if setAlready {
                    showNotficationTime.toggle()
                } else {
                    editNotificationTime.toggle()
                }

            }) {
                if let alermTime = dailyQuest.alermTime {
                    ClockView(hour: Calendar.current.component(.hour, from: alermTime), minute: Calendar.current.component(.minute, from: alermTime))
                        .frame(width:25, height: 25)
                } else {
                    Image(systemName: setAlready ? "bell" : "bell.slash")
                        .opacity(0.7)
                }
                
            }
//            .bold(setAlready)
//            .border(.yellow)
            .frame(width: geoWidth, height: geoHeight)
//            .border(.red)
            .popover(isPresented: $showNotficationTime, attachmentAnchor: .point(.topLeading)) {
                HStack {
                    Text(getNotificationTimeString(from: dailyQuest.alermTime))
                        .padding(.horizontal)
                    Button("수정") {
                        showNotficationTime.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            editNotificationTime.toggle()
                        }
                    }
                    .buttonStyle(NotificationButtonStyle(dailyQuest.currentTier))

                    Button("해제") {
                        if let previousAlermTime = dailyQuest.alermTime {
                            removeNotification(at: previousAlermTime, for: questName) // MARK: questName 변경 시 지울 수 없음
                        }
                        showNotficationTime.toggle()
                        dailyQuest.alermTime = nil
                    }
                    .buttonStyle(NotificationButtonStyle_red(dailyQuest.currentTier))


                }
                .frame(width:popOverWidth2)
//                .frame(width:.greatestFiniteMagnitude, alignment: .center)
//                .frame(width:popOverWidth, height: popOverHeight)
                .foregroundStyle(getBrightTierColorOf(tier: dailyQuest.currentTier))
                .background(getDarkTierColorOf(tier: dailyQuest.currentTier)) // 크기 유지를 위해(없으면 자동 조정됨)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(getDarkTierColorOf(tier: dailyQuest.currentTier))
//                .border(.red)

            }
            .sheet(isPresented: $editNotificationTime) {
                EditNotificationTimeView(
                    dailyQuest: dailyQuest,
                    selectedTime: dailyQuest.alermTime ?? Date(),
                    selectedDay: getDayOption(at: dailyQuest.alermTime ?? Date()),
                    editNotificationTime: $editNotificationTime
                )
                .presentationDetents([.height(sheetHeight)])
//                .frame(width: popOverWidth, height: popOverHeight, alignment: .center)
                .foregroundStyle(getBrightTierColorOf(tier: dailyQuest.currentTier))
                .background(getDarkTierColorOf(tier: dailyQuest.currentTier))
                .presentationDragIndicator(.visible)
//                .preferredColorScheme(.dark)

                
            }
        }
//        .onChange(of: selectedTime, { oldValue, newValue in
//            dailyQuest.alermTime = selectedTime
//        })
//        .onChange(of: dailyQuest.alermTime) { oldValue, newValue in
////            selectedTime = dailyQuest.alermTime
//        }
    }
}

struct NotificationButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    var tier:Int
    

    init(_ tier: Int) {
        self.tier = tier
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal,10)
            .foregroundStyle(getDarkTierColorOf(tier: tier))
            .background(getBrightTierColorOf(tier: tier))
            .clipShape(.buttonBorder)

    }
}

struct NotificationButtonStyle_red: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    var tier:Int
    

    init(_ tier: Int) {
        self.tier = tier
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal,10)
//            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .foregroundStyle(getDarkTierColorOf(tier: tier))
            .background(.red)
            .clipShape(.buttonBorder)
//            .opacity(0.95)

    }
}




struct EditNotificationTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    @State var selectedTime: Date
    @State var selectedDay:DayOption
    
    @Binding var editNotificationTime: Bool
    
    

    var body: some View {
        
        let questName = dailyQuest.getName()

        let setAlready:Bool = dailyQuest.alermTime != nil
        let notModifiedYet:Bool = setAlready && (dailyQuest.alermTime ?? selectedTime) == selectedTime
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            VStack {
                Text(selectedTime,format: .dateTime)
                    .font(.title3)
                    .bold()
//                    .minimumScaleFactor(0.7)
//                    .frame(width:geoWidth)
                    .padding(.top)
                //                if let alermTime = dailyQuest.alermTime {
                ////                    HStack(spacing:0.0) {
                //                        Text(alermTime,format: .dateTime)
                ////                    }
                //                }
                Picker("", selection: $selectedDay) {
                    ForEach(DayOption.allCases, id:\.self) { dayOption in
                        Text(DayOption.dayOption_kor[dayOption] ?? "optionErr") // MARK: foreground, backgroundstyle adjustment not avaialable(xcode15), reported at 24/07/12

                        
                    }

                }
                .pickerStyle(.segmented)
                
                
                DatePicker("Select time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    .frame(height: geoHeight*0.4)
                    .datePickerStyle(WheelDatePickerStyle())
                    .invertColorInLightMode()
                    .clipped()
                    .labelsHidden()
                    .contentShape(Rectangle())
                    .zIndex(-1)
                    .padding()
                    
                
                //                Text("현재 이후의 시간으로만 알림설정이 가능합니다.")
                //                    .foregroundStyle(.red)
                //                    .font(.caption)
                HStack(spacing:0.0) {

                    Button("취소") {
                        editNotificationTime.toggle()
                    }
                    .frame(width: geoWidth/2)
                    .foregroundStyle(.red)
                    .buttonStyle(NotificationButtonStyle(dailyQuest.currentTier))
                    
                    
                    //                    Button((dailyQuest.alermTime ?? selectedTime) == selectedTime ? "취소" : (dailyQuest.alermTime == nil ? "알림 설정" : "알림 수정") ) {
                    Button(dailyQuest.alermTime == nil ? "알림 설정" : "알림 수정") {
                        if let previousAlermTime = dailyQuest.alermTime {
                            removeNotification(at: previousAlermTime, for: questName) // MARK: questName 변경 시 지울 수 없음
                        }
                        dailyQuest.alermTime = selectedTime
                        scheduleNotification(at: selectedTime, for: questName, goal: dailyQuest.dailyGoal, dataType: dailyQuest.dataType, customDataTypeNotation: dailyQuest.customDataTypeNotation
                        )
                        editNotificationTime.toggle()
                    }
                    .frame(width: geoWidth/2)
                    .disabled(notModifiedYet)
                    .opacity(notModifiedYet ? 0.3 : 1.0)
                    .buttonStyle(NotificationButtonStyle(dailyQuest.currentTier))
                    
                }
                .padding()
                
            }
            .padding()
            .frame(width:geoWidth, height: geoHeight)
            .onAppear() {
                if selectedDay == .today && getStartOfDate(date:selectedTime) != getStartDateOfNow() {
                    selectedTime = Date()
                }
            }
            .onChange(of: selectedDay) { oldValue, newValue in
                let calendar = Calendar.current
                switch (oldValue, newValue) {
                    //                case ("today":"today"),("tomorrow":"tomorrow"), ("dayAftertomorrow":"dayAftertomorrow"): break
                case (.tomorrow,.today),(.dayAfterTomorrow,.tomorrow): selectedTime = calendar.date(byAdding: .day, value: -1, to: selectedTime) ?? Date()
                case (.today,.tomorrow),(.tomorrow,.dayAfterTomorrow): selectedTime = calendar.date(byAdding: .day, value: 1, to: selectedTime) ?? Date()
                case (.dayAfterTomorrow,.today): selectedTime = calendar.date(byAdding: .day, value: -2, to: selectedTime) ?? Date()
                case (.today,.dayAfterTomorrow): selectedTime = calendar.date(byAdding: .day, value: 2, to: selectedTime) ?? Date()
                    
                default: break
                }
            }
        }
    }
}


struct ClockView: View {
    var hour: Int
    var minute: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let clockSize = min(width, height)
            let mainLineWidth = clockSize / 10
            let subLineWidth = mainLineWidth * 0.67
            
            ZStack {
                // Draw the clock face
                Circle()
                    .stroke(lineWidth: mainLineWidth)
                    .frame(width: clockSize, height: clockSize)
                
                // Draw the hour ticks
                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1, height: clockSize / 20)
                        .offset(y: -clockSize / 2 + clockSize / 40)
                        .rotationEffect(Angle(degrees: Double(tick) * 30))
                }
                
                Circle()
                    .fill(Color.primary)
                    .frame(width: subLineWidth, height: subLineWidth)
                
                // Draw the hour hand
                Path { path in
                    path.move(to: CGPoint(x: clockSize / 2, y: clockSize / 2))
                    path.addLine(to: CGPoint(x: clockSize / 2, y: clockSize / 4))
                }
                .stroke(Color.primary, style: StrokeStyle(lineWidth: mainLineWidth, lineCap: .round))
                
//                .offset(x: -clockSize / 2, y: -clockSize / 2)
                .rotationEffect(hourAngle(hour: hour, minute: minute), anchor: .center)
                .offset(x:sin(hourAngle(hour: hour, minute: minute).radians)*(mainLineWidth-subLineWidth), y:-cos(hourAngle(hour: hour, minute: minute).radians)*(mainLineWidth-subLineWidth))
                
                // Draw the minute hand
                Path { path in
                    path.move(to: CGPoint(x: clockSize / 2, y: clockSize / 2))
                    path.addLine(to: CGPoint(x: clockSize / 2, y: clockSize / 10))
                }
                .stroke(Color.primary, style: StrokeStyle(lineWidth: subLineWidth, lineCap: .round))
//                .offset(x: -clockSize / 2, y: -clockSize / 2)
                .rotationEffect(minuteAngle(minute: minute), anchor: .center)
            }
            .frame(width: clockSize, height: clockSize)
        }
    }
    
    private func hourAngle(hour: Int, minute: Int) -> Angle {
        let hourIn12 = hour % 12
        let hourAngle = (Double(hourIn12) + Double(minute) / 60.0) * 30.0
        return Angle(degrees: hourAngle)
    }
    
    private func minuteAngle(minute: Int) -> Angle {
        let minuteAngle = Double(minute) * 6.0
        return Angle(degrees: minuteAngle)
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



