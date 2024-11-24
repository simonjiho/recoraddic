


//
import Foundation
import SwiftUI
import UIKit // not available on macOS
import Combine
import ActivityKit



struct MainView_checklist: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @Environment(UserDataViewModel.self) var userDataViewModel
//    @State var dailyRecordsVM: DailyRecordsViewModel = .init()
    @Bindable var dailyRecordsVM: DailyRecordsViewModel
    
//    @State var todos: [String]

    @Environment(\.colorScheme) var colorScheme
    
//    var currentRecordSet: DailyRecordSet
    
    @Binding var selectedView: MainViewName
    @Binding var restrictedHeight:CGFloat
    
//    @State var currentDailyRecord: DailyRecord = DailyRecord()
    
    @State var selectedDate: Date = Date()
    @State var popUp_addDailyMountain: Bool = false
    @State var popUp_changePurpose: Bool = false
    @State var editDiary = false
    @State var selectDiaryOption = false
    @State var selectedAscentDataId: String? = nil
    @State private var timer: Timer? = nil
    @State var todoActivated: Bool = false
    @State var keyboardAppeared = false
    @State var keyboardHeight: CGFloat = 0
    @State var changeMood: Bool = false
    @State var selectedClassification: String = "전체"
    

    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { $0.keyboardHeight },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }



    var body: some View {

        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        let currentDailyRecord = dailyRecordsVM.currentDailyRecord
        let hiddenMountainIds = userDataViewModel.userData.hiddenMountainIds
        let showHiddenMountain: Bool = userDataViewModel.userData.showHiddenMountain
        
        
//        let bgColor: Color = currentDailyRecord.dailyRecordSet?.getIntegratedDailyRecordColor(colorScheme: colorScheme) ?? Color.gray

        GeometryReader { geometry in

            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            let checkListElementWidth: CGFloat = geoWidth * 0.95
            
            let buttonSize = geoWidth*0.06
            
            
            let popUp_changeMood_width = geoWidth * 0.7
            let popUp_changeMood_height = geoHeight * 0.7
            
            let topBarTopPadding = geoHeight*0.035
            let topBarSize = geoHeight*0.05
            let facialExpressionSize = 35.0
            let topBarBottomPadding = geoHeight*0.005
            

            
            ZStack {

                VStack(spacing:0.0) {
                    let dateGap: Int = calculateDaysBetweenTwoDates(from: getStartDateOfNow(), to: selectedDate)
                    HStack(spacing:0.0) {
                        HStack {
                            Text("일기")
                                .frame(width:facialExpressionSize)
                                .font(.caption2)
                                .opacity(currentDailyRecord.dailyText == nil ? 1.0 : 0.0)
                        }
                        .padding(.leading)
                        .frame(width:geoWidth*0.15, alignment: .leading)
                    
                        HStack {
                            Circle().frame(width:5,height:5).opacity((dateGap == -3) ? 1.0 : 0.0)
                            Circle().frame(width:5,height:5).opacity((dateGap == -2 || dateGap == -3) ? 1.0 : 0.0)
                            Circle().frame(width:5,height:5).opacity((dateGap <= -1 && dateGap >= -3) ? 1.0 : 0.0)
                            if dateGap <= 3 && dateGap >= -3 {
                                Rectangle().frame(width:1,height:topBarTopPadding*0.7).opacity(dateGap == 0 ? 0.0 : 1.0)
                            } else {
                                Text("\(dateGap > 0 ? "+" : "")\(dateGap)")
                                    .font(.system(size: topBarTopPadding*0.7))
                                    .bold()
                            }
                            Circle().frame(width:5,height:5).opacity((dateGap >= 1 && dateGap <= 3) ? 1.0 : 0.0)
                            Circle().frame(width:5,height:5).opacity((dateGap == 2 || dateGap == 3) ? 1.0 : 0.0)
                            Circle().frame(width:5,height:5).opacity((dateGap == 3) ? 1.0 : 0.0)
                        }
                        .frame(width: geoWidth*0.7, height:topBarTopPadding)
                        HStack {
                            Text("표정")
                                .frame(width:facialExpressionSize)
                                .font(.caption2)

                        }
                        .padding(.trailing)
                        .frame(width:geoWidth*0.15, alignment: .trailing)

                    }
                    .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)

//                    .foregroundStyle(topForegroundColor)
//                    .border(.red)

                    HStack(spacing:0.0) {
                        if currentDailyRecord.dailyText == nil {
                            
                            Button(action:{selectDiaryOption = true}) {
                                Image(systemName:"book.closed.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(facialExpressionSize*0.1)
                                    .frame(width: facialExpressionSize, height: facialExpressionSize)

                            }
                            .padding(.leading)
                            .frame(width:geoWidth*0.15, alignment: .leading)
                            .buttonStyle(.plain)
                            
//                            .border(.red)
                        } else {
                            Spacer()
                                .frame(width:geoWidth*0.15)
                        }
                        
                        HStack(spacing: 0.0) {


                            if dateToString(selectedDate) > dateToString(Date()) {
                                Button(action: {selectedDate = Date()}) {
                                    Image(systemName: "arrow.uturn.left")
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing,7)
                                .frame(width: geoWidth*0.15, alignment: .trailing)
//                                .border(.red)
                            }
                            else {
                                Spacer()
                                    .frame(width: geoWidth*0.15)

                            }
                            DatePicker(selection: $selectedDate,displayedComponents: [.date]) {}
                                .labelsHidden()
//                                .foregroundStyle(topForegroundColor)


//                                .border(.red)

                            if dateToString(selectedDate) > dateToString(Date()) {
                                Button(action: {selectedDate = Date()}) {
                                    Image(systemName: "arrow.uturn.right")
                                }
                                .padding(.leading,7)
                                .frame(width: geoWidth*0.15, alignment: .leading)
                                .buttonStyle(.plain)
                            }
                            else {
                                Spacer()
                                    .frame(width: geoWidth*0.15)
                                
                            }
                            
                        }
                        .frame(width: geoWidth*0.7)
                        .dynamicTypeSize( ...DynamicTypeSize.xxxLarge)

                            
                        ZStack {
                            if colorScheme == .light {
                                Circle()
                                    .stroke(lineWidth: geoWidth*0.002)
                                    .frame(width:facialExpressionSize, height: facialExpressionSize)
                            } else {
                                Circle()
                                    .fill(.white)
                                    .frame(width:facialExpressionSize, height: facialExpressionSize)
                            }

                            Color.black
                                .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                .mask(
                                    Image("facialExpression_\(currentDailyRecord.mood)")
                                        .resizable()
                                        .frame(width:facialExpressionSize*0.8, height: facialExpressionSize*0.8)
                                )
                        }

                        .padding(.trailing)
                        .frame(width:geoWidth*0.15,alignment: .trailing)
                        .onTapGesture {
                            changeMood.toggle()
                        }
                        .popover(isPresented: $changeMood) {
                            VStack {
                                Picker("분류", selection: $selectedClassification) {
                                    ForEach(["전체", "😆","😀","😐","😟","😩"],id:\.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                //                            .frame(height:geoHeight*0.06)
                                ScrollView {
                                    let numList:[Int] = {
                                        
                                        if selectedClassification == "전체" {return Array(1...125)}
                                        else if selectedClassification == "😆" {return recoraddic.facialExpression_Good2}
                                        else if selectedClassification == "😀" {return recoraddic.facialExpression_Good1}
                                        else if selectedClassification == "😟" {return recoraddic.facialExpression_Bad1}
                                        else if selectedClassification == "😩" {return recoraddic.facialExpression_Bad2}
                                        else if selectedClassification == "😐" {return recoraddic.facialExpression_Middle}
                                        else { return [1]}
                                    }()
                                    let VGridSize = popUp_changeMood_width * 0.2
                                    
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: VGridSize))]) {
                                        Color.black.opacity(0.6)
                                            .mask {
                                                Image(systemName: "questionmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .blur(radius: 0.2)
                                                    .frame(width:VGridSize*0.7, height: VGridSize*0.7)
                                            }
                                            .frame(width:VGridSize, height: VGridSize)
                                            .background(reversedColorSchemeColor.opacity(0.3))
                                            .onTapGesture {
                                                
                                                dailyRecordsVM.currentDailyRecord.mood = numList[Int.random(in: 0...numList.count-1)]
                                                changeMood.toggle()

                                                
                                            } // onTapGesture
                                        
                                        
                                        ForEach(numList, id: \.self) { index in
                                            Color.black.opacity(0.6)
                                                .mask {
                                                    Image("facialExpression_\(index)")
                                                        .resizable()
                                                        .blur(radius: 0.2)
                                                        .frame(width:VGridSize*0.7, height: VGridSize*0.7)
                                                }
                                                .frame(width:VGridSize, height: VGridSize)
                                                .background(reversedColorSchemeColor.opacity(currentDailyRecord.mood == index ? 1.0 : 0.3))
                                            
                                                .shadow(radius: 1)
                                            
                                            
                                                .onTapGesture {
                                                    
                                                    if currentDailyRecord.mood == index {
                                                        dailyRecordsVM.currentDailyRecord.mood = 0
                                                    }
                                                    else {
                                                        dailyRecordsVM.currentDailyRecord.mood = index
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                            changeMood.toggle()
                                                        }
                                                    }
                                                    
                                                } // onTapGesture
                                        }
                                        
                                    } // LazyVGrid
                                    .padding(.top,10)
                                } // ScrollView
                                .frame(width: popUp_changeMood_width*0.95, height: popUp_changeMood_height*0.9)
                            }
                            .padding(.horizontal,popUp_changeMood_width*0.02)
                            .padding(.vertical,popUp_changeMood_height*0.02)
                            .frame(width: popUp_changeMood_width, height: popUp_changeMood_height, alignment: .top)
                            .presentationCompactAdaptation(.popover)
                            
                            
                        }
                        
                        // use "in:" to add date range
                    }
                    .frame(height: topBarSize)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
//                    .padding(.top,geoHeight*0.035)
                    .padding(.bottom, topBarBottomPadding)
//                    .foregroundStyle(topForegroundColor) // 너무 튀는 것 같기도 하고..

                    


                    Color.gray
                        .opacity(0.4)
                        .frame(width: checkListElementWidth, height: 1)
                        .padding(.top, geoHeight*0.015)

                
                    ChecklistView(
                        hiddenMountainIds: hiddenMountainIds,
                        showHiddenMountain: showHiddenMountain,
                        editDiary: $editDiary,
                        selectDiaryOption: $selectDiaryOption,
                        todoActivated: $todoActivated,
                        keyboardAppeared: $keyboardAppeared,
                        keyboardHeight: $keyboardHeight,
                        changeMood: $changeMood
                    )
                }
                .frame(width:geometry.size.width, height: geometry.size.height, alignment: .top)

                HStack(spacing:0.0) {
                    
                    Button(action:{selectedDate = selectedDate.addingDays(-1)}) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .padding(.leading, 20)
                    .frame(width:geoWidth*0.35, alignment: .leading)
                    .buttonStyle(CheckListButtonStyle3(color: reversedColorSchemeColor))

                    Button(action:{
                        popUp_addDailyMountain.toggle()
                        selectDiaryOption = false // ??
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .buttonStyle(CheckListButtonStyle3(color: reversedColorSchemeColor))
                    .frame(width:geoWidth*0.3)
                    
                    Button(action:{selectedDate = selectedDate.addingDays(1)}) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width:buttonSize, height:buttonSize)
                    }
                    .padding(.trailing, 20)
                    .frame(width:geoWidth*0.35, alignment: .trailing)
                    .buttonStyle(CheckListButtonStyle3(color: reversedColorSchemeColor))

                }
                .position(x:geoWidth/2, y:geoHeight*0.95 - 10)


                



                
            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear {
                
                changeDailyRecord()
                startTimer()
                setKeyboardAppearanceStateValue()
                if restrictedHeight == 0 { restrictedHeight = geoHeight }
                
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .onReceive(keyboardHeightPublisher) { value in

                if keyboardAppeared {
                    withAnimation {
                        self.keyboardHeight = value*0.75 //MARK: navigationBarHeight does not contain the bottom safeArea of display, so it is less than actual navigationBarHeight that is displayed
                    }


                }
                else {
                    withAnimation { //MARK: debuger message: Bound preference ViewFrameKey tried to update multiple times per frame. May cause problem later.
                        self.keyboardHeight = value
                    }
                }

            }
//            .onChange(of: selectedView) { oldValue, newValue in
//                
//                for ascentData in currentDailyRecord.ascentDataList! {
//                    ascentData.currentTier = mountains.first(where: {$0.name == ascentData.mountainName && !$0.inTrashCan})?.tier ?? 0
//                }
//                
//            }


            .popover(isPresented: $popUp_addDailyMountain) {
                EditCheckListView(
                    dailyRecordsVM: dailyRecordsVM,
                    popUp_self: $popUp_addDailyMountain,
                    selectedView: $selectedView,
                    todoIsEmpty: currentDailyRecord.todoList?.isEmpty ?? true
                )
                .presentationCompactAdaptation(.fullScreenCover)
                .ignoresSafeArea(.keyboard)
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)

            }
            
            .onChange(of: selectedDate) { oldValue, newValue in
                
//                selectedDate = getStandardDate(from: newValue) // No worry of infinite onChangeCall
                
                
                
                if oldValue < getStandardDateOfYesterday() {
                    removeUselessData()
                }
                changeDailyRecord()
            }


 

        }
        



    }
    


    
    
    func startTimer() { // 오늘의 자정에 timer 맞추기 ( 24/07/11 12:00 -> 24/07/12 00:00 에 작동하는 타이머 설정)
        // MARK: 과연 00:00 에 작동하는가? 23:59에 작동할 가능성은?
        let date = Date()
        let calendar = Calendar.current
        let tommorow = getTomorrowOf(date)
        let timeInterval = tommorow.timeIntervalSince(date)

    }
    
    func setKeyboardAppearanceStateValue() -> Void {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in

            withAnimation {
                keyboardAppeared = true
            }
        }
        

        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardAppeared = false
            }
        }
    }
    
    
    func changeDailyRecord() -> Void {
        dailyRecordsVM.changeCurrentDailyRecord(selectedDate)
    }
        

    func removeUselessData() -> Void {
        // remove empty ascentData or todos
    }
    
    func cleanUpDailyRecords() -> Void { // 1. keep dailyRecord whose date is nil be unique  / 2. delete empty DailyRecords that's been not used for a long
        
    }

    

}


struct CheckListButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    

    init() {
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal,10)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
//            .background(getColorSchemeColor(colorScheme))
            .background(.thinMaterial)
            .clipShape(.buttonBorder)

    }
}

struct CheckListButtonStyle2: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    

    init() {
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
//            .background(getColorSchemeColor(colorScheme))
            .background(.ultraThinMaterial)
            .clipShape(.buttonBorder)

    }
}


struct CheckListButtonStyle3: ButtonStyle {
    
    let color: Color

    init(color:Color) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .foregroundStyle(color)
//            .background(getColorSchemeColor(colorScheme))
            .background(.ultraThinMaterial)
            .clipShape(.buttonBorder)

    }
}




// + special + dayOff(아무것도 기록하고 싶지 않은 날) -> dates/7 개 주어짐.
// 여기서는 checklist의 data들이 시각화되고, 시각화된 부분을 제스처로 제어하는 부분만 구현(QCBD 수정&삭제, DR.diary 수정&삭제 등등)
struct ChecklistView: View {
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(DailyRecordsViewModel.self) var dailyRecordsVM
    @Environment(MountainsViewModel.self) var mountainViewModel
    
    var hiddenMountainIds:[String]
    var showHiddenMountains: Bool
    
    
    @Binding var editDiary: Bool
    @Binding var selectDiaryOption: Bool
    @Binding var todoActivated: Bool
    @Binding var keyboardAppeared: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var changeMood: Bool
    @Binding var forceToChooseMood: Bool
    
    
    @State var applyDailyMountainRemoval: Bool = false
    @State var applyDailyTextRemoval: Bool = false
    @State var targetMountainId: String?
    @State var popUp_changePurpose: Bool = false
    @State var selectedAscentData: String? // mountain id
    
    @State var editingId: String?
    @State var doneButtonPressed: Bool = false
    
    
    @State var diaryViewWiden: Bool = false
    
    @State var todos:[String] = []
    @State var schedules:[String] = []
    
    
    
    
    var body: some View {
        
        let currentDr = dailyRecordsVM.currentDailyRecord
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        
        
        let mountainIds = currentDr.ascentData.keys
        let mountainIds_notHidden_sorted = mountainIds.filter({!showHiddenMountains && !hiddenMountainIds.contains($0.mountainId)}).sorted(by:{
            if $0.notfTime != nil && $1.notfTime != nil {
                return $0.notfTime! <= $1.notfTime!
            }
            else if $0.notfTime != nil && $1.notfTime == nil {
                return true
            }
            else if $0.notfTime == nil && $1.notfTime != nil {
                return false
            }
            
            else {
                return $0.createdTime < $1.createdTime  // Sort by Name in ascending order
            }
            
            
        })
        
        let diaryExists: Bool = currentDr.dailyTextType != nil
        let ascentDataExists: Bool = mountainIds_notHidden_sorted.count !=  0
        let todoExists: Bool = currentDr.todos.count != 0
        
        
        GeometryReader { geometry in
            
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            
            let checkListElementWidth = geometry.size.width*0.97
            
            let mountainCheckBox_purposeTagsWidth = checkListElementWidth*0.1
            let mountainCheckBoxWidth = checkListElementWidth*0.9
            let mountainCheckBoxHeight:CGFloat = 55.0

            
            let todo_purposeTagsWidth = checkListElementWidth * 0.1
            let todo_checkBoxSize = checkListElementWidth * 0.1
            let todo_textWidth = editingId == nil ? checkListElementWidth * 0.7 : checkListElementWidth * 0.8
            let todo_xmarkSize = checkListElementWidth * 0.1
            let todo_height = geoHeight * 0.06
            
            let purposeTagsMaxLength = geometry.size.width*0.2
            let purposeTagsHeight = geometry.size.height*0.04
            
            let diaryHeight = (currentDr.dailyTextType == DailyTextType.diary && editDiary) ? (geometry.size.height - keyboardHeight)*0.9 : mountainCheckBoxHeight
            

            
            ZStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
        
                        Spacer()
                            .frame(height: geoHeight*0.02)
                        
                        if selectDiaryOption {
                            ZStack {
                                HStack(spacing:geoWidth*0.1) {
                                    Button("요약", action:{
                                        editDiary = true // 아래하고 순서 바뀌면 안됨
                                        dailyRecordsVM.currentDailyRecord.dailyTextType = DailyTextType.inShort
                                        dailyRecordsVM.currentDailyRecord.dailyText = ""
                                        if currentDailyRecord.singleElm_diary {
                                            dailyRecordsVM.currentDailyRecord.dailyRecordSet?.updateDailyRecordsMomentum()
                                        }
                                        selectDiaryOption = false
                                    })
                                    .buttonStyle(.bordered)
                                    Button("길게", action:{
                                        editDiary = true // 아래하고 순서 바뀌면 안됨
                                        dailyRecordsVM.currentDailyRecord.dailyTextType = DailyTextType.diary
                                        dailyRecordsVM.currentDailyRecord.dailyText = ""
                                        selectDiaryOption = false
                                        
                                    })
                                    .buttonStyle(.bordered)
                                }
                                Button(action:{
                                    selectDiaryOption.toggle()
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .frame(width:checkListElementWidth, alignment:.trailing)
                            }
                            .padding()
                            
                        }

                        
                        if (currentDr.dailyTextType == DailyTextType.diary) {
                            
                            DiaryView(
                                currentDailyRecord: currentDailyRecord,
                                diaryText: currentDr.dailyText!,
                                applyDiaryRemoval: $applyDailyTextRemoval,
                                isEdit: $editDiary
                            )
                            .frame(width:checkListElementWidth, height: diaryHeight)
                            
                        }
                        else if (currentDr.dailyTextType == DailyTextType.inShort) {
                            InShortView(
                                currentDailyRecord: currentDailyRecord,
                                inShortText: currentDr.dailyText!,
                                applyDailyTextRemoval: $applyDailyTextRemoval
                                //                                    isEdit: $editDiary
                            )
                            .frame(width:checkListElementWidth, height: diaryHeight)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            
                            
                        }
                        
                        
                        if diaryExists {
                            Color.gray
                                .opacity(0.4)
                                .frame(width: checkListElementWidth, height: 1)
                                .padding(.vertical, geoHeight*0.01)
                        }
                        
                        
                        VStack(spacing:5.0) {
                            ForEach(mountainIds_notHidden_sorted, id: \.self) { mountainId in
                                
                                let data = currentDr.ascentData[mountainId] ?? 0
                                let xOffset:CGFloat = data == 0 ? 0.1 : CGFloat(data).map(from:0.0...CGFloat(currentDr.dailyGoals[mountainId] ?? data), to: 0...checkListElementWidth)
                                let isRecent: Bool = {
                                    if let date = dailyRecordsVM.currentDate {
                                        return dateToString(Date().addingDays(-1)) <= date
                                    } else { return false }
                                }()
                                DailyAscentView(
                                    mountainId: mountainId,
                                    targetMountainId: $targetMountainId,
                                    deleteTarget: $applyDailyMountainRemoval,
//                                    value: data,
                                    minutes: dailyRecordsVM.bindingAscentData(for:mountainId),
//                                    dailyGoal: ascentData.dailyGoal,
                                    dailyGoal: dailyRecordsVM.bindingDailyGoal(for:mountainId),
                                    notifTime: dailyRecordsVM.bindingNotfTime(for:mountainId),
                                    xOffset: xOffset,
                                    width: checkListElementWidth,
                                    isRecent: isRecent
                                )
                                
                            }
                        }
                        if ascentDataExists {
                            Color.gray
                                .opacity(0.4)
                                .frame(width: checkListElementWidth, height: 1)
                                .padding(.vertical, geoHeight*0.01)
                        }
                        
                        
//                        let todoList_sorted = currentTodos.sorted(by: {$0.idx < $1.idx})
                        
                        VStack (spacing:todo_height*0.2) {
                            ForEach(Array(currentDr.todos_order.enumerated()), id:\.self) { idx, todoId in
//                                if currentDr.todos.keys.contains(todoId) {
                                if idx < todos.count {
                                    HStack(spacing:0.0) {
                                        PurposeOfTodoView(todoId: todoId, parentWidth: geoWidth, parentHeight: geoHeight)
                                            .frame(width:todo_purposeTagsWidth, height: todo_height)
                                        Button(action:{
                                            dailyRecordsVM.updateTodoDone(todoId: todoId)
                                        }) {
                                            let checkBoxSize = min(todo_checkBoxSize, todo_height)
                                            Image(systemName: currentDr.todos_done[todoId] ?? false ? "checkmark.circle" : "circle")
                                                .resizable()
                                                .frame(width: mountainCheckBoxWidth*0.1*0.65, height: mountainCheckBoxWidth*0.1*0.65)
                                        }
                                        .frame(width: mountainCheckBoxWidth*0.1, alignment: .center)
                                        .buttonStyle(.plain)
                                        
                                        Group {
                                            TextField("", text: $todos[idx])
                                                .padding(.leading, 5)
                                                .frame(width:editingId == todoId ? todo_textWidth*0.8 : todo_textWidth)
                                                .minimumScaleFactor(0.85)
                                                .focused(editingId == todoId)
                                                .onSubmit() {
                                                    insertTodo(prevTodoId: todoId, idx:idx)
                                                }
                                        }
                                        .frame(width:mountainCheckBoxWidth*0.8, alignment:.leading)
                                        
                                        if editingId == todoId {
                                            Button("완료") {
                                                submitTodo(todoId: todoId, idx: idx)
                                                editingId = nil
                                                self.todos = dailyRecordsVM.todoOrder_existencySafe
                                            }
                                            .frame(width:mountainCheckBoxWidth*0.1)
                                            .minimumScaleFactor(0.3)
                                        }
                                        
                                        if editingId == nil {
                                            Button(action:{
                                                dailyRecordsVM.deleteTodo(todoId)
                                                
                                            }) {
                                                let xmarkSize = min(todo_xmarkSize, todo_height)
                                                Image(systemName: "xmark")
                                            }
                                            .buttonStyle(.plain)
                                            //                                            .frame(width: todo_xmarkSize, alignment: .trailing)
                                            //                                            .frame(width: mountainCheckBoxWidth*0.1, alignment:.leading)
                                            .frame(width: mountainCheckBoxWidth*0.1)
                                        }
                                        
                                        
                                        
                                    }
                                    .frame(width: checkListElementWidth, height:todo_height, alignment:.leading)
                                    .id(todoId)
                                }


                                
                            }

                            
                            if editingId != nil {
                                HStack {
                                    Image(systemName: "return")
                                    Text("엔터 키를 통해 계속 입력 가능")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(width:checkListElementWidth)
                                .opacity(0.5)
                            } else {
                                HStack(spacing:0.0) {
                                    let tagSize = min(todo_purposeTagsWidth*0.8,todo_height*0.3)
                                    HStack {
                                        Image(systemName:"questionmark.square")
                                            .resizable()
                                            .frame(width:tagSize, height:tagSize)
                                            .foregroundStyle(reversedColorSchemeColor)
                                        
                                    }
                                    .frame(width: todo_purposeTagsWidth)
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .frame(width: mountainCheckBoxWidth*0.1*0.65, height: mountainCheckBoxWidth*0.1*0.65)
                                    }
                                    .frame(width: mountainCheckBoxWidth*0.1, alignment: .center)
                                    
                                    //                                        HStack(spacing:0.0) {
                                    if let date = currentDr.getLocalDate() {
                                        if date < getStartDateOfNow() {
                                            Text("클릭하여 달성한 일 적기")
                                                .frame(width:mountainCheckBoxWidth*0.8, alignment:.leading)
                                        }
                                        else if date == getStartDateOfNow() {
                                            Text("클릭하여 당장 생각나는 할 일 적기")
                                                .lineLimit(2)
                                                .frame(width:mountainCheckBoxWidth*0.8, alignment:.leading)
                                            
                                        }
                                        else {
                                            Text("클릭하여 나중에 할 일 적기")
                                                .frame(width:mountainCheckBoxWidth*0.8, alignment:.leading)
                                        }
                                    }
                                    
                                    //                                            }
                                    //                                        }
                                    //                                        .frame(width:mountainCheckBoxWidth*0.8, alignment:.leading)
                                    
                                    Spacer()
                                        .frame(width:mountainCheckBoxWidth*0.1)
                                }
                                .frame(width: checkListElementWidth, /*height:todo_height,*/ alignment:.leading)
                                .opacity(0.5)
                                .onTapGesture {
                                    insertTodo(prevTodoId: todoId ?? "", idx:todos.count-1)
                                }
                                
                            }
                        }
                        .dynamicTypeSize( ...DynamicTypeSize.accessibility2)
                        
                        
                        Spacer()
                            .frame(width: geometry.size.width, height: keyboardAppeared ? ( editDiary ? keyboardHeight*1.1 : keyboardHeight + geoHeight * 0.3): geometry.size.height*0.4)
                        
                        //                            TestNotificationView()
                        
                        
                        
                        //                        } // VStack
                        
                        
                    } // scroll view
                    .frame(width:geometry.size.width, height: geometry.size.height)
                    .onChange(of: editingId) {
                        //                            print("changed!!!")
                        if editingId != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    scrollProxy.scrollTo(editingId,anchor: .center)
                                }
                            }
                        }
                    }
                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
                    .scrollDisabled(editDiary)
                    
                }

                
                
            } // zstack
            .frame(width:geometry.size.width, height: geometry.size.height)
            .onAppear() {
                todos = dailyRecordsVM.currentDailyRecord.todos_order.compactMap({dailyRecordsVM.currentDailyRecord.todos[$0]})
                
            }
            .onChange(of: applyDailyMountainRemoval, removeDailyAscent)
            .onChange(of: applyDailyTextRemoval, removeDailyText)
            .onChange(of: dailyRecordsVM.currentDailyRecord, {
                editDiary = false
                editingId = nil
                diaryViewWiden = false
            })
//            .refreshable {
//                Task {
//                    await dailyRecordsVM.refreshCurrentDailyRecord(currentDailyRecord.id)
//                }
                // when refreshed?
                // 아래로 당기면?
//            }
            .onTapGesture {
                targetMountainId = nil
            }
            
            
            
        }
        
        
        
    }
    
    func submitTodo(todoId: String, idx: Int) -> Void {
        dailyRecordsVM.updateTodoContent(todoId:todoId, to: todos[idx])
    }
    
    func insertTodo(prevTodoId: String, idx: Int) -> Void {
        self.todos.insert("", at: idx+1)

        dailyRecordsVM.insertTodo(after: prevTodoId)
        
        // in case of todo is appended
        let newTodos = dailyRecordsVM.todoOrder_existencySafe
        self.todos = dailyRecordsVM.todoOrder_existencySafe
        if idx >= newTodos.count-1 {
            Task {
                editingId = todos.last ?? nil
            }
        }
        else {
            Task {
                editingId = todos[idx+1]
            }
        }
        

    }
    
    
    func removeDailyAscent() -> Void {
        
        guard let selectedDate_str = dailyRecordsVM.currentDailyRecord.id else { return }
        
        if let targetMountainId = targetMountainId {
            let mountainName = mountainViewModel.nameOf(targetMountainId)
            updateMountain_onDelete(for: targetMountainId)
            if let alermTime = ascentData.notfTime {
                removeNotification(at: alermTime, for: mountainName) // MARK: mountainName 변경 시 지울 수 없음
            }
            dailyRecordsVM.deleteAscentData(targetMountainId)
        }
        targetMountainId = nil
        

    }
    
    func updateMountain_onDelete(for targetMountainId: String) -> Void {
        
        guard let selectedDate_str = currentDailyRecord.id else { return }
        //        guard let targetMountain = mountainViewModel.mountains.first(where: {$0.id == ascentData.mountainId}) else { return }
        
        Task {
            await mountainViewModel.removeDailyData(selectedDate_str, mountainId)
        }
        mountainViewModel.mountains[targetMountainId]?.updateTier()
        mountainViewModel.mountains[targetMountainId]?.updateMomentumLevel()
    }
    
    
    func removeDailyText() -> Void {
        dailyRecordsVM.currentDailyRecord.dailyText = nil
        dailyRecordsVM.currentDailyRecord.dailyTextType = nil
        if !currentDailyRecord.hasContent {
            
        }
        editDiary = false
        diaryViewWiden = false
    }



}




struct CountdownView: View {
    
    
    @State private var timeRemaining: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(dueDate: Date) {
        let dueDate_10am: Date = Calendar.current.date(byAdding: .hour, value: 10, to: dueDate)!
        _timeRemaining = State(initialValue: Int(dueDate_10am.timeIntervalSince(Date())))
    }

    var body: some View {
        Text("\(timeString(time: TimeInterval(timeRemaining)))")
            .opacity(0.5)
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
    }

    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}






