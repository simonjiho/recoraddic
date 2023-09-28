//
//  metaData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation
import SwiftData

@Model
class RecordMetaData {
    
    init(_ input: Record) {

    }
}

@Model
class PurposeMetaData {
    var burning_gage: Int?
    var achivement_gage: Int?
    
    init(_ input: Purpose) {
        
    }
    
}

@Model
class QuestMetaData {
    
    var rawData: Quest
    var combo: Int
    var process: Float
    
    init(input: Quest) {
        rawData = input
        combo = 0
        process = 0.0
    }
    
    func update() {
        combo = countNonzeroFromEnd(rawData.data)
        process = sumFloatArray(rawData.data) / rawData.questOption.finalGoal
        
        if process > 1 { process = 1}
    }
    

    
}
