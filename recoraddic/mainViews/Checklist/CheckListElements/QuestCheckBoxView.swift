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
    
    case yesterday
    case today
    case tomorrow
    
    var id: String { self.rawValue }
    
    
    static let dayOption_kor:[DayOption:String] = [.yesterday:"전날", .today:"당일",.tomorrow:"다음날"]

}
func getDayOption(at alermTime: Date, from date: Date) -> DayOption {
    let today = getStartOfDate(date: date)
    let yesterday = today.addingDays(-1)
    let tomorrow = today.addingDays(1)
    if alermTime < today {
        return .yesterday
    }
    else if alermTime >= tomorrow {
        return .tomorrow
    }
    else {
        return .today
    }

}

func getNotificationTimeString(at alermTime: Date?, from date: Date) -> String {
    if let alermTime_nonNil = alermTime {
        let dayOption: DayOption = getDayOption(at: alermTime_nonNil, from: date)
        return (DayOption.dayOption_kor[dayOption] ?? "unexpectedValue") + " " + alermTime_nonNil.hhmmTimeString_local
    } else {
        return "no alermTime"
    }
    
}


// TODO: purpose edit
// TODO: RecentPurpose 수정 / RecentData 수정



struct QuestCheckBoxView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.colorScheme) var colorScheme
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
        
        let height:CGFloat = qcbvHeight(dynamicTypeSize, stopWatchIsRunnig: stopwatch.isRunning, dataType: dailyQuest.dataType)
        //            let geoHeight = geometry.size.height
        let menuSize:CGFloat = width * 0.2
        
        let a: Path = Path(CGPath(rect: CGRect(x: 0, y: 0, width: (xOffset.isFinite && xOffset >= 0 && xOffset <= width +  0.1) ? xOffset : width, height: height), transform: nil))
//        let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0)
        let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0, isDark: colorScheme == .dark)
//        let invertForegroundStyleIntoBright: Bool = {
//            if colorScheme == .dark {
//                if dailyQuest.data == 0  { return true }
//                else if let dailyGoal = dailyQuest.dailyGoal {
//                    if CGFloat(dailyQuest.data) / CGFloat(dailyGoal) <= 0.5 { return true } else { return false }
//                }
//                else { return false }
//            }
//            else {
//                return false
//            }
//        }()
//        let invertForegroundStyleIntoBright: Bool =  colorScheme == .dark && dailyQuest.data == 0
        let invertForegroundStyleIntoBright: Bool =  colorScheme == .dark
//        let letBackgroundStyleGray: Bool = invertForegroundStyleIntoBright || colorScheme == .light
//        let letBackgroundStyleGray: Bool = invertForegroundStyleIntoBright || colorScheme == .light

//        let gradientColors = getGradientColorsOf(tier: dailyQuest.currentTier, type:0, isDark: colorScheme == .dark)
        
//        let isRecent: Bool = getStartDateOfYesterday() <= dailyQuest.dailyRecord!.getLocalDate()!
        
        HStack(spacing:0.0) {
            
            HStack(spacing:0.0) {
                QuestCheckBoxContentView(
                    dailyQuest: dailyQuest,
                    height: height,
                    value: $value,
                    dailyGoal: $dailyGoal,
                    stopwatch: stopwatch,
                    isAnimating: $isAnimating
                )
                .frame(width:width*7/8, height: height)
//                .foregroundStyle(colorScheme == .dark && dailyQuest.data == 0 ? getBrightTierColorOf(tier: dailyQuest.currentTier) : getDarkTierColorOf(tier: dailyQuest.currentTier))
                .bold()
                
                NotificationButton(
                    dailyQuest: dailyQuest,
                    popOverWidth: width,
                    popOverHeight: height
                )
                .frame(width: width*1/8, height: height)
//                .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))
//                .disabled(!isRecent)
//                .opacity( isRecent ? 1.0 : 0.0)
//                .border(.red)
            }
            .frame(width:width, height: height)
//            .foregroundStyle(colorScheme == .dark ? getBrightTierColorOf2(tier: dailyQuest.currentTier) : getDarkTierColorOf(tier: dailyQuest.currentTier))
            .foregroundStyle( invertForegroundStyleIntoBright ? getBrightTierColorOf2(tier: dailyQuest.currentTier) : getDarkTierColorOf(tier: dailyQuest.currentTier))
//            .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))
            .background(
                ZStack {
                    Color.white
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * width, y:0)
//                        .opacity(colorScheme == .light ? 0.6 : 0.75)
                        .opacity(colorScheme == .light ? 0.6 : 0.9)

//                        .opacity(0.6)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * width, y:0)
//                        .opacity(colorScheme == .light ? 0.6 : 0.75)
                        .opacity(colorScheme == .light ? 0.6 : 0.9)
//                        .opacity(0.6)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                }
                    .frame(width:width, height:height)
                    .mask {
                        a
                    }

//                    .background(colorScheme == .light ? .gray.opacity(0.3) : .white.opacity(0.85))
//                    .background(.gray.opacity(colorScheme == .light ? 0.3 : 0.3))
//                    .background(letBackgroundStyleGray ? .gray.opacity(0.3) : getTierColorOf(tier: dailyQuest.currentTier).opacity(0.7))
                    .background(
                        ZStack {
                            if colorScheme == .light {
                                Color.gray.opacity(0.3)
                                if dailyQuest.data != 0 {
                                    getBrightTierColorOf(tier: dailyQuest.currentTier).opacity(0.05)
                                }
                            }
                            else {
                                Color.gray.opacity(0.3)
                                if dailyQuest.data != 0 {
                                    getDarkTierColorOf(tier: dailyQuest.currentTier).opacity(0.3)
                                }
                            }

//                            }
                        }
                    )
//                    .background(dailyQuest.data == 0 ? .gray.opacity(0.3) : (colorScheme == .light ? getBrightTierColorOf(tier: dailyQuest.currentTier).opacity(0.05) : getTierColorOf(tier: dailyQuest.currentTier).opacity(0.7)))
                    .blur(radius: 0.5)

                
            )
            .disabled(offset < -menuSize*0.5)
            .offset(x: offset, y:0)


            
            HStack(spacing:0.0) {
                Image(systemName: "xmark")
                    .frame(width: menuSize, height:height)
                Spacer()
                    .frame(width: menuSize*2, height:height)
            }
            .frame(width: menuSize*3, height:height)
            .background(Color.red.blur(radius: 0.3))
            .offset(x: offset, y:0)
            .disabled(offset > -menuSize*0.5)
            .onTapGesture {
                deleteTarget.toggle()
            }
            
            
        }
        .frame(width:width, height: height, alignment: .leading)
        .clipShape(.buttonBorder)
        .simultaneousGesture(
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
                    if value.translation.width <= 0 || showMenu {
                        if value.translation.width < -menuSize*0.1 {
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
                    } else {
                        targetDailyQuest = nil
                        showMenu = false
                        withAnimation {
                            offset = 0
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
            
            if value == 0  {
                xOffset = 0.01
            } else {
                xOffset = CGFloat(value).map(from:range, to: 0...width)
            }
            
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
            
            if dailyQuest.dataType == DataType.hour.rawValue {
                dailyQuest.dailyRecord?.updateRecordedMinutes()
            }
            

        }
        .onChange(of: stopwatch.isRunning) {
            if dailyGoal == nil && value == 0 {
                if stopwatch.isRunning {
                    xOffset = width
                } else if stopwatch.getTotalSec() < 60 {
                    xOffset = 0.01
                }
            }
        }
//        .onChange(of: isAnimating, { oldValue, newValue in
//            if dailyGoal == nil && value == 0 && stopwatch.isRunning {
//                if newValue == true {
//                    xOffset = width
//                } else if stopwatch.totalSec < 60 && !stopwatch.isRunning {
//                    xOffset = 0.01
//                }
//            }
//        })
        .onChange(of: dailyGoal) {
            dailyQuest.dailyGoal = dailyGoal
            xOffset = CGFloat(value).map(from:range, to: 0...width)
        }
        .onChange(of: range) {
            if value == 0 {
                xOffset = 0.01
            } else {
                xOffset = CGFloat(value).map(from:range, to: 0...width)
            }
        }
        .onChange(of: showMenu) {
            if !showMenu && stopwatch.isRunning {
                isAnimating = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
            }
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
        return quests.first(where: {$0.name == name && !$0.inTrashCan})
    }


}


struct QuestCheckBoxContentView: View {
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    var height: CGFloat
    @Binding var value: Int
    @Binding var dailyGoal: Int?
    @ObservedObject var stopwatch: Stopwatch
    @Binding var isAnimating: Bool



    var body: some View {
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
//            let height:CGFloat = stopwatch.isRunning ? 75.0 : (dailyQuest.dataType != DataType.ox.rawValue ? 60.0 : 50.0)

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
                    stopwatch: stopwatch,
                    isAnimating: $isAnimating
//                    onTimer: dailyQuest.timerStart != nil
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
                Group {
                    Image(systemName: (value == 1) ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: geoWidth*1/7*0.67, height: geoWidth*1/7*0.67)
                }
                .frame(width: geoWidth*1/7, height: geoHeight)
//                .border(.red)
//                .foregroundStyle(getDarkTierColorOf(tier: dailyQuest.currentTier))


                Text(dailyQuest.getName())
                    .frame(width: geoWidth*6/7, height: geoHeight)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: geoWidth,height: geoHeight)
            .background(.gray.opacity(0.01))
            .onTapGesture {
                value = ( value == 1 ) ? 0 : 1
            }
        }
    }
}



struct QuestCheckBoxContent_HOUR:View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
//    @EnvironmentObject var activityManager: ActivityManager

    var dailyQuest: DailyQuest

    
    @Binding var value: Int
    @Binding var dailyGoal: Int?

    
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
    @ObservedObject var stopwatch: Stopwatch
    @Binding var isAnimating: Bool
//    @State var onTimer: Bool
    
//    @ObservedObject var activityManager: ActivityManager
    @State var isEditing_hours: Bool = false
    @State private var activity: Activity<RecoraddicActivityAttributes>? = nil

    @State var highlightValue: Bool = false
    @State var highlightValue2: Int = 1
    
    @State var lastTapTime: Date = Date()
    
    let sheetHeight:CGFloat = 450.0

    
    var body: some View {
        let isRecent: Bool = {
            if let date = dailyQuest.dailyRecord?.getLocalDate() {
                return getStartDateOfYesterday() <= date
            } else { return false }
        }()
//        let isRecent: Bool = getStandardDateOfYesterday() <= dailyQuest.dailyRecord!.date!


        
        let questName = dailyQuest.getName()

//        let dataType = dailyQuest.dataType
//        let customDataTypeNotation = dailyQuest.customDataTypeNotation

        let tier: Int = dailyQuest.currentTier
//        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let height:CGFloat = qcbvHeight(dynamicTypeSize, stopWatchIsRunnig: stopwatch.isRunning)

            HStack(spacing:0.0) {
                

                if stopwatch.isRunning {
                    Button(action:stopStopWatch) {
                        Image(systemName: "pause")
                            .dynamicTypeSize(...DynamicTypeSize.accessibility2)

//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geoWidth*1/9*0.75, height: geoWidth*1/9*0.75)
                            
                    }
                    .frame(width: geoWidth*1/7, alignment: .center)
                    .disabled(!isRecent)
                    .opacity( isRecent ? 1.0 : 0.0)

                    
//                    let heightOnTimer:CGFloat = qcbvHeight_large * qcbvMultiplier(dynamicTypeSize)
                    VStack {
                        Text("\(questName)")
                            .lineLimit(1)
                            .font(.system(size: highlightValue2 == 0 ? height*0.35 : height*0.2))
//                            .minimumScaleFactor(0.5)
                        
//                            .font(.caption2)
                        Text(stopwatch.timeString)
                            .font(.system(size: highlightValue2 == 1 ? height*0.35 : height*0.2))

                        if hasGoal {
                            Text_hours2(prefix: "목표: ",value: dailyQuest.dailyGoal ?? 0)
                                .font(.system(size: highlightValue2 == 2 ? height*0.35 : height*0.2))
//                                .font(.caption2)
                        }

                    }
                    .padding(.horizontal,10)
                    .frame(width:geoWidth*6/7)
//                    .onTapGesture {
//                        lastTapTime = Date()
//                        if dailyQuest.dailyGoal == nil {
//                            highlightValue2 = (highlightValue2 + 1) % 2
//                        } else {
//                            highlightValue2 = (highlightValue2 + 1) % 3
//                        }
//                        if highlightValue2 != 1 {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                                if Date().timeIntervalSince(lastTapTime) > 4.0 {
//                                    highlightValue2 = 1
//                                }
//                            }
//                        }
//                    }



                }
                else {
//                    let height:CGFloat = 60.0
                    Button(action:startStopWatch) {
                        Image(systemName: "play")
                            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
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
//                    .onTapGesture {
//                        lastTapTime = Date()
//                        highlightValue.toggle()
//                        if highlightValue {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                                if !isEditing_hours && (Date().timeIntervalSince(lastTapTime) > 4.0) {
//                                    highlightValue = false
//     
//                                }
//                            }
//                        }
//                    }

                }
            }
            .frame(width: geoWidth,height: height)
            .background(.white.opacity(0.01))
            .onTapGesture {
                
                lastTapTime = Date()
                if stopwatch.isRunning {
                    if dailyQuest.dailyGoal == nil {
                        highlightValue2 = (highlightValue2 + 1) % 2
                    } else {
                        highlightValue2 = (highlightValue2 + 1) % 3
                    }
                    if highlightValue2 != 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if Date().timeIntervalSince(lastTapTime) > 4.0 {
                                highlightValue2 = 1
                            }
                        }
                    }
                }
                else {
                    highlightValue.toggle()
                    if highlightValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if !isEditing_hours && (Date().timeIntervalSince(lastTapTime) > 4.0) {
                                highlightValue = false
 
                            }
                        }
                    }
                }
            }
//            .foregroundStyle(getDarkTierColorOf(tier: tier))
            .sheet(isPresented: $isEditing_hours) {
                // code for on dismiss
            } content: {
                let dialMinutes:[Int] = {
                    if value < 120 || value%5 == 0{
                        return Array(0...120) + stride(from: 125, through: 1440, by: 5)
                    } else {
                        var arr = Array(0...120) + stride(from: 125, through: 1440, by: 5) + [value]
                        return arr.sorted()
                    }
                }()
                DialForHours(
                    questName:questName,
                    dailyGoal: $dailyGoal,
                    value: $value,
                    isEditing: $isEditing_hours,
                    hasGoal_toggle: $hasGoal_toggle,
                    tier: tier,
                    dialMinutes: dialMinutes,
                    dailyGoal_nonNil: dailyGoal ?? value
                )
                .presentationDetents([.height(sheetHeight)])
                .presentationCompactAdaptation(.none)
                .presentationBackground(getDarkTierColorOf(tier: tier))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
        
            .onAppear() {
                if dailyQuest.stopwatchStart != nil {
                    if isRecent {
                        autoCheckActivityAndAdjustToStopWatch()
                    }
                    else {
                        deleteOutdatedActivity()
                        dailyQuest.stopwatchStart = nil
                    }
                }
            }
            .onDisappear() {
                stopwatch.stop()
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
    

    func startStopWatch() -> Void {
        
        let calendar = Calendar.current
        let startTime = calendar.date(byAdding: .minute, value: -(value), to: .now) ?? Date()
        dailyQuest.stopwatchStart = startTime
        stopwatch.setTotalSec(value*60)

//        isAnimating = false
        withAnimation(.easeInOut(duration:0.2)) {
            stopwatch.start(startTime:startTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.21) {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.questName == dailyQuest.getName() && $0.attributes.startTime == startTime}) {
            self.activity = targetActivity
        } else {
            let attributes = RecoraddicActivityAttributes(questName: dailyQuest.getName(), startTime:startTime, containedDate:dailyQuest.dailyRecord?.date ?? Date(), tier: dailyQuest.currentTier)
            let initialContentState = RecoraddicActivityAttributes.ContentState(goal: dailyGoal)
            do {
                let activity = try Activity<RecoraddicActivityAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: initialContentState, staleDate: nil),
                    pushType: nil
                )
                self.activity = activity
                
                
            } catch {
                print("Failed to start activity: \(error.localizedDescription)")
            }
        }

    }
    
    func deleteOutdatedActivity() -> Void {
        let startTime: Date = dailyQuest.stopwatchStart ?? Date()
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.questName == dailyQuest.getName() && $0.attributes.startTime == startTime}) {
            let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
            Task {
                await targetActivity.end(ActivityContent(state: targetActivity.content.state, staleDate: nil), dismissalPolicy: dismissalPolicy)
            }

        } else {
//            onTimer = false
            if Int(Date().timeIntervalSince(startTime)) > 60*60*24 {
                value = 60*24
            } else {
                value = Int(Date().timeIntervalSince(startTime)) / 60
            }
        }
    }
    
    func autoCheckActivityAndAdjustToStopWatch() -> Void {
        
        let startTime: Date = dailyQuest.stopwatchStart ?? Date()
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.questName == dailyQuest.getName() && $0.attributes.startTime == startTime}) {
            stopwatch.setTotalSec(Int(Date().timeIntervalSince(startTime)))
//            isAnimating = false
            stopwatch.start(startTime:startTime)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
            self.activity = targetActivity
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//                onTimer = true
//            }
        } else {
            //            onTimer = false
            if Int(Date().timeIntervalSince(startTime)) > 60*60*24 {
                value = 60*24
            } else {
                value = Int(Date().timeIntervalSince(startTime)) / 60
            }
        }



        
    }
    
    func stopStopWatch() -> Void {
//        onTimer = false
        guard let activity_activated = activity else {
            return
        }
        let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
        Task {
            await activity_activated.end(ActivityContent(state: activity_activated.content.state, staleDate: nil), dismissalPolicy: dismissalPolicy)
        }
        activity = nil
        dailyQuest.stopwatchStart = nil
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {

            withAnimation(.easeInOut(duration:0.2)) {
                stopwatch.stop()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.21) {
                withAnimation(.spring(duration: 0.1)) {
                    isAnimating = false
                }
            }
            value = stopwatch.getTotalSec()/60
            stopwatch.setTotalSec(value*60)
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
    @Environment(\.colorScheme) var colorScheme
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
    
    @State var highlightValue: Bool = false
    @State var onToggleModification: Bool = false
    @State var lastTapTime: Date = Date()

    var body: some View {
        
        let questName = dailyQuest.getName()
        let dataType = dailyQuest.dataType
        let tier: Int = dailyQuest.currentTier
        let customDataTypeNotation = dailyQuest.customDataTypeNotation
//        let tierColor_dark = getDarkTierColorOf(tier: tier)
        
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
                                .foregroundStyle(getReversedColorSchemeColor(colorScheme))
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
                                                .frame(width:geoWidth*0.4, alignment: .leading)
                                                .foregroundStyle(.blue)
//                                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                            Button("완료") {
                                                editDone()
                                            }
                                            .frame(width:geoWidth*0.6, alignment: .trailing)
                                            .foregroundStyle(.blue)
//                                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                        }
//                                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                                        .environment(\.dynamicTypeSize, DynamicTypeSize.medium)

                                    }

                                
                                    
                                }
                            if hasGoal  {
                                Text(" / ")
                                TextField("", text:$goalValueInText)
                                    .keyboardType(.numberPad)
                                    .foregroundStyle(getReversedColorSchemeColor(colorScheme))
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
//                    .environment(\.dynamicTypeSize, DynamicTypeSize.medium)


                }
                .padding(.horizontal,10)
                .frame(width: geoWidth*6/7)
//                .onTapGesture {
//                    lastTapTime = Date()
//                    if !isEditing {
//                        highlightValue.toggle()
//                        if highlightValue {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                                if !isEditing && (Date().timeIntervalSince(lastTapTime) > 4.0) {
//                                    highlightValue = false
//                                }
//                            }
//                        }
//                    }
//                }


            }
            .frame(width: geoWidth,height: geoHeight)
            .background(.white.opacity(0.01))
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
        self.updateTime()
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




//let dialMinutes:[Int] = Array(0...120) + stride(from: 125, through: 1440, by: 5)



struct DialForHours: View {

    @Environment(\.colorScheme) var colorScheme
    
    var questName: String
    
    @Binding var dailyGoal: Int?
    @Binding var value: Int
    @Binding var isEditing: Bool
    @Binding var hasGoal_toggle: Bool
    var tier: Int
    let dialMinutes:[Int]

    
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
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    Button("완료") {
                        isEditing.toggle()
                    }
                    .padding(.trailing, 10)
                    .frame(width: geometry.size.width*0.95, alignment: .trailing)
//

                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
//                .padding(.bottom, geoHeight*0.06)
//                .padding(.bottom)

                
                ZStack {
                    
                    Color.white.opacity(0.005).disabled(true)
//                        .interactiveDismissDisabled(true)
                        .gesture(DragGesture().onChanged({_ in})) // disable dragGesture

                    HStack(spacing:0.0) {
                        
                        VStack {
                            Text("달성")
                                .bold()
                            Picker(selection: $value, label: Text("Second Value")) {
                                //                            ForEach(0..<60*24) { i in
                                ForEach(dialMinutes, id:\.self) { i in
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
                .frame(width:geoWidth)
                .padding(.vertical)
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


//struct QuestCheckBoxColorPreview: View {
//
//    @State var isAnimating: Bool = false
//    var tier: Int
//    
//    var body: some View {
//        
//
//        
//        GeometryReader { geometry in
//            
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height
//            
//            
//            let a: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/20, cornerHeight: geoHeight/20, transform: nil))
//
//            
//            let percentage:CGFloat = 1.0
//            let brightness:CGFloat = percentage * 0.0
//            
//            
//            let gradientColors = getGradientColorsOf(tier: tier, type:0)
//            let _: [Color] = {
//                var newGradient: [Color] = []
//                for idx in 0...(gradientColors.count - 1) {
//                    if idx % 2 == 0 {
//                        newGradient.append(gradientColors[idx].adjust(brightness: brightness))
//                    }
//                    else {
//                        newGradient.append(gradientColors[idx].adjust(brightness: brightness*0.5))
//                    }
//                }
//                return newGradient
//            }()
//            
//
//
//                
//            ZStack {
//                
//                ZStack {
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
//                        )
//                        .frame(width:geoWidth, height:geoHeight)
//                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth, y:0)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
//                    
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
//                        )
//                        .frame(width:geoWidth, height:geoHeight)
//                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth, y:0)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
//                }
//                .frame(width:geoWidth, height:geoHeight)
//                .mask{a}
//                .onAppear() {
//                    isAnimating = true
//                }
//                
//                
//                
//            }
//                    
//
//
//
//
//        }
//    }
//}



struct NotificationButton: View {
    
    @Environment(\.modelContext) var modelContext
    var dailyQuest: DailyQuest
    var popOverWidth: CGFloat
    var popOverHeight: CGFloat

    let sheetHeight:CGFloat = 360.0
    
    @State var showNotficationTime: Bool = false
    @State var editNotificationTime: Bool = false
//    @State var
    
//    let popOverWidth2:CGFloat = UIScreen.main.bounds.width
    let popOverWidth2:CGFloat = UIScreen.main.bounds.width*2
    
    
    var body: some View {

        let questName = dailyQuest.getName()
        let date = dailyQuest.dailyRecord?.getLocalDate() ?? Date()

        let setAlready:Bool = dailyQuest.notfTime != nil
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
                if let alermTime = dailyQuest.notfTime {
                    VStack(spacing:3.0) {
                        Text(hhmmFormatOf(from: alermTime))
                            .font(.system(size: 12.0))
                            .bold()
//                        Text(Calendar.current.component(.hour, from: alermTime) < 12 ? "am" : "pm")
//                            .font(.system(size: 9.0))
//                            .bold()
                    }
                    
//                    VStack(spacing:3.0) {
//                        ClockView(hour: Calendar.current.component(.hour, from: alermTime), minute: Calendar.current.component(.minute, from: alermTime))
//                            .frame(width:25, height: 25)
//                        Text(Calendar.current.component(.hour, from: alermTime) < 12 ? "am" : "pm")
//                            .font(.system(size: 12.0))
//                    }
                } else {
                    Image(systemName: setAlready ? "bell" : "bell.slash")
                        .opacity(0.7)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
                
            }
//            .bold(setAlready)
//            .border(.yellow)
            .frame(width: geoWidth, height: geoHeight)
//            .border(.red)
            .popover(isPresented: $showNotficationTime, attachmentAnchor: .point(.topLeading)) {
                HStack {
                    Text(getNotificationTimeString(at:dailyQuest.notfTime, from: date))
                        .padding(.horizontal)
                    Button("수정") {
                        showNotficationTime.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            editNotificationTime.toggle()
                        }
                    }
                    .buttonStyle(NotificationButtonStyle(dailyQuest.currentTier))

                    Button("해제") {
                        if let previousAlermTime = dailyQuest.notfTime {
                            removeNotification(at: previousAlermTime, for: questName) // MARK: questName 변경 시 지울 수 없음
                        }
                        showNotficationTime.toggle()
                        dailyQuest.notfTime = nil
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
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                .border(.red)

            }
            .sheet(isPresented: $editNotificationTime) {
                let alermTime = {
                    if let alermTime = dailyQuest.notfTime { return alermTime}
                    else if let date = dailyQuest.dailyRecord?.getLocalDate() {
                        if date == getStartDateOfNow() {
                            return Date()
                        }
                        else { return date.addingHours(9)}
                    }
                    else {
                        return getStartDateOfNow()
                    }
                }()
                EditNotificationTimeView(
                    dailyQuest: dailyQuest,
                    selectedTime: alermTime,
                    selectedDay: getDayOption(at: alermTime, from: date),
                    editNotificationTime: $editNotificationTime
                )
                .presentationDetents([.height(sheetHeight)])
//                .frame(width: popOverWidth, height: popOverHeight, alignment: .center)
                .foregroundStyle(getBrightTierColorOf(tier: dailyQuest.currentTier))
                .background(getDarkTierColorOf(tier: dailyQuest.currentTier))
                .presentationDragIndicator(.visible)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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

        let setAlready:Bool = dailyQuest.notfTime != nil
        let notModifiedYet:Bool = setAlready && (dailyQuest.notfTime ?? selectedTime) == selectedTime
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
//                    .bold() // not work
                    .padding()
                    .environment(\.dynamicTypeSize, .large)
                    
                
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
                    
                    Button(selectedTime <= Date() ? "달성 설정" :(dailyQuest.notfTime == nil ? "알림 설정" : "알림 수정")) {
                        if let previousAlermTime = dailyQuest.notfTime {
                            removeNotification(at: previousAlermTime, for: questName) // MARK: questName 변경 시 지울 수 없음
                        }
                        dailyQuest.notfTime = selectedTime
                        if selectedTime > Date() {
                            scheduleNotification(at: selectedTime, for: questName, goal: dailyQuest.dailyGoal, dataType: dailyQuest.dataType, customDataTypeNotation: dailyQuest.customDataTypeNotation
                            )
                        }
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
                // MARK: 쓸 일 없을 것 같은데
                if selectedDay == .today && getStartOfDate(date:selectedTime) != getStartOfDate(date: dailyQuest.dailyRecord?.getLocalDate() ?? Date()) {
                    selectedTime = dailyQuest.dailyRecord?.getLocalDate() ?? Date()
                }
            }
            .onChange(of: selectedDay) { oldValue, newValue in
                let calendar = Calendar.current
                switch (oldValue, newValue) {
                    //                case ("today":"today"),("tomorrow":"tomorrow"), ("dayAftertomorrow":"dayAftertomorrow"): break
                case (.tomorrow,.today),(.today,.yesterday): selectedTime = selectedTime.addingDays(-1)
                case (.today,.tomorrow),(.yesterday,.today): selectedTime = selectedTime.addingDays(1)
                case (.tomorrow,.yesterday): selectedTime = selectedTime.addingDays(-2)
                case (.yesterday,.tomorrow): selectedTime = selectedTime.addingDays(2)
                    
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


//#Preview(body: {
//    VStack {
//        QuestCheckBoxColorPreview(tier: 0)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 5)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 10)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 15)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 20)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 25)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 30)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 35)
//            .frame(width:300, height: 45)
//        QuestCheckBoxColorPreview(tier: 40)
//            .frame(width:300, height: 45)
//
//    }
//
//})



