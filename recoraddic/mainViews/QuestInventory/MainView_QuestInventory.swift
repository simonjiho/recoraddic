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
    @Query var quests:[Quest]
    

    
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
    
    // @State enum -> 보관 / 숨기기 / 휴지통 하시겠습니까? -> enum에 따른 함수 구분해서 바꿔주기
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
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
            let gridWidth = (gridViewFrameWidth) / 2 * 0.97
            let gridHeight = gridWidth / 1.618
            let gridItemWidth = gridWidth * 0.85
            let gridItemHeight = gridHeight * 0.85
            let gridItemSpacing = gridItemWidth*0.3
            let gridVerticalSpacing = gridWidth*0.08
        
            
            let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
            let shadowColor: Color = getShadowColor(colorScheme)
            ZStack {
                NavigationView {
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
                                
                                    
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridWidth, maximum: gridWidth))], spacing: gridVerticalSpacing) {
                                    ForEach(quest_sorted_visible,id:\.createdTime) { quest in
                                        
                                        
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
                                                        .frame(width: gridItemWidth, height: gridItemHeight)
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
                                                                let path: Path = Path(roundedRect: CGRect(x: 0, y: 0, width: gridItemWidth, height: gridItemHeight), cornerSize: CGSize(width: gridItemWidth/20, height: gridItemWidth/20))
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
                                            }
                                            .frame(width:gridWidth, height: gridHeight)
                                            
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
                                            }
                                            .foregroundStyle(.red)
                                        }))
                                        .onAppear() {
                                            quest.updateMomentumLevel()
                                        }
                                        .frame(width:gridWidth, height: gridHeight)
                                        //                                        .border(.yellow)
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    // TODO: plus button
                                    if !isEdit {
                                        ZStack {
                                            
                                            NavigationLink(destination: CreateNewQuest(popUp_createNewQuest: $popUp_addNewQuest)
) {
                                                Image(systemName: "plus.square")
                                                    .resizable()
                                                    .frame(width: gridItemWidth*0.3, height: gridItemWidth*0.3)
                                                
                                            }
                                            .buttonStyle(.plain)
                                            
                                            
                                            
                                            //                                            Button(action: {
                                            //                                                popUp_addNewQuest.toggle()
                                            //                                            }) {
                                            //                                                Image(systemName: "plus.square")
                                            //                                                    .resizable()
                                            //                                                    .frame(width: gridItemWidth*0.4, height: gridItemWidth*0.4)
                                            //                                            }
                                            //                                            .buttonStyle(.plain)
                                        }
                                        .frame(width: gridItemWidth, height: gridItemHeight)
                                    }
                                    
                                    
                                    
                                } // lazyVGrid
                                .frame(width:gridViewFrameWidth)
                                .padding(gridInnerPadding)
//                                .background(.quaternary)
                                .clipShape(.rect(cornerRadius: gridItemWidth/20))
//                                .padding(.top, gridItemSpacing)
                                .padding(.horizontal, gridHorizontalPadding)
                                    

                                
 
                                
                                
                                
                            } // ScrollView
                            .frame(width:geometry.size.width, height: geometry.size.height*0.9)
//                            .border(.red)
                            
                            
                            if quests.filter({$0.isVisible()}).isEmpty {
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
                    .background(.quaternary)

                    .sheet(isPresented: $popUp_questStatisticsInDetail, onDismiss: {selectedQuest = nil}) {
                        QuestInDetail(
                            selectedQuest: $selectedQuest,
                            popUp_questStatisticsInDetail: $popUp_questStatisticsInDetail
                        )
                        .ignoresSafeArea(.keyboard)
                    }
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

            }
            
            .fullScreenCover(isPresented: $editQuestInfo, onDismiss: {selectedQuest=nil}) {
                EditQuest2(
                    popUp_editQuest: $editQuestInfo,
                    selectedQuest: $selectedQuest
                )
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
//    @Environment (\.modelContext) var modelContext
    
//    @Binding var tier: Int
    var tier: Int

    
    var body: some View {
        
        let shadowColor:Color = getShadowColor(colorScheme)
        
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
                    return geoHeight*0.06
                case 3:
                    return geoHeight*0.09
                case 4:
                    return geoHeight*0.09
                default:
                    return 0.0
                }
            }()
            
            let tierViewFrame: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/20, cornerHeight: geoHeight/20, transform: nil))
//            let strokeLineWidth:CGFloat = geoWidth*0.04*(0.5 * CGFloat(tier%5))

            
            ZStack {
                tierViewFrame
                    .fill(LinearGradient(colors: getGradientColorsOf(tier: tier, type:1), startPoint: .topLeading, endPoint: .bottomTrailing))
                
                RotatingGradient(level: tier%5, colors: rotationGradientColors)
                    .frame(width:(geoWidth+strokeWidth*2)*1.5, height: (geoWidth+strokeWidth*2)*1.5)
                    .position(x:geoWidth/2, y:geoHeight/2)
                    .mask {
                        RoundedRectangle(cornerSize: CGSize(width: geoWidth/20, height: geoHeight/20))
                            .stroke(lineWidth: strokeWidth)
                            .frame(width:geoWidth+strokeWidth/2, height: geoHeight+strokeWidth/2)
                    }

                
                
            }
            .frame(width: geoWidth, height: geoHeight)




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
//            let gridItemWidth = geoWidth
            
            ZStack {
                QuestTierView(tier: quest.tier)
                    .frame(width: geoWidth, height: geoHeight)
                    .opacity(0.85)
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
//    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @Query var quests: [Quest]
        
    @Binding var popUp_createNewQuest: Bool
    // isPlan, popUp
    
    @State var questNameToAppend = ""
    @State var questDataTypeToAppend: DataType = .ox
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
            
            
            ZStack {
                VStack(alignment: .leading) {

                    
                    HStack {
//                        Text("이름:")
//                            .frame(width:textBoxWidth,alignment: .trailing)
//                            .font(.title3)
                        TextField("퀘스트 이름", text:$questNameToAppend)
                            .tag(0)
                            .font(.title2)
                            .maxLength(30, text: $questNameToAppend)
                            .multilineTextAlignment(.center)
                            .focused($focusedTextField, equals:0)
                            .textFieldStyle(.roundedBorder)
//                            .shadow(radius: 1)
                        
                    }
                    .padding(.horizontal)
                    .frame(width: geometry.size.width)
                    //                                .frame(height: textBoxHeight)
                    

                        
                    if questNameToAppend == "" {
                        Text("퀘스트 이름을 입력하세요")
                            .frame(width: geometry.size.width)
                            .foregroundStyle(.red)
                            .font(.caption)
                            
                        }
                    else if questNames.contains(questNameToAppend) {
                        Text("퀘스트 이름이 이미 존재합니다.")
                            .frame(width: geometry.size.width, height: 20)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }

                    
                    HStack(spacing:0.0) {
//                        Spacer()
//                            .frame(width:checkBoxWidth, height:1)

                        Text("단위")
                            .padding(.leading, 3)
                            .padding(.trailing,20)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(width:textBoxWidth,alignment: .leading)
                            .multilineTextAlignment(.leading)

//                            .border(.blue)
//                        .padding(.horizontal)
                            
                        Picker("", selection: $questDataTypeToAppend) {
                            ForEach(DataType.allCases, id:\.self) {
                                Text(DataType.kor_stringOf(dataType: $0))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .frame(width: textFieldWidth2)

                    }
                    .padding(.horizontal)
//                    .border(.red)
                    .padding(.top)
                    // MARK: 계획수치 또는 달성수치
                    

                    if questDataTypeToAppend == DataType.custom {
                        HStack(spacing:0.0) {
//                            Spacer()
//                                .frame(width:checkBoxWidth)
//                                .border(.yellow)

                            Text("사용자 지정 단위")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width:textBoxWidth,alignment: .leading)
                                .multilineTextAlignment(.leading)
//                                    .padding(.horizontal)

                            TextField("예시: 푸시업 -> n회",text: $customDataTypeNotation_textField)
                                .frame(width: textFieldWidth2)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedTextField, equals:1)
                                .onChange(of: customDataTypeNotation_textField) {
                                    customDataTypeNotation = customDataTypeNotation_textField
                                }
                        }
                        .padding(.horizontal)
                        .frame(alignment: .leading)
//                        .border(.red)

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
                            
                            
                            Text("줄임말")
                                .padding(.leading, 3)
                                .padding(.trailing,30)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: textBoxWidth2, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .opacity(addSubName ? 1.0 : 0.5)
                            //                            .border(.blue)
                        }
                        .frame(width: textBoxWidth, alignment: .leading)

//                        .padding(.horizontal)
                        
                        TextField("퀘스트를 요약할 이름", text: $questSubnameToAppend)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .focused($focusedTextField, equals:2)
                            .disabled(!addSubName)
                            .opacity(addSubName ? 1.0 : 0.2)


                        Button(action:{
                            showSubnameHelp.toggle()
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                        .padding(.leading)
                        .popover(isPresented: $showSubnameHelp, content: {
                            Text("줄임말 설정 시 퀘스트 상세 창을 제외한 모든 화면에서 줄임말로 표시됩니다.")
                                .padding(.horizontal)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .presentationCompactAdaptation(.popover)
                        })


                        

                    }
                    .padding(.horizontal)

//                    .border(.red)


                        
                    HStack(spacing:0.0) {
                        
                        HStack(spacing:0.0) {
                            
                            Button(action:{
                                addPastCumulative.toggle()
                                focusedTextField = 3
                                
                            }) {
                                Image(systemName: addPastCumulative ? "checkmark.square" : "square")
                            }
                            //                        .border(.yellow)
                            
                            
                            Text("과거 누적량")
                                .padding(.leading, 3)
                                .padding(.trailing,20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: textBoxWidth2, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .opacity(addPastCumulative ? 1.0 : 0.5)
                        }
                        .frame(width: textBoxWidth, alignment: .leading)
//                        .padding(.horizontal)

                        TextField("생성 이전의 누적량", text: $pastCumulative_str)
                            .frame(width: textFieldWidth)
                            .textFieldStyle(.roundedBorder)
                            .disabled(!addPastCumulative)
                            .opacity(addPastCumulative ? 1.0 : 0.0)
                            .focused($focusedTextField, equals:3)
                            .keyboardType(.numberPad)
                        if addPastCumulative {
                            Text(DataType.unitNotationOf(dataType: questDataTypeToAppend, customDataTypeNotation: customDataTypeNotation_textField))
                                .opacity(addPastCumulative ? 1.0 : 0.2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.leading)
                        }
                    }
                    .padding(.horizontal)
//                    .border(.red)
                    .frame(width: geoWidth, alignment: .leading)
//                    .border(.yellow)


                    
                    
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
                .padding()
                .frame(width:geometry.size.width, height:contentHeight, alignment: .top)
                
                
                

                
                
            }// Zstack
            .frame(width:geometry.size.width, height: contentHeight)
            .navigationTitle("새로운 퀘스트")
            .navigationBarTitleDisplayMode(.inline)

            .onAppear() {
                focusedTextField = 0
            }
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
        newQuest.updateTier()
        modelContext.insert(newQuest)
    }
    
    
}







struct QuestHelpView: View {
    
    @Binding var popUp_help: Bool
    
    let options: [String] = ["시간", "시간x"]
    @State var selectedOption: String = "시간"
    
    
    let notHourTierGuideLines: [String] = [
        "0회~",
        "5회~",
        "10회~",
        "40회~",
        "100회~",
        "400회~",
        "1000회~",
        "4000회~",
        "10000회~"
    ]
    let hourTierGuideLines: [String] = [
        "0시간~",
        "5시간~",
        "10시간~",
        "40시간~",
        "100시간~",
        "400시간~",
        "1000시간~",
        "4000시간~",
        "10000시간~"
    ]
    
//    let momentumLevelDays:[Int:Int] = [1:1,3]
    
    let defaultFireGuideLines: [String] = [
        "1일 1회",
        "3일 2회",
        "5일 3회",
        "7일 4회",
        "10일 5회",
        "14일 6회",
//        "최근 20일 중 8일 이상 실행",
//        "최근 30일 중 10일 이상 실행",
//        "최근 40일 중 12일 이상 실행",
//        "최근 50일 중 15일 이상 실행",
        "20일",
        "50일",
        "80일",
        "120일",
        "20일",
        "50일",
        "80일",
        "120일",
        "20일",
        "50일",
        "80일",
        "120일",
        "7일",
        "20일",
        "50일",
        "80일",
        "120일",
        "7일",
        "20일",
        "50일",
        "80일",
        "120일",
        "3일",
        "7일",
        "20일",
        "50일",
        "80일",
        "120일",
    ]


    var body: some View {
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let tierViewSize: CGFloat = geoWidth*0.2
            let fireViewSize: CGFloat = geoWidth*0.2
            
            VStack {
                Text("퀘스트 분류")
                HStack(alignment: .top) {
                    VStack {
                        Text("누적 등급")
                            .font(.caption)
                        Picker("", selection: $selectedOption, content: {
                            ForEach(options,id:\.self) { option in
                                Text(option)
                            }
                        })
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        ScrollView {
                            ForEach(0...8, id:\.self) { tier in
                                VStack {
                                    QuestTierView(tier: tier*5)
                                        .frame(width:tierViewSize, height: tierViewSize)
                                    Text(selectedOption == "시간x" ?  notHourTierGuideLines[tier]: hourTierGuideLines[tier])
                                        .font(.caption)

                                }
                                .frame(width: geoWidth/2)
                                .padding(.vertical,tierViewSize*0.1)
                            }
                        }
                        .frame(width:geoWidth*0.48 - 1)
                    }

                    Spacer()
                        .frame(width: 1,height: geoHeight*0.7)
                        .background(.gray.opacity(0.5))
                        .padding(.horizontal,geoWidth*0.01)
                    
                    
                    
                    VStack {
                        Text("불꽃")
                            .font(.caption)
                        ScrollView(.vertical) {
                            VStack {
                                Text("기본 불꽃")
                                    .font(.caption)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(1...6, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)
                            
                            VStack {
                                Text("꾸준함의 불꽃(10%)")
                                    .font(.caption)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(7...10, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)

                            VStack {
                                Text("꾸준함의 불꽃(30%)")
                                    .font(.caption)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(11...14, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)
                            
                            VStack {
                                Text("꾸준함의 불꽃(50%)")
                                    .font(.caption)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(15...18, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)

                            
                            VStack {
                                Text("열정의 불꽃(70%)")
                                    .font(.caption)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(19...23, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)
                            
                            
                            VStack {
                                Text("열정의 불꽃(85%)")
                                    .font(.caption)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(24...28, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)
                            
                            
                            VStack {
                                Text("연속의 불꽃(100%)")
                                    .font(.caption)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        
                                        ForEach(29...34, id:\.self) { momentumLevel in
                                            VStack(spacing:0.0) {
                                                FireView(momentumLevel: momentumLevel)
                                                    .frame(width:fireViewSize, height: fireViewSize)
                                                Text("최근 \(defaultFireGuideLines[momentumLevel-1])")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(.gray.opacity(0.2))
                            .clipShape(.buttonBorder)
                            .padding(.bottom,30)
                            
                            
                            
                            
                            
                            //                        ForEach(1...10, id:\.self) { momentumLevel in
                            //
                            //                            VStack {
                            //
                            //
                            //                                FireView(momentumLevel: momentumLevel)
                            //                                        .frame(width:fireViewSize, height: fireViewSize)
                            //                                Text(fireGuideLines[momentumLevel-1])
                            //                                    .font(.caption)
                            //                            }
                            //                            .frame(width: geoWidth/2)
                            //                            .padding(.vertical,fireViewSize*0.1)
                            //
                            //                        }
                        }
                        .frame(width:geoWidth*0.48)
                    }

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
//            let gridItemWidth = geoWidth
            
            ZStack {
                QuestTierView(tier: tier)
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
