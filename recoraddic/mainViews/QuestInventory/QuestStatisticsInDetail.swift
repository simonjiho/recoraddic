//
//  Popup_QuestStatistics.swift
//  recoraddic
//
//  Created by 김지호 on 3/16/24.
//

import Foundation
import SwiftUI


//func divideByWeek(input: [Date: Int]) -> [[Date: Int]] {
//    let sortedDates = input.keys.sorted()
//    var result = [[Date: Int]]()
//    var currentWeek: [Date: Int] = [:]
//    var currentWeekOfYear: Int?
//
//    for date in sortedDates {
//        let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
//        if weekOfYear != currentWeekOfYear {
//            if !currentWeek.isEmpty {
//                result.append(currentWeek)
//            }
//            currentWeek = [:]
//            currentWeekOfYear = weekOfYear
//        }
//        currentWeek[date] = input[date]
//    }
//
//    if !currentWeek.isEmpty {
//        result.append(currentWeek)
//    }
//
//    return result
//}

func partitionByWeek(startDate: Date, endDate: Date) -> [[Date]] {
    var result:[[Date]] = [[Date]]()
    var currentWeek:[Date] = []
    var currentDate = startDate

    while currentDate <= endDate {
        let weekOfYear = Calendar.current.component(.weekOfYear, from: currentDate)
        let weekOfYearNextDay = Calendar.current.component(.weekOfYear, from: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)

        currentWeek.append(currentDate)

        if weekOfYear != weekOfYearNextDay {
            result.append(currentWeek)
            currentWeek = []
        }

        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }

    if !currentWeek.isEmpty {
        result.append(currentWeek)
    }

    return result
}




struct QuestStatisticsInDetail: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selectedQuest: Quest? // MARK: 이렇게 하지 않으면 화면이 잘 업데이트 되지 않았었음.
    
    @Binding var popUp_questStatisticsInDetail: Bool
    
    
    
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let contentColor: Color = colorScheme == .light ? colorSchemeColor.adjust(brightness: -0.05) : colorSchemeColor
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let contentWidth1 = geoWidth*0.8
            let contentWidth2 = geoWidth*0.7
            let contentWidth3 = contentWidth2/7

            if selectedQuest == nil {
                Spacer()
            }
            else {
                VStack {
                    Text(selectedQuest!.name)
                        .font(.title)
                    if let startDate: Date  = selectedQuest!.dailyData.keys.first {
                        Text("시작일: \(yyyymmddFormatOf(startDate))")
                    }
                    Text("진행상황")
//                        .font(.title3)
                        .padding(.leading, contentWidth1*0.02)
                        .frame(width:contentWidth1)
                        .padding(.top,geoHeight*0.07)
                    
                    VStack {
                        HStack(spacing:0.0) {
                            Text("일")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("월")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("화")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("수")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("목")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("금")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                            Text("토")
                                .font(.subheadline)
                                .frame(width:contentWidth3)
                        }
                        .padding(.vertical,geoHeight*0.02)

                        ScrollView {
                            SerialVisualization(data: selectedQuest!.dailyData)
                                .frame(width: contentWidth2, alignment: .center)
                            
                        }
                        .frame(width:contentWidth1)

                    }
                    .frame(width:contentWidth1, height: geoHeight*0.4)
                    .background(contentColor)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: geoWidth*0.05, height: geoWidth*0.05)))
                }
                .padding(.top, geoHeight*0.05)
                .frame(width: geoWidth, height: geoHeight, alignment: .top)
            }

        }
    }
}


struct SerialVisualization:View {
    
    var data: [Date:Int]
    
    var body: some View {
            
        // withFirstDate and EndDate in One row -> 말일:오, 1:왼, ~말일-1:아래, 2~:아래
        // 다른 row -> 말일있는 모든 row: 아래 , 시작일있는 모든 row: 위
        
        // 캘린터 형태, 기록한 날은 색칠 되어 있음
        // 일월화수목금토일 정렬
        // 클릭 시에 날짜와 기록수치 나타남
        // 날짜는 시작 날짜와 끝날짜면 조그맣게 나와있음
        
        // TODO: 클릭 시 그 날 날짜와 상세 데이터 출력, 클릭 시 해당 블럭 커짐.
        // TODO: 1달과 1년 구분해서 border 넣기, 미래의 2주정도를 희미하게 넣기

        // MARK: 나중에 오늘 날짜를 end로 잡고 싶으면 바꿔주기
        let date_partition: [[Date]] = data.count != 0 ? partitionByWeek(startDate: data.keys.sorted().first!, endDate: data.keys.sorted().last!) : []
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let elementSize: CGFloat = geoWidth/7
            
            VStack(spacing:0.0) {
                //            GridDemo()
                                
                let firstRow:[Date]? = date_partition.first
                let lastRow:[Date]? = date_partition.last
                
                

                switch date_partition.count {
                case 0:
                    Spacer()
                case 1:
                        
                    let doneList_firstRow: [Bool] = firstRow!.map{data.keys.contains($0)}
//                    let doneList: [Date:Bool] = Dictionary(uniqueKeysWithValues: firstRow!.map({($0, data.keys.contains($0))}))
                    RowContent(dates:firstRow!,doneList:doneList_firstRow, isFirst: true)
                        .frame(width:elementSize*7, height: elementSize)
//                        .border(.blue)
                    
                default:
                    let middleRows:[[Date]] = {
                        var a = date_partition
                        a.removeFirst()
                        a.removeLast()
                        return a
                    }()

                    
                    
                    let doneList_firstRow: [Bool] = firstRow!.map{data.keys.contains($0)}
//                    let doneList: [Date:Bool] = Dictionary(uniqueKeysWithValues: firstRow!.map({($0, data.keys.contains($0))}))
                    RowContent(dates:firstRow!,doneList:doneList_firstRow, isFirst: true)
                        .frame(width:elementSize*7, height: elementSize)


                    ForEach(middleRows, id:\.self) { row in
                        let doneList: [Bool] = row.map{data.keys.contains($0)}
                        RowContent(dates:row,doneList:doneList)
                            .frame(width:elementSize*7, height: elementSize)
                    }
                    
                    let doneList_lastRow: [Bool] = lastRow!.map{data.keys.contains($0)}
                    RowContent(dates:lastRow!,doneList:doneList_lastRow, isLast: true)
                        .frame(width:elementSize*7, height: elementSize)
                }
                
                
                
                
            }
            .frame(width:geoWidth)
        }
        .onAppear() {
            print(date_partition)
            print(data.sorted(by: { keyval1, keyval2 in
                keyval1.key < keyval2.key
            }))
        }
    }
}



struct RowContent: View {
    
    var dates: [Date]
    var doneList: [Bool]
    
    var isFirst: Bool = false
    var isLast: Bool = false
    
    
    let gradiant_done: LinearGradient = LinearGradient(colors: [.green.opacity(0.4),.blue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
    let gradiant_notDone: LinearGradient = LinearGradient(colors: [.gray.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        let elementCnt: Int = dates.count
        
        let startOfMonthIndex: Int? = dates.firstIndex(where: {$0.isStartOfMonth})
        let isMonthChangingRow: Bool = startOfMonthIndex != nil
        
        let startOfMonthIndexIsNonzero: Bool = {
            if !isMonthChangingRow {
                return false
            }
            else {
                return startOfMonthIndex != 0
            }
        }()
        
        let containsStartAndEnd: Bool = isMonthChangingRow && startOfMonthIndexIsNonzero
        
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let elementSize: CGFloat = geoHeight
            let elementsWidth: CGFloat = elementSize * CGFloat(elementCnt)


            ZStack {
                HStack(spacing:0.0) {
                    ForEach(0..<elementCnt, id:\.self) { index in
                        let date = dates[index]
                        let isDone = doneList[index]
                        let monthRepresentaion: Bool = date.isStartOfMonth || (isFirst&&index==0)
                        ZStack {
                            Spacer()
                                .background(isDone ? gradiant_done: gradiant_notDone)
                                .blur(radius: 0.5)
                            
                            if monthRepresentaion {
                                Text(yymmFormatOf(date))
                                    .font(.caption2)
                                    .opacity(0.3)
                                    .padding(.bottom, 5)
                                    .frame(width:elementSize, height: elementSize, alignment: .bottom)

                            }
                            Text(ddFormatOf(date))
                                .font(.caption2)
                                .opacity(0.7)
                                .padding(.top, 2.5)
                                .padding(.leading, 2.5)
                                .frame(width:elementSize, height: elementSize, alignment: .topLeading)

                        }
                        .frame(width:elementSize, height: elementSize)
//                        .background(isDone ? gradiant_done: gradiant_notDone)
                    }
                }
                .frame(width:geoWidth, height: geoHeight, alignment: isFirst ? .trailing : .leading)
//                .frame(width:geoWidth, height: geoHeight)

                if isMonthChangingRow && containsStartAndEnd {
                    
                    let startPos: CGFloat = isFirst ? geoWidth - elementsWidth : 0
                    let conversionPos: CGFloat = startPos + elementSize * CGFloat(startOfMonthIndex!)
                    let endPos: CGFloat = isLast ? elementsWidth : geoWidth
                    
                    Path { path in
                        path.move(to: CGPoint(x: startPos, y: geoHeight))
                        path.addLine(to: CGPoint(x: conversionPos, y: geoHeight))
                        path.addLine(to: CGPoint(x: conversionPos, y: 0))
                        path.addLine(to: CGPoint(x: endPos, y: 0))
                    }
                        .stroke(Color.green, lineWidth: 2)
                }
                else if isMonthChangingRow && !containsStartAndEnd {
                    let startPos: CGFloat = isFirst ? geoWidth - elementsWidth : 0
                    let endPos: CGFloat = isLast ? elementsWidth : geoWidth

                    Path { path in
                        path.move(to: CGPoint(x: startPos, y: 0))
                        path.addLine(to: CGPoint(x: endPos, y: 0))
                    }
                        .stroke(Color.green, lineWidth: 2)


                }
                
                
            }
            .frame(width:geoWidth, height: geoHeight)
        }

    }
        
}




let dateExample:Date = Calendar.current.startOfDay(for: Date())
let calendarCurrent = Calendar.current
let datesExample:[Date] = [
//    Calendar.current.date(byAdding: .day, value:-30, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-29, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-28, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-27, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-26, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-25, to: dateExample)!,
//    Calendar.current.date(byAdding: .day, value:-24, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-23, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-22, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-21, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-20, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-19, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-18, to: dateExample)!,
    Calendar.current.date(byAdding: .day, value:-17, to: dateExample)!,
]
let doneListExample: [Bool] = [
    true,
    false,
    true,
    true,
    false,
    true,
    false
]

#Preview(body: {
    RowContent(dates: datesExample, doneList: doneListExample)
        .frame(width:210, height: 30)
})

