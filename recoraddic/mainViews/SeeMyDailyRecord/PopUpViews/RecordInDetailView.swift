//
//  RecordInDetail.swift
//  recoraddic
//
//  Created by 김지호 on 1/25/24.
//

import Foundation
import SwiftUI
import SwiftData



struct RecordInDetailView_new: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    @Query var quests: [Quest]
    
    
    @Binding var selectedDailyRecord: DailyRecord?
    @State var selectedDrDate: Date?
    
    
    var body: some View {
        
        let dailyRecords_withContent = dailyRecords.filter({$0.hasContent})
        
            
            ScrollView(.horizontal) {
                LazyHStack(spacing:0.0) {
                    ForEach(dailyRecords_withContent, id:\.self) { dr in
                        VStack {
                            if let date = dr.date {
                                DailyRecordInShort(dailyRecord: dr)
                            } else {
                                Text("nil dailyRecord")
                            }
                        }
                        .containerRelativeFrame([.horizontal, .vertical])
                        .id(dr.date)
                    }
                }
                .scrollTargetLayout()

                
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selectedDrDate)
            .scrollIndicators(.never)
            .onAppear() {
                
                DispatchQueue.main.async {
                    selectedDrDate = selectedDailyRecord?.date ?? nil

                }
            }
        

    }


}



struct DailyRecordInShort: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) var modelContext

    @Query var quests: [Quest]

    var dailyRecord: DailyRecord
    


    var body: some View {
        
        let reversedcolorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        let questNames_hidden:[String] = quests.filter({$0.isHidden}).map{$0.name}


        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let imageOrStoneHeight = geometry.size.height*0.16
            let imageOrStoneWidth = dailyRecord.diaryImage != nil ? geometry.size.width*0.8 : imageOrStoneHeight*1.5
            
            let questBoxWidth = geometry.size.width*0.9
            let questBoxHeight = 40.0
            let todoHeight = 30.0
            
            let confirmationPopUp_width = geoWidth*0.7
//            let confirmationPopUp_height = confirmationPopUp_width*0.6

            let elementWidth = geometry.size.width*0.9

            let tagSize:CGFloat = questBoxHeight*0.4
            let spacing:CGFloat = tagSize*0.1


            let facialExpressionSize = geoWidth * 0.08
            
//            let iconWidth: CGFloat = 20
//            let iconHeight: CGFloat = 35
            
            VStack {
                
                HStack(spacing:geoWidth*0.05) {
                    if dailyRecord.mood != 0 {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: geoWidth*0.002)
                                .frame(width:facialExpressionSize, height: facialExpressionSize)
                            reversedcolorSchemeColor
                                .frame(width:facialExpressionSize, height: facialExpressionSize)
                                .mask(
                                    Image("facialExpression_\(dailyRecord.mood)")
                                        .resizable()
                                        .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                )
                        }
                        .frame(width:facialExpressionSize, height: facialExpressionSize)
                    }
                    Text(kor_yyyymmddFormatOf(dailyRecord.date ?? Date()))
                    //                        .frame(width: geoWidth)
                        .font(.title3)
                        .bold()
                }
                .padding(.top,30)
                
                
                ScrollView {
                    VStack {
                        if dailyRecord.diaryImage != nil {
                            Image(uiImage: UIImage(data:dailyRecord.diaryImage!)!)
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .frame(width: imageOrStoneWidth, height: imageOrStoneHeight)
                        }
                        
                        
                        if dailyRecord.dailyText != nil && dailyRecord.dailyText != "" {

                            Group {
                                
                                Image(systemName: "book.closed.fill")
                                    .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                            }
                            .frame(width:elementWidth,alignment: .leading)
                            
                            
                            
                            Text(dailyRecord.dailyText ?? "")
                                .padding(elementWidth*0.03)
                                .frame(width:elementWidth)
                                .background(.gray.opacity(0.1))
                                .padding(.bottom,geoHeight*0.05)
                        }


                        if dailyRecord.recordedAmount > 0 {
                            Text("달성한 퀘스트")
                                .padding(.top, 20)
                                .font(.headline)
                                .frame(width: questBoxWidth, alignment: .leading)
                        }
                        ForEach(dailyRecord.dailyQuestList!, id:\.self) { questdata in
                            
                            if !questNames_hidden.contains(questdata.questName) && questdata.data != 0 {
                                let text:String = dataTypeFrom(questdata.dataType) != DataType.ox ? "\(questdata.questName)  \(DataType.string_fullRepresentableNotation(data: questdata.data, dataType: dataTypeFrom(questdata.dataType), customDataTypeNotation: questdata.customDataTypeNotation))" : questdata.questName
                                HStack {
                                    if !questdata.defaultPurposes.isEmpty {
                                        PurposeTagsView_vertical(purposes: questdata.defaultPurposes)
                                            .frame(width:20, height:questBoxHeight*0.8)
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:20, height:questBoxHeight*0.8)
                                            .foregroundStyle(getDarkTierColorOf(tier: questdata.currentTier))
                                    }
                                    Text(text)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(2)
                                        .foregroundStyle(getDarkTierColorOf(tier: questdata.currentTier))


                                }
                                .padding(.leading,10)
                                .frame(width:questBoxWidth, height: questBoxHeight, alignment: .leading)
                                .background(LinearGradient(colors: getGradientColorsOf(tier: questdata.currentTier, type: 0), startPoint: .topLeading, endPoint: .bottomTrailing)) // TODO: 당시 quest티어색 적용, 버닝 색도 적용 -> 그러려면 그것도 dailyRecord의 DailyQuest에 저장을 해야겠지?
                                .clipShape(.buttonBorder)
                                //                                .shadow(color:shadowColor, radius: 2.0)
                                //                                .shadow(color:shadowColor, radius: 2.0)
                                //                            .border(.background)
                            }
                        }
                        
                        ForEach(dailyRecord.todoList!, id:\.self) { todo in
                            if todo.content != "" {
                                let purposeCount2 = todo.purpose.count
                                HStack {
                                    if todo.purpose.count != 0 {
                                        PurposeTagsView_vertical(purposes: todo.purpose)
                                            .frame(width:20, height:todoHeight*0.9)
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:20, height:todoHeight*0.9)
                                    }
                                    Text("\(todo.content)")
                                        .lineLimit(3)
                                }
                                .frame(width:elementWidth,alignment: .leading)
                            }
                        }
                        
                        

                    }//VStack
                    .frame(width: geometry.size.width, alignment: .top)
                    .padding(.vertical,10)

                }//ScrollView
                .frame(width: geometry.size.width, height: geometry.size.height*0.8)
            } // VStack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)

                


        }//geometryReader
    }
}


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
                                
                                if !questNames_hidden.contains(questdata.questName) && questdata.data != 0 {
                                    let text:String = dataTypeFrom(questdata.dataType) != DataType.ox ? "\(questdata.questName)  \(DataType.string_fullRepresentableNotation(data: questdata.data, dataType: dataTypeFrom(questdata.dataType), customDataTypeNotation: questdata.customDataTypeNotation))" : questdata.questName
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
                                if todo.content != "" {
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
                            }
                            
                            

                        }//VStack
                        .frame(width: geometry.size.width, alignment: .top)
                        .padding(.vertical,10)

                    }//ScrollView
                    .frame(width: geometry.size.width, height: geometry.size.height*0.8)
                } // VStack
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
//                .alert("해당 일일기록을 삭제하시겠습니까?", isPresented: $popUp_inTrashCanConfirmation) {
//                    Button("Ok") {
//                        adjustDailyRecordChanges(dailyRecord: record, option: .trashCan)
//                        popUp_inTrashCanConfirmation.toggle()
//                        popUp_recordInDetail.toggle()
//                    }
//                    Button("no..") {popUp_inTrashCanConfirmation.toggle()}
//                } message: {
//                    Text("(삭제한 일일기록은 휴지통으로 이동됩니다.)")
//                }
                            
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)


        }//geometryReader
        
    }
    

    
    
}
