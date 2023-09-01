//
//  metaData.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/08/11.
//

import Foundation


class RecordMetaData {
    
    init(_ input: Record) {

    }
}

class GroupMetaData {
    var burning_gage: Int?
    var achivement_gage: Int?
    
    init(_ input: Group) {
        
    }
    
}

class GoalMetaData {
    
    var rawData: Goal
    var combo: Int
    var process: Float
    
    init(input: Goal) {
        rawData = input
        combo = 0
        process = 0.0
    }
    
    func update() {
        combo = countNonzeroFromEnd(rawData.data)
        process = sumFloatArray(rawData.data) / rawData.option.finalGoal
        
        if process > 1 { process = 1}
    }
    

    
}
