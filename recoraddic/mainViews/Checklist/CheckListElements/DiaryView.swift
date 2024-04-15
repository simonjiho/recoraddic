//
//  DiaryView.swift
//  recoraddic
//
//  Created by 김지호 on 12/20/23.
//


/*
 하나로 통합
 바깥에서 texteditor 변수 받아옴
 바깥에서 text 길이 보고 창 크기 조절
 내부에서는 text 길이 보고 사진 크기 조절(일정 길이 까지는 조그맣게, 일정 길이 이상부터는 위에 크게
 아니면 geowidth가 일정 크기 이상 커지면 바뀌게
 
 */

import Foundation
import SwiftUI
import SwiftData


struct InShortView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
//    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    

    
    var selectedDailyRecord: DailyRecord
    
    @State var inShortText: String
    
    @Binding var applyDailyTextRemoval: Bool
//    @Binding var diaryEllipsisTapped: Bool
    
    
    @Binding var isEdit: Bool
    
    @FocusState var keyBoard: Bool
    
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            

            let iconWidth: CGFloat = 20
            
            let iconHeight: CGFloat = 20
            

            
            ZStack {
                
                if !isEdit {
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .frame(width:iconWidth, height: iconHeight)
                            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                        Text(inShortText)
                            .frame(width:geoWidth*0.85, height: geoHeight*0.9)
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    }

                }
                else {
                    HStack {

                
                        VStack(alignment: .trailing) {
                            TextField("하루를 요약해보세요",text:$inShortText)
                                .frame(width:geoWidth*0.8, alignment: .trailing)
                                .lineLimit(3)
                                .focused($keyBoard)
                                .maxLength(50, text: $inShortText)
                            Text("\(inShortText.count)/50")
                                .font(.footnote)
                            
                        }
                        .frame(width:geoWidth*0.8, height: geoHeight*0.8)
                        .onAppear() {
                            keyBoard = true
                        }
                        .onChange(of:keyBoard) {
                            if !keyBoard {
                                isEdit = false
                            }
                        }

                        Button("완료", action:{
                            isEdit = false
                            keyBoard = false
                            selectedDailyRecord.dailyText = inShortText
                        })
                        
                    }
                }

                
                
                Menu {
                    
                    Button("수정",action: {
                        isEdit = true
                        keyBoard = true
                    })
                    Button("삭제",action: {
                        applyDailyTextRemoval.toggle()
                    })
                    //
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(height: geoHeight*0.75, alignment:.top)

//                        .frame(height: geoHeight/2 <= 40 ? geoHeight/2 : 40, alignment:.top)

                }
                .padding(.top,3)
                .frame(width:geoWidth*0.975, height: geoHeight, alignment: .topTrailing)
                .disabled(isEdit)

            
                
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onChange(of: selectedDailyRecord) {
                inShortText = selectedDailyRecord.dailyText!
            }





        }
    }

}

//struct DiaryView: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.modelContext) var modelContext
//
//    var selectedDailyRecord: DailyRecord
//
//    var image: Data?
//
//    @State var diaryText: String
//
//    @State var diaryViewWiden: Bool
////    @Binding var popUp_addDiary: Bool
//    @Binding var applyDiaryRemoval: Bool
////    @Binding var diaryEllipsisTapped: Bool
//    
////    @State var isEdit: Bool
//
//    @Binding var isEdit: Bool
//    @FocusState var keyBoard: Bool
//    
//    @State var showWholeContent:Bool = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height
//            
//            
//
//            let iconWidth: CGFloat = diaryViewWiden ? 40 : 20
//            let imageWidth: CGFloat = image == nil ? 0.0 : (diaryViewWiden ? geometry.size.width*0.8 : geometry.size.width*0.15)
//            let textBoxWidth: CGFloat = diaryViewWiden ? geometry.size.width*0.9 : (geometry.size.width-imageWidth-iconWidth)*0.8
//            
//            let iconHeight: CGFloat = diaryViewWiden ? 35 : 20
//            let imageHeight: CGFloat = image == nil ? 0.0 : (diaryViewWiden ? geometry.size.height*0.2 : imageWidth)
//            let textBoxHeight: CGFloat = diaryViewWiden ? (geometry.size.height - imageHeight - iconHeight - 30) : geometry.size.height*0.8
////            let textBoxHeight: CGFloat = diaryViewWiden ? (geometry.size.height - imageHeight)*(isEdit ? 0.7 : 1.0) : geometry.size.height*0.8
//            
////            let iconAndDoneButtonHStackWidth:  CGFloat = iconWidth*2
//            
//            let text = diaryViewWiden ? diaryText : String(describing: diaryText.prefix(30))
//            
//            let axisWiden = geometry.size.width/2
//            let axisNotWiden = geometry.size.height/2
//            
//            let iconPosition: CGPoint = diaryViewWiden ? CGPoint(x: axisWiden, y: 10 + iconHeight/2): CGPoint(x: 10 + iconWidth/2, y: axisNotWiden)
////            let iconAndHStackPosition: CGPoint = CGPoint(x: axisWiden, y: 10 + iconHeight/2)
//            let imagePosition: CGPoint = diaryViewWiden ? CGPoint(x: axisWiden, y: 10 + iconHeight + 10 + imageHeight/2): CGPoint(x: 10 + iconWidth + 5 + imageWidth/2 , y: axisNotWiden)
//            let textBoxPosition: CGPoint = diaryViewWiden ? CGPoint(x: axisWiden, y: 10 + iconHeight + 10 + imageHeight + 10 + textBoxHeight/2): CGPoint(x: 10 + iconWidth + 5 + imageWidth + 10 + textBoxWidth/2 , y: axisNotWiden)
//            
//            let ellipsisPositon: CGPoint = CGPoint(x:geometry.size.width*0.975, y: 10)
//            
//            ZStack(alignment:diaryViewWiden ? .top : .leading) {
//                
//                Group {
//                    
//                    Color.clear
//                        .background(.background)
//                    HStack {
//                        Image(systemName: "book.closed.fill")
//                            .resizable()
//                            .frame(width:iconWidth, height: iconHeight)
//                            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
//                        if isEdit {
//                            Button("완료") {
//                                isEdit = false
//                                keyBoard = false
//                                selectedDailyRecord.dailyText = diaryText
//                            }
//                            .buttonStyle(.borderedProminent)
//                        }
//                    }
//                    .position(iconPosition)
//
//                    
//                    
//                    if image != nil {
//                        Image(uiImage: UIImage(data: image!)!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width:imageWidth, height: imageHeight)
//                            .clipShape(.buttonBorder)
//                            .position(imagePosition)
//                    }
//                    
//                    
//                    if isEdit {
//                        TextEditor(text: $diaryText)
//                            .frame(width:textBoxWidth, height: textBoxHeight, alignment: .top)
//                            .position(textBoxPosition)
//                            .border(.gray)
//                            .focused($keyBoard)
//                            .onAppear() {
//                                diaryViewWiden = true
//                                keyBoard = true
//                            }
//
//                        
//                    }
//                    else {
//                        
//
//                            Text("\(text)\(diaryText.count > text.count ? "..." : "")")
//                                .lineLimit(diaryViewWiden ? 100 : 1)
//                                .scrollDisabled(false)
//                                .position(textBoxPosition)
//                                .border(.gray)
//                            
////                        }
////                        .scrollDisabled(!diaryViewWiden)
//                    }
//                }
//                .onTapGesture {
//                    if !isEdit {
//                        withAnimation {
//                            if !diaryViewWiden {
//                                showWholeContent.toggle()
//                            }
//                            diaryViewWiden.toggle()
//
//                        }
//                    }
//                }
//                .onChange(of: keyBoard) {
//                    isEdit = keyBoard
//                }
//                .onChange(of: isEdit) {
//                    keyBoard = isEdit
//                }
//                
//                
//                if !diaryViewWiden {
//                    Menu {
//                        
//                        Button("수정",action: {
//                            //                        popUp_addDiary.toggle()
//                            //                        withAnimation {
//                            //                            diaryViewWiden = true
//                            //                        }
//                            isEdit = true
//                            keyBoard = true
//                            
//                        })
//                        Button("삭제",action: {
//                            applyDiaryRemoval.toggle()
//                        })
//                        //
//                    } label: {
//                        Image(systemName: "ellipsis")
//                            .font(.title3)
//                            .frame(height: geoHeight*0.75, alignment:.top)
//                        //                        .frame(height: geoHeight/2 <= 40 ? geoHeight/2 : 40, alignment:.top)
//                        
//                    }
//                    .padding(.top,3)
//                    .frame(width:geoWidth*0.975, height: geoHeight, alignment: .topTrailing)
//                    //                .position(ellipsisPositon)
//                    //                .onTapGesture {
//                    //                    diaryEllipsisTapped.toggle()
//                    //                }
//                    //                .me
//                }
//
//            
//                
//                
//            }
//            .frame(width: geometry.size.width, height: geoHeight)
//            .onChange(of: selectedDailyRecord) {
//                diaryText = selectedDailyRecord.dailyText!
//            }
//            .fullScreenCover(isPresented: $showWholeContent, content: {
//                DiaryView(selectedDailyRecord: selectedDailyRecord, diaryText: selectedDailyRecord.dailyText ?? "", diaryViewWiden: true, applyDiaryRemoval: .constant(false), isEdit: .constant(false))
//            })
//
//
//
//
//
//        }
//    }
//}




struct DiaryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

    var selectedDailyRecord: DailyRecord


    @State var diaryText: String

//    @State var diaryViewWiden: Bool
//    @Binding var popUp_addDiary: Bool
    @Binding var applyDiaryRemoval: Bool
//    @Binding var diaryEllipsisTapped: Bool
    
//    @State var isEdit: Bool

    @Binding var isEdit: Bool
    @FocusState var keyBoard: Bool
    
    @State var showWholeContent:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            

            let iconWidth: CGFloat = isEdit ? 40 : 20
            let textBoxWidth: CGFloat = isEdit ? geometry.size.width*0.9 : (geometry.size.width-iconWidth)*0.8

            let iconHeight: CGFloat = isEdit ? 35 : 20
            let textBoxHeight: CGFloat = isEdit ? (geometry.size.height  - iconHeight - 30) : geometry.size.height*0.8
//            let textBoxHeight: CGFloat = diaryViewWiden ? (geometry.size.height - imageHeight)*(isEdit ? 0.7 : 1.0) : geometry.size.height*0.8

//            let iconAndDoneButtonHStackWidth:  CGFloat = iconWidth*2

            let text = isEdit ? diaryText : String(describing: diaryText.prefix(30))

            let axisWiden = geometry.size.width/2
            let axisNotWiden = geometry.size.height/2

            let iconPosition: CGPoint = isEdit ? CGPoint(x: axisWiden, y: 10 + iconHeight/2): CGPoint(x: 10 + iconWidth/2, y: axisNotWiden)
//            let iconAndHStackPosition: CGPoint = CGPoint(x: axisWiden, y: 10 + iconHeight/2)
            let imagePosition: CGPoint = isEdit ? CGPoint(x: axisWiden, y: 10 + iconHeight + 10 ): CGPoint(x: 10 + iconWidth + 5 , y: axisNotWiden)
            let textBoxPosition: CGPoint = isEdit ? CGPoint(x: axisWiden, y: 10 + iconHeight + 10 + 10 + textBoxHeight/2): CGPoint(x: 10 + iconWidth + 5 + 10 + textBoxWidth/2 , y: axisNotWiden)
            //
//            let iconWidth: CGFloat = 20
//            let textBoxWidth: CGFloat = (geometry.size.width-iconWidth)*0.8
//            let iconHeight: CGFloat = 20
//            let textBoxHeight: CGFloat = geometry.size.height*0.8
//            let textBoxHeight: CGFloat = diaryViewWiden ? (geometry.size.height - imageHeight)*(isEdit ? 0.7 : 1.0) : geometry.size.height*0.8
            
//            let iconAndDoneButtonHStackWidth:  CGFloat = iconWidth*2
            
//            let text = String(describing: diaryText.prefix(30))
            
//            let axisWiden = geometry.size.width/2
//            let axis = geometry.size.height/2
//            
//            let iconPosition: CGPoint = CGPoint(x: 10 + iconWidth/2, y: axis)
//            let textBoxPosition: CGPoint = CGPoint(x: 10 + iconWidth + 5 + 10 + textBoxWidth/2 , y: axis)
            
            
            ZStack(alignment:isEdit ? .top : .leading) {
                
                Group {
                    
                    Color.clear
                        .background(.background)
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .frame(width:iconWidth, height: iconHeight)
                            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                        if isEdit {
                            Button("완료") {
                                withAnimation {
                                    isEdit = false
                                }
                                keyBoard = false
                                selectedDailyRecord.dailyText = diaryText
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .position(iconPosition)

                    
                    
                    
                    if isEdit {
                        TextEditor(text: $diaryText)
                            .frame(width:textBoxWidth, height: textBoxHeight, alignment: .top)
                            .position(textBoxPosition)
//                            .border(.gray)
                            .focused($keyBoard)
                            .onAppear() {
                                keyBoard = true
                            }

                    }
                    else {
   
                            Text("\(text)\(diaryText.count > text.count ? "..." : "")")
                                .lineLimit(1)
                                .position(textBoxPosition)
//                                .border(.gray)
                    }
                }
                .onTapGesture {
                    if !isEdit {
                        showWholeContent.toggle()
                    }
                }
//                .onChange(of: keyBoard) {
//                    if isEdit != keyBoard {
//                        withAnimation {
//                            isEdit = keyBoard
//                        }
//                    }
//                }
//                .onChange(of: isEdit) {
//                    if isEdit != keyBoard {
//                        keyBoard = isEdit
//                    }
//                }
                
                
                Menu {
                    
                    Button("수정",action: {

                        withAnimation {
                            isEdit = true
                        }
                        keyBoard = true
                        
                    })
                    Button("삭제",action: {
                        applyDiaryRemoval.toggle()
                    })
                    //
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(height: geoHeight*0.75, alignment:.top)
                    
                }
                .padding(.top,3)
                .frame(width:geoWidth*0.975, height: geoHeight, alignment: .topTrailing)


            
                
                
            }
            .frame(width: geometry.size.width, height: geoHeight)
            .onChange(of: selectedDailyRecord) {
                diaryText = selectedDailyRecord.dailyText!
            }
            .sheet(isPresented: $showWholeContent, content: {
                GeometryReader { geometry2 in
                    VStack {
                        DiaryView_WholeContent(diaryText: diaryText, showWholeContent: $showWholeContent)
                            .frame(width:geometry2.size.width*0.95, height: geometry2.size.height*0.85)
                    }
                    .frame(width:geometry2.size.width, height: geometry2.size.height, alignment: .center)
                }
//                    .presentationCompactAdaptation(.none)

            })





        }
    }
}



struct DiaryView_WholeContent: View {
    
    @Environment(\.colorScheme) var colorScheme

    var diaryText: String

    @Binding var showWholeContent: Bool
    

    
    var body: some View {
        
        let shadowColor = getShadowColor(colorScheme)
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let contentWidth = geoWidth*0.95
            let contentHeight = geoHeight*0.9
            

            let iconWidth: CGFloat = 40
//            let imageWidth: CGFloat = image == nil ? 0.0 : geometry.size.width*0.8
            let textBoxWidth: CGFloat = geometry.size.width*0.9
            
            let iconHeight: CGFloat = 35
//            let imageHeight: CGFloat = image == nil ? 0.0 : geometry.size.height*0.2
            let textBoxHeight: CGFloat = geometry.size.height  - iconHeight - 30
//            let textBoxHeight: CGFloat = diaryViewWiden ? (geometry.size.height - imageHeight)*(isEdit ? 0.7 : 1.0) : geometry.size.height*0.8
            
//            let iconAndDoneButtonHStackWidth:  CGFloat = iconWidth*2
            
            
            
            
                
                VStack(spacing:0.0) {
                    
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .frame(width:iconWidth, height: iconHeight)
                        .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                        .padding(.vertical, 10)
                    
                    
                    ScrollView {
                        Text("\(diaryText)")
                            .frame(width: contentWidth*0.95)
                    }
                    .frame(width: geoWidth ,height: max(geoHeight-20-iconHeight-10, 0.0))
                    .background(colorSchemeColor)
                    .padding(.bottom, 10)

                }
                .frame(width: geoWidth, height: geoHeight, alignment: .center)
                .background(colorSchemeColor)
                .clipShape(.containerRelative)
                .shadow(color:shadowColor.opacity(0.6), radius: 2)
                .border(.gray)
            









        }
    }
}
