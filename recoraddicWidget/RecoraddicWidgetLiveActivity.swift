//
//  recoraddicWidgetLiveActivity.swift
//  recoraddicWidget
//
//  Created by 김지호 on 7/9/24.
//

import ActivityKit
import WidgetKit
import SwiftUI
//import UIKit

struct RecoraddicLiveActivityView: View {
  
    var questName: String
    var startTime: Date
    var tier: Int
    var goal: Int?
    
    var body: some View {
        VStack(alignment:.center) {
            Text(questName)
                .foregroundStyle(getDarkTierColorOf(tier: tier))
                .font(.title2)
                .bold()
            Text(startTime, style: .timer)
                .foregroundStyle(getDarkTierColorOf(tier: tier))
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
        }
        .containerRelativeFrame(.horizontal, alignment: .center)
//        HStack(alignment:.center) {
//            Text(questName)
//                .foregroundStyle(getDarkTierColorOf(tier: tier))
//                .font(.title3)
//                .bold()
//            Text(startTime, style: .timer)
//                .foregroundStyle(getDarkTierColorOf(tier: tier))
//                .font(.title3)
//                .bold()
//        }
//        .multilineTextAlignment(.center)
//        .containerRelativeFrame(.horizontal, alignment: .center)
//        .frame(alignment: .center)
        

    }
    
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RotatingRectangleView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        RotatedShape(shape: Rectangle(), angle: Angle(degrees: rotationAngle))
            .fill(Color.blue)
            .frame(width: 30, height: 30)
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
    }
}

struct RecoraddicWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecoraddicWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            let questName = context.attributes.questName
            let startTime = context.attributes.startTime
            let tier = context.attributes.tier
            let goal = context.state.goal
            RecoraddicLiveActivityView(
                questName: questName,
                startTime: startTime,
                tier: tier,
                goal: goal
            )
            .activityBackgroundTint(getTierColorOf(tier: tier))
//            .activitySystemActionForegroundColor(getDarkTierColorOf(tier: tier))

        } dynamicIsland: { context in

            DynamicIsland {
                let questName = context.attributes.questName
                let startTime = context.attributes.startTime
                let tier = context.attributes.tier
                let goal = context.state.goal
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                expandedContent(questName: questName, startTime: startTime, tier: tier, goal: goal)
            } compactLeading: {

                Image(systemName:"stopwatch.fill")
                    .foregroundStyle(getTierColorOf(tier: context.attributes.tier))

            } compactTrailing: {
//                Text(context.attributes.startTime, style: .offset)
                Text(context.attributes.startTime, style: .timer)
//                    .frame(width: UIScreen.mai)
//                    .frame(width: self.window?.windowScene?.screen.bounds.width ?? 0.0)
                    .frame(width: 60) //MARK: style을 정하면 text의 가변적인 길이를 고려하여 기본 frame길이는 넉넉하게 잡힌다. 그런데 너무 길게 잡히는 것이 문제이다. 그래서 일단 강제로 크기를 고정시켰다
                    .foregroundStyle(getTierColorOf(tier: context.attributes.tier))
                    .border(.red)
//                    .font(.title3)
//                    .bold()
                    .multilineTextAlignment(.center)
                    .clipped()
                
            } minimal: {
//                Image("fire1_frame1")
                Image(systemName:"stopwatch.fill")
                    .foregroundStyle(getTierColorOf(tier: context.attributes.tier))
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
    
    
    @DynamicIslandExpandedContentBuilder
    private func expandedContent(questName: String, startTime: Date, tier: Int, goal: Int?) -> DynamicIslandExpandedContent<some View> {
//        DynamicIslandExpandedRegion(.leading) {
//
//        }
//        
//        DynamicIslandExpandedRegion(.trailing) {
//            Text("fire")
//                .font(.headline)
//        }
        
        DynamicIslandExpandedRegion(.center) {
            Text(questName)
                .font(.title2)
                .bold()
                .foregroundStyle(getTierColorOf(tier: tier))
        }
        DynamicIslandExpandedRegion(.bottom) {
            VStack {
                Text(startTime, style: .timer)
                    .foregroundStyle(getTierColorOf(tier: tier))
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                //                StopwatchView(startTime: startTime)
//                ProgressView(value: progress(from: endTime), total: 1.0)
//                    .progressViewStyle(LinearProgressViewStyle())
//                    .tint(progress(from: endTime) <= 0.2 ? Color.red : Color.green)
//                Text("Time remaining")
//                    .font(.caption)
            }
        }
    }

        
    
}

//extension RecoraddicWidgetAttributes {
//    fileprivate static var preview: RecoraddicWidgetAttributes {
//        RecoraddicWidgetAttributes(name: "World")
//    }
//}

//extension RecoraddicWidgetAttributes.ContentState {
//    fileprivate static var smiley: RecoraddicWidgetAttributes.ContentState {
//        RecoraddicWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: RecoraddicWidgetAttributes.ContentState {
//         RecoraddicWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}

//#Preview("Notification", as: .content, using: RecoraddicWidgetAttributes.preview) {
//   RecoraddicWidgetLiveActivity()
//} contentStates: {
//    RecoraddicWidgetAttributes.ContentState.smiley
//    RecoraddicWidgetAttributes.ContentState.starEyes
//}
