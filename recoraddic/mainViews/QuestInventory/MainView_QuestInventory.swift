//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI
import SwiftData

enum QuestEditOption {
    case archive
    case hide
    case delete
}


struct MainView_QuestInventory: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Query var quests:[Quest]
    
    @Binding var selectedView: MainViewName
    
//    @State var chooseQuestToHide:Bool = false
    
    enum StatisticOption {
        case quest
        case defaultPurpose
    } // add customPurpose later
    
    @State var selectedQuest: Quest?
    @State var selectedQuest2: Quest = Quest(name: "", dataType: 0)
    @State var popUp_questStatisticsInDetail: Bool = false
    
    @State var popUp_addNewQuest: Bool = false
    @State var popUp_help: Bool = false
    @State var popUp_confirmation: Bool = false
    @State var editConfirmed: Bool = false
    @State var isEdit: Bool = false
    @State var selectedQuestNames: Set<String> = []
    
    @State var editOption: QuestEditOption?
    
    @State var editQuestInfo: Bool = false
    
    @State var popOver_changePurpose: Bool = false
    
    // @State enum -> 보관 / 숨기기 / 휴지통 하시겠습니까? -> enum에 따른 함수 구분해서 바꿔주기
    
    var body: some View {
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let quest_sorted_visible = quests.filter({$0.isVisible()}).sorted(by: {
            if $0.momentumLevel != $1.momentumLevel {
                return $0.momentumLevel > $1.momentumLevel
            } else if $0.tier != $1.tier {
                return $0.tier > $1.tier
            } else {
                return $0.createdTime > $0.createdTime
            }
        })
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height

            let gridHorizontalPadding = geoWidth*0.02
            let gridInnerPadding = geoWidth * 0.02
            let gridViewFrameWidth = geoWidth - gridHorizontalPadding*2 - gridInnerPadding*2
            let gridWidth = questThumbnailWidth(dynamicTypeSize, defaultWidth: (gridViewFrameWidth) / 2) * 0.97
            let gridHeight = gridWidth / 1.618
            let gridItemWidth = gridWidth * 0.92
            let gridItemHeight = gridHeight * 0.92
//            let gridItemSpacing = gridItemWidth*0.3
            let gridVerticalSpacing = gridWidth*0.06
        
            let topBarTopPadding = geoHeight*0.035
            let topBarSize = geoHeight*0.05
            let topBarBottomPadding = geoHeight*0.005
            
            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let shadowColor: Color = getShadowColor(colorScheme)
            ZStack {
                NavigationView {
                    VStack {
                        ZStack {
                            HStack(spacing:0.0) {
                                //                            if !isEdit {
                                Text_scaleToFit("누적 퀘스트 목록")
                                    .bold()
                                    .fontDesign(.serif)
                                    .padding(.trailing, 10)
                                
                                Button("", systemImage: "flame.circle", action: {
                                    popUp_help.toggle()
                                })
//                                .buttonStyle(.plain)

                            }
                            Button(isEdit ? "취소" : "편집") {
                                isEdit.toggle()
                                resetEditData()
                            }
                            .frame(width: geoWidth*0.95, alignment: .trailing)
                        }
                        .frame(width: geoWidth*0.95, height: topBarSize)
                        .padding(.top,topBarTopPadding)
                        .padding(.bottom,topBarBottomPadding)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                        
                        
                        ZStack {
                            ScrollView {
                                
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridWidth, maximum: gridWidth))], spacing: gridVerticalSpacing) {
                                    ForEach(quest_sorted_visible,id:\.createdTime) { quest in
                                        ZStack {
                                            Button(action:{
                                                if !isEdit {
                                                    selectedQuest = quest
                                                    popUp_questStatisticsInDetail.toggle()
                                                }
                                                else {
                                                    if selectedQuestNames.contains(quest.name) {
                                                        selectedQuestNames.remove(quest.name)
                                                    }
                                                    else {
                                                        selectedQuestNames.insert(quest.name)
                                                    }
                                                }
                                            }) {
                                                QuestThumbnailView_redesigned(quest: quest)
                                                    .frame(width: gridItemWidth, height: gridItemHeight)
                                            }
                                            .contextMenu(ContextMenu(menuItems: {
                                                
                                                Button("정보 수정") {
                                                    selectedQuest = quest
                                                    editQuestInfo.toggle()
                                                    //                                                toggleEditQuestInfo()
                                                }
                                                Button("보관") {
                                                    quest.isArchived = true
                                                }
                                                Button("숨기기") {
                                                    quest.isHidden = true
                                                }
                                                
                                                Button("휴지통으로 이동", systemImage:"trash") {
                                                    quest.inTrashCan = true
                                                    quest.deletedTime = Date()
                                                }
                                                .foregroundStyle(.red)
                                            }))

                                            
                                            if isEdit {
                                                Button(action:{
                                                    if selectedQuestNames.contains(quest.name) {
                                                        selectedQuestNames.remove(quest.name)
                                                    }
                                                    else {
                                                        selectedQuestNames.insert(quest.name)
                                                    }
                                                }) {
                                                    ZStack {
                                                        let path: Path = Path(roundedRect: CGRect(x: 0, y: 0, width: gridItemWidth, height: gridItemHeight), cornerSize: CGSize(width: gridItemWidth/11, height: gridItemWidth/11))
                                                        path
                                                            .stroke(lineWidth: gridItemHeight/15)
                                                        if selectedQuestNames.contains(quest.name) {
                                                            Image(systemName:"checkmark")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width:gridItemWidth*0.6, height: gridItemHeight*0.6)
                                                        }
                                                        
                                                    }
                                                    .frame(width:gridItemWidth, height: gridItemHeight)
                                                    .foregroundStyle(.blue)
                                                    
                                                }
                                            }
                                        }
                                        .frame(width: gridItemWidth, height: gridItemHeight)
                                        .onAppear() {
                                            quest.updateMomentumLevel()
                                        }
                                        .frame(width:gridWidth, height: gridHeight)
                                        //                                        .border(.yellow)
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    // TODO: plus button
                                    if !isEdit {
                                        
                                        NavigationLink(destination: CreateNewQuest(popUp_createNewQuest: $popUp_addNewQuest) .ignoresSafeArea(.keyboard)
                                                       
                                        ){
                                            ZStack {
                                                Image(systemName: "plus")
                                                    .resizable()
                                                    .frame(width: gridItemWidth*0.2, height: gridItemWidth*0.2)
                                            }
                                            .frame(width: gridItemWidth, height: gridItemHeight)
                                            .background(.gray.opacity(0.3))
                                            .clipShape(.rect(cornerSize: CGSize(width: gridItemWidth/11, height: gridItemHeight/11)))
                                            
                                            
                                        }
                                        .buttonStyle(.plain)
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    
                                } // lazyVGrid
                                .frame(width:gridViewFrameWidth)
                                .padding(gridInnerPadding)
                                .padding(.horizontal, gridHorizontalPadding)
                                
                                
                                
                                Spacer()
                                    .frame(height:gridItemHeight*(quest_sorted_visible.count%2 == 0 ? 2 : 3))
                                
                                
                                
                                
                            } // ScrollView
                            .frame(width:geometry.size.width, height: geometry.size.height*0.9)
                            
                            if quests.filter({$0.isVisible()}).isEmpty {
                                VStack {
                                    Text_scaleToFit("반복적으로 해야 할 일을 퀘스트로 생성하고 ")
                                        
                                    HStack {
                                        Image(systemName: "checklist.checked")
                                            .bold()
                                        Text("체크리스트")
                                            .bold() +
                                        Text("에 추가해보세요!")
                                    }
                                    .minimumScaleFactor(0.3)

                                }
                                .foregroundStyle(.opacity(0.5))
                            }
                        }
                        .frame(width:geometry.size.width, height: geoHeight*0.9)
                        
                        
                    } // VStack
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    .background(.quinary)
                    .sheet(isPresented: $popUp_questStatisticsInDetail, onDismiss: {selectedQuest = nil}) {
                        QuestInDetail(
                            selectedQuest: $selectedQuest,
                            popUp_questStatisticsInDetail: $popUp_questStatisticsInDetail
                        )
                        .ignoresSafeArea(.keyboard)
                        .dynamicTypeSize(...DynamicTypeSize.xxLarge)

                    }
                }

                if popUp_help {
                    Color.gray.opacity(0.01)
                        .background(.ultraThinMaterial)
                        .onTapGesture {
                            popUp_help.toggle()
                        }
                    QuestHelpView(popUp_help: $popUp_help)
                        .popUpViewLayout()

                        .position(CGPoint(x: geoWidth/2, y: geoHeight*0.85*0.6))
                        .shadow(color:shadowColor, radius: 3.0)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }

            }
            .onAppear() {print("main: \(geoHeight)")}
            .fullScreenCover(isPresented: $editQuestInfo, onDismiss: {selectedQuest=nil}) {
                EditQuest2(
                    popUp_editQuest: $editQuestInfo,
                    selectedQuest: $selectedQuest
                )

            }
            .sheet(isPresented: $isEdit) {
                    ZStack {
                        Text("\(selectedQuestNames.count)개의 퀘스트 선택")
                        HStack(spacing:0.0) {
                            Button(action:{
                                editOption = .archive
                                popUp_confirmation.toggle()
                            }){Image(systemName: "archivebox")}
                                .frame(width:geoWidth*0.12,alignment: .center)
                                .disabled(selectedQuestNames.count == 0)
                            Button(action:{
                                editOption = .hide
                                popUp_confirmation.toggle()
                            }){Image(systemName: "eye.slash")}
                                .frame(width:geoWidth*0.76, alignment: .leading)
                                .disabled(selectedQuestNames.count == 0)
                            Button(action:{
                                editOption = .delete
                                popUp_confirmation.toggle()
                            }){Image(systemName: "trash")}
                                .foregroundStyle(selectedQuestNames.count == 0 ? .gray : .red)
                                .frame(width:geoWidth*0.12, alignment: .center)
                                .disabled(selectedQuestNames.count == 0)
                        }
                        .sheet(isPresented: $popUp_confirmation) {
                            let questName = (selectedQuestNames.count == 1) ? selectedQuestNames.first! : "\(selectedQuestNames.count)개의 퀘스트"
                            QuestEditConfirmationView2(
                                questName: questName,
                                editOption: $editOption,
                                editConfirmed: $editConfirmed,
                                popUp_self: $popUp_confirmation
                            )
                            .presentationDetents([.height(editOption == .delete ? 200*1.2 : 200)])
                            .presentationBackground(.thickMaterial)
                        }

                    }
                    .presentationDetents([.height(100)])
                    .presentationCornerRadius(0.0)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(100)))
                    .presentationBackground(.thickMaterial)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            }


            .onChange(of: editConfirmed) { oldValue, newValue in
                if newValue == true {
                    if editOption == .archive {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName && !$0.isArchived}).first {
                                targetQuest.isArchived = true
                            }
                        }
                    }
                    else if editOption == .hide {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName && !$0.isHidden}).first {
                                targetQuest.isHidden = true
                            }
                        }
                    }
                    else if editOption == .delete {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName && !$0.inTrashCan}).first {
                                targetQuest.inTrashCan = true
                                targetQuest.deletedTime = Date()
                            }
                        }
                    }
                    

                }
            }
            .onChange(of:popUp_confirmation) { oldValue, newValue in
                if newValue == false {
                    if editConfirmed {
                        isEdit = false
                        resetEditData()
                    }
                }
            }
            .onChange(of: selectedView) {
                popUp_help = false
            }
            

        } // geometryRecord
        

    }
    
    func resetEditData() -> Void {
        selectedQuestNames = []
        editOption = nil
        editConfirmed = false
    }
    
//    func toggleEditQuestInfo() -> Void {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if selectedQuest != nil {
//                editQuestInfo = true
//            } else {
//                toggleEditQuestInfo()
//            }
//        }
//    }
    
}

extension PresentationDetent {
    static let bar = Self.custom(BarDetent.self)
    static let small = Self.height(100)
    static let extraLarge = Self.fraction(0.75)
}


private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.5)
    }
}


struct QuestEditConfirmationView: View {
        
    var questName: String
    
    var editOption: QuestEditOption
    
    @Binding var editConfirmed: Bool
    @Binding var popUp_self: Bool
    
    
    var body: some View {
        
        let question: String = {
            if editOption == .archive {
                return "\(questName) 를 보관하시겠습니까?"
            }
            else if editOption == .hide {
                return "\(questName) 를 숨기시겠습니까?"
            }
            else if editOption == .delete {
                return "\(questName) 를 삭제하시겠습니까?"
            }
            else {
                return ""
            }
        }()
        
        let buttonName = {
            if editOption == .archive {
                return "보관"
            }
            else if editOption == .hide {
                return "숨기기"
            }
            else if editOption == .delete {
                return "삭제"
            }
            else {
                return ""
        }
        }()
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            VStack {
                Text("\(question)")
                if editOption == .delete {
                    Text("(삭제한 누적퀘스트는 휴지통으로 이동됩니다.)")
                }
                HStack {
                    Button("\(buttonName)") {
                        editConfirmed.toggle()
                        popUp_self.toggle()
                    }
                    .frame(width: geoWidth/2)
                    .foregroundStyle(.red)
                    Button("취소") {
                        popUp_self.toggle()
                    }
                    .frame(width: geoWidth/2)
                }
                .padding(.top, geoHeight*0.1)
            }
            .frame(width:geoWidth, height: geoHeight)
        }
    }
}


struct QuestEditConfirmationView2: View {
        
    var questName: String
    
    @Binding var editOption: QuestEditOption?
    
    @Binding var editConfirmed: Bool
    @Binding var popUp_self: Bool
    
    
    var body: some View {
        
        let question: String = {
            if editOption == .archive {
                return "\(questName) 를 보관하시겠습니까?"
            }
            else if editOption == .hide {
                return "\(questName) 를 숨기시겠습니까?"
            }
            else if editOption == .delete {
                return "\(questName) 를 삭제하시겠습니까?"
            }
            else {
                return ""
            }
        }()
        
        let buttonName = {
            if editOption == .archive {
                return "보관"
            }
            else if editOption == .hide {
                return "숨기기"
            }
            else if editOption == .delete {
                return "삭제"
            }
            else {
                return ""
        }
        }()
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let elementHeight = geoHeight * 0.15
            VStack {
                List {
                    Section {
                        VStack(spacing:0.0) {
                            Text("\(question)")
                                .frame(height:elementHeight)
                            if editOption == .delete {
                                Text("(삭제한 누적퀘스트는 휴지통으로 이동됩니다.)")
                                    .frame(height:elementHeight)
                            }
                        }
                        Button("\(buttonName)") {
                            editConfirmed.toggle()
                            popUp_self.toggle()
                        }
                        .foregroundStyle(.red)
                        .frame(height:elementHeight)
                    }
                    Section {
                        Button("취소") {
                            popUp_self.toggle()
                        }
                        .frame(height:elementHeight)
                    }
                }
                .scrollClipDisabled()
                .scrollDisabled(true)
                .listSectionSpacing(ListSectionSpacing.compact)
            }
            .frame(width:geoWidth, height: geoHeight, alignment: .bottom)


                
            
        }
        
    }
        
}


struct QuestTierView: View {
    
    @Environment (\.colorScheme) var colorScheme
    
    var tier: Int
    var notUsedYet: Bool

    
    var body: some View {
        
        
        let tierColor:Color = getTierColorOf(tier: tier)
        
        let nextTierColor: Color = getTierColorOf(tier: tier+5)
        
        
        let tierColor_bright:Color = getBrightTierColorOf2(tier: tier)
        
        
        let tierColor_frame1:Color = tierColor_bright
        let tierColor_frame2:Color = tierColor
        let currentTierColor_frame:Color = tierColor
        let nextTierColor_frame:Color = nextTierColor

        
        let rotationGradientColors: [Color] = {
            switch tier%5 {
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
                    return geoHeight*0.04
                case 2:
                    return geoHeight*0.07
                case 3:
                    return geoHeight*0.10
                case 4:
                    return geoHeight*0.12
                default:
                    return 0.0
                }
            }()
            
            let tierViewFrame: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/11, cornerHeight: geoWidth/11, transform: nil))

            
            
            ZStack {
                tierViewFrame
                    .fill(.white)
                    .opacity(notUsedYet ? 0.0 : 1.0 )
                
                if notUsedYet {
                    tierViewFrame
                        .fill(Color.gray.opacity(0.7))
                } else {
                    tierViewFrame
//                    Rectangle()
                        .fill(LinearGradient(colors: getGradientColorsOf(tier: tier, type:1), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .opacity(colorScheme == .light ? 0.6 : 0.8)

                }
                
                
                if tier % 5 == 4 {
                    let width1:CGFloat = geoWidth+strokeWidth/3
//                    let height1: CGFloat = geoHeight+strokeWidth/3
                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white.opacity(0.7), lineWidth: strokeWidth/3)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                        .rotationEffect(.radians(.pi/36*0.6))

                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white.opacity(0.7), lineWidth: strokeWidth/3)
    //                    .stroke(lineWidth: strokeWidth)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                        .rotationEffect(.radians(-(.pi/36*0.6)))

                }
                if tier % 5 == 3 {
                    let width1:CGFloat = geoWidth+strokeWidth/3
//                    let height1: CGFloat = geoHeight+strokeWidth/3
                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white, lineWidth: strokeWidth/3)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                }
                


                let width2:CGFloat = geoWidth+strokeWidth
//                let height2: CGFloat = geoHeight+strokeWidth
                RotatingGradient(level: tier%5, colors: rotationGradientColors)
                    .frame(width:(geoWidth+strokeWidth*2)*1.5, height: (geoWidth+strokeWidth*2)*1.5)
                    .position(x:geoWidth/2, y:geoHeight/2)
                    .mask {
                        RoundedRectangle(cornerSize: CGSize(width: width2/11, height: width2/11))
                            .stroke(lineWidth: strokeWidth)
                            .frame(width:geoWidth, height: geoHeight)
                    }
//                    .opacity()
                    .opacity(tier % 5 <= 1 ? 1.0 : (colorScheme == .light ? 0.4 : 0.7))

//                    .opacity(colorScheme == .light ? 0.5 : 0.6)

                
                
            }
            .frame(width: geoWidth, height: geoHeight)
//            .clipShape(.buttonBorder)




        }
        
    }
}
struct QuestThumbnailView_redesigned: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var quest: Quest
    @State var showMomentumLvDetail:Bool = false
    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            let badgeSize:CGFloat = geoHeight*0.45
            let textWidth:CGFloat = (geoWidth - badgeSize)*0.9
            
            ZStack {
                QuestTierView(tier: quest.tier, notUsedYet: quest.cumulative() == 0)
                    .frame(width: geoWidth, height: geoHeight)
                HStack(spacing: 0.0) {
                    VStack(spacing:0.0) {
                        FireView(momentumLevel: quest.momentumLevel)
                            .frame(width: badgeSize, height: badgeSize, alignment: .trailing)
                            .onTapGesture{showMomentumLvDetail.toggle()}
                            .popover(isPresented:$showMomentumLvDetail) {
                                Text(quest.textForMomentumLevel())
//                                    .buttonStyle(.plain)
                                    .padding()
                                    .presentationCompactAdaptation(.popover)
                            }
                        PurposeOfQuestView_redesigned(quest:quest)
                        .frame(width:badgeSize, height:badgeSize)
                        
                    }
                    .frame(width:badgeSize,height:geoHeight*0.9)
                    VStack(spacing:5.0) {
                        Text(quest.getName())
                            .foregroundStyle(getDarkTierColorOf(tier:quest.tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(quest.representingDataToString())
                            .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                            .font(.caption)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                        
                        
                    }
                    .frame(width:textWidth,alignment: .center)


                }
                .frame(width:geoWidth,height:geoHeight)

                
            }
        }
       
    }
}




struct QuestThumbnailView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var quest: Quest

    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            
            ZStack {
                QuestTierView(tier: quest.tier, notUsedYet: quest.cumulative() == 0)
                    .frame(width: geoWidth, height: geoHeight)
                PurposeOfQuestView(quest:quest, parentWidth:UIScreen.main.bounds.width, parentHeight:UIScreen.main.bounds.height)
                    .frame(width:geoWidth/4, height:geoWidth/4)
                    .position(CGPoint(x: geoWidth/8, y: geoWidth/8))
                    .opacity(0.8)
                FireView(momentumLevel: quest.momentumLevel)
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                    .opacity(0.7)
                VStack {
                    Text("\(quest.getName())")
                        .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                        .bold()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.bottom, geoHeight/10)
                    
                    //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                    
                    Text(quest.representingDataToString())
                        .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                        .font(.caption)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)

                    
                }
                .padding(10)
                .frame(width:geoWidth ,height: geoHeight, alignment: .center)
//                .onAppear() {
//                    print("\(quest.name): tier \(quest.tier)")
//                }
                
            }
        }
    }
}



struct CreateNewQuest: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
//    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @Query var quests: [Quest]
        
    @Binding var popUp_createNewQuest: Bool
    // isPlan, popUp
    
    @State var questNameToAppend = ""
    @State var questDataTypeToAppend: DataType = .hour
    @State var customDataTypeNotation: String?
    @State var customDataTypeNotation_textField: String = ""
    @State var additionalInfo: Bool = false
    @State var addSubName: Bool = false
    @State var questSubnameToAppend = ""
    @State var addPastCumulative: Bool = false
    @State var pastCumulative: Int = 0
    @State var pastCumulative_str:String = ""
    @State var showSubnameHelp: Bool = false
    
    @FocusState var focusedTextField: Int?
    
    let largeDynamicTypeSizes: [DynamicTypeSize] = [.accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5, .xxxLarge, .xxLarge]
//    @State var recordOption: String = "ox"
//    let recordOptions:[String] = ["ox", "recordTheQuantity"]
    
    var body: some View {
        
        let questNames = quests.filter({!$0.inTrashCan}).map { $0.name }
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let textBoxWidth = geometry.size.width * 0.35
            let textBoxWidth2 = geometry.size.width * 0.3
            let textFieldWidth = geoWidth * 0.4
            let textFieldWidth2 = geoWidth * 0.5
            let textBoxHeight = geometry.size.height * 0.15
            let messageBoxHeight = geometry.size.height * 0.1
            
            let contentHeight = geometry.size.height*0.9
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    

                    TextField("퀘스트 이름", text:$questNameToAppend)
                        .padding(.horizontal)
                        .frame(width: geometry.size.width)
                    
                        .font(.title2)
                        .maxLength(30, text: $questNameToAppend)
                        .multilineTextAlignment(.center)
                        .focused($focusedTextField, equals:0)
                        .textFieldStyle(.roundedBorder)

                    
                    
//                    HStack {
                        if questNameToAppend == "" {
                            Text_scaleToFit("퀘스트 이름을 입력하세요")
                                .lineLimit(1)
                                .padding(.horizontal)
                                .frame(width: geometry.size.width)
                                .font(.caption)
                                .foregroundStyle(.red)
                            
                        }
                        else if questNames.contains(questNameToAppend) {
                            Text_scaleToFit("퀘스트 이름이 이미 존재합니다.")
                                .lineLimit(1)
                                .padding(.horizontal)
                                .frame(width: geometry.size.width)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    
                    
                    HStack(spacing:0.0) {
                        HStack {
                            Text_scaleToFit("기록 유형")
                                .lineLimit(1)
                                .padding(.leading, 3)
                                .font(.body)
                                .padding(.trailing)
                        }
                        
                        .frame(width:textBoxWidth,alignment:.leading)

                        VStack(spacing:0.0) {
                            Picker("", selection: $questDataTypeToAppend) {
                                
                                ForEach([DataType.hour, DataType.ox, DataType.custom], id:\.self) {
                                    
                                    Text(DataType.kor_stringOf(dataType: $0))
                                    
                                }
                            }
                            .labelsHidden()
                            
                            
                            if questDataTypeToAppend == .hour {
                                Text_scaleToFit("소요된 시간을 기록합니다")
                                    .frame(width:textFieldWidth)
                                    .lineLimit(2)
                                    .font(.caption)
                            } else if questDataTypeToAppend == .custom {
                                Text_scaleToFit("사용자 지정 단위를 기록합니다")
                                    .frame(width:textFieldWidth)
                                    .lineLimit(2)
                                //                                .minimumScaleFactor(0.2)
                                    .font(.caption)
                            } else if questDataTypeToAppend == .ox {
                                Text_scaleToFit("달성여부를 체크박스로 체크합니다.")
                                    .frame(width:textFieldWidth)
                                    .lineLimit(2)
                                    .font(.caption)
                            }
                            
                        }
//                        .frame(width:textFieldWidth)

                        
                    }
                    .padding(.top,10)
                    .padding(.horizontal)
                    
                    
                    // MARK: 계획수치 또는 달성수치
                    if questDataTypeToAppend == DataType.custom {
                        HStack(spacing:0.0) {
                            
                            Text_scaleToFit("사용자 지정 단위")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(2)
                                .frame(width:textBoxWidth,alignment: .leading)
                                .multilineTextAlignment(.leading)
                            
                            TextField("예시: 푸시업 -> n회",text: $customDataTypeNotation_textField)
                                .frame(width: textFieldWidth2)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedTextField, equals:1)
                                .onChange(of: customDataTypeNotation_textField) {
                                    customDataTypeNotation = customDataTypeNotation_textField
                                }
                        }
                        .padding(.horizontal)
//                        .frame(idealHeight:geoHeight*0.07, alignment: .leading)
                        
                        
                    }
                    
                    
                    HStack(spacing:0.0) {
                        HStack(spacing:0.0) {
                            
                            Button(action:{
                                addSubName.toggle()
                                focusedTextField = 2
                                
                            }) {
                                Image(systemName: addSubName ? "checkmark.square" : "square")
                            }
                            //                        .border(.yellow)
                            
                            
                            Text_scaleToFit("줄임말")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(1)

                                .opacity(addSubName ? 1.0 : 0.5)
                            
                        }
                        .frame(width: textBoxWidth, alignment: .leading)
                        
                        
                        TextField("퀘스트를 요약할 이름", text: $questSubnameToAppend)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .focused($focusedTextField, equals:2)
                            .disabled(!addSubName)
                            .opacity(addSubName ? 1.0 : 0.5)
                        
                        
                        Button(action:{
                            showSubnameHelp.toggle()
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                        .padding(.leading)
                        .popover(isPresented: $showSubnameHelp, content: {
                            Text_scaleToFit("줄임말 설정 시 퀘스트 상세 창을 제외한 모든 화면에서 줄임말로 표시됩니다.")
                                .padding(.horizontal)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .presentationCompactAdaptation(.popover)
                        })
                        
                        
                        
                        
                    }
                    .padding(.horizontal)


                    HStack(spacing:0.0) {
    
                        HStack(spacing:0.0) {
    
                            Button(action:{
                                addPastCumulative.toggle()
                                focusedTextField = 3
    
                            }) {
                                Image(systemName: addPastCumulative ? "checkmark.square" : "square")
                            }
    
    
                            Text_scaleToFit("과거 누적량")
                                .lineLimit(2)
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .multilineTextAlignment(.leading)
                                .opacity(addPastCumulative ? 1.0 : 0.5)
                        }
                        .frame(width: textBoxWidth, alignment: .leading)
    
                        TextField("생성 이전의 누적량", text: $pastCumulative_str)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .disabled(!addPastCumulative)
                            .opacity(addPastCumulative ? 1.0 : 0.5)
                            .focused($focusedTextField, equals:3)
                            .keyboardType(.numberPad)
    //                        if addPastCumulative {
                        HStack {
                            Text_scaleToFit(DataType.unitNotationOf(dataType: questDataTypeToAppend, customDataTypeNotation: customDataTypeNotation_textField))
                                .opacity(addPastCumulative ? 1.0 : 0.5)
                                .lineLimit(2)
                                .frame(width:geoWidth*0.1)
                                .padding(.leading)
                        }
                        .frame(idealHeight:geoHeight*0.08)
                    }
                    .padding(.horizontal)
                    

    
    
    
    
    
                    Button(action: {
                        createNewQuest()
                        dismiss.callAsFunction()
    
                    } ) {
                        Text("생성")
                    }
                    .buttonStyle(.bordered)
                    .padding(.top,10)
                    .disabled(
                        (
                            questNames.contains(questNameToAppend) || (questDataTypeToAppend == .custom && (customDataTypeNotation == "" || customDataTypeNotation == nil)) ||
                            questNameToAppend == "")
    
                    )
                    .frame(width:geometry.size.width, alignment: .center)
                    
                    
                } // Vstack
                .frame(width:geometry.size.width,alignment: .top)
                Spacer().frame(height:geoHeight*0.7)
            }
            .navigationTitle("새로운 누적 퀘스트")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDisabled(!largeDynamicTypeSizes.contains(dynamicTypeSize))
            .onAppear() {
                focusedTextField = 0
            }
                
                

                
                
//            }// Zstack
//            .frame(width:geometry.size.width, height: contentHeight)

//            .onChange(of: customDataTypeNotation) { oldValue, newValue in
//                if customDataTypeNotation == DataType.CUSTOM {
//                    
//                }
//            }
            
        }
    }
    
    func createNewQuest() -> Void {
        let newQuest = Quest(name: questNameToAppend, dataType: questDataTypeToAppend.rawValue)
        if questDataTypeToAppend == .custom {
            newQuest.customDataTypeNotation = customDataTypeNotation
        }
        if addSubName && questSubnameToAppend != "" {
            newQuest.subName = questSubnameToAppend
        }
        if addPastCumulative {
            if let pastCumulatve = Int(pastCumulative_str) {
                if questDataTypeToAppend == .hour {
                    newQuest.pastCumulatve = pastCumulatve * 60
                }
                else {
                    newQuest.pastCumulatve = pastCumulatve
                }
            }
        }
        
        modelContext.insert(newQuest)
        try? modelContext.save()

        
        let dataType_rawVal:Int = questDataTypeToAppend.rawValue
        
        let predicate = #Predicate<DailyQuest> { dailyQuest in
            dailyQuest.quest == nil && dailyQuest.questName == questNameToAppend && dailyQuest.dataType == dataType_rawVal && dailyQuest.customDataTypeNotation == customDataTypeNotation
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        try! modelContext.enumerate(
            descriptor,
            batchSize: 5000,
            allowEscapingMutations: true
        ) { dailyQuest in
            
            dailyQuest.quest = newQuest
            
            if let date = dailyQuest.dailyRecord?.date {
                if dailyQuest.data != 0 { newQuest.dailyData[date] = dailyQuest.data }
            }
            

            try? modelContext.save()
            
        }
        
        
        newQuest.updateTier()
        newQuest.updateMomentumLevel()
        
        try? modelContext.save()


        
    }
    
    
}


//
//struct PickerElement:View {
//    var option: DataType
//    let string: String
//    
//    init(option: DataType) {
//        self.option = option
//        self.string = {
//            if option == .ox {
//                return "달성여부를 체크박스로 체크합니다."
//            } else if option == .hour {
//                return "소요된 시간을 기록합니다"
//            } else {
//                return "사용자 지정 단위를 기록합니다"
//            }
//        }()
//    }
//    
//    var body: some View {
//        Text(DataType.kor_stringOf(dataType: option))
//            .font(.callout) +
//        Text("\n\(string)")
//            .font(.system(size: 20.0))
//    }
//}









struct RotatingGradient: View {
    @State private var isRotating = false
    let level: Int
    let colors: [Color]

    var body: some View {
        // 10 7 5 3.5 1
//        let duration: CGFloat = 5/(CGFloat(level)+4.0) * 3.0
//        let duration: CGFloat = {
//            switch level {
//            case 1:
//                return 8
//            case 2:
//                return 4
//            case 3:
//                return 2.5
//            case 4:
//                return 1.5
//            default: return 1.0
//            }
//        }()
        let duration: CGFloat = {
            switch level {
            case 1:
                return 12
            case 2:
                return 9
            case 3:
                return 6
            case 4:
                return 4
            default: return 4.0
            }
        }()

        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let a = Path(ellipseIn: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight))
            
//            Circle()
            a
                .fill(
                    AngularGradient(gradient: Gradient(colors: colors), center: .center)
                )
                .scaleEffect(0.9)
                .position(CGPoint(x:geometry.size.width/2, y:geometry.size.height/2))
//                .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
                .animation(.linear(duration: duration).repeatForever(autoreverses: false), body: { a in
                    a.rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
                })
//                .animation(Animation.linear(duration: duration).repeatForever(autoreverses: false))
                .onAppear() {
                    self.isRotating = true
                }
        }
    }
}



struct EditQuest2: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var quests: [Quest]
        
    @Binding var popUp_editQuest: Bool
    @Binding var selectedQuest: Quest?

    
    var body: some View {
        if let quest = selectedQuest {
            EditQuest(
                popUp_editQuest: $popUp_editQuest,
                quest: quest,
                questName: quest.name,
                questDataType: DataType(rawValue: quest.dataType) ?? .hour ,
                customDataTypeNotation:quest.customDataTypeNotation,
                customDataTypeNotation_textField: quest.customDataTypeNotation ?? "",
                addSubName: quest.subName != nil,
                questSubname: quest.subName ?? "",
                addPastCumulative: quest.pastCumulatve != 0,
                pastCumulative: quest.pastCumulatve/60,
                pastCumulative_str: String(quest.pastCumulatve/60)
            )

            
        } else {
            Spacer()
        }
    }
    
    
    
}

