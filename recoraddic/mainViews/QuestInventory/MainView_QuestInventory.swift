//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI
import SwiftData

enum EditOption {
    case archive
    case hide
    case delete
}


struct MainView_QuestInventory: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort:\Quest.momentumLevel) var quests:[Quest]
    

    
//    @State var chooseQuestToHide:Bool = false
    
    enum StatisticOption {
        case quest
        case defaultPurpose
    } // add customPurpose later
    
    @State var selectedQuest: Quest?
    @State var popUp_questStatisticsInDetail: Bool = false
    
    @State var popUp_addNewQuest: Bool = false
    @State var popUp_help: Bool = false
    @State var popUp_confirmation: Bool = false
    @State var editConfirmed: Bool = false
    @State var isEdit: Bool = false
    @State var selectedQuestNames: Set<String> = []
    
    @State var editOption: EditOption?
    
    // @State enum -> 보관 / 숨기기 / 휴지통 하시겠습니까? -> enum에 따른 함수 구분해서 바꿔주기
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let quest_sorted = quests.filter({!$0.isArchived && !$0.isHidden && !$0.inTrashCan})
        
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height

            let gridHorizontalPadding = geoWidth*0.04
            let gridViewFrameWidth = geoWidth - gridHorizontalPadding*2
            let gridSize = (gridViewFrameWidth) / 3 * 0.955
            let gridItemSize = gridSize * 0.85
            let gridItemSpacing = gridItemSize*0.3
            let gridVerticalSpacing = gridSize*0.08
        
            
            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let shadowColor: Color = getShadowColor(colorScheme)
            ZStack {
                VStack {
                    ZStack {
                        HStack(spacing:0.0) {
//                            if !isEdit {
                                Text("누적 퀘스트 목록")
                                    .bold()
                                    .fontDesign(.serif)
                                    .frame(height: geoHeight*0.07)
                                    .padding(.trailing, 10)
                                Button("", systemImage: "questionmark.circle", action: {
                                    popUp_help.toggle()
                                })
                                
//                            }
//                            else {
//                                Button(action:{}){Image(systemName: "trash")}.foregroundStyle(.red)
//                                    .frame(width:geoWidth*0.05)
//                                Text("\(selectedQuestNames.count)개의 퀘스트 선택")
//                                    .frame(width:geoWidth*0.7,alignment: .center)
//                                Button(action:{}){Image(systemName: "archivebox")}
//                                    .frame(width:geoWidth*0.05,alignment: .center)
//                                    .padding()
//                                Button(action:{}){Image(systemName: "eye.slash")}
//                                    .frame(width:geoWidth*0.05, alignment: .center)
//                                    .padding(.trailing, geoWidth*0.15)
//                                    
//                            }
                        }
                        Button(isEdit ? "취소" : "편집") {
                            isEdit.toggle()
                            resetEditData()
                        }
                        .frame(width: geoWidth*0.95, height: geoHeight*0.07, alignment: .trailing)
                    }
                    .frame(width: geoWidth*0.95, height: geoHeight*0.07)

                    
                    ZStack {
                        ScrollView {
                            ZStack {
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize, maximum: gridSize))], spacing: gridVerticalSpacing) {
                                    ForEach(quest_sorted,id:\.createdTime) { quest in
                                        
                                        
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
                                            ZStack {
                                                ZStack {
                                                    QuestThumbnailView(quest: quest)
                                                        .frame(width: gridItemSize, height: gridItemSize)
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
                                                                let path: Path = Path(roundedRect: CGRect(x: 0, y: 0, width: gridItemSize, height: gridItemSize), cornerSize: CGSize(width: gridItemSize/20, height: gridItemSize/20))
                                                                path
                                                                    .stroke(lineWidth: gridItemSize/15)
                                                                if selectedQuestNames.contains(quest.name) {
                                                                    Image(systemName:"checkmark")
                                                                        .resizable()
                                                                        .frame(width:gridItemSize*0.6, height: gridItemSize*0.6)
                                                                }
                                                                
                                                            }
                                                            .frame(width:gridItemSize, height: gridItemSize)
                                                            .foregroundStyle(.blue)
                                                            
                                                        }
                                                    }
                                                }
                                                .frame(width: gridItemSize, height: gridItemSize)
                                            }
                                            .frame(width:gridSize, height: gridSize)
                                            
                                        }
                                        .contextMenu(ContextMenu(menuItems: {
                                            Button("숨기기") {
                                                quest.isHidden = true
                                            }
                                        }))
                                        .onAppear() {
                                            quest.updateMomentumLevel()
                                        }
                                        .frame(width:gridSize, height: gridSize)
//                                        .border(.yellow)
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    // TODO: plus button
                                    if !isEdit {
                                        ZStack {
                                            Button(action: {
                                                popUp_addNewQuest.toggle()
                                            }) {
                                                Image(systemName: "plus.square")
                                                    .resizable()
                                                    .frame(width: gridItemSize*0.4, height: gridItemSize*0.4)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .frame(width: gridItemSize, height: gridItemSize)
                                    }
                                    
                                    
                                    
                                } // lazyVGrid
                                .frame(width:gridViewFrameWidth)
//                                .border(.red)
                                Path { path in
                                    let items = quest_sorted.count
                                    let size = gridViewFrameWidth/3
                                    
                                    let halfOfHorizontalPadding = (gridViewFrameWidth - gridSize*3)/2/2
                                    let x1 = gridSize + halfOfHorizontalPadding
                                    let x2 = gridSize * 2 + halfOfHorizontalPadding * 3
                                    
                                    path.move(to: CGPoint(x: x1, y: 0.0))
                                    path.addLine(to: CGPoint(x: x1, y:CGFloat((items + 2) / 3) * size))
                                    path.move(to: CGPoint(x: x2, y: 0.0))
                                    path.addLine(to: CGPoint(x: x2, y:CGFloat((items + 1) / 3) * size))

                                    
                                    let rowsNum = (items - 1) / 3
                                    let lastRowElmNum = items % 3
                                    let halfOfVerticalPadding = gridVerticalSpacing/2
                                    let height = gridSize + halfOfVerticalPadding*2

                                    for i in 0..<rowsNum {
                                        let y = height * CGFloat(i + 1) - halfOfVerticalPadding
//                                        if i != rowsNum - 1 {
                                            path.move(to: CGPoint(x: 0, y: y))
                                            path.addLine(to: CGPoint(x: size * 3.0, y: y))
//                                        }
//                                        else {
//                                            path.move(to: CGPoint(x: 0, y: y))
//                                            path.addLine(to: CGPoint(x: size * CGFloat(lastRowElmNum), y: y))
//                                        }

                                    }

                                }
                                .stroke(.gray.opacity(0.7), lineWidth: 1)
                            }
                            .frame(width:geoWidth - gridHorizontalPadding*2)
                            .padding(.top, gridItemSpacing)
                            .padding(.horizontal, gridHorizontalPadding)
                            
                            
                            
                            
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
                        .position(CGPoint(x: geoWidth/2, y: geoHeight*0.45*0.7))
                        .shadow(color:shadowColor, radius: 3.0)
                }
                if popUp_help {
                    Color.gray.opacity(0.2)
                        .onTapGesture {
                            popUp_help.toggle()
                        }
                    QuestHelpView(popUp_help: $popUp_help)
                        .popUpViewLayout(width: geoWidth*0.9, height: geoHeight*0.85, color: colorSchemeColor)
                        .position(CGPoint(x: geoWidth/2, y: geoHeight*0.85*0.6))
                        .shadow(color:shadowColor, radius: 3.0)
                }
//                if popUp_confirmation {
//                    Color.gray.opacity(0.2)
//                        .onTapGesture {
//                            popUp_confirmation.toggle()
//                        }
//                    let questName = (selectedQuestNames.count == 1) ? selectedQuestNames.first! : "\(selectedQuestNames.count)개의 퀘스트"
//                    QuestEditConfirmationView(
//                        questName: questName,
//                        editOption: editOption!,
//                        editConfirmed: $editConfirmed,
//                        popUp_self: $popUp_confirmation
//                    )
//                        .popUpViewLayout(width: geoWidth*0.8, height: geoHeight*0.25, color: colorSchemeColor)
//                        .position(CGPoint(x: geoWidth/2, y: geoHeight*0.5))
//                        .shadow(color:shadowColor, radius: 3.0)
//                }
                
            }
            .sheet(isPresented: $isEdit) {
//                if popUp_confirmation {
//
//                }
//                else {
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
//                            .presentationDetents([.bar])
                            .presentationBackground(.thickMaterial)
                        }

                    }
                    .presentationDetents([.height(100)])
                    .presentationCornerRadius(0.0)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(100)))
                    .presentationBackground(.thickMaterial)


//                }
            }


            .onChange(of: editConfirmed) { oldValue, newValue in
                if newValue == true {
                    if editOption == .archive {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName}).first {
                                targetQuest.isArchived = true
                            }
                        }
                    }
                    else if editOption == .hide {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName}).first {
                                targetQuest.isHidden = true
                            }
                        }
                    }
                    else if editOption == .delete {
                        for selectedQuestName in selectedQuestNames {
                            if let targetQuest:Quest = quests.filter({$0.name == selectedQuestName}).first {
                                targetQuest.inTrashCan = true
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

        } // geometryRecord
        

    }
    
    func resetEditData() -> Void {
        selectedQuestNames = []
        editOption = nil
        editConfirmed = false
    }
    
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
    
    var editOption: EditOption
    
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
    
    @Binding var editOption: EditOption?
    
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


                
            
//            .background(.clear)
        }
        
    }
        
}


struct QuestTierView: View {
    
    @Environment (\.colorScheme) var colorScheme
//    @Environment (\.modelContext) var modelContext
    
    @Binding var tier: Int
    

    
    var body: some View {
        
        let shadowColor:Color = getShadowColor(colorScheme)
        
        let tierColor:Color = getTierColorOf(tier: tier)
        
        let nextTierColor: Color = getTierColorOf(tier: tier+5)
        
        
        let tierColor_bright:Color = getBrightTierColorOf2(tier: tier)
        
        
        let tierColor_frame1:Color = tierColor_bright
        let tierColor_frame2:Color = tierColor
        let currentTierColor_frame:Color = tierColor
        let nextTierColor_frame:Color = nextTierColor

        
        let colorsForGradient: [Color] = {
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
                    .fill(LinearGradient(colors: getTierColorsOf(tier: tier, type:1), startPoint: .topLeading, endPoint: .bottomTrailing))
                
                RotatingGradient(level: tier%5, colors: colorsForGradient)
                    .frame(width:(geoWidth+strokeWidth*2)*1.5, height: (geoHeight+strokeWidth*2)*1.5)
                    .position(x:geoWidth/2, y:geoHeight/2)
                    .mask {
                        RoundedRectangle(cornerSize: CGSize(width: geoWidth/20, height: geoHeight/20))
                            .stroke(lineWidth: strokeWidth)
                            .frame(width:geoHeight+strokeWidth/2, height: geoHeight+strokeWidth/2)
                    }

                
                
            }
            .frame(width: geoWidth, height: geoHeight)
//            .shadow(color: shadowColor, radius: 1)
//            .shadow(color: getTierColorOf(tier: tier).adjust(brightness: -0.3), radius: 1)



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
                    .opacity(0.85)
                FireView(momentumLevel: quest.momentumLevel)
                //                                        Fire6()
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                    .opacity(0.7)
                //                                            .opacity(0.7)
                VStack {
                    Text("\(quest.name)")
                        .foregroundStyle(getDarkTierColorOf(tier: quest.tier))
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(2)
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

struct QuestHelpView: View {
    
    @Binding var popUp_help: Bool
    
    let options: [String] = ["notHour", "hour"]
    @State var selectedOption: String = "notHour"
    
    
    let notHourTierGuideLines: [String] = [
        "0회","1회", "2회", "3회", "4회",
        "5회" , "6회", "7회", "8회", "9회",
        "10~15회","16~21회", "22~27회", "28~33회", "34~39회",
        "40~51회", "52~63회", "64~75회", "76~87회", "88~99회",
        "100~159회", "160~219회", "220회~279회", "280~339회", "340~399회",
        "400~519회", "520~639회", "640~759회", "760~879회", "880~999회",
        "1000~1599회", "1600~2199회", "2200~2799회", "2800~3399회", "3400~3999회",
        "4000~5199회", "5200~6399회", "6400~7599회", "7600~8799회", "8800~9999회",
        "10000회 이상"
    ]
    let hourTierGuideLines: [String] = [
        "0시간","1시간", "2시간", "3시간", "4시간",
        "5시간" , "6시간", "7시간", "8시간", "9시간",
        "10~15시간","16~21시간", "22~27시간", "28~33시간", "34~39시간",
        "40~51시간", "52~63시간", "64~75시간", "76~87시간", "88~99시간",
        "100~159시간", "160~219시간", "220시간~279시간", "280~339시간", "340~399시간",
        "400~519시간", "520~639시간", "640~759시간", "760~879시간", "880~999시간",
        "1000~1599시간", "1600~2199시간", "2200~2799시간", "2800~3399시간", "3400~3999시간",
        "4000~5199시간", "5200~6399시간", "6400~7599시간", "7600~8799시간", "8800~9999시간",
        "10000시간 이상"
    ]
    
    let fireGuideLines: [String] = [
        "최근 1일 중 1일 실행",
        "최근 3일 중 2일 이상 실행",
        "최근 5일 중 3일 이상 실행",
        "최근 7일 중 4일 이상 실행",
        "최근 10일 중 5일 이상 실행",
        "최근 14일 중 6일 이상 실행",
        "최근 20일 중 8일 이상 실행",
        "최근 30일 중 10일 이상 실행",
        "최근 40일 중 12일 이상 실행",
        "최근 50일 중 15일 이상 실행",
    ]


    var body: some View {
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let tierViewSize: CGFloat = geoWidth*0.2
            let fireViewSize: CGFloat = geoWidth*0.2
            
            VStack {
                Picker("hour or times", selection: $selectedOption, content: {
                    ForEach(options,id:\.self) { option in
                        Text(option)
                    }
                })
                .pickerStyle(.segmented)
                HStack(alignment: .top) {
                    ScrollView {
                        ForEach(0...40, id:\.self) { tier in
                            VStack {
                                QuestTierView(tier: .constant(tier))
                                    .frame(width:tierViewSize, height: tierViewSize)
                                Text(selectedOption == "notHour" ?  notHourTierGuideLines[tier]: hourTierGuideLines[tier])
                            }
                            .frame(width: geoWidth/2)
                            .padding(.vertical,tierViewSize*0.1)
                        }
                    }
                    .frame(width:geoWidth/2)

                    ScrollView {
                        ForEach(1...10, id:\.self) { momentumLevel in
                            
                            VStack {
                                FireView(momentumLevel: momentumLevel)
                                        .frame(width:fireViewSize, height: fireViewSize)
                                Text(fireGuideLines[momentumLevel-1])
                                    .font(.caption)
                            }
                            .frame(width: geoWidth/2)
                            .padding(.vertical,fireViewSize*0.1)

                        }
                    }
                    .frame(width:geoWidth/2)

                }
                .frame(width:geoWidth)
                Button(action:{
                    popUp_help.toggle()
                }) {
                    Image(systemName: "xmark")
                }
                .padding(.vertical, geoHeight*0.02)

            }
            .frame(width: geoWidth, height: geoHeight)
        }
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
#Preview(body: {
    HStack {
        VStack {
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 0,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 5,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 10,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 15,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 20,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)

        }
        VStack {
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 25,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 30,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 35,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 40,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)

        }
        
    }

})


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


