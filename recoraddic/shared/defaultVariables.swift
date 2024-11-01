//
//  defaultVariables.swift
//  recoraddic
//
//  Created by 김지호 on 12/14/23.
//

import Foundation
import SwiftUI

let defaultPurposes:[String] = [DefaultPurpose.hlt, DefaultPurpose.cmp, DefaultPurpose.ent, DefaultPurpose.atr, DefaultPurpose.inq, DefaultPurpose.ach, DefaultPurpose.ftr, DefaultPurpose.rts, DefaultPurpose.lov, DefaultPurpose.fml, DefaultPurpose.cmn, DefaultPurpose.alt, DefaultPurpose.wrl]

let defaultPurposes_per: [String] = [DefaultPurpose.hlt, DefaultPurpose.cmp, DefaultPurpose.ent, DefaultPurpose.atr, DefaultPurpose.inq, DefaultPurpose.ach, DefaultPurpose.ftr, DefaultPurpose.rts]
let defaultPurposes_notper: [String] = [DefaultPurpose.lov, DefaultPurpose.fml, DefaultPurpose.cmn, DefaultPurpose.alt, DefaultPurpose.wrl]


let defaultPurposeExpression1:[String:String] = [
    DefaultPurpose.hlt: "운동선수",
    DefaultPurpose.cmp: "야심가",
    DefaultPurpose.ent: "쾌락주의자",
    DefaultPurpose.atr: "스타",
    DefaultPurpose.inq: "학자",
    DefaultPurpose.ach: "등산가",
    DefaultPurpose.ftr: "개척자",
    DefaultPurpose.rts: "사교가",
    DefaultPurpose.lov: "사랑꾼",
    DefaultPurpose.fml: "파수꾼",
    DefaultPurpose.cmn: "수호자",
    DefaultPurpose.alt: "박애주의자", // 천사?
    DefaultPurpose.wrl: "영웅"
]
let defaultPurposeExpression2:[String:String] = [
    DefaultPurpose.hlt: "건강한",
    DefaultPurpose.cmp: "승부욕 강한",
    DefaultPurpose.ent: "행복한",
    DefaultPurpose.atr: "매력적인",
    DefaultPurpose.inq: "호기심 많은",
    DefaultPurpose.ach: "열정적인",
    DefaultPurpose.ftr: "별을 좇는",
    DefaultPurpose.rts: "사교적인",
    DefaultPurpose.lov: "사랑을 좇는",
    DefaultPurpose.fml: "헌신적인",
    DefaultPurpose.cmn: "정의로운",
    DefaultPurpose.alt: "이타적인",
    DefaultPurpose.wrl: "세계를 구하는"
]


// TODO: create recommended questions depending on the person's feature.




let facialExpression_Bad1:[Int] = [2,4,10,13,19,21,25,26,29,39,40,50,51,52,53,55,65,75,76,79,80,83,84,100,104,107,120,122,124] // 부정적 감정
let facialExpression_Bad2:[Int] = [18,36,45,47,60,61,64,66,68,69,78,81,82,86,87,88,92,93,94,95,99,108,109,112,113,114,115,116,119] // 강렬하게 부정적인 감정


let facialExpression_Good1:[Int] = [1,7,9,15,21,22,27,31,32,33,41,43,44,49,54,68,70,71,73,74,87,96,101,108,111,112,117,123] // 긍정적 감정

let facialExpression_Good2:[Int] = [5,6,12,16,17,28,30,35, 38,39,46,48,57,61,62,63,67,69,77,82,90,91,97,98,103,110,121,125] // 강렬하게 긍정적인 감정

let facialExpression_Good:[Int] = [1,5,6,7,9,12,15,16,17,21,22,27,28,30,31,32,33,35,38,39,41,43,44,46,48,49,54,57,61,62,63,67,68,69,70,71,73,74,77,82,87,90,91,96,97,98,101,103,108,110,111,112,117,121,123,125]

let facialExpression_Bad:[Int] = [2,4,10,13,18,19,21,25,26,29,36,39,40,45,47,50,51,52,53,55,60,61,64,65,66,68,69,75,76,78,79,80,81,82,83,84,86,87,88,92,93,94,95,99,100,104,107,108,109,112,113,114,115,116,119,120,122,124]
let facialExpression_Middle:[Int] =
//[1,2,3,7,8,9,10,11,13,14,15,20,21,23,24,25,26,27,34,37,39,42,43,44,47,48,50,54,56,58,59,72,79,82,85,86,87,88,89,96,99,100,101,102,105,106,111,112,116,118,122,123]
[1,2,3,7,8,9,10,11,13,14,15,20,21,23,24,25,26,27,34,37,42,44,50,54,56,58,59,72,79,85,87,88,89,96,99,100,102,105,106,111,112,116,118,122,123]



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


//func getBottomSafeAreaHeight() -> CGFloat {
//    let window = UIApplication.shared.connectedScenes
//        .filter { $0.activationState == .foregroundActive }
//        .map { $0 as? UIWindowScene }
//        .compactMap { $0 }
//        .first?.windows
//        .filter { $0.isKeyWindow }
//        .first
//    let windowHeight = window?.windowScene?.windows.first?.screen.bounds.height ?? 0
////    let mainHeight = window?.windowScene?.windows.first?.frame.height ?? 0
//    let mainHeight = window?.windowScene?.
//    let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//    print(windowHeight)
//    print(mainHeight)
//    print(statusBarHeight)
//    return windowHeight - statusBarHeight - mainHeight // 전체 창 크기
//}
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




let qcbvHeight_large: CGFloat = 70.0
let qcbvHeight_medium: CGFloat = 55.0
let qcbvHeight_small: CGFloat = 45.0

func qcbvHeight(_ dynamicTypeSize: DynamicTypeSize, stopWatchIsRunnig:Bool, dataType:Int) -> CGFloat {
    let height:CGFloat = stopWatchIsRunnig ? qcbvHeight_large : (dataType != DataType.ox.rawValue ? qcbvHeight_medium : qcbvHeight_small)
    let multiplier = qcbvMultiplier(dynamicTypeSize)

    return height * multiplier
}

func qcbvHeight(_ dynamicTypeSize: DynamicTypeSize, dataType:Int) -> CGFloat {
    let height:CGFloat = dataType != DataType.ox.rawValue ? qcbvHeight_medium : qcbvHeight_small
    let multiplier = qcbvMultiplier(dynamicTypeSize)
    return height * multiplier
}

func qcbvHeight(_ dynamicTypeSize: DynamicTypeSize, stopWatchIsRunnig:Bool) -> CGFloat {
    let height:CGFloat = stopWatchIsRunnig ? qcbvHeight_large : qcbvHeight_medium
    let multiplier = qcbvMultiplier(dynamicTypeSize)
    return height * multiplier
}

func qcbvMultiplier(_ dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch dynamicTypeSize {
    case ...DynamicTypeSize.large: return 1.0
    case .xLarge: return 1.05
    case .xxLarge: return 1.1
    case .xxxLarge: return 1.2
    case .accessibility1: return 1.3
    case .accessibility2: return 1.4
    case .accessibility3: return 1.5
    case .accessibility4: return 1.6
    default: return 1.8 // == case .accessibility5
    }
}

func questThumbnailWidth(_ dynamicTypeSize: DynamicTypeSize, defaultWidth: CGFloat) -> CGFloat {
    switch dynamicTypeSize {
    case ...DynamicTypeSize.accessibility1: return defaultWidth
    default: return defaultWidth*2
    }
}

func stoneSizeMultiplier(_ dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch dynamicTypeSize {
    case ...DynamicTypeSize.xLarge: return 1.00
    case .xxLarge: return 1.05
    case .xxxLarge: return 1.1
    case .accessibility1: return 1.15
    case .accessibility2: return 1.2
    case .accessibility3: return 1.25
    case .accessibility4: return 1.3
    default: return 1.4
    }
}


//func questThumbnailHeight(_ dynamicTypeSize: DynamicTypeSize, height: CGFloat) -> CGFloat {
//    switch dynamicTypeSize {
//    case ...DynamicTypeSize.xxxLarge: return height
//    default: return height*2
//    }
//}
