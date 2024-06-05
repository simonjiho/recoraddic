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
    @Query var quests: [Quest]

    
    @Binding var popUp_recordInDetail: Bool
//    @Binding var dailyRecordHidden: Bool
//    @Binding var dailyRecordDeleted: Bool
    @Binding var record: DailyRecord?
    @State var alert_deleteRecordConfirmation: Bool = false
    
    var body: some View {
        
        
        if record == nil {
            Spacer()
        }

        else {
            RecordInDetailView(
                popUp_recordInDetail: $popUp_recordInDetail,
                alert_deleteRecordConfirmation: $alert_deleteRecordConfirmation,
//                dailyRecordHidden: $dailyRecordHidden,
//                dailyRecordDeleted: $dailyRecordDeleted,
                dailyRecordThemeName: record!.dailyRecordSet!.dailyRecordThemeName,
                dailyRecordColorIndex: record!.dailyRecordSet!.dailyRecordColorIndex,
                record: record!

            )
            .alert("해당 구간기록을 영구적으로 삭제하시겠습니까?", isPresented: $alert_deleteRecordConfirmation) {
                Button("Ok") {
                    adjustDailyRecordChanges(dailyRecord: record!, option: .delete)
                    let targetDr: DailyRecord = record!
                    record = nil

                    if calculateDaysBetweenTwoDates(from: targetDr.date!, to: getStartOfDate(date:.now)) < 2 { //다시 저장할 수 있는 날짜라면 quest에 기록 된 것 지워야 하므로
                        for quest in quests {
                            if quest.dailyData.keys.contains(targetDr.date!) {
                                quest.dailyData.removeValue(forKey: targetDr.date!)
                            }
                        }
                    }
                    
                    
                    alert_deleteRecordConfirmation.toggle()
                    popUp_recordInDetail.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 없으면 ㅈ댐
                        modelContext.delete(targetDr)
                    }

                    
                    // 뭔가 이상하다.. recalculation이!

                }
                Button("no..") {alert_deleteRecordConfirmation.toggle()}
            } message: {
                Text("(당일, 전날의 일일기록을 제외하고는 퀘스트의 기록에 영향을 끼치지 않습니다.)")
            }
            
        }
    }
    
    
}




struct RecordInDetailView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query var quests: [Quest]

    
    @Binding var popUp_recordInDetail: Bool
//    @Binding var dailyRecordHidden: Bool
//    @Binding var dailyRecordDeleted: Bool
    @Binding var alert_deleteRecordConfirmation: Bool

        
    var dailyRecordThemeName: String
    var dailyRecordColorIndex: Int
    
    var record: DailyRecord
    
    @State var editDailyText = false
    @State var applyDailyTextRemoval = false
    @State var popUp_inTrashCanConfirmation: Bool = false
//    @State var diaryViewWiden = false
    


    
    var body: some View {
        

//        let elementColor: Color = getColorSchemeColor(colorScheme).adjust(brightness: colorScheme == .light ? -0.05 : 0.05)
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedcolorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
//        let shadowColor:Color = getShadowColor(colorScheme)
            
        
        let questNames_hidden:[String] = quests.filter({$0.isHidden}).map{$0.name}
            
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let imageOrStoneHeight = geometry.size.height*0.16
            let imageOrStoneWidth = record.diaryImage != nil ? geometry.size.width*0.8 : imageOrStoneHeight*1.5
            
            let questBoxWidth = geometry.size.width*0.9
            let questBoxHeight = geometry.size.height*0.07
            
            let confirmationPopUp_width = geoWidth*0.7
//            let confirmationPopUp_height = confirmationPopUp_width*0.6

            let elementWidth = geometry.size.width*0.9

            let tagSize:CGFloat = questBoxHeight*0.4
            let spacing:CGFloat = tagSize*0.1


            let facialExpressionSize = geoWidth * 0.08
            
//            let iconWidth: CGFloat = 20
//            let iconHeight: CGFloat = 35
            
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
                        Text(kor_yyyymmddFormatOf(record.date!))
                        //                        .frame(width: geoWidth)
                            .font(.title3)
                            .bold()
                        Menu {
                            

                            Button(!record.isVisible() ? "되돌리기":"숨기기") {
                                if record.isVisible() {
                                    adjustDailyRecordChanges(dailyRecord: record, option:.hide)
                                }
                                else {
                                    adjustDailyRecordChanges(dailyRecord: record, option:.visible)
                                }
                                
                                //                                dailyRecordHidden.toggle()
                                popUp_recordInDetail.toggle()
                            }
                            
                            if (!record.inTrashCan) {
                                Button("휴지통으로 이동") {
                                    popUp_inTrashCanConfirmation.toggle()
//                                    adjustDailyRecordChanges(dailyRecord: record, option:.trashCan)
//                                    popUp_recordInDetail.toggle()
                                }
                            }
                            else {
                                Button("영구적으로 삭제") {
                                    alert_deleteRecordConfirmation.toggle()
                                }
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
                            
                            
                            if record.dailyText != nil && record.dailyText != "" {

                                Group {
                                    
                                    Image(systemName: "book.closed.fill")
                                        .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                                }
                                .frame(width:elementWidth,alignment: .leading)
                                
                                
                                
                                Text(record.dailyText!)
                                    .padding(elementWidth*0.03)
                                    .frame(width:elementWidth)
                                    .background(.gray.opacity(0.1))
                                    .padding(.bottom,geoHeight*0.05)
                            }


                            
                            Text("달성한 퀘스트")
                                .padding(.top, 20)
                                .font(.headline)
                                .frame(width: questBoxWidth, alignment: .leading)
                            ForEach(record.dailyQuestList!, id:\.self) { questdata in
                                
                                if !questNames_hidden.contains(questdata.questName) {
                                    let text:String = questdata.dataType != DataType.OX ? "\(questdata.questName)  \(DataType.string_fullRepresentableNotation(data: questdata.data, dataType: questdata.dataType, customDataTypeNotation: questdata.customDataTypeNotation))" : questdata.questName
                                    HStack {
                                        
                                        let purposeCount = questdata.defaultPurposes.count
                                        let totalWidth:CGFloat = tagSize * CGFloat(purposeCount) + (purposeCount > 0 ? spacing * CGFloat(purposeCount - 1) : 0.0)
                                        Text(text)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        PurposeTagsView_horizontal(purposes: questdata.defaultPurposes, tagSize: tagSize, spacing:spacing, totalWidth: totalWidth)
                                            .frame(width:totalWidth, height: tagSize)
                                        
                                    }
                                    .frame(width:questBoxWidth, height: questBoxHeight, alignment: .center)
                                    .background(LinearGradient(colors: getGradientColorsOf(tier: questdata.currentTier, type: 0), startPoint: .topLeading, endPoint: .bottomTrailing)) // TODO: 당시 quest티어색 적용, 버닝 색도 적용 -> 그러려면 그것도 dailyRecord의 DailyQuest에 저장을 해야겠지?
                                    .clipShape(.buttonBorder)
                                    //                                .shadow(color:shadowColor, radius: 2.0)
                                    //                                .shadow(color:shadowColor, radius: 2.0)
                                    .padding(3)
                                    //                            .border(.background)
                                }
                            }
                            
                            ForEach(record.todoList!, id:\.self) { todo in
                                let purposeCount2 = todo.purpose.count
                                let totalWidth2:CGFloat = tagSize * CGFloat(purposeCount2) + (purposeCount2 > 0 ? spacing * CGFloat(purposeCount2 - 1) : 0.0)
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("\(todo.content)")
                                        .lineLimit(3)
                                    PurposeTagsView_horizontal(purposes: todo.purpose, tagSize: tagSize, spacing:spacing, totalWidth: totalWidth2)
                                        .frame(width:totalWidth2, height: tagSize)

                                    
                                    
                                }
                                .frame(width:elementWidth, alignment: .leading)
                            }
                            
                            

                        }//VStack
                        .frame(width: geometry.size.width, alignment: .top)
                        .padding(.vertical,10)

                    }//ScrollView
                    .frame(width: geometry.size.width, height: geometry.size.height*0.8)
                } // VStack
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .alert("해당 일일기록을 삭제하시겠습니까?", isPresented: $popUp_inTrashCanConfirmation) {
                    Button("Ok") {
                        adjustDailyRecordChanges(dailyRecord: record, option: .trashCan)
                        popUp_inTrashCanConfirmation.toggle()
                        popUp_recordInDetail.toggle()
                    }
                    Button("no..") {popUp_inTrashCanConfirmation.toggle()}
                } message: {
                    Text("(삭제한 일일기록은 휴지통으로 이동됩니다.)")
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
