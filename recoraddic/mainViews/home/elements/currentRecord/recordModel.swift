//
//  recordModel.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/14.
//

import Foundation
import SwiftUI


//protocol CurrentRecord {
//    var currentRecord: Record {get}
//    var currentRecordModel: RecordModel {get}
//}





// figure(View)들을 각각 정의하고, 그 뷰들을 list에 저장, List는 record, group, quest로 나뉨.
// list들을 structure로 저장...?
// 그런 structure을 정의...?







protocol RecordModelProtocol {
//    associatedtype viewArray
//    var recordFig: [String:(Any) -> Any] { get }
//    var recordFig: [String: (Any) -> AnyView] { get }
    
    
    associatedtype Value
    var recordFig: [String: (Any) -> Value] { get }
    
//    var groupFig: [String: any View] { get }
//    var questFig: [String: any View] { get }
//
//    var recordFigPos: [String: SIMD2<Float>] { get }
//    var groupFigPos: [String: SIMD2<Float>] { get }
//    var questFigPos: [String: SIMD2<Float>] { get }
    
}


extension RecordModelProtocol {
    func checkElements() -> Bool {
        return recordFig.keys.contains("recordName")
//        && recordFig.keys.contains("recordBackground")
//        && recordFig.keys.contains("recordCombo")
//        && recordFig.keys.contains("recordProgress")
//        && recordFig.keys.contains("recordLockButton")
//        && recordFig.keys.contains("recordTermProgress")
//        && groupFig.keys.contains("groupName")
//        && groupFig.keys.contains("groupBackground")
//        && groupFig.keys.contains("groupCombo")
//        && groupFig.keys.contains("groupProgress")
//        && groupFig.keys.contains("groupLockButton")
//        && questFig.keys.contains("questName")
//        && questFig.keys.contains("questCombo")
//        && questFig.keys.contains("questProgress")
//        && questFig.keys.contains("questLockButton")
//        && questFig.keys.contains("questStatisticsButton")
//        && questFig.keys.contains("questStatisticsContent")
        
        // add contraints of ~~~FigPos later
        
        
    }
}




//
//protocol RecordModel {
////    var name: String { get }
//
//    var figures: any RecordModelFig { get } // 모든 그래픽 요소
////    var positions: RecordModelPosType.Type { get }// 모든 위치 요소
//
//    // overlap 시 미리 cut하는 function 넣기!!
//
//    // Change color func
//}
//
//protocol RecordName: View {
//    var name: String { get }
//}
//
////Figure contains graphical contents
//protocol RecordModelFig {
//    // 나중에는 기기마다 구성요소 조금씩 특성 바꿀 수 있게
//    associatedtype recordName: RecordName
////    var recordName: RecordNameType { get }
////    typealias recordName = RecordName
////    var recordName: any RecordName { get set }
//
////    var recordBackground: any View { get }
////    var recordCombo: any View { get }
////    var recordProgress: any View { get }
////    var recordLockButton: any View { get }
////    var recordTermProgress: any View { get }
////
////    var groupName: any View { get }
////    var groupBackground: any View { get }
////    var groupCombo: any View { get }
////    var groupProgress: any View { get }
////    var groupLockButton: any View { get }
////
////    var questName: any View { get }
////    var questCombo: any View { get }
////    var questProgress: any View { get }
////    var questLockButton: any View { get }
////    var questStatisticButtion: any View { get }
////    var questStatisticContent: any View { get } // for  popup statistics
//////
//}
//
//
//
////Pos contains positional contents
//protocol RecordModelPos {
//    // 나중에는 기기마다 구성요소 조금씩 특성 바꿀 수 있게
////    var recordName: SIMD2<Float> { get }
////    var recordBackground: SIMD2<Float> { get }
////    var recordCombo: SIMD2<Float> { get }
////    var recordProgress: SIMD2<Float> { get }
////    var recordLockButton: SIMD2<Float> { get }
////    var recordTermProgress: SIMD2<Float> { get }
////
////    var groupName: SIMD2<Float> { get }
////    var groupBackground: SIMD2<Float> { get }
////    var groupCombo: SIMD2<Float> { get }
////    var groupProgress: SIMD2<Float> { get }
////    var groupLockButton: SIMD2<Float> { get }
////
////    var questName: SIMD2<Float> { get }
////    var questCombo: SIMD2<Float> { get }
////    var questProgress: SIMD2<Float> { get }
////    var questLockButton: SIMD2<Float> { get }
////    var questStatisticButtion: SIMD2<Float> { get }
////    var questStatisticContent: SIMD2<Float> { get }
//}
