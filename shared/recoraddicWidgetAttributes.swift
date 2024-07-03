//
//  StopWatchAttributes.swift
//  recoraddic
//
//  Created by 김지호 on 7/9/24.
//

import Foundation
import ActivityKit

struct RecoraddicWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var goal: Int?
        
    }
    var questName: String
    var startTime: Date
    var tier: Int

}

//import
//struct StopwatchView: View {
//    var startTime: Date
//
//    var body: some View {
//        TimelineView(.periodic(from: Date(), by: 1.0)) { context in
//            let elapsedTime = context.date.timeIntervalSince(startTime)
//            Text(timeString(from: elapsedTime))
//                .font(.largeTitle)
//        }
//    }
//
//    func timeString(from interval: TimeInterval) -> String {
//        let minutes = Int(interval) / 60
//        let seconds = Int(interval) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
