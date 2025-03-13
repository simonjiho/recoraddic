//
//  recoraddictionApp.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//



// openSettingsURLString -> For direct to cloud setting


import SwiftUI
import SwiftData
import CloudKit
import UserNotifications
import CoreData


@main
struct recoraddicApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var containerHolder = ModelContainerHolder()

    

    var syncManager: SyncManager = SyncManager()


    
    
    var body: some Scene {

        
        WindowGroup {
//            Text("????")
            if let container = containerHolder.container {
                ContentView_withLaunchScreen()
                    .modelContainer(container)
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
                    }

            }
            else {
                LoadingView_fetch(retryCount: containerHolder.getRetryCount())
            }
            

        }


    


    }
}

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
    
    private func setupNotificationCategories() {
        let customCategory = UNNotificationCategory(
            identifier: "dailyQuestNotification",
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



struct ContentView_withLaunchScreen:View {
    @State private var isActive: Bool = false
    var body: some View {
        if isActive {
            ContentView()
        }
        else {
            LoadingView()
//                .containerRelativeFrame([.horizontal,.vertical])
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }

            }

    }
    

}


class ModelContainerHolder: ObservableObject {
    @Published var container: ModelContainer?
    private var retryCount = 0
    private let maxRetries = 3

    init() {
        initializeContainer()
    }
        
    func getRetryCount() -> Int {return retryCount}
    private func initializeContainer() {
        do {
            container = try ModelContainer(
                for: Schema([Quest.self, Todo.self, DailyQuest.self, DailyRecord.self, DailyRecordSet.self, Profile.self, Todo_preset.self]),
                migrationPlan: RecoraddicMigrationPlan.self,
                configurations: ModelConfiguration(cloudKitDatabase: .automatic)
            )
            print("ModelContainer initialized successfully.")
        } catch {
            print("Failed to create ModelContainer: \(error.localizedDescription)")
            if retryCount < maxRetries {
                retryCount += 1
                // Retry after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.initializeContainer()
                }
            } else {
                // Handle the failure after retries
                print("Failed to initialize ModelContainer after \(maxRetries) attempts.")
                // You can update your UI to inform the user or take other appropriate actions
            }
        }
    }
}
