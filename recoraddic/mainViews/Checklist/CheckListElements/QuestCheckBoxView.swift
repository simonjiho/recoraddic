//
//  MountainCheckBoxView.swift
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



struct DailyAscentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(MountainsViewModel.self) var mountainsVM
    
//    @Bindable var dailyRecordsVM: DailyRecordsViewModel
    
    var mountainId:String
    
    
    @Binding var targetMountainId: String?
    @Binding var deleteTarget: Bool
    
//    @State var minutes: Int
    @Binding var minutes: Int
//    @State var dailyGoal: Int?
    @Binding var dailyGoal: Int?
    @Binding var notfTime: Date?
    var range: ClosedRange<CGFloat> {
        return 0.0...CGFloat(dailyGoal ?? minutes)
    }
    @State var xOffset: CGFloat

    let width: CGFloat
    
    @StateObject var stopwatch = Stopwatch()
    @State var showMenu: Bool = false
//    @State var isDragging: Bool = false
    @State var isAnimating: Bool = false
    @State private var offset: CGFloat = 0

    
    var isRecent: Bool
    
    var body: some View {
        let name = mountainsVM.nameOf(mountainId)
        let tier = mountainsVM.tierOf(mountainId)

        
        let height:CGFloat = qcbvHeight(dynamicTypeSize, stopWatchIsRunnig: stopwatch.isRunning)
        let menuSize:CGFloat = width * 0.2
        
        let a: Path = Path(CGPath(rect: CGRect(x: 0, y: 0, width: (xOffset.isFinite && xOffset >= 0 && xOffset <= width +  0.1) ? xOffset : width, height: height), transform: nil))
        let gradientColors = getGradientColorsOf(tier: tier, type:0, isDark: colorScheme == .dark)

        let invertForegroundStyleIntoBright: Bool =  colorScheme == .dark

        
        HStack(spacing:0.0) {
            
            HStack(spacing:0.0) {
                AscentDataContentView(
                    name: name,
                    tier: tier,
                    minutes: $minutes,
                    dailyGoal: $dailyGoal,
                    hasGoal: dailyGoal != nil,
                    hasGoal_toggle: dailyGoal != nil,
                    stopwatch: stopwatch,
                    isAnimating: $isAnimating,
                    isRecent: isRecent
                )
                .frame(width:width*7/8, height: height)
                .bold()
                
                NotificationButton(
                    name: name,
                    tier: tier,
                    notfTime: $notfTime,
                    popOverWidth: width,
                    popOverHeight: height
                )
                .frame(width: width*1/8, height: height)

            }
            .frame(width:width, height: height)
            .foregroundStyle( invertForegroundStyleIntoBright ? getBrightTierColorOf2(tier: tier) : getDarkTierColorOf(tier: tier))
            .background(
                ZStack {
                    Color.white
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * width, y:0)
                        .opacity(colorScheme == .light ? 0.6 : 0.9)

                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width:width, height:height)
                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * width, y:0)
                        .opacity(colorScheme == .light ? 0.6 : 0.9)
                }
                    .frame(width:width, height:height)
                    .mask {
                        a
                    }
                    .background(
                        ZStack {
                            if colorScheme == .light {
                                Color.gray.opacity(0.3)
                                if minutes != 0 {
                                    getBrightTierColorOf(tier: tier).opacity(0.05)
                                }
                            }
                            else {
                                Color.gray.opacity(0.3)
                                if minutes != 0 {
                                    getDarkTierColorOf(tier: tier).opacity(0.3)
                                }
                            }

                        }
                    )
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
                .onChanged { data in
                    
                    targetMountainId = nil
                    
                    if showMenu {
                        if data.translation.width < 0 {
                            let delta = log10(10 - data.translation.width*0.1)
                            offset = (-menuSize) * (delta)
                        }
                        else if data.translation.width > menuSize {
                            let delta = log10(1 + (data.translation.width - menuSize)*0.01)
                            offset = (menuSize) * (delta)
                        }
                        else {
                            offset = -menuSize + data.translation.width
                            
                        }
                    } else {
                        if data.translation.width < -menuSize {
                            let delta = log10(10 - (data.translation.width + menuSize)*0.1)
                            offset = (-menuSize) * (delta)
                        }
                        else if data.translation.width > 0 {
                        }
                        else {
                            offset = data.translation.width
                        }
                        
                    }
                    
                    
                }
                .onEnded { data in
                    if data.translation.width <= 0 || showMenu {
                        if data.translation.width < -menuSize*0.1 {
                            targetMountainId = mountainId
                            withAnimation {
                                offset = -menuSize
                            }
                            showMenu = true
                            
                        } else {
                            targetMountainId = nil
                            showMenu = false
                            withAnimation {
                                offset = 0
                            }
                        }
                    } else {
                        targetMountainId = nil
                        showMenu = false
                        withAnimation {
                            offset = 0
                        }
                    }
                    
                }
        )
        .onChange(of: targetMountainId) { oldValue, newValue in

            let nilToSelf = oldValue == nil && newValue == mountainId

            
            if nilToSelf {
                withAnimation {
                    offset = -menuSize
                }
            }

            else {
                withAnimation {
                    offset = 0
                }
            }
            
        }
        .onChange(of: minutes) { oldValue, newValue in
            
            if minutes == 0  {
                xOffset = 0.01
            } else {
                xOffset = CGFloat(minutes).map(from:range, to: 0...width)
            }
            
//            dailyRecordsVM.updateAscentData(mountainId, minutes)
            let date = self.dailyRecordsVM.currentDate
            mountainsVM.updateAscentData(id: mountainId, minutes: minutes, date: date)

            

        }
        .onChange(of: stopwatch.isRunning) {
            if dailyGoal == nil && minutes == 0 {
                if stopwatch.isRunning {
                    xOffset = width
                } else if stopwatch.getTotalSec() < 60 {
                    xOffset = 0.01
                }
            }
        }

        .onChange(of: dailyGoal) {
            mountainsVM.updateDailyGoal(of: mountainId, value: dailyGoal)
            xOffset = CGFloat(minutes).map(from:range, to: 0...width)
        }
        .onChange(of: range) {
            if minutes == 0 {
                xOffset = 0.01
            } else {
                xOffset = CGFloat(minutes).map(from:range, to: 0...width)
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


}





struct AscentDataContentView:View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
//    @EnvironmentObject var activityManager: ActivityManager

    var name: String
    var tier: Int
    
    @Binding var minutes: Minutes
    @Binding var dailyGoal: Minutes?
    
    @State var hasGoal: Bool
    @State var hasGoal_toggle: Bool // onChangeOf(hasGoal) 과 toggle버튼에 의해서만 변경해야 함
    @ObservedObject var stopwatch: Stopwatch
    @Binding var isAnimating: Bool
    var isRecent: Bool
    
    @State var isEditing_hours: Bool = false
    @State private var activity: Activity<RecoraddicActivityAttributes>? = nil

    @State var highlightValue: Bool = false
    @State var highlightValue2: Int = 1
    
    @State var lastTapTime: Date = Date()
    
    let sheetHeight:CGFloat = 450.0

    
    var body: some View {
        
        let date = dailyRecordsVM.currentDailyRecord.id ?? "")




        



        let tier: Int = tier
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let height:CGFloat = qcbvHeight(dynamicTypeSize, stopWatchIsRunnig: stopwatch.isRunning)

            HStack(spacing:0.0) {
                

                if stopwatch.isRunning {
                    Button(action:stopStopWatch) {
                        Image(systemName: "pause")
                            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                            
                    }
                    .frame(width: geoWidth*1/7, alignment: .center)
                    .disabled(!isRecent)
                    .opacity( isRecent ? 1.0 : 0.0)

                    
                    VStack {
                        Text("\(name)")
                            .lineLimit(1)
                            .font(.system(size: highlightValue2 == 0 ? height*0.35 : height*0.2))
                        
                        Text(stopwatch.timeString)
                            .font(.system(size: highlightValue2 == 1 ? height*0.35 : height*0.2))

                        if hasGoal {
                            Text_hours2(prefix: "목표: ",minutes: dailyGoal ?? 0)
                                .font(.system(size: highlightValue2 == 2 ? height*0.35 : height*0.2))
                        }

                    }
                    .padding(.horizontal,10)
                    .frame(width:geoWidth*6/7)




                }
                else {
                    Button(action:startStopWatch) {
                        Image(systemName: "play")
                            .dynamicTypeSize(...DynamicTypeSize.accessibility2)


                    }
                    .frame(width: geoWidth*1/7, alignment: .center)
                    .disabled(!isRecent)
                    .opacity( isRecent ? 1.0 : 0.0)

                    
                    HStack {
                        VStack {
                            Text("\(name)")
                                .lineLimit(1)
                                .font(.system(size: highlightValue ? height*0.25 : height*0.4))
                                .minimumScaleFactor(0.85)

                            HStack {
                                Text_hours(minutes: minutes)
                                    .lineLimit(1)
                                if hasGoal {
                                    Text("/")
                                        .lineLimit(1)
                                    Text_hours(minutes: dailyGoal ?? 0)
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

                }
            }
            .frame(width: geoWidth,height: height)
            .background(.white.opacity(0.01))
            .onTapGesture {
                
                lastTapTime = Date()
                if stopwatch.isRunning {
                    if dailyGoal == nil {
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
                    if minutes < 120 || minute%5 == 0{
                        return Array(0...120) + stride(from: 125, through: 1440, by: 5)
                    } else {
                        var arr = Array(0...120) + stride(from: 125, through: 1440, by: 5) + [minute]
                        return arr.sorted()
                    }
                }()
                DialForHours(
                    name:name,
                    dailyGoal: $dailyGoal,
                    minutes: $minutes,
                    isEditing: $isEditing_hours,
                    hasGoal_toggle: $hasGoal_toggle,
                    tier: tier,
                    dialMinutes: dialMinutes,
                    dailyGoal_nonNil: dailyGoal ?? minute
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
                if dailyMountain.stopwatchStart != nil {
                    if isRecent {
                        autoCheckActivityAndAdjustToStopWatch()
                    }
                    else {
                        deleteOutdatedActivity()
                        dailyMountain.stopwatchStart = nil
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
            dailyGoal = (minute/5+1)*5
        }
        else {
            dailyGoal = nil
        }
    }
    

    func startStopWatch() -> Void {
        
        let calendar = Calendar.current
        let startTime = calendar.date(byAdding: .minutes, minutes: -(minutes), to: .now) ?? Date()
        dailyMountain.stopwatchStart = startTime
        stopwatch.setTotalSec(minute*60)

//        isAnimating = false
        withAnimation(.easeInOut(duration:0.2)) {
            stopwatch.start(startTime:startTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.21) {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.name == dailyMountain.getName() && $0.attributes.startTime == startTime}) {
            self.activity = targetActivity
        } else {
            let attributes = RecoraddicActivityAttributes(name: dailyMountain.getName(), startTime:startTime, containedDate:dailyMountain.dailyRecord?.date ?? Date(), tier: tier)
            let initialContentState = RecoraddicActivityAttributes.ContentState(dailyGoal: dailyGoal)
            do {
                let activity = try Activity<RecoraddicActivityAttributes>.remountain(
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
        let startTime: Date = dailyMountain.stopwatchStart ?? Date()
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.name == dailyMountain.getName() && $0.attributes.startTime == startTime}) {
            let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
            Task {
                await targetActivity.end(ActivityContent(state: targetActivity.content.state, staleDate: nil), dismissalPolicy: dismissalPolicy)
            }

        } else {
//            onTimer = false
            if Int(Date().timeIntervalSince(startTime)) > 60*60*24 {
                minutes = 60*24
            } else {
                minutes = Int(Date().timeIntervalSince(startTime)) / 60
            }
        }
    }
    
    func autoCheckActivityAndAdjustToStopWatch() -> Void {
        
        let startTime: Date = dailyMountain.stopwatchStart ?? Date()
        
        if let targetActivity: Activity<RecoraddicActivityAttributes> = Activity<RecoraddicActivityAttributes>.activities.first(where: {$0.attributes.name == dailyMountain.getName() && $0.attributes.startTime == startTime}) {
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
                minutes = 60*24
            } else {
                minutes = Int(Date().timeIntervalSince(startTime)) / 60
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
        dailyMountain.stopwatchStart = nil
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {

            withAnimation(.easeInOut(duration:0.2)) {
                stopwatch.stop()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.21) {
                withAnimation(.spring(duration: 0.1)) {
                    isAnimating = false
                }
            }
            minutes = stopwatch.getTotalSec()/60
            stopwatch.setTotalSec(minute*60)
        }
    }
}


struct Text_hours: View {
    var minutes: Int
    var body: some View {
        let (hours,minutes) = minute.hhmmFormat
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
    var minutes: Int
    var suffix: String = ""
    var body: some View {
        let (hours,minutes) = minute.hhmmFormat
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
    
    var name: String
    
    @Binding var dailyGoal: Int?
    @Binding var minutes: Int
    @Binding var isEditing: Bool
    @Binding var hasGoal_toggle: Bool
    var tier: Int
    let dialMinutes:[Minute]


    @State var dailyGoal_nonNil = 0

    var body: some View {
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            VStack {
                
                ZStack(alignment:.top) {
                    VStack {
                        Text(name)
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
                            Picker(selection: $minutes, label: Text("Second Value")) {
                                //                            ForEach(0..<60*24) { i in
                                ForEach(dialMinutes, id:\.self) { i in
                                    Text("\(i.hhmmFormat)")
                                        .foregroundStyle(getDarkTierColorOf(tier: tier))
                                    
                                }
                                let a: String = 1.format
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
                                        Text("\((i+1)*5.hhmmFormat)")
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
                dailyGoal_nonNil = (minutes/5+1)*5
            }
        }


        
    }

    
  
}





struct NotificationButton: View {
    

    
    var name: String
    var tier: Int
    var notfTime: Date?
    var popOverWidth: CGFloat
    var popOverHeight: CGFloat

    let sheetHeight:CGFloat = 360.0
    
    @State var showNotficationTime: Bool = false
    @State var editNotificationTime: Bool = false
//    @State var
    
//    let popOverWidth2:CGFloat = UIScreen.main.bounds.width
    let popOverWidth2:CGFloat = UIScreen.main.bounds.width*2
    
    
    var body: some View {

        let date_str = dailyRecordsVM.currentDailyRecord.id ?? ""
        let date = stringToDate(date_str)

        let setAlready:Bool = notfTime != nil
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let size = min(geoWidth, geoHeight)

            Button(action: {
                if setAlready {
                    showNotficationTime.toggle()
                } else {
                    editNotificationTime.toggle()
                }

            }) {
                if let alermTime = notfTime {
                    VStack(spacing:3.0) {
                        Text(hhmmFormatOf(from: alermTime))
                            .font(.system(size: 12.0))
                            .bold()
                    }
                    
                } else {
                    Image(systemName: setAlready ? "bell" : "bell.slash")
                        .opacity(0.7)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
                
            }
            .frame(width: geoWidth, height: geoHeight)
            .popover(isPresented: $showNotficationTime, attachmentAnchor: .point(.topLeading)) {
                HStack {
                    Text(getNotificationTimeString(at:notfTime, from: date))
                        .padding(.horizontal)
                    Button("수정") {
                        showNotficationTime.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            editNotificationTime.toggle()
                        }
                    }
                    .buttonStyle(NotificationButtonStyle(tier))

                    Button("해제") {
                        if let previousAlermTime = notfTime {
                            removeNotification(at: previousAlermTime, for: name) // MARK: name 변경 시 지울 수 없음
                        }
                        showNotficationTime.toggle()
                        notfTime = nil
                    }
                    .buttonStyle(NotificationButtonStyle_red(tier))


                }
                .frame(width:popOverWidth2)
                .foregroundStyle(getBrightTierColorOf(tier: tier))
                .background(getDarkTierColorOf(tier: tier)) // 크기 유지를 위해(없으면 자동 조정됨)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(getDarkTierColorOf(tier: tier))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            }
            .sheet(isPresented: $editNotificationTime) {
                let initialNotfTime = {
                    if let notfTime = notfTime { return notfTime }
                    else {
                        if date == getStartDateOfNow() {
                            return Date()
                        }
                        else { return date.addingHours(9)}
                    }

                }()
                EditNotificationTimeView(
                    name: name,
                    tier: tier,
                    notfTime: $notfTime,
                    selectedTime: initialNotfTime,
                    selectedDay: getDayOption(at: initialNotfTime, from: date),
                    editNotificationTime: $editNotificationTime
                )
                .presentationDetents([.height(sheetHeight)])
                .foregroundStyle(getBrightTierColorOf(tier: tier))
                .background(getDarkTierColorOf(tier: tier))
                .presentationDragIndicator(.visible)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                
            }
        }

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

    @Bindable var dailyRecordsVM: DailyRecordsViewModel

    var name: String
    var tier: Int
    var notfTime: Date?
    @State var selectedTime: Date
    @State var selectedDay:DayOption
    
    @Binding var editNotificationTime: Bool
    
    

    var body: some View {
        

        let setAlready:Bool = notfTime != nil
        let notModifiedYet:Bool = setAlready && (notfTime ?? selectedTime) == selectedTime
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            VStack {
                Text(selectedTime,format: .dateTime)
                    .font(.title3)
                    .bold()
                    .padding(.top)

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
                    
                
                HStack(spacing:0.0) {

                    Button("취소") {
                        editNotificationTime.toggle()
                    }
                    .frame(width: geoWidth/2)
                    .foregroundStyle(.red)
                    .buttonStyle(NotificationButtonStyle(tier))
                    

                    
                    Button(selectedTime <= Date() ? "달성 설정" :(notfTime == nil ? "알림 설정" : "알림 수정")) {
                        if let previousAlermTime = notfTime {
                            removeNotification(at: previousAlermTime, for: name) // MARK: name 변경 시 지울 수 없음
                        }
                        notfTime = selectedTime
                        if selectedTime > Date() {
                            scheduleNotification(at: selectedTime, for: name, goal: dailyGoal)
                            
                        }
                        editNotificationTime.toggle()
                    }
                    .frame(width: geoWidth/2)
                    .disabled(notModifiedYet)
                    .opacity(notModifiedYet ? 0.3 : 1.0)
                    .buttonStyle(NotificationButtonStyle(tier))
                    
                }
                .padding()
                
            }
            .padding()
            .frame(width:geoWidth, height: geoHeight)
            .onAppear() {
                // MARK: 쓸 일 없을 것 같은데
                if selectedDay == .today && getStartOfDate(date:selectedTime) != getStartOfDate(date: dailyMountain.dailyRecord?.getLocalDate() ?? Date()) {
                    selectedTime = dailyMountain.dailyRecord?.getLocalDate() ?? Date()
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


//struct ClockView: View {
//    var hour: Int
//    var minutes: Int
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let width = geometry.size.width
//            let height = geometry.size.height
//            let clockSize = min(width, height)
//            let mainLineWidth = clockSize / 10
//            let subLineWidth = mainLineWidth * 0.67
//            
//            ZStack {
//                // Draw the clock face
//                Circle()
//                    .stroke(lineWidth: mainLineWidth)
//                    .frame(width: clockSize, height: clockSize)
//                
//                // Draw the hour ticks
//                ForEach(0..<12) { tick in
//                    Rectangle()
//                        .fill(Color.primary)
//                        .frame(width: 1, height: clockSize / 20)
//                        .offset(y: -clockSize / 2 + clockSize / 40)
//                        .rotationEffect(Angle(degrees: Double(tick) * 30))
//                }
//                
//                Circle()
//                    .fill(Color.primary)
//                    .frame(width: subLineWidth, height: subLineWidth)
//                
//                // Draw the hour hand
//                Path { path in
//                    path.move(to: CGPoint(x: clockSize / 2, y: clockSize / 2))
//                    path.addLine(to: CGPoint(x: clockSize / 2, y: clockSize / 4))
//                }
//                .stroke(Color.primary, style: StrokeStyle(lineWidth: mainLineWidth, lineCap: .round))
//                
////                .offset(x: -clockSize / 2, y: -clockSize / 2)
//                .rotationEffect(hourAngle(hour: hour, minutes: minutes), anchor: .center)
//                .offset(x:sin(hourAngle(hour: hour, minutes: minutes).radians)*(mainLineWidth-subLineWidth), y:-cos(hourAngle(hour: hour, minutes: minutes).radians)*(mainLineWidth-subLineWidth))
//                
//                // Draw the minutes hand
//                Path { path in
//                    path.move(to: CGPoint(x: clockSize / 2, y: clockSize / 2))
//                    path.addLine(to: CGPoint(x: clockSize / 2, y: clockSize / 10))
//                }
//                .stroke(Color.primary, style: StrokeStyle(lineWidth: subLineWidth, lineCap: .round))
////                .offset(x: -clockSize / 2, y: -clockSize / 2)
//                .rotationEffect(minuteAngle(minutes: minutes), anchor: .center)
//            }
//            .frame(width: clockSize, height: clockSize)
//        }
//    }
//    
//    private func hourAngle(hour: Int, minutes: Int) -> Angle {
//        let hourIn12 = hour % 12
//        let hourAngle = (Double(hourIn12) + Double(minutes) / 60.0) * 30.0
//        return Angle(degrees: hourAngle)
//    }
//    
//    private func minuteAngle(minutes: Int) -> Angle {
//        let minuteAngle = Double(minutes) * 6.0
//        return Angle(degrees: minuteAngle)
//    }
//}






