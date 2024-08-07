//
//  ContentView.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

// make configuration of some features, such as the view's size for each device
// TODO: network연결 끊기면 DR 저장 불가능하게 하기
// TODO: 지속적으로 화면 상태 초기화해서 데이터 동기화된 것 바로 적용하기

// TODO: 지금 당장 해결해야하는 것: 기기를 옮겼을 때 동기화 완료할 때까지 edit 막기 -> 이것만 하면 튜토리얼만 만들고 바로 한국출시는 가능.

// MARK: signOutErrorPrevention: 로그아웃 시 Error가 발생하는 것을 막기 위한 코드


// need to integrate imports in one file
import SwiftUI
import SwiftData
import CloudKit
import Network


enum MainViewName {
    case checkList
    case gritBoardAndStatistics
    case seeMyRecord
    case profileAndSettings
    
}

let sampleData: Bool = false


// MARK: cloud 연결확인 코드 후보3
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}



struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("shouldBlockTheView") var shouldBlockTheView: Bool = true
    @AppStorage("iCloudAvailable_forTheFirstTime") var iCloudAvailable: Bool = false
    @AppStorage("initialization") var initialization: Bool = true
    @AppStorage("fetchDone") var fetchDone: Bool = false
    @AppStorage("update_240808") var update_240808: Bool = false


    @StateObject var netWorkMonitor: NetworkMonitor = NetworkMonitor()
//    @StateObject private var notificationManager = NotificationManager()

    
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query(sort:\Quest.name) var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord] // currentDailyRecord -> date = nil -> thus it places on first on sorted array
    @Query var dailyQuests: [DailyQuest]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]

    
    
    @Query var defaultPurposeDatas: [DefaultPurposeData]

    // 여기서 순서 지정
    let mainViews: [MainViewName] = [.checkList, .gritBoardAndStatistics, .seeMyRecord, .profileAndSettings]
    @State var selectedView: MainViewName = .checkList //HomeView
    
    @State var isNewDailyRecordAdded: Bool = false
    
    @State var currentDailyRecord: DailyRecord?
    
//    @State var todayRecordExists: Bool = false
//    @State var yesterday
    
    
    let images: [MainViewName:String] = [
        .checkList : "checklist.checked",
        .gritBoardAndStatistics: "flame",
        .seeMyRecord: "map",
        .profileAndSettings: "person.crop.circle"
        
    ] // (view name) : (ImageName)


    
    
     var body: some View {

         if initialization {
             Text("초기화 중")
             .onAppear() {
                 print("initializing")
                 initialize()
             }
         }
         else {
             
             // MARK: 이 조건문이 필요한가?
             if profiles.count == 0 || dailyRecords.count == 0 || defaultPurposeDatas.count == 0 || dailyRecordSets.count == 0 {
                 // MARK: 설치 후 로그인하면 fetch 완료 후에도 local에 제대로 저장이 되지 않는 경우가 존재
                 VStack {
                     Text("새로 시작중")
                 }
                 
             }
             else {
                 
                 let profile = profiles.first ?? Profile()
//                 let showHiddenQuests: Bool = profiles.first?.showHiddenQuests ?? false
                     
                 TabView(selection: $selectedView){
                     MainView_checklist(
//                        currentRecordSet: currentDailyRecordSet,
                        selectedView: $selectedView
                        
                     )
                     .background(.quaternary)
                     .tabItem {
                         Image(systemName: images[mainViews[0]]!)
                     }
                     .tag(mainViews[0])
                     .ignoresSafeArea(.keyboard)
                     
                     MainView_QuestInventory()
                     .tabItem {
                         Image(systemName: images[mainViews[1]]!)
                     }
                     .ignoresSafeArea(.keyboard)
                     .tag(mainViews[1])

                     let currentDailyRecordSet: DailyRecordSet = dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).last ?? DailyRecordSet(start: getStandardDate(from: Date().addingDays(1000))) // MARK: signOutErrorPrevention
                     let index = dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).count > 0 ? dailyRecordSets.filter({$0.start < .now}).count-1 : 0
                     MainView_SeeMyDailyRecord(
                        selectedDailyRecordSetIndex: index,
                        selectedDailyRecordSet: currentDailyRecordSet,
                        isNewDailyRecordAdded: $isNewDailyRecordAdded,
                        selectedView: $selectedView
//                            navigationBarHeight: navigationBarHeight
                     )
                     .tabItem {
                         Image(systemName: images[mainViews[2]]!)
                     }
                     .ignoresSafeArea(edges:.top)
                     .ignoresSafeArea(.keyboard)


                     .tag(mainViews[2])
                     MainView_ProfileAndSettings(profile: profile)
                     .tabItem {
                         Image(systemName: images[mainViews[3]]!)
                     }
                     .ignoresSafeArea(.keyboard)
                     .tag(mainViews[3])
                 }
                 .onAppear() {
                     NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "fetchDone"), object: nil, queue: .main) { _ in
                         DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                             print("merge datas")
                             reorganizeDailyRecord()
                             mergeDuplicatedDRS()
                             mergeDuplicatedDR()
                             try? modelContext.save()
                         }
                     }

//                      codes used for data transition
                     if UserDefaults.standard.value(forKey: "update_240809") == nil {
                         UserDefaults.standard.setValue(false, forKey: "update_240809")
                     }
                     if !update_240808 {
                         let dateComponents = DateComponents(calendar: Calendar.current, year:2024, month: 8, day: 7, hour:10, minute: 15)
                         for dailyQuest in dailyQuests {
                             if dailyQuest.createdTime < Calendar.current.date(from: dateComponents)! {
                                 if dailyQuest.dataType == DataType.custom.rawValue {
                                     dailyQuest.dataType = DataType.ox.rawValue
                                 }
                                 else if dailyQuest.dataType == DataType.ox.rawValue {
                                     dailyQuest.dataType = DataType.custom.rawValue
                                 }
                             }
                         }
                         
                         for quest in quests {
                             if quest.createdTime < Calendar.current.date(from: dateComponents)! {
                                 if quest.dataType == DataType.custom.rawValue {
                                     quest.dataType = DataType.ox.rawValue
                                 }
                                 else if quest.dataType == DataType.ox.rawValue {
                                     quest.dataType = DataType.custom.rawValue
                                 }
                             }
                         }
                         UserDefaults.standard.setValue(true, forKey: "update_240809")
                     }
                 }
                 .onChange(of: selectedView) { oldValue, newValue in //여기에 다양한 것 넣어주기
                     
                     let unSavedDailyRecords = dailyRecords.filter({$0.date == nil})
                     print("unSavedDailyRecords.count: ",unSavedDailyRecords.count)
                     if unSavedDailyRecords.count > 1 {
                         var unSavedDailyRecords_sorted = unSavedDailyRecords.sorted(by: {$0.createdTime < $1.createdTime})
                         unSavedDailyRecords_sorted.removeLast()
                         for unSavedDailyRecord in unSavedDailyRecords_sorted {
                             modelContext.delete(unSavedDailyRecord)
                         }
                     }
                     
                     
                     for quest in quests {
                         quest.updateTier()
                         quest.updateMomentumLevel()
                     }
                     
                     
                 }

                     
                     

            }

                 
                 
//             }
         }
    

     }
    
    
    func initialize() -> Void {
        // Usage example
        checkiCloudAccountStatus { (status, error) in
            switch status {
            case .available:
                print("iCloud available")
                UserDefaults.standard.setValue(true,forKey: "iCloudAvailable_forTheFirstTime")
                Task {
                    
                    print("waiting for fetchDone")
                    while !fetchDone {
                        // Wait for a short interval before checking again
                        try? await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                    }
                    print("waiting for extra fetch process")
                    try? await Task.sleep(nanoseconds: UInt64(6.0 * Double(NSEC_PER_SEC))) // TODO: fetchDone이 되어도 실제로 데이터에 적용이 안되있었다. 그래서 좀 더 기다리니 확실하게 적용되었다. 나중엔 좀 더 정확한 기준이 필요함.
                    
                    initializeDatas()
                    UserDefaults.standard.setValue(false,forKey: "initialization")
                }


            default:
                print("Unknown iCloud status")
                initializeDatas()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UserDefaults.standard.setValue(false,forKey: "initialization")
                }
                
            }
            
            
            if let error = error {
                print("Error checking iCloud account status: \(error.localizedDescription)")
            }
        }
        
        
        
    }
    
    func mergeDuplicatedDRS() -> Void {
        print("mergingDuplicatedDRS")
        let drsDates:[Date] = dailyRecordSets.map({$0.start})
        for date in drsDates {
            var dupDRS:[DailyRecordSet] = dailyRecordSets.filter({$0.start == date})
            if dupDRS.count > 1 {
                if let mainDRS = dupDRS.sorted(by: {$0.createdTime <= $1.createdTime}).first {
                    dupDRS.removeFirst()
                    for drs in dupDRS {
                        for dr in drs.dailyRecords! {
                            if let mainDR = mainDRS.dailyRecords!.first(where:{$0.date == dr.date}) {
                                mainDR.dailyQuestList! += dr.dailyQuestList!
                                mainDR.todoList! += dr.todoList!
                                if mainDR.dailyText != nil && dr.dailyText != nil {
                                    mainDR.dailyText! += dr.dailyText!
                                }
                                modelContext.delete(dr)
                            } else {
                                dr.dailyRecordSet = mainDRS
                            }
                        }
                        modelContext.delete(drs)
                    }
                }
                
            }
        }
        
    }
    
    func mergeDuplicatedDR() -> Void {
        print("mergingDuplicatedDR")
        let drDates:[Date] = dailyRecords.compactMap({$0.date})
        for date in drDates {
            var dupDR:[DailyRecord] = dailyRecords.filter({$0.date == date})
            if dupDR.count > 1 {
                if let mainDR = dupDR.sorted(by: {$0.createdTime <= $1.createdTime}).first {
                    dupDR.removeFirst()
                    for dr in dupDR {
                        mainDR.dailyQuestList! += dr.dailyQuestList!
                        mainDR.todoList! += dr.todoList!
                        if mainDR.dailyText != nil && dr.dailyText != nil {
                            mainDR.dailyText! += dr.dailyText!
                        }
                        modelContext.delete(dr)
                    }
                }
                
            }

        }
    }
    
    func reorganizeDailyRecord() -> Void {
        print("reorganizingDailyRecord")
        for dailyRecord in dailyRecords {
            if let date = dailyRecord.date {
                if let nearestDRS:DailyRecordSet = dailyRecordSets.filter({$0.start <= date}).last {
                    if nearestDRS.start != dailyRecord.dailyRecordSet?.start {
                        dailyRecord.dailyRecordSet = nearestDRS
                    }
                }
                
                
            }
        }
    }

        
    func initializeDatas() -> Void {
        if profiles.count == 0 {
            modelContext.insert(Profile())
        }
        if dailyRecords.count == 0 || dailyRecordSets.count == 0 {
            // put functions that you wanna set as default data for debug
            if sampleData {
                situation_YesterdayDataRemains()
            }
            else {
                defaultInitialization()
            }
        }
        if defaultPurposeDatas.count == 0 {
            for defaultPurpose in recoraddic.defaultPurposes {
                modelContext.insert(DefaultPurposeData(name: defaultPurpose))
            }
        }
    }

    
}

func checkiCloudAccountStatus(completion: @escaping (CKAccountStatus, Error?) -> Void) {
    let container = CKContainer.default()
    
    container.accountStatus { (status, error) in
        DispatchQueue.main.async {
            completion(status, error)
        }
    }
}




