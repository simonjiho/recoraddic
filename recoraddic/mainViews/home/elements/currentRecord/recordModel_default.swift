//
//  recordModel_default.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/16.
//

import Foundation
import SwiftUI

// 잠금기능 UI와 데이터의 동기화, record,group,quest 단위 조심

// 이미지적 요소는 모두 내부의 customized view 안에 구현
// 위치세팅(여백, 정렬, 세부 위치)는 실제 구현 시

struct RecordModel_default: View {
    
    var data: Record
//    var model: any RecordModelProtocol
//    var figures: [String: (Any) -> any View]
//    var positions: RecordModelPos
    var groupsData: [Group]
    
    
//    var recordCombo: any View
//    var recordProgress: any View
//    var recordLockButton: any View
//    var recordTermProgress: any View
    
    struct RecordName: View {
        var name: String
        init(_ name: String) { self.name = name}
        var body: some View {
            Text(name)
        }
    }
    
    struct RecordBackground: View {
        var body: some View {
            Rectangle()
                .fill(Color(red: 0.9, green: 0.7, blue: 0.7))
//            Image(CGImage., scale: <#T##CGFloat#>, label: <#T##Text#>)
        }
            
    }
    //        recordCombo = figures.recordCombo
    //        recordProgress = figures.recordProgress
    //        recordLockButton = figures.recordLockButton
    //        recordTermProgress = figures.recordTermProgress
    
    // 음.. 이 안에 다 만들까 아니면 group 따로 quest 따로 만들까......
    
    
    init(_ data: Record) {
        self.data = data
        groupsData = data.groups

        
    }
    
    
    var body: some View {
        ScrollView {
            ZStack {
                RecordBackground()
                VStack {
                    RecordName(data.name)
                    ForEach(groupsData, id:\.name) { group in
                        GroupView_default(group)
                            .padding(10)
//                            .overlay(Circle())
                    }
                    Spacer().frame(height: 50)
                }
            }
        }
        
    }
    
}





struct GroupView_default: View {
    var groupData: Group
    var items: [Goal]
    
    struct GroupName : View {
        var name: String
        init(_ name: String) { self.name = name}
        var body: some View {
            Text(name)
        }
    }
    
    struct GroupBackground: View {
        var body: some View {
            Rectangle()
                .fill(Color(red: 0.7, green: 0.9, blue: 0.8))
//            Image(CGImage., scale: <#T##CGFloat#>, label: <#T##Text#>)
        }
    }
    
//    struct GroupCombo: View {}
//    struct GroupProgress: View {}
//    struct GroupLockbutton: View {}
    
    
    init(_ input: Group) {
        groupData = input
        items = groupData.goals
    }
    
    var body: some View {
        ZStack {
            GroupBackground()
            VStack {
                GroupName(groupData.name)
                    .padding(10)
                ForEach(items, id: \.name) { item in
                    GoalView(item)
                }
                Spacer(minLength: 10.0)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 20))

    }
}





struct GoalView: View {
    @State var locked: Bool = true
    var goalData: Goal
    
    struct QuestName: View {
        var name: String
        init(_ name: String) { self.name = name}
        var body: some View {
            Text(name)
        }
    }
    struct QuestCombo: View {
        var combo: Int
        init(_ combo:Int) { self.combo = combo }
        var body: some View {
            ComboStone_default(combo)
        }
        
    }
    struct QuestProgress: View {
        var progress: Float
        init(_ progress:Float) {self.progress = progress}
        var body: some View {
            ProgressView(value: progress)
        }
    }
    
    struct QuestLockbutton: View {
        @State var locked: Bool = true
        init(_ locked: Bool) { self.locked = locked }
        var body: some View {
            Button(action: { toggleLock() }) {
                locked ? Image(systemName: "lock") : Image(systemName: "lock.open")
            }
        }
        
        func toggleLock() {
//            goalData.option.changeLockState()
            locked.toggle()
        }
        
    }
            
    struct QuestStatisticsButton: View {
        @State var statistics: Bool = false
        var body: some View {
            Button(action: { showStatistics() }) {
                Image(systemName: "chart.bar.xaxis")
            }
        }
    
        func showStatistics() {
            statistics.toggle()
            //show new view
        }
        
    }
    
//    struct QuestStatisticsContent: View {}
    
    
    
    init(_ input: Goal) {
        goalData = input
        locked = goalData.option.lock
//        print(goalData.name)
    }
    
    var body: some View {
            HStack(spacing: 5) {
                QuestName(goalData.name).frame(width:100)
                    .padding(10)
                QuestProgress(goalData.metaData.process)
                HStack {
                    QuestCombo(goalData.metaData.combo)
                    QuestLockbutton(locked)
                }
            }
            .padding(.horizontal,30)
            .frame(alignment: .center)
            
    }
}
    

    

