//
//  Records_StoneTower.swift
//  recoraddic
//
//  Created by 김지호 on 1/25/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: debugger 연결되어있으면 렉 발생, debugger 끊기면 렉없이 잘됨(23.03.09, ios17.4, xcode15.3 기준)
// Don't put variable, 최대한 let으로 이용하기, 특히 computed property 이용 금지 (너무 무거움)


// TODO: 글씨 색도 stonecolor에 맞춰서.
struct StoneTower: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    
    
//    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
//    @Query var dailyRecords: [DailyRecord]
//    @Query(sort:\Profile.createdTime) var profiles: [Profile]
//    @Query var quests: [Quest]
    
    var questData:[Quest:Int]
    var questData_hours:[Quest:CGFloat]
    var purposeData:[String:Int]
    var purposeData_hours:[String:CGFloat]
    var quests_sorted: [Quest]
    var quests_sorted_hours: [Quest]
    var purposes_sorted: [String]
    var purposes_sorted_hours: [String]
    var restrictedHeight: CGFloat
    var cumulative_cnt:Int
    var cumulative_hours:CGFloat
    var dailyRecords_visible: [DailyRecord]
    var dailyRecords_withDiaries: [DailyRecord]
    
    
    
    @State var checkQuest_hourly: Bool = true
    @State var popUp_diaries:Bool = false

    
    
    var body: some View {


        //        let statusBarHeight:CGFloat = getStatusBarHeight()
        
//        let shadowColor: Color = getShadowColor(colorScheme)
        let totalHeightMultiplier:CGFloat = dailyRecords_visible.reduce(0) { $0 + TowerView.stoneHeightMultiplier($1.recordedMinutes) }

        let colorParameter:CGFloat = min(totalHeightMultiplier, 100.0)
        let highestColor: Color = bgTopColor(parameter: 100.0, colorScheme: colorScheme)
        let lowestColor: Color = bgBottomColor(parameter: 0.0, colorScheme: colorScheme)
        let bgTopColor: Color = bgTopColor(parameter: colorParameter, colorScheme: colorScheme)
        let bgBottomColor: Color = bgBottomColor(parameter: colorParameter, colorScheme: colorScheme)
//        let textColor: Color = .cyan
//        let buttonColor: Color = .blue
        let groundGradient: LinearGradient = {
            if colorScheme == .light {
                return LinearGradient(colors: [Color(red:250.0/255.0, green:255.0/255.0, blue: 230.0/255.0), Color(red:220.0/255.0, green:255.0/255.0, blue: 180.0/255.0)],startPoint: .top, endPoint: .bottom)
            } else {
                return LinearGradient(colors: [Color(red:0.0/255.0, green:25.0/255.0, blue: 0.0/255.0), Color(red:0.0/255.0, green:55.0/255.0, blue: 0.0/255.0)],startPoint: .top, endPoint: .bottom)

            }
        }()


        
        GeometryReader { geometry in
            
            
            
            let geoWidth:CGFloat = geometry.size.width
            let geoHeight:CGFloat = geometry.size.height
            
        
            
            let topPadding:CGFloat = geoHeight*0.2
            let titleHeight:CGFloat = geoHeight*0.08
            let content1Height:CGFloat = geoHeight*0.25
            let content2Height:CGFloat = geoHeight*0.47
            let content2TopPadding:CGFloat = content2Height*0.2
            let content2ButtonHeight:CGFloat = content2Height*0.2
            let content2TowerHeight:CGFloat = content2Height*0.6
            
            
            let content1Width:CGFloat = geoWidth*0.45
            let content1HorizontalPadding:CGFloat = (geoWidth - content1Width*2 - 1)/8
            let content1WidthWithInnerPadding:CGFloat = content1Width+content1HorizontalPadding*2
            
            let textOpacity = colorScheme == .light ? 0.6 : 0.8
            
            
            ZStack {
                
                VStack(spacing:0.0) {
                    Spacer().frame(height:topPadding)
                    ZStack {
                        if checkQuest_hourly {
                            Text("누적 \(String(format:"%.1f",cumulative_hours))hr")
                                .padding(.bottom,5)
                                .frame(width:geoWidth, height:titleHeight, alignment: .center)
                                .font(.title)
                                .bold()
                                .minimumScaleFactor(0.5)
                                .opacity(textOpacity)
                        } else {
                            Text("누적 \(cumulative_cnt)회")
                                .padding(.bottom,5)
                                .frame(width:geoWidth, height:titleHeight, alignment: .center)
                                .font(.title)
                                .bold()
                                .minimumScaleFactor(0.5)
                                .opacity(textOpacity)

                        }
                        Button(action:{checkQuest_hourly.toggle()}) {
                            Text(checkQuest_hourly ? "시간" : "기록횟수")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.thickMaterial)
                                .clipShape(.buttonBorder)
                                .opacity(textOpacity)
                        }
                        .frame(width:(geoWidth-content1HorizontalPadding*2), height:titleHeight, alignment: .trailing)
                        .buttonStyle(.plain)

//                        .buttonStyle(.borderedProminent)
//                        .opacity(0.6)
                    }
                    .frame(width:geoWidth, height:titleHeight)
//                    .border(.red)


                    HStack(spacing:0.0) {

                        ScrollView {
                            if checkQuest_hourly {
                                ForEach(Array(quests_sorted_hours.enumerated()), id: \.0) { idx,quest in
                                    HStack(spacing:0.0) {
                                        //                                            Text("\(idx+1). ")
                                        //                                                .frame(width:content1Width*0.15, alignment: .trailing)
                                        Text(quest.getName())
                                            .frame(width:content1Width*0.65, alignment: .leading)
                                            .opacity(textOpacity)
                                        Text("(\(String(format:"%.1f",questData_hours[quest] ?? -999.0))hr)")
                                            .frame(width:content1Width*0.35, alignment: .trailing)
                                            .minimumScaleFactor(0.5)
                                            .opacity(textOpacity)
                                    }
                                    .frame(width:content1WidthWithInnerPadding, alignment: .center)
                                    
                                    if idx != quests_sorted_hours.count - 1 {
                                        Color.gray.opacity(0.5).frame(width:content1Width, height:1)
                                            .padding(.horizontal,1.5)
                                    }
                                }
                            }
                            else {
                                ForEach(Array(quests_sorted.enumerated()),id:\.0) { idx,quest in
                                    HStack(spacing:0.0) {
                                        //                                            Text("\(idx+1). ")
                                        //                                                .frame(width:content1Width*0.15, alignment: .trailing)
                                        Text(quest.getName())
                                            .frame(width:content1Width*0.7, alignment: .leading)
                                            .opacity(textOpacity)
                                        Text("(\(questData[quest] ?? -999)회)")
                                            .frame(width:content1Width*0.3, alignment: .trailing)
                                            .minimumScaleFactor(0.5)
                                            .opacity(textOpacity)
                                    }
                                    .frame(width:content1WidthWithInnerPadding, alignment: .center)
                                    
                                    if idx != quests_sorted.count - 1 {
                                        Color.gray.opacity(0.5).frame(width:content1Width, height:1)
                                            .padding(.horizontal,1.5)
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal, content1HorizontalPadding)
                        .frame(width:content1WidthWithInnerPadding)
                        .padding(.leading, content1HorizontalPadding)
                        
                        Color.gray.opacity(0.5).frame(width:1)
                            .padding(.horizontal, content1HorizontalPadding)
                        
                        
                        ScrollView {
                            if checkQuest_hourly {
                                ForEach(Array(purposes_sorted_hours.enumerated()), id: \.0) { idx,purpose in
                                    HStack(spacing:0.0) {
                                        Image(purpose)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:content1Width*0.15)
                                        Text(DefaultPurpose.inKorean(purpose))
                                            .frame(width:content1Width*0.45, alignment: .leading)
                                            .opacity(textOpacity)
                                        Text("(\(String(format:"%.1f",purposeData_hours[purpose] ?? -999.0))hr)")
                                            .frame(width:content1Width*0.4, alignment: .trailing)
                                            .minimumScaleFactor(0.5)
                                            .opacity(textOpacity)

                                    }
                                    .frame(width:content1WidthWithInnerPadding, alignment: .center)
                                    
                                    if idx != purposes_sorted_hours.count - 1 {
                                        Color.gray.opacity(0.5).frame(width:content1Width, height:1)
                                            .padding(.horizontal,1.5)
                                    }
                                }
                            }
                            else {
                                ForEach(Array(purposes_sorted.enumerated()),id:\.0) { idx,purpose in
                                    HStack(spacing:0.0) {
                                        Image(purpose)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:content1Width*0.15)
                                        Text(DefaultPurpose.inKorean(purpose))
                                            .frame(width:content1Width*0.45, alignment: .leading)
                                            .opacity(textOpacity)
                                        Text("(\(purposeData[purpose] ?? -999)회)")
                                            .frame(width:content1Width*0.4, alignment: .trailing)
                                            .minimumScaleFactor(0.5)
                                            .opacity(textOpacity)
                                    }
                                    .frame(width:content1WidthWithInnerPadding, alignment: .center)
                                    
                                    if idx != purposes_sorted.count - 1 {
                                        Color.gray.opacity(0.5).frame(width:content1Width, height:1)
                                            .padding(.horizontal,1.5)
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal, content1HorizontalPadding)
                        .frame(width:content1WidthWithInnerPadding)
                        .padding(.leading, content1HorizontalPadding)
                        
                        
                        
                    }
                    .frame(width:geoWidth, height:content1Height, alignment: .center)

                    
                    VStack(spacing:0.0) {
                        Spacer().frame(height:content2TopPadding)
                            
                        HStack {
                            Button(action:{
                                popUp_diaries.toggle()
                            }) {
                                Image(systemName: "book.closed.fill")
                            }
                            .disabled(dailyRecords_withDiaries.count == 0)
                            
//                            Button(action:{
//                                
//                            }) {
//                                Image(systemName: "list.dash")
//                            }
                        }
                        .frame(height:content2ButtonHeight)


                        TowerView(
                            dailyRecords_visible: dailyRecords_visible,
                            groundGradient: groundGradient
                        )
                        .frame(width:geoWidth, height: content2TowerHeight)

                        
                    }
                    .frame(height:content2Height)
                    
                    
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                
            }
            .background(LinearGradient(colors: [bgTopColor, bgBottomColor], startPoint: .top, endPoint: .bottom))
            .fullScreenCover(isPresented: $popUp_diaries) {
                StoneTower_diaries(
                    dailyRecords_withDiaries: dailyRecords_withDiaries,
                    topColor: bgTopColor,
                    bottomColor: lowestColor,
                    popUp_diaries: $popUp_diaries)
                .ignoresSafeArea(.container)


            }
        } // geometryReader




        
    }
    
    

    
    func bgTopColor(parameter: CGFloat, colorScheme:ColorScheme) -> Color {
        if colorScheme == .light {
            return Color(red:(100.0 - parameter)/255.0, green:255.0/255.0, blue: 255.0/255.0)
        } else {
            return Color(red:0.0/255.0, green:0.0/255.0, blue: (100.0 + parameter)/255.0)
            
        }
    }
    func bgBottomColor(parameter: CGFloat, colorScheme:ColorScheme) -> Color {
        if colorScheme == .light {
            return Color(red:(245.0 - (parameter*0.5))/255.0, green:255.0/255.0, blue: 255.0/255.0)
        } else {
            return Color(red:0.0/255.0, green:0.0/255.0, blue: (0.0 + parameter)/255.0)
            
        }
    }
    
    
    
}





struct StoneTower_popUp_ChangeStyleView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var popUp_changeStyle: Bool
    @Binding var defaultColorIndex_tmp: Int
    
    var body: some View {
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth*0.2
            
            VStack {
                Text("돌멩이 색 변경")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 60))]) {
                    ForEach(0...5,id:\.self) { index in
                        Circle()
                            .fill(TowerView.getIntegratedDailyRecordColor(index: index,colorScheme: colorScheme))
                            .stroke(getReversedColorSchemeColor(colorScheme), style: StrokeStyle(lineWidth: index == defaultColorIndex_tmp ? 5.0 : 1.0))
                            .padding(10)
                            .frame(width:gridSize, height: gridSize)
                            .onTapGesture {
                                defaultColorIndex_tmp = index
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                                    popUp_changeStyle.toggle()
                                }
                            }
                    }
                    
                }
            }
            .padding(50)
            
            
            
            
        }
    }
    
}


struct TowerView: View {
    var dailyRecords_visible: [DailyRecord]
    let groundGradient: LinearGradient

    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let extendedHeight:CGFloat = geoHeight*1.4
            
            let stoneWidth:CGFloat = geoWidth*0.22
            let stoneHeight:CGFloat = stoneWidth*0.5
            let horizontalUnitWidth:CGFloat = stoneWidth*0.07
            
            let totalHeight:CGFloat = dailyRecords_visible.reduce(0) { $0 + stoneHeight*TowerView.stoneHeightMultiplier($1.recordedMinutes) }
            let represented_cnt:Int = {
                var cumulative:CGFloat = 0.0
                var cnt: Int = 0
                for record in dailyRecords_visible {
                    cumulative += stoneHeight*TowerView.stoneHeightMultiplier(record.recordedMinutes)
                    cnt += 1
                    if cumulative >= extendedHeight {
                        break
                    }
                }
                return cnt
            }()
            
            let dr_represented: [DailyRecord] = represented_cnt == 0 ? [] : Array(dailyRecords_visible[..<represented_cnt])
            
            let groundHeight = extendedHeight < totalHeight ? 0.0 : extendedHeight


            VStack(spacing:0.0) {
                ForEach(Array(dr_represented.enumerated()), id:\.0) { idx, record in
                    let brightness:Int = TowerView.brightness(record.recordedAmount)
                    let shapeNum:Int = TowerView.shapeNum(record.recordedMinutes)
                    let misalignment:Int = TowerView.misalignment(record.absence, idx)
                    let heat:Int = TowerView.heatNum(record.streak)
                    let width:CGFloat = stoneWidth
                    let height:CGFloat = stoneHeight * TowerView.stoneHeightMultiplier(record.recordedMinutes)

                    ZStack {
                        StoneTower_stone(
                            shapeNum: shapeNum,
                            brightness: brightness,
                            defaultColorIndex: 0,
                            facialExpressionNum: record.mood
                        )
                        .frame(width: width, height: height)
                        .opacity(0.8)
                        
                        if record.dailyTextType == DailyTextType.inShort {
                            Image(systemName:"book.closed")
                                .font(.caption)
                                .frame(width: width, height: height, alignment:.topLeading)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            
                        } else if record.dailyTextType == DailyTextType.diary {
                            Image(systemName:"book.closed.fill")
                                .font(.caption)
                                .frame(width: width, height: height, alignment:.topLeading)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        }
                        
                    }
                    .frame(width: width, height: height)
                    .padding(.leading, geoWidth/2 - width/2 + CGFloat(misalignment)*horizontalUnitWidth)
                    .padding(.trailing, geoWidth/2 - width/2 - CGFloat(misalignment)*horizontalUnitWidth)
                }
                groundGradient.frame(height: groundHeight)

            }
                .frame(height:geoHeight, alignment: .top)
        }
    }
    
    static func stoneHeightMultiplier(_ input: Int) -> CGFloat {
        return 1.0 + min(1.0, CGFloat(input)/900.0) * 3.0 // 900분 == 15시간
    }

    
    static func shapeNum(_ input: Int) -> Int { // 기록 시간 -> 모양 (0~1시간 / 1시간~3시간 / 3~5시간 / 5시간 이상)
        switch input {
        case 0: return 2
        default: return 3
//        case 0...59: return 0
//        case 60...119: return 1
//        case 120...179: return 2
//        case 180...: return 3
//        default: return 0
        }
        
    }
    
    static func brightness(_ input: Int) -> Int { // 기록 갯수(색)
        
        switch input {
        case 0: return -3
        case 1...7: return (input - 4)
        default: return 3 // 8개 이상의 기록갯수
        }
        
    }
    
    static func misalignment(_ input: Int, _ idx: Int) -> Int { // 기록 연속성(오랜만에 쌓을 수록 비뚤어짐) 0일 -> 0 / -1~-3일 -> +-1~3
        
        //        let plusOrMinus:Int = Int.random(in: 0...1) == 1 ? 1 : -1
        let plusOrMinus:Int = idx % 2 * 2 - 1
        
        if idx  == 0 { return 0 }
        
        switch input {
        case ...1: return 0
        case 2...4: return (input-1) * plusOrMinus
        default: return 3 * plusOrMinus
        }
        
    }
    
    static func heatNum(_ input: Int) -> Int { //기록 연속성2(오래 쌓을 수록 달궈짐) ->  2일 /  3일 / 4~5일 / 6~8일 / 9~11일 / 12~15일 / 16일~ /  20일~ / 25일~ / 30일~
        
        switch input {
        case ...1: return 0
        case 2: return 1
        case 3: return 2
        case 4...5: return 3
        case 6...8: return 4
        case 9...11: return 5
        case 12...15: return 6
        case 16...20: return 7
        case 21...25: return 8
        case 26...30: return 9
        default: return 10
        }
    }
    
    
    static func getDailyRecordColor(index:Int) -> Color {
        if index == 0 {
            return Color.white // almost zero
        }
        else if index == 1 {
            return Color.pink.adjust(saturation:-0.45, brightness: 0.4) // 0.14(o) 0.068(x)
        }
        else if index == 2 {
            return Color.blue.adjust(hue:0.05, saturation:-0.5, brightness: 0.4) // 0.475(o) 0.36(x)
        }
        else if index == 3 {
            return Color.green.adjust(hue:-0.1, saturation:-0.45, brightness: 0.3) // 0.354(o)   0.35(x)
        }
        else if index == 4 {
            return Color.purple.adjust(hue:-0.05, saturation:-0.4, brightness: 0.3) // 0.1(o)  0.03(not that good)
        }
        else if index == 5 {
            return Color.orange.adjust(hue:-0.04, saturation:-0.4, brightness: 0.5) //      0.37
        }
        else {
            return Color.white
        }
    }
    
    
    static func getIntegratedDailyRecordColor(index:Int, colorScheme:ColorScheme) -> Color {
        return getDailyRecordColor(index: index).adjust(brightness: colorScheme == .light ? -0.02 : -0.25).colorExpressionIntegration()
    }

}
//
//  StoneTower1_stones.swift
//  recoraddic
//
//  Created by 김지호 on 3/26/24.
//


struct StoneTower_diaries:View {
    @Environment(\.colorScheme) var colorScheme
    
    var dailyRecords_withDiaries: [DailyRecord]
    var topColor: Color
    var bottomColor: Color
    @Binding var popUp_diaries: Bool
    
    var body: some View {
        let reversedColorSchemeColor = getReversedColorSchemeColor(colorScheme)
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let diaryContentWidth = geoWidth*0.9
            
            let facialExpressionSize = 35.0
            
            
            ZStack {
                ScrollView {
                    ZStack(alignment:.top) {
                        Spacer()
                            .frame(width: geoWidth, height: geoHeight)
                        VStack {
                            ForEach(dailyRecords_withDiaries) { dr in
                                let brightness:Int = TowerView.brightness(dr.recordedAmount)
                                let shapeNum:Int = TowerView.shapeNum(dr.recordedMinutes)
                                let heat:Int = TowerView.heatNum(dr.streak)
                                let diaryColor = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: brightness, colorScheme: colorScheme)
                                
                                VStack {
                                    HStack {
                                        ZStack {
                                            if colorScheme == .light {
                                                Circle()
                                                    .stroke(lineWidth: geoWidth*0.002)
                                                    .frame(width:facialExpressionSize, height: facialExpressionSize)
                                            } else {
                                                Circle()
                                                    .fill(.white.opacity(0.6))
                                                    .frame(width:facialExpressionSize, height: facialExpressionSize)
                                            }

                                            Color.black
                                                .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                                .mask(
                                                    Image("facialExpression_\(dr.mood)")
                                                        .resizable()
                                                        .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                                )
                                        }
                                        .frame(width:diaryContentWidth*0.2, alignment: .leading)
                                        .opacity(dr.mood == 0 ? 0 : 1)
                                        Text(kor_yyyymmddFormatOf(dr.date!))
                                            .frame(width:diaryContentWidth*0.5)
                                            .font(.title3)
                                            .bold()

                                        HStack {
//                                            Button(action:{}) {
//                                                Image(systemName: "list.bullet")
//                                                
//                                            }
//                                            Button(action:{}) {
//                                                Image(systemName: "pencil")
//                                            }
                                        }
                                        .frame(width:diaryContentWidth*0.2, alignment: .trailing)

                                    }
                                    .padding(.bottom,10)
                                    Text(dr.dailyText!)
                                }
                                .padding(10)
                                .frame(width:diaryContentWidth)
//                                .foregroundStyle(diaryForgroundColor)
                                .background(.ultraThinMaterial)
//                                .background(.thinMaterial)
                                .clipShape(.buttonBorder)
//                                .background(StoneShape_diary(mainColor: diaryColor).opacity(0.6))
                                

                                
                                
                            }
                        }
                        .padding(.top, geoHeight*0.15)
                    }
                    .background(LinearGradient(colors: [topColor, bottomColor], startPoint: .top, endPoint: .bottom), ignoresSafeAreaEdges: .top)
//                    .background(LinearGradient(colors: [topColor, bottomColor], startPoint: .top, endPoint: .bottom))

                }
                .frame(width: geoWidth, height: geoHeight)

                
                Button(action:{popUp_diaries.toggle()}) {
                    Image(systemName: "xmark")
                        .bold()
                }
                .padding(.bottom, 50)
                .frame(width: geoWidth, height: geoHeight, alignment: .bottom)
            }
            .frame(width: geoWidth, height: geoHeight)

            
        }
    }
}

// MARK: Path rules: start from top left, clockwise

import Foundation
import SwiftUI

struct StoneTower_stone: View {
    
    @Environment(\.colorScheme) var colorScheme
    // themeName, visualValue1, visualValue2
    var shapeNum: Int
    var brightness: Int
    var facialExpressionNum: Int
    
    var defaultColorIndex:Int
    
    
    
    init(shapeNum: Int, brightness: Int, defaultColorIndex: Int, facialExpressionNum: Int) {
        self.shapeNum = shapeNum
        self.brightness = brightness
        self.facialExpressionNum = facialExpressionNum
        self.defaultColorIndex = defaultColorIndex
    }
    
    
    
    var body: some View {
        
        let stoneColor: Color = StoneTower_stone.getStoneColor(defaultColorIdx: defaultColorIndex, brightness: brightness, colorScheme: colorScheme)
        
        
        
        GeometryReader { geometry in
            
            
            //            let geoWidth = geometry.size.width
            //            let geoHeight = geometry.size.height
            
            
            ZStack {
                // TODO: 그림자를 그 다음 stone과의 visualValue3 차이만큼 받아서 적용, nil이면 그림자 없음
                
                switch shapeNum {
                case 2:
                    StoneShape2(mainColor: stoneColor)
                        .opacity(0.85)
                case 3:
                    StoneShape3(mainColor: stoneColor)
                        .opacity(0.85)
                default:
                    Text("ERROR")
                }

                
                if facialExpressionNum != 0 {
                    
                    /*toneColor.adjust(brightness: -0.15)*/
                    Color.black
                        .mask {
                            Image("facialExpression_\(facialExpressionNum)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            //                        .frame(height: geometry.size.height*0.8)
                            //                                .frame(width:geometry.size.width*0.8)
                                .frame(width:geometry.size.width*0.65, height:geometry.size.height*0.85)
                        }
                        .opacity(0.6)
                    
                    
                }
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        
    }
    
    
    
    
    static func getStoneColor(defaultColorIdx: Int, brightness: Int, colorScheme: ColorScheme) -> Color {
        // later control saturation
        
        let defaultColor:  Color = TowerView.getDailyRecordColor(index: defaultColorIdx)
        
        let mainColorDarkness: CGFloat = {
            let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = defaultColor.getRGBA()
            //            print("0: ",mainColor_rgba.0)
            //            print("1: ",mainColor_rgba.1)
            //            print("2: ",mainColor_rgba.2)
            //                print(3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2)
            return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
        }()
        
        let shouldBeDarkerInDarkStoneInDarkMode: Bool = mainColorDarkness > 0.001 && colorScheme == .dark
        
        switch brightness {
        case 3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.25)
        case 2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.08 : -0.38)
        case 1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.14 : -0.51)
        case 0: return defaultColor.adjust(brightness: colorScheme == .light ? -0.27 : -0.64)
        case -1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.39 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.8 : -0.70))
        case -2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.47 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.9 : -0.75))
        case -3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.55 : (shouldBeDarkerInDarkStoneInDarkMode ? -1.0 : -0.80))
            
        default: return Color.red
        }
        
    }

    
    
    
    
    
    
    
    
}



struct StoneShape2: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.24, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.76, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.85, y: 0.10)
    let point4:CGPoint = CGPoint(x: 0.93, y: 0.35)
    let point5:CGPoint = CGPoint(x: 0.93, y: 0.65)
    let point6:CGPoint = CGPoint(x: 0.85, y: 0.93)
    let point7:CGPoint = CGPoint(x: 0.76, y: 1.00)
    let point8:CGPoint = CGPoint(x: 0.24, y: 1.00)
    let point9:CGPoint = CGPoint(x: 0.15, y: 0.93)
    let point10:CGPoint = CGPoint(x: 0.07, y: 0.65)
    let point11:CGPoint = CGPoint(x: 0.07, y: 0.35)
    let point12:CGPoint = CGPoint(x: 0.15, y: 0.10)
    
    
    
    //    let point13:CGPoint = CGPoint(x: 0.27, y: 0.08)
    //    let point14:CGPoint = CGPoint(x: 0.73, y: 0.08)
    //    let point15:CGPoint = CGPoint(x: 0.79, y: 0.15)
    //    let point16:CGPoint = CGPoint(x: 0.85, y: 0.33)
    //    let point17:CGPoint = CGPoint(x: 0.85, y: 0.67)
    //    let point18:CGPoint = CGPoint(x: 0.79, y: 0.85)
    let point13:CGPoint = CGPoint(x: 0.31, y: 0.10)
    let point14:CGPoint = CGPoint(x: 0.69, y: 0.10)
    let point15:CGPoint = CGPoint(x: 0.78, y: 0.18)
    let point16:CGPoint = CGPoint(x: 0.85, y: 0.36)
    let point17:CGPoint = CGPoint(x: 0.85, y: 0.64)
    let point18:CGPoint = CGPoint(x: 0.80, y: 0.82)
    
    //    let point19:CGPoint = CGPoint(x: 0.70, y: 0.95)
    //    let point20:CGPoint = CGPoint(x: 0.30, y: 0.95)
    //    let point21:CGPoint = CGPoint(x: 0.21, y: 0.85)
    //    let point22:CGPoint = CGPoint(x: 0.15, y: 0.67)
    //    let point23:CGPoint = CGPoint(x: 0.15, y: 0.33)
    //    let point24:CGPoint = CGPoint(x: 0.21, y: 0.15)
    let point19:CGPoint = CGPoint(x: 0.71, y: 0.94)
    let point20:CGPoint = CGPoint(x: 0.29, y: 0.94)
    let point21:CGPoint = CGPoint(x: 0.20, y: 0.82)
    let point22:CGPoint = CGPoint(x: 0.15, y: 0.64)
    let point23:CGPoint = CGPoint(x: 0.15, y: 0.36)
    let point24:CGPoint = CGPoint(x: 0.22, y: 0.18)
    
    
    // inner point (order: topLeft, clockwise)
    
    /*
     1         2
     13       14
     12  24              15 3
     
     11  23                  16  4
     
     10  22                  17  5
     21              18
     9       20    19      6
     8          7
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        let color1 = mainColor.adjust(saturation:-0.07, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.02 : 0.07)
        let color3 = mainColor.adjust(saturation:-0.03, brightness: colorScheme == .light ? 0.01 : 0.035)
        let color4 = mainColor
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.03)
        let color6 = mainColor.adjust(brightness: colorScheme == .light ? -0.04 : -0.06)
        let color7 = mainColor.adjust(brightness: colorScheme == .light ? -0.065 : -0.09)
        let color8 = mainColor.adjust(brightness: colorScheme == .light ? -0.09 : -0.12)
        
        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        let color6_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color6.getRGBA()
        let color7_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color7.getRGBA()
        let color8_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color8.getRGBA()
        
        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point14, point13
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point13, point24, point12
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point15, point14
        ]
        let topLeftPoints2: [CGPoint] = [
            point12, point24, point23, point11
        ]
        let topRightPoints2: [CGPoint] = [
            point15, point3, point4, point16
        ]
        let centerLeftPoints: [CGPoint] = [
            point11, point23, point22, point10
        ]
        let centerRightPoints: [CGPoint] = [
            point16, point4, point5, point17
        ]
        let bottomLeftPoints: [CGPoint] = [
            point10, point22, point21, point9
        ]
        let bottomRightPoints: [CGPoint] = [
            point17, point5, point6, point18
        ]
        let bottomLeftPoints2: [CGPoint] = [
            point21, point20, point8, point9
        ]
        let bottomRightPoints2: [CGPoint] = [
            point18, point6, point7, point19
        ]
        let bottomCenterPoints: [CGPoint] = [
            point20, point19, point7, point8
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides2:Path = Path { path in
                path.addLines(topLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let centerSides:Path = Path { path in
                path.addLines(centerLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(centerRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides2:Path = Path { path in
                path.addLines(bottomLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                //                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                //                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                //                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),
                
            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.09), endPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.93)))
            
            //            context.fill(outLine, with: .radialGradient(Gradient(colors: [
            //                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
            ////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            ////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
            //                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),
            //
            //            ]), center: CGPoint(x: frameWidth/2, y: frameHeight/5), startRadius: 0, endRadius: frameWidth/2))
            
            //            context.fill(outLine,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(topSides2,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(centerSides,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
            context.fill(bottomSides,with: .color(red:color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2))
            context.fill(bottomSides2,with: .color(red:color7_rgba.0, green: color7_rgba.1, blue: color7_rgba.2))
            context.fill(bottomCenter,with: .color(red:color8_rgba.0, green: color8_rgba.1, blue: color8_rgba.2))
            
            
        }
        
        
        
    }
    
}
struct StoneShape3: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    
    
    var mainColor: Color
    
    var body: some View {
        
        let color_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()
        Canvas { context, size in
            let frameWidth = size.width*0.85
            let frameHeight = size.height
//            context.blendMode = .lighten
            context.blendMode = .normal
//            context.blendMode = .hardLight
//            context.blendMode = .softLight
            context.opacity = 1.0
            let xOrigin: CGFloat = size.width*0.075
            

            let outLine:Path = Path(roundedRect: CGRect(x: xOrigin, y: 0, width: frameWidth, height: frameHeight), cornerSize:CGSize(width: frameWidth*0.09, height: frameWidth*0.06), style: .continuous)
            
            let oneElement:CGFloat = frameWidth*0.067

            context.fill(outLine, with: .color(mainColor.colorExpressionIntegration()))
            
            context.blendMode = .softLight
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .white.opacity(0.6),
                .white.opacity(0.0)
            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: oneElement*2)))

            context.blendMode = .darken

            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .black.opacity(0.1),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .black.opacity(0.1)
            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))

            
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .white.opacity(0.0),
                .black.opacity(0.2)
            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight-oneElement), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))
            
            

            

        }
        
        
        
    }
    
}


//struct StoneShape3: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    
//    
//    
//    
//    var mainColor: Color
//    
//    var body: some View {
//        
//        let mainColorDarkness: CGFloat = {
//            let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()
//            return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
//        }()
//        
//        
//        let color1 = {
//            if mainColorDarkness > 0.2 {
//                return mainColor.adjust(saturation:-0.06, brightness: colorScheme == .light ? 0.08 : 0.07)
//            }
//            else {
//                return mainColor.adjust(saturation:-0.045, brightness: colorScheme == .light ? 0.08 : 0.07)
//                
//            }
//        }()
//
//        let color3 = {
//            if mainColorDarkness > 0.1 || colorScheme == .dark {
//                return mainColor
//            }
//            else {
//                //                return mainColor.adjust(saturation:-0.04, brightness: 0.03)
//                //                print("hoho")
//                return mainColor.adjust(brightness: -0.03)
//                
//            }
//        }()
//        
//        
//        //        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
//        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.1 : -0.13)
//        
//        
//        // MARK: Canvas does not apply color in the same process as the normal SwiftUI views. Even it's the same Color object(by SwiftUI), the display will return the unusual different color. So it should be substracted as rgb component to apply the same color. (24.03.29)
//        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
//        //        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
//        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
//        //        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
//        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
//        
//        
//        
//        Canvas { context, size in
//            let frameWidth = size.width*0.85
//            let frameHeight = size.height
////            context.blendMode = .lighten
//            context.blendMode = .normal
////            context.blendMode = .hardLight
////            context.blendMode = .softLight
//            context.opacity = 1.0
//            let xOrigin: CGFloat = size.width*0.075
//            
//
//            let outLine:Path = Path(roundedRect: CGRect(x: xOrigin, y: 0, width: frameWidth, height: frameHeight), cornerSize:CGSize(width: frameWidth*0.09, height: frameWidth*0.06), style: .continuous)
//            
//            let oneElement:CGFloat = frameWidth*0.067
//
//            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2).opacity(1.0),
//                .black.opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(1.0),
//                .black.opacity(1.0)
////                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2).opacity(1.0)
//
//            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))
//            
//            context.fill(outLine, with: .linearGradient(Gradient(colors: [
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.5),
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.5),
//                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2).opacity(0.5)
//                
//            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: oneElement*2)))
//            
//            
//            context.fill(outLine, with: .linearGradient(Gradient(colors: [
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.5),
////                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2).opacity(1.0)
//                .black.opacity(0.5)
//            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight-oneElement), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))
//            
//            
//
//            
////            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2)
////                
////            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: oneElement*2)))
////            
////            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////
////            ]), startPoint: CGPoint(x: frameWidth/2, y: oneElement*2), endPoint: CGPoint(x: frameWidth/2, y: frameHeight-oneElement)))
////            
////            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2)
////            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight-oneElement), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))
////            
////            
////            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.3),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.7),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.7),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.7),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.7),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.7),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.3)
////
////            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))
////
////            context.fill(outLine, with: .linearGradient(Gradient(colors: [
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),
////                
////            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))
//            
//            
//
//        }
//        
//        
//        
//    }
//    
//}

let color1 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: 3, colorScheme: ColorScheme.light)
let color2 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: 2, colorScheme: ColorScheme.light)
let color3 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: 1, colorScheme: ColorScheme.light)
let color4 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: 0, colorScheme: ColorScheme.light)
let color5 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: -1, colorScheme: ColorScheme.light)
let color6 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: -2, colorScheme: ColorScheme.light)
let color7 = StoneTower_stone.getStoneColor(defaultColorIdx: 0, brightness: -3, colorScheme: ColorScheme.light)


#Preview(body: {
    HStack {
        StoneShape3(mainColor: color1)
        StoneShape3(mainColor: color2)
        StoneShape3(mainColor: color3)
        StoneShape3(mainColor: color4)
        StoneShape3(mainColor: color5)
        StoneShape3(mainColor: color6)
        StoneShape3(mainColor: color7)

    }
    .padding(10)
    .frame(height:100)
    .background(.cyan.opacity(0.2))
})



struct StoneShape_diary: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    
    
    var mainColor: Color
    
    var body: some View {
        
        let color_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            let oneElement:CGFloat = frameWidth*0.02

            let outLine:Path = Path(roundedRect: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight), cornerSize:CGSize(width: frameWidth*0.04, height: frameWidth*0.03), style: .continuous)
    
            
            context.blendMode = .normal
            context.opacity = 1.0
                        
            context.fill(outLine, with: .color(mainColor.colorExpressionIntegration()))
            
            context.blendMode = .softLight
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .white.opacity(0.2),
                .white.opacity(0.0)
            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: oneElement*2)))

            context.blendMode = .darken

            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .black.opacity(0.1),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .white.opacity(0.0),
                .black.opacity(0.1)
            ]), startPoint: CGPoint(x: 0, y: frameHeight/2), endPoint: CGPoint(x: frameWidth, y: frameHeight/2)))

            
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                .white.opacity(0.0),
                .black.opacity(0.1)
            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight-oneElement), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))
        
        




            

        }
        
        
        
    }
    
}

















//let color_example: Color = Color.white.adjust(brightness: -0.4)
//let color_example2: Color = Color.white.adjust(brightness: -0.1)
//
//let color_ex_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color_example.getRGBA()
//
////#Preview(body: {
////    VStack {
////        Color.white
////        Color.white.adjust(brightness: -0.1).adjust(brightness: 0.1)
////        color_example2.adjust(brightness: 0.1)
////        Canvas { context, size in
////            context.blendMode = .copy
////            context.opacity = 1.0
////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(red: color_ex_rgba.0, green: color_ex_rgba.1, blue: color_ex_rgba.2))
//////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(.blue.opacity(0.5)))
////        }
//////        Color.blue.opacity(0.5)
////        color_example
////        Color.white.adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.05).adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.1)
////        Color.white.adjust(brightness: -0.35).adjust(brightness: -0.35)
////        Color.white.adjust(brightness: -0.7)
////
////
////
////    }
////    .border(.red)
////})

struct MainButtonStyle2: ButtonStyle {
    
    @Environment(\.colorScheme) var colorScheme
    
    
    var width:CGFloat
    var height:CGFloat
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, height/8)
            .padding(.horizontal, width/8)
            .frame(width: width, height: height)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
            .background(getColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)
        
    }
}

struct MainButtonStyle3: ButtonStyle {
    
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    func makeBody(configuration: Configuration) -> some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let goeHeight = geometry.size.height
            
            configuration.label
                .padding(.vertical, goeHeight/8)
                .padding(.horizontal, geoWidth/8)
                .frame(width: geoWidth, height: goeHeight)
                .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                .background(getReversedColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
                .cornerRadius(8)
        }
        
    }
}

