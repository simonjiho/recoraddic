////
////  EventCheckBoxView.swift
////  recoraddic
////
////  Created by 김지호 on 12/19/23.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
//struct EventCheckBoxView: View {
//    
//    var eventCheckBoxData: EventCheckBoxData
//
//    
////    @State var checkBoxToggle: Bool = false
//    
//    
//    @Binding var applyDailyEventRemoval: Bool
//
//    @Binding var eventCheckBoxDataToDelete: EventCheckBoxData?
//    
//    var body: some View {
//        GeometryReader { geometry in
//            
//            let checkBoxSize = geometry.size.width*0.12
//            let secondaryContentSize = geometry.size.width*0.65
//            let ellipsisFrameSize = geometry.size.width*0.05
//            let checkBoxSpacing = geometry.size.width*0.06
//
//            
//            ZStack {
//                HStack {
//                    Image(systemName: eventCheckBoxData.isDone ? "checkmark.square.fill":"square.fill")
//                        .resizable()
//                        .frame(width: checkBoxSize, height: checkBoxSize)
////                        .position(x:checkBoxSize/2 + 10, y:geometry.size.height/2)
//                        .padding(.trailing,checkBoxSpacing)
//                        .onTapGesture {
//                            eventCheckBoxData.isDone.toggle()
//                        }
//
//                    
//                    ResizableText(text: eventCheckBoxData.eventName, width: geometry.size.width*0.9, height: geometry.size.height)
//                        .frame(width:secondaryContentSize, height: geometry.size.height*0.9)
//                    
//                    Menu {
//                        Button("delete", action: {
//                            eventCheckBoxDataToDelete = eventCheckBoxData
//                            applyDailyEventRemoval.toggle()
//                        })
//                        
//                    } label: {
//                        Image(systemName: "ellipsis")
//                    }
//                    .frame(width: ellipsisFrameSize,height:geometry.size.height*0.7, alignment: .top)
//
//
//                    
//                } // hstack
//                .padding(.horizontal,geometry.size.width*0.04)
//                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .trailing)
//            
//                
//
//
//
//            
//
//
//                
//            } // zstack
//            .frame(width: geometry.size.width, height: geometry.size.height)
//        }
//    }
//}
