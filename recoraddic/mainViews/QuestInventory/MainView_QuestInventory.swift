//
//  recordMyDayView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/27.
//

import Foundation
import SwiftUI
import SwiftData

enum MountainEditOption {
    case archive
    case hide
    case delete
}

// TODO: 내일은 여기부터
struct MainView_MountainInventory: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @Bindable var mountainsViewModel: MountainsViewModel
    
    @Binding var selectedView: MainViewName
    
//    @State var chooseMountainToHide:Bool = false
    
    enum StatisticOption {
        case mountain
        case defaultPurpose
    } // add customPurpose later
    
    @State var selectedMountain: Mountain_fb?
    @State var selectedMountain2: Mountain_fb = Mountain_fb(name: "")
    @State var popUp_mountainStatisticsInDetail: Bool = false
    
    @State var popUp_addNewMountain: Bool = false
    @State var popUp_help: Bool = false
    @State var popUp_confirmation: Bool = false
    @State var editConfirmed: Bool = false
    @State var isEdit: Bool = false
    @State var selectedMountainNames: Set<String> = []
    
    @State var editOption: MountainEditOption?
    
    @State var editMountainInfo: Bool = false
    
    @State var popOver_changePurpose: Bool = false
    
    // @State enum -> 보관 / 숨기기 / 휴지통 하시겠습니까? -> enum에 따른 함수 구분해서 바꿔주기
    
    var body: some View {

        
        let mountains = mountainsViewModel.mountains
        let mountain_sorted_visible = mountains.filter({$0.isVisible()}).sorted(by: {
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
            let gridWidth = mountainThumbnailWidth(dynamicTypeSize, defaultWidth: (gridViewFrameWidth) / 2) * 0.97
            let gridHeight = gridWidth / 1.618
            let gridItemWidth = gridWidth * 0.92
            let gridItemHeight = gridHeight * 0.92
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
                                Text_scaleToFit("누적 기록 목록")
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
                                    ForEach(mountain_sorted_visible,id:\.createdTime) { mountain in
                                        ZStack {
                                            Button(action:{
                                                if !isEdit {
                                                    selectedMountain = mountain
                                                    popUp_mountainStatisticsInDetail.toggle()
                                                }
                                                else {
                                                    if selectedMountainNames.contains(mountain.name) {
                                                        selectedMountainNames.remove(mountain.name)
                                                    }
                                                    else {
                                                        selectedMountainNames.insert(mountain.name)
                                                    }
                                                }
                                            }) {
                                                MountainThumbnailView_redesigned(mountain: mountain)
                                                    .frame(width: gridItemWidth, height: gridItemHeight)
                                            }
                                            .contextMenu(ContextMenu(menuItems: {
                                                
                                                Button("정보 수정") {
                                                    selectedMountain = mountain
                                                    editMountainInfo.toggle()
                                                    //                                                toggleEditMountainInfo()
                                                }
                                                Button("보관") {
                                                    mountain.isArchived = true
                                                }
                                                Button("숨기기") {
                                                    mountain.isHidden = true
                                                }
                                                
                                                Button("휴지통으로 이동", systemImage:"trash") {
                                                    mountain.inTrashCan = true
                                                    mountain.deletedTime = Date()
                                                }
                                                .foregroundStyle(.red)
                                            }))

                                            
                                            if isEdit {
                                                Button(action:{
                                                    if selectedMountainNames.contains(mountain.name) {
                                                        selectedMountainNames.remove(mountain.name)
                                                    }
                                                    else {
                                                        selectedMountainNames.insert(mountain.name)
                                                    }
                                                }) {
                                                    ZStack {
                                                        let path: Path = Path(roundedRect: CGRect(x: 0, y: 0, width: gridItemWidth, height: gridItemHeight), cornerSize: CGSize(width: gridItemWidth/11, height: gridItemWidth/11))
                                                        path
                                                            .stroke(lineWidth: gridItemHeight/15)
                                                        if selectedMountainNames.contains(mountain.name) {
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
                                            mountain.updateMomentumLevel()
                                        }
                                        .frame(width:gridWidth, height: gridHeight)
                                        //                                        .border(.yellow)
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    // TODO: plus button
                                    if !isEdit {
                                        
                                        NavigationLink(destination: CreateNewMountain(popUp_createNewMountain: $popUp_addNewMountain) .ignoresSafeArea(.keyboard)
                                                       
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
                                    .frame(height:gridItemHeight*(mountain_sorted_visible.count%2 == 0 ? 2 : 3))
                                
                                
                                
                                
                            } // ScrollView
                            .frame(width:geometry.size.width, height: geometry.size.height*0.9)
                            
                            if mountains.filter({$0.isVisible()}).isEmpty {
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
                    .sheet(isPresented: $popUp_mountainStatisticsInDetail, onDismiss: {selectedMountain = nil}) {
                        MountainInDetail(
                            selectedMountain: $selectedMountain,
                            popUp_mountainStatisticsInDetail: $popUp_mountainStatisticsInDetail
                        )
                        .ignoresSafeArea(.keyboard)
                        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
//                        .onAppear() {
//                            if let mountain = selectedMountain {
//                                print("check if dailyMountain is connected")
//                                print(mountain.dailyMountains?.count)
//                            }
//                        }
                    }
                }

                if popUp_help {
//                    Color.gray.opacity(0.2)
                    Color.gray.opacity(0.01)
                        .background(.ultraThinMaterial)
                        .onTapGesture {
                            popUp_help.toggle()
                        }
                    MountainHelpView(popUp_help: $popUp_help)
//                        .popUpViewLayout(width: geoWidth*0.9, height: geoHeight*0.85, color: colorSchemeColor)
//                        .popUpViewLayout(width: geoWidth*0.9, height: 200, color: colorSchemeColor)
                        .popUpViewLayout()
//                        .frame(width:UIScreen.main.bounds.width*0.9, height:150)

                        .position(CGPoint(x: geoWidth/2, y: geoHeight*0.85*0.6))
                        .shadow(color:shadowColor, radius: 3.0)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }

            }
            .onAppear() {print("main: \(geoHeight)")}
            .fullScreenCover(isPresented: $editMountainInfo, onDismiss: {selectedMountain=nil}) {
                EditMountain2(
                    dailyRecordsViewModel: dailyRecordsViewModel,
                    popUp_editMountain: $editMountainInfo,
                    selectedMountain: $selectedMountain
                )
                

            }
            .sheet(isPresented: $isEdit) {
//                if popUp_confirmation {
//
//                }
//                else {
                    ZStack {
                        Text("\(selectedMountainNames.count)개의 퀘스트 선택")
                        HStack(spacing:0.0) {
                            Button(action:{
                                editOption = .archive
                                popUp_confirmation.toggle()
                            }){Image(systemName: "archivebox")}
                                .frame(width:geoWidth*0.12,alignment: .center)
                                .disabled(selectedMountainNames.count == 0)
                            Button(action:{
                                editOption = .hide
                                popUp_confirmation.toggle()
                            }){Image(systemName: "eye.slash")}
                                .frame(width:geoWidth*0.76, alignment: .leading)
                                .disabled(selectedMountainNames.count == 0)
                            Button(action:{
                                editOption = .delete
                                popUp_confirmation.toggle()
                            }){Image(systemName: "trash")}
                                .foregroundStyle(selectedMountainNames.count == 0 ? .gray : .red)
                                .frame(width:geoWidth*0.12, alignment: .center)
                                .disabled(selectedMountainNames.count == 0)
                        }
                        .sheet(isPresented: $popUp_confirmation) {
                            let mountainName = (selectedMountainNames.count == 1) ? selectedMountainNames.first! : "\(selectedMountainNames.count)개의 퀘스트"
                            MountainEditConfirmationView2(
                                mountainName: mountainName,
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
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

//                }
            }


            .onChange(of: editConfirmed) { oldValue, newValue in
                if newValue == true {
                    if editOption == .archive {
                        for selectedMountainName in selectedMountainNames {
                            if let targetMountain:Mountain = mountains.filter({$0.name == selectedMountainName && !$0.isArchived}).first {
                                targetMountain.isArchived = true
                            }
                        }
                    }
                    else if editOption == .hide {
                        for selectedMountainName in selectedMountainNames {
                            if let targetMountain:Mountain = mountains.filter({$0.name == selectedMountainName && !$0.isHidden}).first {
                                targetMountain.isHidden = true
                            }
                        }
                    }
                    else if editOption == .delete {
                        for selectedMountainName in selectedMountainNames {
                            if let targetMountain:Mountain = mountains.filter({$0.name == selectedMountainName && !$0.inTrashCan}).first {
                                targetMountain.inTrashCan = true
                                targetMountain.deletedTime = Date()
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
        selectedMountainNames = []
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


struct MountainEditConfirmationView: View {
        
    var mountainName: String
    
    var editOption: MountainEditOption
    
    @Binding var editConfirmed: Bool
    @Binding var popUp_self: Bool
    
    
    var body: some View {
        
        let mountainion: String = {
            if editOption == .archive {
                return "\(mountainName) 를 보관하시겠습니까?"
            }
            else if editOption == .hide {
                return "\(mountainName) 를 숨기시겠습니까?"
            }
            else if editOption == .delete {
                return "\(mountainName) 를 삭제하시겠습니까?"
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
                Text("\(mountainion)")
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


struct MountainEditConfirmationView2: View {
        
    var mountainName: String
    
    @Binding var editOption: MountainEditOption?
    
    @Binding var editConfirmed: Bool
    @Binding var popUp_self: Bool
    
    
    var body: some View {
        
        let mountainion: String = {
            if editOption == .archive {
                return "\(mountainName) 를 보관하시겠습니까?"
            }
            else if editOption == .hide {
                return "\(mountainName) 를 숨기시겠습니까?"
            }
            else if editOption == .delete {
                return "\(mountainName) 를 삭제하시겠습니까?"
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
                            Text("\(mountainion)")
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


struct MountainTierView: View {
    
    @Environment (\.colorScheme) var colorScheme
//    @Environment (\.modelContext) var modelContext
    
//    @Binding var tier: Int
    var tier: Int
    var notUsedYet: Bool

    
    var body: some View {
        
//        let shadowColor:Color = getShadowColor(colorScheme)
        
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
//            let strokeLineWidth:CGFloat = geoWidth*0.04*(0.5 * CGFloat(tier%5))

            
            
            ZStack {
                tierViewFrame
                    .fill(.white)
                    .opacity(notUsedYet ? 0.0 : 1.0 )
                
//                RoundedRectangle(cornerSize: CGSize(width: geoWidth/11, height: geoWidth/11))
//                tierViewFrame
//                    .stroke(lineWidth: strokeWidth)
//                    .fill(.white)
//                    .frame(width:geoWidth+strokeWidth/2, height: geoHeight+strokeWidth/2)
//                    .opacity(colorScheme == .light ? 0.5 : 0.6)
                
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
                    let height1: CGFloat = geoHeight+strokeWidth/3
                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white.opacity(0.7), lineWidth: strokeWidth/3)
    //                    .stroke(lineWidth: strokeWidth)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                        .rotationEffect(.radians(.pi/36*0.6))
//                        .position(x:width1/2, y:height1/2)

                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white.opacity(0.7), lineWidth: strokeWidth/3)
    //                    .stroke(lineWidth: strokeWidth)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                        .rotationEffect(.radians(-(.pi/36*0.6)))
//                        .position(x:width1/2-strokeWidth/3, y:height1/2-strokeWidth/3)

                }
                if tier % 5 == 3 {
                    let width1:CGFloat = geoWidth+strokeWidth/3
                    let height1: CGFloat = geoHeight+strokeWidth/3
                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
                        .stroke(.white, lineWidth: strokeWidth/3)
    //                    .stroke(lineWidth: strokeWidth)
                        .frame(width:geoWidth, height: geoHeight)
                        .position(x:geoWidth/2, y:geoHeight/2)
                }
//                else if tier % 5 == 4 {
//                    let width1:CGFloat = geoWidth+strokeWidth/3
//                    let height1: CGFloat = geoHeight+strokeWidth/3
//                    RoundedRectangle(cornerSize: CGSize(width: width1/11, height: width1/11))
//                        .stroke(.white.opacity(0.4), lineWidth: strokeWidth/3)
//    //                    .stroke(lineWidth: strokeWidth)
//                        .frame(width:geoWidth, height: geoHeight)
//                        .position(x:geoWidth/2, y:geoHeight/2)
//                }
                


                let width2:CGFloat = geoWidth+strokeWidth
                let height2: CGFloat = geoHeight+strokeWidth
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
struct MountainThumbnailView_redesigned: View {
    
    @Environment(\.colorScheme) var colorScheme

    @State var mountain: Mountain_fb
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
                MountainTierView(tier: mountain.tier, notUsedYet: mountain.cumulative() == 0)
                    .frame(width: geoWidth, height: geoHeight)
                HStack(spacing: 0.0) {
                    VStack(spacing:0.0) {
                        FireView(momentumLevel: mountain.momentumLevel)
                            .frame(width: badgeSize, height: badgeSize, alignment: .trailing)
                            .onTapGesture{showMomentumLvDetail.toggle()}
                            .popover(isPresented:$showMomentumLvDetail) {
                                Text(mountain.textForMomentumLevel())
//                                    .buttonStyle(.plain)
                                    .padding()
                                    .presentationCompactAdaptation(.popover)
                            }
                        PurposeOfMountainView_redesigned(mountain:mountain)
                        .frame(width:badgeSize, height:badgeSize)
                        
                    }
                    .frame(width:badgeSize,height:geoHeight*0.9)
                    VStack(spacing:5.0) {
                        Text(mountain.getName())
                            .foregroundStyle(getDarkTierColorOf(tier:mountain.tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(mountain.representingDataToString())
                            .foregroundStyle(getDarkTierColorOf(tier: mountain.tier))
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




struct MountainThumbnailView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var mountain: Mountain_fb

    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            
            ZStack {
                MountainTierView(tier: mountain.tier, notUsedYet: mountain.cumulative() == 0)
                    .frame(width: geoWidth, height: geoHeight)
                PurposeOfMountainView(mountain:mountain, parentWidth:UIScreen.main.bounds.width, parentHeight:UIScreen.main.bounds.height)
                    .frame(width:geoWidth/4, height:geoWidth/4)
                    .position(CGPoint(x: geoWidth/8, y: geoWidth/8))
                    .opacity(0.8)
                FireView(momentumLevel: mountain.momentumLevel)
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                    .opacity(0.7)
                VStack {
                    Text("\(mountain.getName())")
                        .foregroundStyle(getDarkTierColorOf(tier: mountain.tier))
                        .bold()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.bottom, geoHeight/10)
                    
                    //                                        Text(MountainRepresentingData.titleOf(representingData: mountain.representingData))
                    
                    Text(mountain.representingDataToString())
                        .foregroundStyle(getDarkTierColorOf(tier: mountain.tier))
                        .font(.caption)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)

                    
                }
                .padding(10)
                .frame(width:geoWidth ,height: geoHeight, alignment: .center)
//                .onAppear() {
//                    print("\(mountain.name): tier \(mountain.tier)")
//                }
                
            }
        }
    }
}



struct CreateNewMountain: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
//    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @Bindable var mountainsViewModel: MountainsViewModel
        
    @Binding var popUp_createNewMountain: Bool
    // isPlan, popUp
    
    @State var mountainNameToAppend = ""
    @State var customDataTypeNotation: String?
    @State var customDataTypeNotation_textField: String = ""
    @State var additionalInfo: Bool = false
    @State var addSubName: Bool = false
    @State var mountainSubnameToAppend = ""
    @State var addPastCumulative: Bool = false
    @State var pastCumulative: Int = 0
    @State var pastCumulative_str:String = ""
    @State var showSubnameHelp: Bool = false
    
    @FocusState var focusedTextField: Int?
    
    let largeDynamicTypeSizes: [DynamicTypeSize] = [.accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5, .xxxLarge, .xxLarge]
//    @State var recordOption: String = "ox"
//    let recordOptions:[String] = ["ox", "recordTheQuantity"]
    
    var body: some View {
        
        let mountains:[Mountain_fb] = Array(mountainsViewModel.mountains.values)
        
        let mountainNames = mountains.filter({$0.mountainState != .archived}).map { $0.name }
        
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
                    
                    

                    TextField("퀘스트 이름", text:$mountainNameToAppend)
                        .padding(.horizontal)
                        .frame(width: geometry.size.width)
                    
                        .font(.title2)
                        .maxLength(30, text: $mountainNameToAppend)
                        .multilineTextAlignment(.center)
                        .focused($focusedTextField, equals:0)
                        .textFieldStyle(.roundedBorder)

                    
                    
//                    HStack {
                        if mountainNameToAppend == "" {
                            Text_scaleToFit("퀘스트 이름을 입력하세요")
                                .lineLimit(1)
                                .padding(.horizontal)
                                .frame(width: geometry.size.width)
                                .font(.caption)
                                .foregroundStyle(.red)
                            
                        }
                        else if mountainNames.contains(mountainNameToAppend) {
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


                        
                    }
                    .padding(.top,10)
                    .padding(.horizontal)
                    
                    
                    
                    
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
                        
                        
                        TextField("퀘스트를 요약할 이름", text: $mountainSubnameToAppend)
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
                        HStack {
                            Text_scaleToFit("시간")
                                .opacity(addPastCumulative ? 1.0 : 0.5)
                                .lineLimit(2)
                                .frame(width:geoWidth*0.1)
                                .padding(.leading)
                        }
                        .frame(idealHeight:geoHeight*0.08)
                    }
                    .padding(.horizontal)
                    

    
    
    
    
    
                    Button(action: {
                        createNewMountain()
                        dismiss.callAsFunction()
    
                    } ) {
                        Text("생성")
                    }
                    .buttonStyle(.bordered)
                    .padding(.top,10)
                    .disabled(
                        (
                            mountainNames.contains(mountainNameToAppend) || (ascentDataTypeToAppend == .custom && (customDataTypeNotation == "" || customDataTypeNotation == nil)) ||
                            mountainNameToAppend == "")
    
                    )
                    .frame(width:geometry.size.width, alignment: .center)
                    
                    
                } // Vstack
                .frame(width:geometry.size.width,alignment: .top)
                Spacer().frame(height:geoHeight*0.7)
            }
            .navigationTitle("새로운 누적 기록")
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
    
    func createNewMountain() -> Void {
        var newMountain = Mountain_fb(name: mountainNameToAppend)
        if ascentDataTypeToAppend == .custom { // should not be put in on initialization
            newMountain.customDataTypeNotation = customDataTypeNotation
        }
        if addSubName && mountainSubnameToAppend != "" { // should not be put in on initialization
            newMountain.subName = mountainSubnameToAppend
        }
        if addPastCumulative { // should not be put in on initialization
            if let pastCumulatve = Int(pastCumulative_str) {
                if ascentDataTypeToAppend == .hour {
                    newMountain.pastCumulatve = pastCumulatve * 60
                }
                else {
                    newMountain.pastCumulatve = pastCumulatve
                }
            }
        }
        
        newMountain.updateTier()
        newMountain.updateMomentumLevel()
        
        mountainsViewModel.addNewMountain(newMountain)
        
        
        
        

        
        

        


        
    }
    
    
}









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



struct EditMountain2: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var dailyRecordsViewModel: DailyRecordsViewModel
    
        
    @Binding var popUp_editMountain: Bool
    @Binding var selectedMountain: Mountain_fb?

    
    var body: some View {
        if let mountain = selectedMountain {
            EditMountain(
                dailyRecordsViewModel:dailyRecordsViewModel,
                popUp_editMountain: $popUp_editMountain,
                mountain: mountain,
                mountainName: mountain.name,
                addSubName: mountain.subName != nil,
                mountainSubname: mountain.subName ?? "",
                addPastCumulative: mountain.pastCumulatve != 0,
                pastCumulative: mountain.pastCumulatve/60,
                pastCumulative_str: String(mountain.pastCumulatve/60)
                
            )

            
        } else {
            Spacer()
        }
    }
    
    
    
}

