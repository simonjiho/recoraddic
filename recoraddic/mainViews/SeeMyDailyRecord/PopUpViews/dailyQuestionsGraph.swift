////
////  dailyQuestionsGraph.swift
////  recoraddic
////
////  Created by 김지호 on 6/23/24.
////
//
//import Foundation
//import SwiftUI
//import Charts
//
//
//struct DailyQuestionsStatistics: View {
//    
//    @Environment(\.modelContext) var modelContext
//    @Environment(\.colorScheme) var colorScheme
//    var selectedDRS: DailyRecordSet
//    @State var selectedQuestion: String
//    
//    var body: some View {
//        
//        let questions:[String] = selectedDRS.dailyQuestions
//        let drColor: Color = selectedDRS.getIntegratedDailyRecordColor(colorScheme: colorScheme)
//        
//        GeometryReader { geometry in
//            let geoWidth:CGFloat = geometry.size.width
//            let geoHeight:CGFloat = geometry.size.height
//            
//            
//            VStack {
//                
//                let data:[Date:Int] = {
//                    let datesAndValues:[(Date,Int)] = {
//                        switch questions.firstIndex(of: selectedQuestion) {
//                        case 0:
//                            return selectedDRS.dailyRecords!.map{ (record) -> (Date, Int) in
//                                (record.date!, record./*questionValue1*/!) }
//                        case 1:
//                            return selectedDRS.dailyRecords!.map{ (record) -> (Date, Int) in
//                                (record.date!, record.questionValue2!) }
//                        case 2:
//                            return selectedDRS.dailyRecords!.map{ (record) -> (Date, Int) in
//                                (record.date!, record.questionValue3!) }
//                        default:
//                            return [(Date,Int)]()
//                        }
//                    }()
//                    return Dictionary(uniqueKeysWithValues: datesAndValues)
//                }()
//                
//                // TODO: 돌 모습들
//                
//                QuestionValueChart(chartData:data, drColor: drColor)
//                
//                
//                Picker("", selection: $selectedQuestion) {
//                    ForEach(questions, id:\.self) { question in
//                        Text("질문\((questions.firstIndex(of: question) ?? 0) + 1): \(question)")
//                    }
//                }
//                
//                
//                
//            }
//            
//            .padding(.vertical, geoHeight*0.05)
//            .padding(.horizontal, geoWidth*0.03)
//            .onChange(of: selectedDRS) { oldValue, newValue in
//                // 같은 theme일때는 폐기 되지 않고 view를 재사용 하기 때문에
//                selectedQuestion = selectedDRS.dailyQuestions.first!
//            }
//        }
//
//    }
//}
//
//
//struct QuestionValueChart: View {
//    
//    var chartData: [Date:Int]
//    var drColor: Color
//
//    @State var maxValue: Int = 0
//
//    
//    @State var termOption: Int = 0
//    
//    
//    var body: some View {
//        
//        if chartData.count == 0 {
//            Spacer()
//        }
//        else {
//            
//            let maxValue:Int = chartData.values.max() ?? 0
//            
//            Chart {
//                ForEach(chartData.sorted(by: <), id:\.key) { item in
//
//                    LineMark(
//                        x: .value("Date", item.key),
//                        y: .value("Marks",  item.value),
//                        series: .value("Company", "A")
//                    )
//                    .foregroundStyle(drColor)
//                    
//                    PointMark(
//                        x: .value("Date", item.key),
//                        y: .value("Marks",  item.value)
//                    )
//                    .foregroundStyle(drColor)
//                    
//                    
//                }
//            
//            }
//            .chartYAxis(.visible)
//            .chartXAxis(.visible)
//            .chartYAxis {
//                AxisMarks(values: [-3, -2, -1, 0, 1, 2, 3]) {
//                    AxisGridLine()
//                }
//                AxisMarks(values: [-3, 0, 3]) {
//                    AxisValueLabel()
//                }
//            }
//            .chartXAxis {
//
//                AxisMarks(values: .stride(by: .day, count: 1)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            if value.index == 0 || date.isStartOfMonth {
//                                Text(mmddFormatOf(date))
//                            }
//                            else {
//                                Text(date, format: .dateTime.day())
//                                    .onAppear() {
//                                        print("it appeared")
//                                    }
//                            }
////                            VStack {
////
////                                if value.index == 0 {
////                                    Text(date, format: .dateTime.month().day())
////                                }
////                                Text(date, format: .dateTime.day())
////                            }
//                        }
////                        default:
////                            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
////                        }
////
////
////                        if hour == 0 {
////                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
////                            AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
////                        } else {
////                            AxisGridLine()
////                            AxisTick()
////                        }
//                    }
//                }
//            }
//            
//
//            
//        }
//
//    }
//}
