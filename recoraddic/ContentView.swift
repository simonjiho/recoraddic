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
    @AppStorage("iCloudAvailable") var iCloudAvailable: Bool = false
    @StateObject var netWorkMonitor: NetworkMonitor = NetworkMonitor()
    
    
    @Query var profiles: [Profile]
    @Query(sort:\Quest.name) var quests: [Quest]
    @Query(sort:\DailyRecord.date) var dailyRecords: [DailyRecord]
    @Query(sort:\DailyRecordSet.start) var dailyRecordSets: [DailyRecordSet]
    var dailyRecordSets_notHidden: [DailyRecordSet] {
        dailyRecordSets.filter({!$0.isHidden})
    }
    
    
    @Query var defaultPurposeDatas: [DefaultPurposeData]

    // 여기서 순서 지정
    let mainViews: [MainViewName] = [.checkList, .gritBoardAndStatistics, .seeMyRecord, .profileAndSettings]
    @State var selectedView: MainViewName = .checkList //HomeView
    
    @State var isNewDailyRecordAdded: Bool = false
    
    
    
    let images: [MainViewName:String] = [
        .checkList : "checklist.checked",
        .gritBoardAndStatistics: "flame",
        .seeMyRecord: "map",
        .profileAndSettings: "person.crop.circle"
        
    ] // (view name) : (ImageName)


    
    
     var body: some View {
         if !netWorkMonitor.isConnected && (!iCloudAvailable || shouldBlockTheView) { // 처음 실행 시 네트워크 연결 안되있을 때
             Text("네트워크 연결 필요")
         }
         else if !iCloudAvailable {
             Text("기기가 AppleID 로그인 되어있지 않거나\nICloud 권한이 막혀있지 않은지 확인하세요.")
// 네트워크 에러 때는?

         }
         else if shouldBlockTheView {
             Text("데이터 가져오는 중...")
         }

         
         else {
             
             // MARK: 이렇게 하지 말고, 시작 단계에서 CKRecord를 직접확인하고 없으면 CKContainer에 직접 추가해주기
             if profiles.count == 0 || dailyRecords.count == 0 || defaultPurposeDatas.count == 0 || dailyRecordSets.count == 0 {
                 // MARK: 설치 후 로그인하면 fetch 완료 후에도 local에 제대로 저장이 되지 않는 경우가 존재
                 VStack {
                     Text("새로 시작중")
                         .onAppear() {        // initialization of data(초기 설정 이후에는 여기로 들어올 가능성 0)

                             try! modelContext.save() //MARK: 강제 저장을 통해 해결(그러나 modelContext.hasChanges = false로 나타남, swiftData또는 CKSyncEngine 자체의 문제인 것으로 추정(24.03.02))
                                 
                             if profiles.count == 0 {
                                 modelContext.insert(Profile())
                             }
                             if dailyRecords.count == 0 || dailyRecordSets.count == 0 {
                                 // put functions that you wanna set as default data for debug
//                                 situation_YesterdayDataRemains()
                                 defaultInitialization()
                             }
                             if defaultPurposeDatas.count == 0 {
                                 for defaultPurpose in recoraddic.defaultPurposes {
                                     modelContext.insert(DefaultPurposeData(name: defaultPurpose))
                                 }
                             }
                             
                             // 일반적인 상황은 아니지만, cloudData가 전부 삭제되고, local에 데이터가 남아있으면 여기 갇힘...(24.03.03)
                            // 일단 chatGPT 말로는 cloudData에 직접 접근해서 기존에 존재하는 앱 데이터를 외부에서나, 사용자가 직접 다 지우는 것이 불가능하기에, 위의 언급한 문제는 벌어지지 않을 가능성이 높다.
                         }
                 }
                 
             }
             else {
                 
                 
                 let recordOfToday: DailyRecord = dailyRecords.last ?? DailyRecord(date: Calendar.current.date(byAdding: .day, value: 1000, to: .now)!) // MARK: signOutErrorPrevention: 순간 개수가 0이 됨. 왜일까!
                 
                 let currentDailyRecordSet: DailyRecordSet = dailyRecordSets.last ?? DailyRecordSet(start: Calendar.current.date(byAdding: .day, value: 1000, to: .now)!) // MARK: signOutErrorPrevention

                     
                     TabView(selection: $selectedView){
                         MainView_checklist(
                            recordOfToday: recordOfToday,
                            // recordOfYesterday is nil if it is not remained one.
                            recordOfYesterday: {  // if horizontalPosition is the 기준 of dailyRecord is yesterday's remained data.
                                if dailyRecords.count >= 2 {
                                    if dailyRecords[dailyRecords.count - 2].visualValue1 == nil {
                                        return dailyRecords[dailyRecords.count - 2]
                                    }
                                    else {
                                        return nil
                                    }
                                }
                                else {
                                    return nil
                                }
                            }(),
                            currentRecordSet: currentDailyRecordSet,
                            selectedView: $selectedView,
                            isNewDailyRecordAdded: $isNewDailyRecordAdded
 
                         )
                         .tabItem {
                             Image(systemName: images[mainViews[0]]!)
                         }
                         .tag(mainViews[0])
                         .ignoresSafeArea(.keyboard)
                         MainView_QuestAndPurposeInventory()
                         .tabItem {
                             Image(systemName: images[mainViews[1]]!)
                         }
                         .ignoresSafeArea(.keyboard)
                         .tag(mainViews[1])
                         MainView_SeeMyDailyRecord(
                            selectedDailyRecordSetIndex: dailyRecordSets_notHidden.count-1,
                            selectedDailyRecordSet: currentDailyRecordSet,
                            isNewDailyRecordAdded: $isNewDailyRecordAdded
//                            navigationBarHeight: navigationBarHeight
                         )
                         .tabItem {
                             Image(systemName: images[mainViews[2]]!)
                         }
                         .ignoresSafeArea(edges:.top)
                         .ignoresSafeArea(.keyboard)


                         .tag(mainViews[2])
                         MainView_ProfileAndSettings()
                         .tabItem {
                             Image(systemName: images[mainViews[3]]!)
                         }
                         .ignoresSafeArea(.keyboard)
                         .tag(mainViews[3])
                     }
                     

                 }
                 
                 
//             }
         }

     }
    

    
}



//struct MainButtonStyle: ButtonStyle {
//    @Environment(\.colorScheme) var colorScheme
//    
//    var size:CGFloat
//    
//
//
//    
//    init(_ size: CGFloat) {
//        self.size = size
//    }
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding(size/5)
//            .frame(width: size, height: size)
//            .foregroundStyle(getColorSchemeColor(colorScheme))
//            .background(getReversedColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
//            .cornerRadius(8)
//
//    }
//}


struct MainButtonStyle2: ButtonStyle {
    
    @Environment(\.colorScheme) var colorScheme

    
    var width:CGFloat
    var height:CGFloat
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, height/8)
            .padding(.horizontal, width/8)
            .frame(width: width, height: height)
            .foregroundStyle(getReversedColorSchemeColor(colorScheme))
            .background(getColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)

    }
}

struct MainButtonStyle3: ButtonStyle {
    

    @Environment(\.colorScheme) var colorScheme


    
    func makeBody(configuration: Configuration) -> some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let goeHeight = geometry.size.height
            
            configuration.label
                .padding(.vertical, goeHeight/8)
                .padding(.horizontal, geoWidth/8)
                .frame(width: geoWidth, height: goeHeight)
                .foregroundStyle(getReversedColorSchemeColor(colorScheme))
                .background(getReversedColorSchemeColor(colorScheme).opacity(configuration.isPressed ? 0.7 : 1))
                .cornerRadius(8)
        }

    }
}



class AppDelegate_forOrientationLock: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return Self.orientationLock
    }
}



