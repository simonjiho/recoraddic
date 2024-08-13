//
//  defaultVariables.swift
//  recoraddic
//
//  Created by 김지호 on 12/14/23.
//

import Foundation
import SwiftUI


let defaultPurposes:[String] = [DefaultPurpose.atr, DefaultPurpose.hlt, DefaultPurpose.ftr, DefaultPurpose.ent, DefaultPurpose.rts, DefaultPurpose.inq, DefaultPurpose.ach, DefaultPurpose.sgn, DefaultPurpose.fml, DefaultPurpose.cmn, DefaultPurpose.alt, DefaultPurpose.wrl]

let defaultPurposes_per: [String] = [DefaultPurpose.atr, DefaultPurpose.hlt, DefaultPurpose.ftr, DefaultPurpose.ent, DefaultPurpose.rts, DefaultPurpose.inq, DefaultPurpose.ach]
let defaultPurposes_notper: [String] = [DefaultPurpose.sgn, DefaultPurpose.fml, DefaultPurpose.cmn, DefaultPurpose.alt, DefaultPurpose.wrl]


//let defaultDataTypes:[DataType] = [.hour, DataType.REP, DataType.HOUR, DataType.CUSTOM]

//let diaryTopics:[String] = [DiaryTopic.inShort, DiaryTopic.feedbacks, DiaryTopic.specialEvent]
// feedback is too heavy, making people irritated

let defaultQuestions:[String] = ["더 나은 내가 된 하루였나요?", "괜찮은 하루를 보냈나요?"]

// TODO: create recommended questions depending on the person's feature.

let facialExpression_tmp:[Int] = [1,2,3,7,8,9,10,11,13,14,15,20,21,23,24,25,26,27,34,37,39,42,43,44,47,48,50,54,56,58,59,72,79,82,85,86,87,88,89,96,99,100,101,102,105,106,111,112,116,118,122,123]


let facialExpression_Middle1:[Int] = []
let facialExpression_Middle2:[Int] = []



let facialExpression_Bad1:[Int] = [2,4,10,13,19,21,25,26,29,39,40,50,51,52,53,55,65,75,76,79,80,83,84,100,104,107,120,122,124]
let facialExpression_Bad2:[Int] = [18,36,45,47,60,61,64,66,68,69,78,81,82,86,87,88,92,93,94,95,99,108,109,112,113,114,115,116,119]


let facialExpression_Good1:[Int] = [1,7,9,15,21,22,27,31,32,33,41,43,44,49,54,68,70,71,73,74,87,96,101,108,111,112,117,123]

let facialExpression_Good2:[Int] = [5,6,12,16,17,28,30,35, 38,39,46,48,57,61,62,63,67,69,77,82,90,91,97,98,103,110,121,125]

let facialExpression_Good:[Int] = [1,5,6,7,9,12,15,16,17,21,22,27,28,30,31,32,33,35,38,39,41,43,44,46,48,49,54,57,61,62,63,67,68,69,70,71,73,74,77,82,87,90,91,96,97,98,101,103,108,110,111,112,117,121,123,125]

let facialExpression_Bad:[Int] = [2,4,10,13,18,19,21,25,26,29,36,39,40,45,47,50,51,52,53,55,60,61,64,65,66,68,69,75,76,78,79,80,81,82,83,84,86,87,88,92,93,94,95,99,100,104,107,108,109,112,113,114,115,116,119,120,122,124]
let facialExpression_Middle:[Int] = [1,2,3,7,8,9,10,11,13,14,15,20,21,23,24,25,26,27,34,37,39,42,43,44,47,48,50,54,56,58,59,72,79,82,85,86,87,88,89,96,99,100,101,102,105,106,111,112,116,118,122,123]

#Preview {
    VStack {
        Text("\(facialExpression_tmp.count)/\(facialExpression_Middle.count)")
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
            ForEach(facialExpression_tmp, id:\.self) { idx in
                VStack(spacing:0.0) {
                    Text("\(idx)")
                        .font(.caption2)
                    Image("facialExpression_\(idx)")
                        .resizable()
                        .frame(width:30, height: 30)
                }
            }
            
        }
        .padding(.bottom)
        
        
        Text("\(facialExpression_Middle1.count)")
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
            ForEach(facialExpression_Middle1, id:\.self) { idx in
                VStack(spacing:0.0) {
                    Text("\(idx)")
                        .font(.caption2)
                    Image("facialExpression_\(idx)")
                        .resizable()
                        .frame(width:30, height: 30)
                }
            }
            
        }
        .padding(.bottom)
        
        Text("\(facialExpression_Middle2.count)")
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
            ForEach(facialExpression_Middle2, id:\.self) { idx in
                VStack(spacing:0.0) {
                    Text("\(idx)")
                        .font(.caption2)
                    Image("facialExpression_\(idx)")
                        .resizable()
                        .frame(width:30, height: 30)
                }
            }
            
        }
        .padding(.bottom)
        
        
        //        LazyVGrid(columns: [GridItem], content: <#T##() -> Content#>)
        
        Text("\(Set(facialExpression_tmp).intersection(Set(facialExpression_Middle1)))")
        Text("\(Set(facialExpression_tmp).intersection(Set(facialExpression_Middle2)))")
        Text("\(Set(facialExpression_Middle1).intersection(Set(facialExpression_Middle2)))")
        
        Text("\(Set(facialExpression_Middle) == Set(facialExpression_Middle1+facialExpression_Middle2+facialExpression_tmp))")

    }
}


func getStatusBarHeight() -> CGFloat {
    let window = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .map { $0 as? UIWindowScene }
        .compactMap { $0 }
        .first?.windows
        .filter { $0.isKeyWindow }
        .first

    return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
}


func getButtomSafeAreaHeight() -> CGFloat {
    let window = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .map { $0 as? UIWindowScene }
        .compactMap { $0 }
        .first?.windows
        .filter { $0.isKeyWindow }
        .first

    let windowHeight = window?.windowScene?.windows.first?.screen.bounds.height ?? 0
    let mainHeight = window?.windowScene?.windows.first?.frame.height ?? 0
    let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    return windowHeight - statusBarHeight - mainHeight // 전체 창 크기
}
//TODO: windowHeight 랑 mainHeight 값 확인
func getmainHeight() -> CGFloat {
    let window = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .map { $0 as? UIWindowScene }
        .compactMap { $0 }
        .first?.windows
        .filter { $0.isKeyWindow }
        .first

//    let height = window?.windowScene?.keyWindow?.frame.height
    let height = window?.screen.bounds.height ?? 0
//    let windowHeight = window?.windowScene?.windows.first?.screen.bounds.height ?? 0
//    let mainHeight = window?.windowScene?.windows.first?.frame.height ?? 0
//    let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    return height // 전체 창 크기
}


let iphone15plusHeight: CGFloat = 932.0

