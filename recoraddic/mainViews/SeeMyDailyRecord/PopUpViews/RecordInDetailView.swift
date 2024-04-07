//
//  RecordInDetail.swift
//  recoraddic
//
//  Created by 김지호 on 1/25/24.
//

import Foundation
import SwiftUI
import SwiftData


// Since HiddenRecords view don't apply the selectedRecord slowly, this is the buffer view to remove possibility of unwraping nil when RecordInDetailView is initialized.
struct RecordInDetailView_optional: View {
    @Environment(\.modelContext) var modelContext

    @Environment(\.colorScheme) private var colorScheme
    
    
    @Binding var popUp_recordInDetail: Bool
//    @Binding var dailyRecordHidden: Bool
//    @Binding var dailyRecordDeleted: Bool
    
    
    @Binding var record: DailyRecord?
    
    var body: some View {
        if record == nil {
            Spacer()
        }

        else {
            RecordInDetailView(
                popUp_recordInDetail: $popUp_recordInDetail,
//                dailyRecordHidden: $dailyRecordHidden,
//                dailyRecordDeleted: $dailyRecordDeleted,
                dailyRecordThemeName: record!.dailyRecordSet!.dailyRecordThemeName,
                dailyRecordColorIndex: record!.dailyRecordSet!.dailyRecordColorIndex,
                record: record!
            )
        }
    }
    
    
}




struct RecordInDetailView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    
    @Binding var popUp_recordInDetail: Bool
//    @Binding var dailyRecordHidden: Bool
//    @Binding var dailyRecordDeleted: Bool
        
    var dailyRecordThemeName: String
    var dailyRecordColorIndex: Int
    
    var record: DailyRecord
    
    @State var editDailyText = false
    @State var applyDailyTextRemoval = false
//    @State var diaryViewWiden = false
    
    @State var popUp_deleteRecordConfirmation: Bool = false


    
    var body: some View {
        

        let elementColor: Color = getColorSchemeColor(colorScheme).adjust(brightness: colorScheme == .light ? -0.05 : 0.05)
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedcolorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
//        let foregroundColor: Color =  {
//            if dailyRecordThemeName == "stoneTower_0" {
//                return StoneTower_0.getDailyRecordColor(index: dailyRecordColorIndex)
//            }
//            else if dailyRecordThemeName == "stoneTower_1" {
//                return StoneTower_1.getDailyRecordColor(index: dailyRecordColorIndex)
//            }
//            else {
//                return Color.white
//            }
//        }()
        
        let shadowColor:Color = getShadowColor(colorScheme)
            
            
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let imageOrStoneHeight = geometry.size.height*0.16
            let imageOrStoneWidth = record.diaryImage != nil ? geometry.size.width*0.8 : imageOrStoneHeight*1.5
            
            let questBoxWidth = geometry.size.width*0.9
            let questBoxHeight = geometry.size.height*0.08
            
            let confirmationPopUp_width = geoWidth*0.6
            let confirmationPopUp_height = confirmationPopUp_width*0.7

            let elementWidth = geometry.size.width*0.9
            let diaryHeight = record.dailyTextType == DailyTextType.diary ? geometry.size.height*0.8 : 60.0

            let facialExpressionSize = geoWidth * 0.08
            
            let iconWidth: CGFloat = 40
            let iconHeight: CGFloat = 35
            
            ZStack {
                VStack {
                    
                    HStack(spacing:geoWidth*0.05) {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: geoWidth*0.002)
                                .frame(width:facialExpressionSize, height: facialExpressionSize)
                            reversedcolorSchemeColor
                                .frame(width:facialExpressionSize, height: facialExpressionSize)
                                .mask(
                                    Image("facialExpression_\(record.mood)")
                                        .resizable()
                                        .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                )
                        }
                        .frame(width:facialExpressionSize, height: facialExpressionSize)
                        Text(kor_yyyymmddFormatOf(record.date))
                        //                        .frame(width: geoWidth)
                            .font(.title3)
                            .bold()
                        Menu {
                            Button(record.hide ? "되돌리기":"숨기기") {
                                if !record.hide {
                                    recalculateVisualValues_hiddenOrDeleted(dailyRecord: record)
                                    record.hide.toggle()
                                }
                                else {
                                    record.hide.toggle()
                                    recalculateVisualValues_unhidden(dailyRecord: record)
                                }
                                
                                //                                dailyRecordHidden.toggle()
                                popUp_recordInDetail.toggle()
                            }
                            
                            Button("삭제") {
                                //                                dailyRecordDeleted.toggle()
                                popUp_deleteRecordConfirmation.toggle()
                                

                                
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .frame(width:facialExpressionSize, height: facialExpressionSize)

                        }
                        
                    }
                    .padding(.top,30)
                    
                    
                    ScrollView {
                        VStack {
                            if record.diaryImage != nil {
                                Image(uiImage: UIImage(data:record.diaryImage!)!)
                                    .resizable()
                                    .aspectRatio(contentMode:.fit)
                                    .frame(width: imageOrStoneWidth, height: imageOrStoneHeight)
                            }

                            if record.dailyTextType == DailyTextType.inShort {
                                InShortView(
                                    selectedDailyRecord: record,
                                    inShortText: record.dailyText ?? "",
                                    applyDailyTextRemoval: $applyDailyTextRemoval,
                                    isEdit: $editDailyText
                                )
                                .frame(width:elementWidth, height: diaryHeight)
                                .background(colorSchemeColor)
                                .clipShape(.buttonBorder)
                                .shadow(color:shadowColor, radius: 3)
                            }
                            else if record.dailyTextType == DailyTextType.diary {
                                
                                VStack(spacing:0.0) {
                                    Image(systemName: "book.closed.fill")
                                        .resizable()
                                        .frame(width:iconWidth, height: iconHeight)
                                        .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                                        .padding(.vertical, 10)
                                    
                                    Text("\(record.dailyText ?? "")")
                                        .frame(width: elementWidth*0.95)
                                        .background(colorSchemeColor)
                                        .padding(.bottom, 20)

                                }
                                .frame(width:elementWidth, alignment: .center)
                                .background(colorSchemeColor)
                                .clipShape(.containerRelative)
                                .shadow(color:shadowColor.opacity(0.6), radius: 2)
                                .border(.gray)
//                                DiaryView_WholeContent(diaryText: record.dailyText ?? "", showWholeContent: .constant(false))
////                                DiaryView(
////                                    selectedDailyRecord: record,
////                                    diaryText: record.dailyText ?? "",
////                                    applyDiaryRemoval: $applyDailyTextRemoval,
////                                    isEdit: $editDailyText
////                                )
//                                .frame(width:elementWidth, height: diaryHeight)
//                                .background(colorSchemeColor)
//                                .clipShape(.containerRelative)
//                                .shadow(color:shadowColor.opacity(0.5), radius: 2)
//                                .scrollDisabled(!diaryViewWiden) // does not work on debug mode, how about in non debug mode?

                            }
                            

                            
                            Text("달성한 퀘스트:")
                                .padding(.top, 20)
                                .font(.headline)
                                .frame(width: questBoxWidth, alignment: .leading)
                            ForEach(record.dailyQuestList!, id:\.self) { questdata in
                                
                                let text:String = questdata.dataType != DataType.OX ? "\(questdata.questName)  \(DataType.string_unitDataToRepresentableData(data: questdata.data, dataType: questdata.dataType)) \(DataType.unitNotationOf(dataType: questdata.dataType, customDataTypeNotation: questdata.customDataTypeNotation))" : questdata.questName
                                
                                Text(text)
                                    .font(.title3)
                                    .minimumScaleFactor(0.5)
                                    .frame(width:questBoxWidth, height: questBoxHeight, alignment: .center)
                                    .background(elementColor) // TODO: 당시 quest티어색 적용, 버닝 색도 적용 -> 그러려면 그것도 dailyRecord의 DailyQuest에 저장을 해야겠지?
                                    .clipShape(.buttonBorder)
                                //                                .shadow(color:shadowColor, radius: 2.0)
                                //                                .shadow(color:shadowColor, radius: 2.0)
                                    .padding(3)
                                //                            .border(.background)
                            }
                            
                            
                            //                        HStack {
                            //                            Button(record.hide ? "되돌리기":"숨기기") {
                            //                                if !record.hide {
                            //                                    recalculateVisualValues_hiddenOrDeleted(dailyRecord: record)
                            //                                    record.hide.toggle()
                            //                                }
                            //                                else {
                            //                                    record.hide.toggle()
                            //                                    recalculateVisualValues_unhidden(dailyRecord: record)
                            //                                }
                            //
                            ////                                dailyRecordHidden.toggle()
                            //                                popUp_recordInDetail.toggle()
                            //                            }
                            //
                            //                            Button("삭제") {
                            ////                                dailyRecordDeleted.toggle()
                            //                                popUp_recordInDetail.toggle()
                            //                                if !record.hide {
                            //                                    recalculateVisualValues_hiddenOrDeleted(dailyRecord: record)
                            //                                }
                            //                                modelContext.delete(record)
                            //
                            //                            }
                            //                        }
                            
                            
                        }//VStack
                        .frame(width: geometry.size.width, alignment: .top)
                        .padding(.vertical,10)

                    }//ScrollView
                    .frame(width: geometry.size.width, height: geometry.size.height*0.8)
                } // VStack
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                if popUp_deleteRecordConfirmation {
                    Color.gray
                        .opacity(0.1)
                    VStack(spacing:0.0) {
                        Text("정말로 삭제하시겠습니까?")
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.bottom, confirmationPopUp_height*0.3)
                        HStack {
                            Button("예") {
                                popUp_deleteRecordConfirmation.toggle()
                                popUp_recordInDetail.toggle()
                                if !record.hide {
                                    recalculateVisualValues_hiddenOrDeleted(dailyRecord: record)
                                }
                                modelContext.delete(record)
                            }
                            .frame(width: confirmationPopUp_width*0.5)
                            Button("아니오") {
                                popUp_deleteRecordConfirmation.toggle()
                            }
                            .frame(width: confirmationPopUp_width*0.5)

                        }

                    }
                    .frame(width: confirmationPopUp_width, height: confirmationPopUp_width*0.65)
                    .background(.background)
                    .clipShape(.rect(cornerSize: CGSize(width: confirmationPopUp_width*0.1, height: confirmationPopUp_width*0.65*0.1)))
                    .shadow(color:reversedcolorSchemeColor,radius: 5)
                }


                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)

//            .overlay {
//
//
//            }
//            
        }//geometryReader
        
    }
    
    
//    func recalculateVisualValues_unhidden() -> Void {
//        
//        if selectedDailyRecord!.dailyRecordSet!.dailyRecordThemeName == "stoneTower_1" {
//            // 1 3 6 -> 1 4 -> 1 3 6
//            // 1 3 6 10 -> 1 (3) 4 7 -> 1 (3)
//            
//            let targetIndex: Int = dailyRecords_saved.firstIndex(of: selectedDailyRecord!)!
//            let drCount: Int = dailyRecords_saved.count
//            let plusVisualValue3: Int = {
//                if targetIndex == 0 {
//                    return dailyRecords_saved[targetIndex].visualValue3!
//                }
//                else {
//                    return dailyRecords_saved[targetIndex].visualValue3! - dailyRecords[targetIndex-1].visualValue3! // 음 어떻게 할까 이게 항상 같지가 않음... ㅅㅂ
//                }
//            }()
//
//            if (plusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) { return }
//            else {
//                for i in (targetIndex+1)...(drCount-1) {
//                    dailyRecords_saved[i].visualValue3! += plusVisualValue3
//                }
//            }
//
//        }
//        else {
//            print("error: failed to recalculate visual values")
//        }
//        
//        selectedDailyRecord = nil
//
//    }
    
    
}
