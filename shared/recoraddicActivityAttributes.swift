//
//  StopWatchAttributes.swift
//  recoraddic
//
//  Created by 김지호 on 7/9/24.
//
import Foundation
import ActivityKit

struct RecoraddicActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var goal: Int?
        
    }
    var questName: String
    var startTime: Date
    var containedDate: Date
    var tier: Int

}

