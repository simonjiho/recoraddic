//
//  BuildDailyRecordStoneView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/09/23.
//

import Foundation
import SwiftUI
import SceneKit

struct BuildDailyRecordStoneView: View {
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record
    
    @State var steps: Int = 0
    @State var isCubeRotate: Bool = false
    
    @State var progressValue: Float = 0.5
    
    @State var dailyRecord_notModel: DailyRecord_notModel = DailyRecord_notModel(date:.now)


    
    var body: some View {
        
        VStack {
            DailyRecordStoneContainerView(isCubeRotate:$isCubeRotate)
            ProgressBarView(value: progressValue)
                .frame(width:320, height: 30)
            if steps == 0 {
                HowWasYourDayView(currentRecord: currentRecord, dailyRecord_notModel: $dailyRecord_notModel, isCubeRotate: $isCubeRotate)
                    .onAppear() {
                        print(dailyRecord_notModel.dailyAccomplishment == nil)
                        dailyRecord_notModel.getData(record: currentRecord)
                    }

            }
            else if steps == 1 {
                if !dailyRecord_notModel.isDataLoaded {
                    Text("loading data...")
                    ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                }
                else {
                    Text("계획했던 퀘스트는 얼마나 했나요?")
                    QuestAccomplishmentView(currentRecord: currentRecord, dailyRecord_notModel: dailyRecord_notModel)
                }
                
            }
            else if steps == 2 {
                // step2.5
                // 내가 원하는 하루를 살았나요?
                // 효율성? 만족?
            }
            else if steps == 3 {
                // step3. pictures & comments
                // selection: 소감 / 일기 / 한줄평 / 감정 / 오늘 잘된 이유 / 오늘 잘 안된 이유 / 다짐 / 피드백 / 즐거웠던 일 / 인상깊었던 일 / 기억하고 싶은 일
                
            }
            else if steps == 4 {
                // step4. get record stone (should be distinct View from this?)
                // no.1 부터 no.300까지의 random한 noncustom outfit 제공(도감 제공: 각 종류별로 성취도에 따른 shape 도감도 존재)
                // 모든 dailyStone은 소중합니다. 당신의 소중한 일부에요. 성취도0은 발전가능성이 무궁무진한 원석이라는 것이고, 성취도10은 정말 잘 하고 있는 보석같은 존재라는 것.
            }
            
            HStack {
                Button(action: {
                    steps -= 1
                }) {
                    Text("previous")
                }.disabled(steps <= 0)
                Button(action: {
                    steps += 1
                }) {
                    Text("next")
                }.disabled(steps >= 4)
            }
            Spacer()
            
        }.background(Color.gray)
            .frame(width: 400, height: 400)
//            .onAppear() {
//                dailyRecord.getData()
//            }
        
    }
}


struct ProgressBarView: View {
    var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))

                Rectangle().frame(width: CGFloat(self.value)*geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemTeal))
//                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}


struct HowWasYourDayView :View {
    
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record!
    
    @Binding
    var dailyRecord_notModel: DailyRecord_notModel
    
    @State private var selectedItems = Set<String>()
    let data = (1...100).map { "face \($0)" }
    @Binding var isCubeRotate: Bool
    
    var body: some View {
        VStack {
            Text("오늘 하루는 어땠나요?")
            Spacer()
                .frame(height:60)
            ScrollView{
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(data, id: \.self) { item in
                        Text(item)
                            .padding()
                            .frame(width:50)
                            .background(selectedItems.contains(item) ? Color.blue : Color.clear)
                            .foregroundColor(selectedItems.contains(item) ? .white : .black)
                            .border(Color.black, width: /* border width */ 1)
                            .onTapGesture {
                                

                                if selectedItems.contains(item) {
                                    selectedItems.remove(item)
                                }
                                
                                else {
                                    if selectedItems.count < 3 {
    
                                        if isCubeRotate {
                                            DispatchQueue.main.asyncUnsafe {
                                                isCubeRotate = false
                                            }
                                            DispatchQueue.main.asyncAfterUnsafe(deadline:.now()+0.1) {
                                                isCubeRotate = true
                                            }
                                        }
                                        else {
                                            isCubeRotate = true
                                        }
                                        
                                        selectedItems.insert(item)
                                    }
                                }
                                
                            }
                    }
                }
            }.background(Color.yellow)

        }

    }
}


struct QuestAccomplishmentView: View {
    
    // homeview 와는 다른 독립적인, 심플하지만 강력한 UI
    
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record!

    
    @Bindable
    var dailyRecord_notModel: DailyRecord_notModel

    
    var body: some View {
        Text("how")
        List {
            ForEach(dailyRecord_notModel.dailyAccomplishment!.purposeNames, id:\.self) { purposeName in
                VStack {
                    Text(purposeName)
                    ForEach(dailyRecord_notModel.dailyAccomplishment!.questNames[purposeName]!, id:\.self) { questName in
                        HStack {
                            Text(questName)
//                            dailyRecord_notModel.dailyAccomplishment!.questDailyGoals[questName]
                        }
//                        var questNames: [String:[String]] = [:]
//                        var questDailyGoals: [String:Float] = [:]
//                        var questIsCheckingDate: [String:Bool] = [:]
//                        var questDataTypes: [String:Int] = [:]
//                        var questInputDatas: [String:Int] = [:]
                    }
                }
            }
        }
        
        
    }
}


struct QuestRecorder: View {
    
    @Binding private var current: CGFloat
    
    let minValue = 0.0
    let maxValue = 100.0

    var body: some View {
        VStack {
            Gauge(value: current, in: minValue...maxValue) {
                Text("Gauge")
            }
            currentValueLabel: {
                Text("\(Int(current))")
            }
            minimumValueLabel: {
                Text("\(Int(minValue))")
            }
            maximumValueLabel: {
                Text("\(Int(maxValue))")
            }
            .gaugeStyle(.accessoryCircular)

            CustomSlider(value: $current, range: minValue...maxValue)
        }
    }
}


struct CustomSlider: View {

    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    @State private var xOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: xOffset)
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .offset(x: xOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let translation = value.translation
                                let sliderPos = max(0, min(lastOffset + translation.width, geometry.size.width - 30))
                                let sliderVal = sliderPos.map(from: 0...(geometry.size.width - 30), to: range)
                                xOffset = sliderPos
                                self.value = sliderVal
                            }
                            .onEnded { _ in
                                lastOffset = xOffset
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}

extension CGFloat {
    func map(from source: ClosedRange<CGFloat>, to target: ClosedRange<CGFloat>) -> CGFloat {
        return target.lowerBound + (self - source.lowerBound) * (target.upperBound - target.lowerBound) / (source.upperBound - source.lowerBound)
    }
}


struct DailyRecordStoneContainerView : View {
    @Binding var isCubeRotate: Bool
    var body: some View {
        ZStack {
            Spacer()
                .frame(width: 400, height: 120)
                .background(Color.gray)
            SceneKitView(isCubeRotate: $isCubeRotate)
                .frame(width:100, height: 100, alignment: .center)
        }

    }
}


struct SceneKitView: UIViewRepresentable {
    
    @Binding var isCubeRotate: Bool
    
    let boxRotate:SCNAction = {
        let action = SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.8)
        action.timingMode = .easeInEaseOut
        return action
    } ()
    
    func makeUIView(context: Context) -> SCNView {
        let scene = SCNScene()
        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true

        // Create a box
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.05)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor.red
        box.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(boxNode)

        // Create a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 2, y: 2, z: 2)
        scene.rootNode.addChildNode(cameraNode)

        // Create a look-at constraint
        let constraint = SCNLookAtConstraint(target: boxNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if isCubeRotate {
//            let action = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 2)
            uiView.scene?.rootNode.childNodes.first?.runAction(boxRotate) {
                DispatchQueue.main.async {
                    self.isCubeRotate = false
                }
            }

        } else {
            uiView.scene?.rootNode.childNodes.first?.removeAllActions()
        }
        
        
//        if isCubeRotate {
//            uiView.scene?.rootNode.childNode(withName: "boxNode", recursively: true)?.runAction(boxRotate)
//            isCubeRotate = false
//            
//        }
    
    }
}

