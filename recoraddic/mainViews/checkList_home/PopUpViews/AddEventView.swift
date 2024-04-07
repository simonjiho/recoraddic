////
////  AddEventView.swift
////  recoraddic
////
////  Created by 김지호 on 12/17/23.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
//
//struct AddEventView: View {
//
//    @Environment(\.modelContext) private var modelContext
//    
//    var recordOfToday: DailyRecord
//    
//    @Binding var popUp_addEvent: Bool
//    
//    @State var dailyEventToAppend:String = ""
//
//    var body: some View {
//        
//        VStack {
//            TextField("일회성 체크리스트를 생성하세요.",text:$dailyEventToAppend)
//
//            Button(action:{
//                let newEventCheckBoxData = EventCheckBoxData(eventName: dailyEventToAppend, isDone: false)
//                newEventCheckBoxData.dailyRecord = recordOfToday
//                newEventCheckBoxData.createdTime = Date()
//                modelContext.insert(newEventCheckBoxData)
//                popUp_addEvent.toggle()
//                
//            }) {
//                Text("done")
//            }
//            .buttonStyle(.bordered)
//            .disabled(dailyEventToAppend == "")
//                
//            
//        }
//    }
//}
