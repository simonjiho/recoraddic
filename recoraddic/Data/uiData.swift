//
//  uiData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation
import SwiftData


//let StoredRecord = [Record(), Record()]


    
    
@Model
class UIData_DailyStones {
    init() {}
}
@Model
class UIData_RecordStone {
    init() {}
}

@Model
class UIData_CurrentRecord {
    init() {}
}



// ------------------------------------------------ 여기 아래는 나중에 위로 통합하기


//@Model
class AllRecordStonesData {
    var background: Int!
    var recordStonesData: [RecordStoneData]!
    var dailyStonesData:  [DailyStoneData]!
    var adjustedSkin: Int!
    
    init(recordData:[RecordStoneData] , dailyData:[DailyStoneData] ) {
        recordStonesData = recordData
        dailyStonesData = dailyData
    }
    
}



//@Model
class RecordStoneData {
    
    // term -> 크기
    // 성취도 -> ?
    // 티어 -> ?
    // 필요 데이터 : 액션, 스킨or컬러, 크기, representingdata(기간, 성취도, 티어, 소감 등)
    var color: Float!
    var size: Float!
    
    init(color in1: Float,size in2: Float) {
        color = in1
        size = in2
    }
    
}



//@Model
class DailyStoneData {
    // 특징: 시각화되는 것들
    
    // (달성도 -> 크기) , (기분 -> 표정1, 액션의 크기) , (하루소감 -> 클릭 시에만 대화 상자처럼 나옴) , (생산성 -> 색요소2) , (스킨넘버 -> 스킨), (액션넘버 -> 액션)
    // 남은 요소: 표정2, 테두리
    
//    var dailyAchievement: Array<[String:Float]> // to size & saturation
//    var dailyMood: String // to facial expression
//    var dailyEfficiency: Float! // to glow effect
//    var someThingSpecial: SomethingSpecial // to glowEffect
//    var actionName: String // to action
//    var selectedDesign: String // to color&skin

    
    
//    var dailyStoneRandomDeco1: Int!
//    var dailyStoneRandomDeco2: Int!
    var dailyStoneCustomAction: Int!

    
    
    // fixed Ones
    var dailyStoneFixedColor: Int!
    var dailyStoneFixedDeco1: Int!
    var dailyStoneFixedDeco2: Int!
    // var random
    // 클릭시 간단하게 실제 수치도 나옴
    
    
    var color: Float!
    var size: Float!
    
    
    
    
    init (color in1: Float, size in2: Float) {
        color = in1
        size = in2
    }
    
    
}

