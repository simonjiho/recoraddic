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
    

    
    var currentDailyRecord: DailyRecord
    
    @State var inShortText: String
    
    @Binding var applyDailyTextRemoval: Bool
//    @Binding var diaryEllipsisTapped: Bool
    
    
//    @Binding var isEdit: Bool
    
    @FocusState var keyBoard: Bool
    
    
    @State private var offset: CGFloat = 0
    @State var showMenu: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let menuSize = geoWidth * 0.2


            let iconWidth: CGFloat = 20
            
            let iconHeight: CGFloat = 20
            

            HStack(spacing:0.0) {

                HStack(spacing:0.0) {
                    Image(systemName: "book.closed")
                        .frame(width:geoWidth*0.1)
                        .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                    
                    VStack(alignment: .trailing) {
                        TextField("하루를 요약해보세요",text:$inShortText)
                            .frame(width:geoWidth*(keyBoard ? 0.77 : 0.9), alignment: .trailing)
                            .lineLimit(3)
                            .minimumScaleFactor(keyBoard ? 1.0 : 0.8)
                            .focused($keyBoard)
                            .maxLength(50, text: $inShortText)
                        
                        if keyBoard {
                            Text("\(inShortText.count)/50")
                                .font(.footnote)
                                .dynamicTypeSize(...DynamicTypeSize.xLarge)
                        }
                        
                    }
                    .frame(width: geoWidth*(keyBoard ? 0.8 : 0.9), height: geoHeight*0.95, alignment: keyBoard ? .bottom : .center)
                    if keyBoard {
                        Button("완료", action:{
                            keyBoard = false
                            currentDailyRecord.dailyText = inShortText
                        })
                        .frame(width:geoWidth*0.1)
                        .minimumScaleFactor(0.5)
                    }
                }
                .frame(width: geoWidth, height: geoHeight, alignment: .leading)
                .disabled(offset < -menuSize*0.5)
                .offset(x: offset, y:0)
                
                HStack(spacing:0.0) {
                    Image(systemName: "xmark")
                        .frame(width: menuSize, height:geoHeight)
                    Spacer()
                        .frame(width: menuSize*2, height:geoHeight)
                }
                .frame(width: menuSize*3, height:geoHeight)
                .background(Color.red.blur(radius: 1))
                .offset(x: offset, y:0)
                .disabled(offset > -menuSize*0.5)
                .onTapGesture {
                    applyDailyTextRemoval.toggle()
                }
                
            }
            .frame(width:geoWidth, height: geoHeight, alignment: .leading)
            .background(.gray.opacity(0.2))
            .clipped()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if keyBoard { return }
                        
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
//                        if keyBoard { return }
                        
                        if !(value.translation.width > 0 && !showMenu) {
                            if value.translation.width < -menuSize*0.1 {
                                withAnimation {
                                    offset = -menuSize
                                }
                                showMenu = true
                                
                            } else {
                                showMenu = false
                                withAnimation {
                                    offset = 0
                                }
                            }
                        }
                        
                    }
            )
//            .onChange(of: currentDailyRecord) {
//                inShortText = currentDailyRecord.dailyText!
//            }




            

        }
    }

}



struct DiaryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

    var currentDailyRecord: DailyRecord


    @State var diaryText: String

//    @State var diaryViewWiden: Bool
//    @Binding var popUp_addDiary: Bool
    @Binding var applyDiaryRemoval: Bool
//    @Binding var diaryEllipsisTapped: Bool
    
//    @State var isEdit: Bool

    @Binding var isEdit: Bool
    @FocusState var keyBoard: Bool
    
    
    @State private var offset: CGFloat = 0
    @State var showMenu: Bool = false


    
    var body: some View {
        GeometryReader { geometry in
            
            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let menuSize = geoWidth * 0.2

            
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

            HStack(spacing:0.0) {
                ZStack(alignment:isEdit ? .top : .leading) {
                    
                    
                    Color.gray.opacity(0.2)
                        .frame(width: geoWidth, height: geoHeight)
                        .position(CGPoint(x: geoWidth/2, y: geoHeight/2))
                        .onTapGesture {
                            if !isEdit {
                                withAnimation {
                                    isEdit = true
                                }
                            }
                        }
//                        .border(.blue)
//                        .zIndex(1)
                    
                        

                    
    
                    
                    if isEdit {
                        TextEditor(text: $diaryText)
                            .padding(.bottom,10)
                            .frame(width:textBoxWidth, height: textBoxHeight, alignment: .top)
                            .scrollContentBackground(.hidden)
                            .position(textBoxPosition)
//                            .border(.red)
                        //                            .border(.gray)
                            .focused($keyBoard)
                            .onAppear() {
                                if diaryText == "" {
                                    keyBoard = true
                                }
                            }
//                            .zIndex(2)
                        
                    }
                    else {
                        
                        Text("\(text)\(diaryText.count > text.count ? "..." : "")")
                            .frame(width:textBoxWidth)
                            .lineLimit(1)
                            .position(textBoxPosition)
                            .onTapGesture {
                                if !isEdit {
                                    withAnimation {
                                        isEdit = true
                                    }
                                }
                            }
                        //                                .border(.gray)
                    }
                    
                    
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                        if isEdit {
                            if keyBoard {
                                Button("완료") {
                                    withAnimation {
                                        isEdit = false
                                    }
                                    keyBoard = false
                                    currentDailyRecord.dailyText = diaryText
                                }
//                                .zIndex(11)
                                .buttonStyle(.borderedProminent)
                            }
                            else {
                                Button(action: {
                                    withAnimation {
                                        isEdit = false
                                    }
                                }) {
                                    Color.white.opacity(0.01)
                                        .overlay(
                                            Image(systemName: "chevron.up")
                                    )
                                        .frame(width:iconWidth, height: iconHeight)
                                        .foregroundStyle(reversedColorSchemeColor)
                                }

                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .position(iconPosition)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    

                }
                .frame(width: geoWidth, height: geoHeight)
                .disabled(offset < -menuSize*0.5)
                .offset(x: offset, y:0)

                
                HStack(spacing:0.0) {
                    Image(systemName: "xmark")
                        .frame(width: menuSize, height:geoHeight)
                    Spacer()
                        .frame(width: menuSize*2, height:geoHeight)
                }
                .frame(width: menuSize*3, height:geoHeight)
                .background(Color.red.blur(radius: 1))
                .offset(x: offset, y:0)
                .disabled(offset > -menuSize*0.5)
                .onTapGesture {
                    applyDiaryRemoval.toggle()
                }
            }
            .frame(width:geoWidth, height: geoHeight, alignment: .leading)
            .clipped()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if isEdit { return }
                        
                        if showMenu {
                            if value.translation.width < 0 {
                                let delta = log10(10 - value.translation.width*0.1)
                                offset = (-menuSize) * (delta)
                            }
                            else if value.translation.width > menuSize {
                                let delta = log10(1 + (value.translation.width - geoHeight)*0.01)
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
                        if isEdit { return }
                        
                        if !(value.translation.width > 0 && !showMenu) {
                            if value.translation.width < -menuSize*0.1 {
                                withAnimation {
                                    offset = -menuSize
                                }
                                showMenu = true
                                
                            } else {
                                showMenu = false
                                withAnimation {
                                    offset = 0
                                }
                            }
                        }
                        
                    }
            )
            .onChange(of: currentDailyRecord) {
                diaryText = currentDailyRecord.dailyText!
            }




        }
    }
}



