//
//  recoraddictionApp.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//



// MARK: Recoraddic의 기조: 1)기록 삭제는 가능하지만 기록 수정은 불가능하다. 2)각각의 기록 삭제(quest <-> dr&drs)는 서로의 데이터에 영향을 끼치지 않는다.


// openSettingsURLString -> For direct to cloud setting


import SwiftUI
import SwiftData
import CloudKit
import UserNotifications
import CoreData


@main
struct recoraddicApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject private var activityManager = ActivityManager()

    
    static let container = try! ModelContainer(for:Schema([Quest.self, Todo.self, DailyQuest.self, DailyRecord.self, DefaultPurposeData.self, DailyRecordSet.self, Profile.self, Todo_preset.self]), configurations: ModelConfiguration(cloudKitDatabase: ModelConfiguration.CloudKitDatabase.automatic))

    var syncManager: SyncManager = SyncManager()

    
    var body: some Scene {

        
        WindowGroup {
            ContentView()
//                .environmentObject(activityManager)
                .onAppear() {
                    print("App started")
                    if UserDefaults.standard.value(forKey: "stateSerialization") == nil {
                        UserDefaults.standard.setValue(nil, forKey: "stateSerialization")
                    }

                    if UserDefaults.standard.value(forKey: "initialization") == nil {
                        UserDefaults.standard.setValue(true, forKey: "initialization")
                    }
                    if UserDefaults.standard.value(forKey: "shouldBlockTheView") == nil {
                        UserDefaults.standard.setValue(false,forKey: "shouldBlockTheView") // at initial, it starts with true
                    }
                    if UserDefaults.standard.value(forKey: "iCloudAvailable_forTheFirstTime") == nil {
                        UserDefaults.standard.setValue(false,forKey: "iCloudAvailable_forTheFirstTime")
                    }
                    if UserDefaults.standard.value(forKey: "fetchDone") == nil {
                        UserDefaults.standard.setValue(false,forKey: "fetchDone")
                    }
                    
                    
                    
//                    NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidMergeChangesObjectIDs, object: nil, queue: .main) { (notification) in
//                        print("didSave")
//                        
//                        UserDefaults.standard.setValue(false, forKey: "shouldBlockTheView") // MARK: 너무 빨리 풀면 query가 적용이 안됨...swiftData와 cloudSyncEngine의 문제인가? 로그인 후 설치는 괜찮지만 설치 후 로그인은 문제가 됨.... ㅅㅂ?
//                    }
                }
//                .onChange(of: <#T##V#>, <#T##(V, V) -> Void#>)
        }

        .modelContainer(Self.container)

    


    }
}

//extension Notification.Name {
//    static let scenePhaseChanged = Notification.Name("scenePhaseChanged")
//}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
                self.setupNotificationCategories()
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        return true
    }
    

//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if url.scheme == "stopWatch" && url.host == "recoraddic" {
//            url.description
//            // Handle the tap on the Live Activity
//            NotificationCenter.default.post(name: .specificNotification, object: nil, userInfo: <#T##[AnyHashable : Any]?#>)
//            return true
//        }
//        return false
//    }
//    
////     This method is called when the app is opened from a notification
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        handleNotification(userInfo)
//        completionHandler(.newData)
//    }
//    
//    
//    // This method is called when the app is opened from a notification while being in the background
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        handleNotification(userInfo)
//    }
//
//    func handleNotification(_ userInfo: [AnyHashable : Any]) {
//        NotificationCenter.default.post(name: Notification.Name(""), object: nil, userInfo: userInfo)
//    }

    private func setupNotificationCategories() {
        let customCategory = UNNotificationCategory(
            identifier: "customNotificationCategory",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([customCategory])
    }
    
    // Handle notification response
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: Notification.Name("NotificationReceived"), object: nil, userInfo: userInfo)
        completionHandler()
    }
}

