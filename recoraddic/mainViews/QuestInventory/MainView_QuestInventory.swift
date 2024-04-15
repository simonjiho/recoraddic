//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI
import SwiftData

struct MainView_QuestInventory: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort:\Quest.momentumLevel) var quests:[Quest]
    
    var notHiddenQuests: [Quest] {
        quests.filter({quest in !(quest.isHidden)})
    }
    
//    @State var chooseQuestToHide:Bool = false
    
    enum StatisticOption {
        case quest
        case defaultPurpose
    } // add customPurpose later
    
    
    
    @State var selectedQuest: Quest?
    @State var popUp_questStatisticsInDetail: Bool = false
    
    @State var popUp_addNewQuest: Bool = false
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height

            let gridItemSize = geoWidth/3 * 0.78
            let gridItemSpacing = gridItemSize*0.3
            
            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let shadowColor: Color = getShadowColor(colorScheme)
//            let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
            ZStack {
                VStack {
//                    Picker("", selection: $statisticOption) {
//                        Text("퀘스트").tag(StatisticOption.quest)
//                        Text("성향").tag(StatisticOption.defaultPurpose)
//                    }
//                    .frame(height: geometry.size.height*0.1)
                    Text("퀘스트 보관함")
                        .font(.title3)
                        .bold()
                        .fontDesign(.serif)
                        .frame(height: geoHeight*0.1)
                    
                        ZStack {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum:gridItemSize))], spacing: gridItemSpacing) {
                                    ForEach(notHiddenQuests,id:\.createdTime) { quest in
                                        
                                        
                                        Button(action:{
                                            selectedQuest = quest
                                            popUp_questStatisticsInDetail.toggle()
                                        }) {
                                            QuestThumbnailView(quest: quest)
                                                .frame(width: gridItemSize, height: gridItemSize)
                                        }
                                        .contextMenu(ContextMenu(menuItems: {
                                            Button("숨기기") {
                                                quest.isHidden = true
                                            }
                                        }))
                    
                                        
                                        
                                        
                                    }
                                    
                                    
                                    // TODO: plus button
                                    Button(action: {
                                        popUp_addNewQuest.toggle()
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .resizable()
                                            .frame(width: gridItemSize*0.4, height: gridItemSize*0.4)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    
                                    
                                } // lazyVGrid
                                .padding(.top, gridItemSpacing)
                                
                            } // ScrollView
                            .frame(width:geometry.size.width, height: geometry.size.height*0.9)
                            

                            if quests.filter({!$0.isHidden}).isEmpty {
                                VStack {
                                    Text("반복적으로 해야 할 일을 퀘스트로 생성하고 ")
                                    HStack {
                                        Image(systemName: "checklist.checked")
                                            .bold()
                                        Text("체크리스트")
                                            .bold()
                                        Text("에 추가해보세요!")
                                        
                                    }
                                }
                                .foregroundStyle(.opacity(0.5))
                            }
                        }
                        .frame(width:geometry.size.width, height: geometry.size.height*0.9)
                        
                    

                    
                } // VStack
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .sheet(isPresented: $popUp_questStatisticsInDetail, onDismiss: {selectedQuest = nil}) {
                    QuestStatisticsInDetail(
                        selectedQuest: $selectedQuest,
                        popUp_questStatisticsInDetail: $popUp_questStatisticsInDetail
                    )
                }
                if popUp_addNewQuest {
                    Color.gray.opacity(0.2)
                        .onTapGesture {
                            popUp_addNewQuest.toggle()
                            
                        }
                    CreateNewQuest(popUp_createNewQuest: $popUp_addNewQuest)
                        .popUpViewLayout(width: geoWidth*0.9, height: geoHeight*0.45, color: colorSchemeColor)
                        .position(CGPoint(x: geoWidth/2, y: geoHeight/2*0.7))
                        .shadow(color:shadowColor, radius: 3.0)
                }
            }
        } // geometryRecord
        

    }
    
}


struct QuestTierView: View {
    
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.modelContext) var modelContext
    
    @Binding var tier: Int
    
    let iron = Color.black.adjust(brightness: 0.5)
    let bronze = Color.brown.adjust(brightness: 0.0)
    let silver = Color.gray.adjust(brightness:0.2) //
    let gold = Color.brown.adjust(brightness:0.37) //
    let platinum = Color.blue.adjust(saturation:-0.5, brightness:0.5) //
    let diamond = Color.cyan.adjust(saturation:-0.57, brightness:0.2) //
    let master = Color(red: 0.3, green: 0.5, blue: 1.0).adjust(brightness:0) //
    let superMaster = Color(red: 0.46, green: 0.4, blue: 0.9).adjust(brightness:0.7)
    let grandMaster = Color.gray.adjust(brightness:0.25) // 무지개
    
    var body: some View {
        
        let shadowColor:Color = getShadowColor(colorScheme)
        
        let tierColor:Color = {
            switch tier/5 {
            case 0:
                return iron
            case 1:
                return bronze
            case 2:
                return silver
            case 3:
                return gold
            case 4:
                return platinum
            case 5:
                return diamond
            case 6:
                return master
            case 7:
                return superMaster
            case 8:
                return grandMaster
            default:
                return Color.black
            }
            
        }()
        
        let nextTierColor: Color = {
            switch tier/5 {
            case 0:
                return bronze
            case 1:
                return silver
            case 2:
                return gold
            case 3:
                return platinum
            case 4:
                return diamond
            case 5:
                return master
            case 6:
                return superMaster
            case 7:
                return grandMaster
            case 8:
                return grandMaster
            default:
                return Color.black
            }
            
        }()
        
        
        
        let tierColor_bright:Color = tier/5 != 4 ? tierColor.adjust(brightness: 0.2) : tierColor.adjust(brightness: 0.35)
        let tierColor_frame1:Color = tierColor_bright.adjust(brightness: 0.05)
        let tierColor_frame2:Color = tierColor.adjust(brightness: -0.05)
        
        let currentTierColor_frame:Color = tierColor.adjust(brightness: 0.1)
        let nextTierColor_frame:Color = nextTierColor.adjust(brightness: 0.1)
        //        let nextTierColor_frame2:Color = tierColor.adjust(brightness: -0.05)
        
        let colorsForGradient: [Color] = {
            switch tier%5 {
            case 0:
                return [tierColor_frame1, tierColor_frame2, tierColor_frame1, tierColor_frame2, tierColor_frame1]
            case 1:
                return [tierColor_frame1, tierColor_frame2, tierColor_frame1, tierColor_frame2, tierColor_frame1]
            case 2:
                return [tierColor_frame1, tierColor_frame2, tierColor_frame1, tierColor_frame2, tierColor_frame1]
            case 3:
                return [tierColor_frame1, tierColor_frame2, tierColor_frame1, tierColor_frame2, tierColor_frame1]
            case 4:
                return [currentTierColor_frame, nextTierColor_frame, currentTierColor_frame, nextTierColor_frame, currentTierColor_frame]
            default:
                return [tierColor_frame1, tierColor_frame2, tierColor_frame1, tierColor_frame2, tierColor_frame1]
            }
        }()
        
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let strokeWidth: CGFloat = {
                switch tier%5 {
                case 0:
                    return 0.0
                case 1:
                    return geoWidth*0.04
                case 2:
                    return geoWidth*0.06
                case 3:
                    return geoWidth*0.09
                case 4:
                    return geoWidth*0.09
                default:
                    return 0.0
                }
            }()
            
            let tierViewFrame: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/20, cornerHeight: geoHeight/20, transform: nil))
//            let strokeLineWidth:CGFloat = geoWidth*0.04*(0.5 * CGFloat(tier%5))

            
            ZStack {
                tierViewFrame
                    .fill(LinearGradient(colors: [tierColor, tierColor_bright, tierColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                RotatingGradient(level: tier%5, colors: colorsForGradient)
                    .frame(width:(geoWidth+strokeWidth*2)*1.5, height: (geoHeight+strokeWidth*2)*1.5)
                    .position(x:geoWidth/2, y:geoHeight/2)
                    .mask {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .stroke(lineWidth: strokeWidth)
                            .frame(width:geoHeight+strokeWidth/2, height: geoHeight+strokeWidth/2)
                    }
//                tierViewFrame
//                    .stroke(lineWidth: strokeLineWidth)
//                //                .fill(background)
//                    .fill(LinearGradient(colors: [tierColor_bright,  tierColor,tierColor_bright], startPoint: .bottomTrailing, endPoint: .topLeading))
                // stroke밝기를 라이트 다크모드에 따라 다르게?
                
                
            }
            .frame(width: geoWidth, height: geoHeight)
            .shadow(color: shadowColor, radius: 1)


        }
        
    }
}




struct QuestThumbnailView: View {
    
    @Environment(\.modelContext) var modelContext

    @State var quest: Quest

    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemSize = geoWidth
            
            ZStack {
                QuestTierView(tier: $quest.tier)
                    .frame(width: geoWidth, height: geoHeight)
                FireView(momentumLevel: quest.momentumLevel)
                //                                        Fire6()
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                //                                            .opacity(0.7)
                VStack {
                    Text("\(quest.name)")
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(2)
                        .padding(.bottom, geoHeight/10)
                    
                    //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                    
                    Text(quest.representingDataToString())
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    
                }
                .padding(10)
                .frame(width:geoWidth ,height: geoHeight, alignment: .center)
                .onAppear() {
                    print("\(quest.name): tier \(quest.tier)")
                }
                
            }
        }
    }
}

struct CreateNewQuest: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    @Query var quests: [Quest]
        
    @Binding var popUp_createNewQuest: Bool
    // isPlan, popUp
    
    @State var questNameToAppend = ""
    @State var questDataTypeToAppend = DataType.OX
    @State var customDataTypeNotation: String?
    @State var customDataTypeNotation_textField: String = ""
    
    @FocusState var initialInputPos: Bool
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        GeometryReader { geometry in
            
            
            
            let textBoxWidth = geometry.size.width * 0.3
            let textBoxHeight = geometry.size.height * 0.15
            let messageBoxHeight = geometry.size.height * 0.1
            
            let contentHeight = geometry.size.height*0.9
            
            
            ZStack {
                VStack(alignment: .leading) {
                    Button(action:{
                        popUp_createNewQuest.toggle()
                    }) {
                        Image(systemName: "xmark")
                    }
                        .frame(width:geometry.size.width*0.975, alignment: .trailing)
                    Text("새로운 퀘스트")
                        .frame(width:geometry.size.width, alignment: .center)
                        .font(.title3)
                        .padding(.vertical,10)
                    
                    HStack {
                        Text("이름:")
                            .frame(width:textBoxWidth,alignment: .trailing)
                        TextField("새로운 퀘스트 이름", text:$questNameToAppend)
                            .maxLength(30, text: $questNameToAppend)
                            .focused($initialInputPos)
//                            .shadow(radius: 1)
                        
                    }
                    //                                .frame(height: textBoxHeight)
                    
                    HStack {
                        Spacer()
                            .frame(width:textBoxWidth)
                        
                        if questNameToAppend == "" {
                            Text("퀘스트 이름을 입력하세요")
                                .foregroundStyle(.red)
                                .font(.caption)
                            
                        }
                        else if quests.contains(where: {quest in quest.name == questNameToAppend}) {
                            ResizableText_Width(text:"퀘스트 이름이 이미 존재합니다.", width:geometry.size.width*0.5)
                                .foregroundStyle(.red)
                                .font(.caption)
                            
                        }
                    }
                    
                    HStack {
                        Text("단위:")
                            .frame(width:textBoxWidth,alignment: .trailing)
                        Picker("", selection: $questDataTypeToAppend) {
                            ForEach(recoraddic.defaultDataTypes, id:\.self) {
                                Text(DataType.kor_stringOf(dataType: $0))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }

                    }
                    // MARK: 계획수치 또는 달성수치

                    if questDataTypeToAppend == DataType.CUSTOM {
                        HStack {
                            VStack {
                                
                            }
                            Text("사용자 지정 단위:")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width:textBoxWidth,alignment: .trailing)
                            TextField("ex: 물 마신 양 기록 -> mL",text: $customDataTypeNotation_textField)
                                .onChange(of: customDataTypeNotation_textField) {
                                    customDataTypeNotation = customDataTypeNotation_textField
                                }
                        }
                    }

                            
                            
                            
                    
                    
                    // MARK: 목적
                    
                    Button(action: {
                        createNewQuest()
                        popUp_createNewQuest.toggle()

                    } ) {
                        Text("생성")
                    }
                    .buttonStyle(.bordered)
                    .padding(.top,10)
                    .disabled(
                        (
                            quests.contains(where: {quest in quest.name == questNameToAppend}) || (questDataTypeToAppend == DataType.CUSTOM && (customDataTypeNotation == "" || customDataTypeNotation == nil)) ||
                            questNameToAppend == "")
                        
                    )
                    .frame(width:geometry.size.width, alignment: .center)
                    
                    
                } // Vstack
                .frame(width:geometry.size.width, height:contentHeight, alignment: .top)
                
                
                

                
                
            }// Zstack
            .frame(width:geometry.size.width, height: contentHeight)
            .onAppear() {
                initialInputPos = true
            }
            
        }
    }
    
    func createNewQuest() -> Void {
        let newQuest = Quest(name: questNameToAppend, dataType: questDataTypeToAppend)
        if questDataTypeToAppend == DataType.CUSTOM {
            newQuest.customDataTypeNotation = customDataTypeNotation
        }
        modelContext.insert(newQuest)
    }
    
    
}



struct PurposeInventoryView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}


//let sampleQuest = {
//    let workOut = Quest(name: "운동", dataType: DataType.HOUR)
//    workOut.dailyData = [Date():1000]
//    workOut.tier = 20
//    workOut.momentumLevel = 10
//    return workOut
//}()
//

struct QuestThumbnailView_forPreview: View {
    
    var name: String
    var tier: Int
    var momentumLevel: Int
    var cumulativeVal: String
    var unitNotation: String

    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemSize = geoWidth
            
            ZStack {
                QuestTierView(tier: .constant(tier))
                    .frame(width: geoWidth, height: geoHeight)
                FireView(momentumLevel: momentumLevel)
                //                                        Fire6()
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                //                                            .opacity(0.7)
                VStack {
                    Text("\(name)")
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(2)
                        .padding(.bottom, geoHeight/10)
                    
                    //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                    
                    Text("\(cumulativeVal)\(unitNotation)")
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    
                }
                .padding(10)
                .frame(width:geoWidth ,height: geoHeight, alignment: .center)
                .onAppear() {
//                    print("\(name): tier \(tier)")
                }
                
            }
        }
    }
}
//
//#Preview(body: {
//    QuestThumbnailView_forPreview(
//        name: "운동",
//        tier: 23,
//        momentumLevel: 7,
//        cumulativeVal: "1000.0",
//        unitNotation: "시간")
//        .frame(width: 100, height: 100)
//})


struct RotatingGradient: View {
    @State private var isRotating = false
    let level: Int
    let colors: [Color]

    var body: some View {
        // 10 7 5 3.5 1
//        let duration: CGFloat = 5/(CGFloat(level)+4.0) * 3.0
        let duration: CGFloat = {
            switch level {
            case 1:
                return 8
            case 2:
                return 4
            case 3:
                return 2.5
            case 4:
                return 1.5
            default: return 1.0
            }
        }()

        
        Circle()
            .fill(
                AngularGradient(gradient: Gradient(colors: colors), center: .center)
            )
            .scaleEffect(0.9)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(Animation.linear(duration: duration).repeatForever(autoreverses: false))
            .onAppear() {
                self.isRotating = true
            }
    }
}

//struct BorderView: View {
//    let level: Int
//    var body: some View {
//        GeometryReader { geometry in
//            
//            let geoWidth: CGFloat = geometry.size.width
//            let geoHeight: CGFloat = geometry.size.height
//            let strokeWidth: CGFloat = {
//                switch level {
//                case 0:
//                    return 0.0
//                case 1:
//                    return geoWidth*0.04
//                case 2:
//                    return geoWidth*0.06
//                case 3:
//                    return geoWidth*0.09
//                case 4:
//                    return geoWidth*0.12
//                default:
//                    return 0.0
//                }
//            }()
////            let strokeWidth: CGFloat = geoWidth*0.03*CGFloat(level)
//            RotatingGradient(level: level)
//                .frame(width:(geoWidth+strokeWidth*2)*1.5, height: (geoHeight+strokeWidth*2)*1.5)
//                .position(x:geoWidth/2, y:geoHeight/2)
//                .mask {
//                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
//                        .stroke(lineWidth: strokeWidth)
//                        .frame(width:geoHeight+strokeWidth/2, height: geoHeight+strokeWidth/2)
//                }
//                .border(.red)
//        }
//    }
//}
