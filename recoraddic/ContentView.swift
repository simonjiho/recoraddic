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
    case memo
    
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


    @StateObject var netWorkMonitor: NetworkMonitor = NetworkMonitor()
//    @StateObject private var notificationManager = NotificationManager()

    
    @Query(sort:\Profile.createdTime) var profiles: [Profile]
    @Query(sort:\Quest.name) var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord] // currentDailyRecord -> date = nil -> thus it places on first on sorted array
    @Query var dailyQuests: [DailyQuest]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]

    
    // 여기서 순서 지정
    let mainViews: [MainViewName] = [.checkList, .gritBoardAndStatistics, .seeMyRecord, .memo, .profileAndSettings]
    @State var selectedView: MainViewName = .checkList //HomeView
    
    @State var isNewDailyRecordAdded: Bool = false
    
    @State var currentDailyRecord: DailyRecord?
    

    @State var restrictedHeight:CGFloat = 0
    @State var topEdgeIgnortedHeight:CGFloat = 0
    
    let images: [MainViewName:String] = [
        .checkList : "checklist.checked",
        .gritBoardAndStatistics: "flame",
        .seeMyRecord: "map",
        .profileAndSettings: "person.crop.circle",
        .memo: "note.text"
    ] // (view name) : (ImageName)


    
    
     var body: some View {

         if initialization {
             LoadingView_initialization()
                 .containerRelativeFrame([.horizontal,.vertical])
                 .onAppear() {
                 print("initializing")
                 initialize()
             }
         }
         else {
             
             // MARK: 이 조건문이 필요한가?
             if profiles.count == 0 || dailyRecords.count == 0 || dailyRecordSets.count == 0 {
                 // MARK: 설치 후 로그인하면 fetch 완료 후에도 local에 제대로 저장이 되지 않는 경우가 존재
                 LoadingView_initialization()
                     .containerRelativeFrame([.horizontal,.vertical])
                     .onAppear() {
                         DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
                             if profiles.count == 0 || dailyRecords.count == 0 || dailyRecordSets.count == 0 {
                                 initializeDatas()
                             }
                         }
                     }
                 
             }
             else {
                 
                 let profile = profiles.first ?? Profile()
//                 let showHiddenQuests: Bool = profiles.first?.showHiddenQuests ?? false
                     
                 TabView(selection: $selectedView){
                     MainView_checklist(
//                        currentRecordSet: currentDailyRecordSet,
                        selectedView: $selectedView,
                        restrictedHeight: $restrictedHeight
                        
                     )
//                     .background(.quaternary)
                     .background(.quinary)
//                     .background(colorScheme == .dark ? .quaternary : .quinary)

                     .tabItem {
                         Image(systemName: images[mainViews[0]]!)
                     }
                     .tag(mainViews[0])
                     .ignoresSafeArea(.keyboard)
                     
                     MainView_QuestInventory(selectedView:$selectedView)
                     .tabItem {
                         Image(systemName: images[mainViews[1]]!)
                     }
                     .background(.quinary)
                     .ignoresSafeArea(.keyboard)
                     .tag(mainViews[1])

                     
                     let currentDailyRecordSet: DailyRecordSet = dailyRecordSets.filter({$0.start <= getStandardDateOfNow()}).last ?? DailyRecordSet(start: getStandardDate(from: Date().addingDays(1000))) // MARK: signOutErrorPrevention(alternative DRS shouldn't be selected)
                     let index = dailyRecordSets.filter({$0.start < getStandardDateOfNow()}).count > 0 ? dailyRecordSets.filter({$0.start < .now}).count-1 : 0
                     MainView_TermSummation(
                        selectedDrsIdx: index,
                        selectedDailyRecordSet: currentDailyRecordSet,
                        isNewDailyRecordAdded: $isNewDailyRecordAdded,
                        selectedView: $selectedView,
                        restrictedHeight: $restrictedHeight,
                        topEdgeIgnoredHeight: $topEdgeIgnortedHeight
//                            navigationBarHeight: navigationBarHeight
                     )
                     .tabItem {
                         Image(systemName: images[mainViews[2]]!)
                     }
                     #if os(iOS)
                     .ignoresSafeArea(edges:.top)
                     #endif
                     .ignoresSafeArea(.keyboard)


                     .tag(mainViews[2])
                     
                     MainView_Memo(profile:profile)
//                         .fixedSize()
                         .tabItem {
                             Image(systemName: images[mainViews[3]]!)
                         }
                         .background(.quinary)
//                         .ignoresSafeArea(.keyboard)
                         .tag(mainViews[3])

                     
                     MainView_ProfileAndSettings(profile: profile)
                     .tabItem {
                         Image(systemName: images[mainViews[4]]!)
                     }
                     .background(.quinary)
                     .ignoresSafeArea(.keyboard)
                     .tag(mainViews[4])
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


                     // 아래 코드는 1.0.7 배포 후 migration 시 didMigrate에 있는 closure가 잘 작동하지 않았을 때 활성화
//                     // (11.21.2024) 임시코드 -> migration과정에서 didMigrate 부분의 코드가 실행되지 않아 일단 이 코드를 통해 실행 -> 1년 뒤 삭제
//                     // 왜 안될까!!!! Test code (testingSpace.xcodeproj 의 testingSpace18_migration.swift에서 비슷한 기능의 코드를 실행 시 잘 작동하던데...
//                     if UserDefaults.standard.bool(forKey: "ifMigrationV1toV2Fails") {
//                         for quest in quests {
//                             quest.id = UUID() // if not do this, some duplicated ids will be generated.(Don't know why) (11.21.2024)
//                             for dailyQuest in dailyQuests {
//                                 if dailyQuest.questName == quest.name {
//                                     dailyQuest.quest = quest
//                                 }
//                             }
//                         }
//                     }
                         
                             
                         
                         

                     
                 }
                 .onChange(of: selectedView) { oldValue, newValue in //여기에 다양한 것 넣어주기
                     
                     let unSavedDailyRecords = dailyRecords.filter({$0.date == nil})
//                     print("unSavedDailyRecords.count: ",unSavedDailyRecords.count)
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
                         if quest.inTrashCan {
                             if let deletedTime = quest.deletedTime {
                                 if calculateDaysBetweenTwoDates(from: deletedTime, to: .now) > 30 {
                                     modelContext.delete(quest)
                                 }
                             }

                         }

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
                                } else if mainDR.dailyText == nil {
                                    mainDR.dailyText = dr.dailyText
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
                        } else if mainDR.dailyText == nil {
                            mainDR.dailyText = dr.dailyText
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




