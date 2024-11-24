//
//  recoraddictionApp.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//



// openSettingsURLString -> For direct to cloud setting


import UserNotifications
import SwiftUI
import SwiftData
import FirebaseCore
import UIKit
import FirebaseAnalytics
import FirebaseAuth
import FirebaseFirestore
//import FirebaseAnalyticsSwift


@main
struct recoraddicApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

//    @State var migrationCompleted: Bool = false // will be deprecated after 2025
//    @StateObject var containerHolder = ModelContainerHolder() // will be deprecated after 2025
    
    
    var body: some Scene {
        WindowGroup {
            //            NavigationView {
            AuthenticatedView {
                Image("loadingLogo")
                    .resizable()
                    .frame(width: 100 , height: 100)
//                    .foregroundColor(Color(.systemPink))
                    .aspectRatio(contentMode: .fit)
//                    .clipShape(Circle())
//                    .clipped()
                    .padding(4)
//                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                Text("기록중독에 오신 것을 환영합니다")
                    .font(.title)
                Text("로그인 방법을 선택하세요")
            } content: {
                    ContentView_withLaunchScreen()
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
        
        FirebaseApp.configure()
        
        
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

// will be deprecated after 2025
//class ModelContainerHolder: ObservableObject {
//    @Published var container: ModelContainer?
//    private var retryCount = 0
//    private let maxRetries = 3
//    
//    init() {
//        initializeContainer()
//    }
//    
//    func getRetryCount() -> Int {return retryCount}
//    private func initializeContainer() {
//        do {
//            container = try ModelContainer(
//                for: Schema([Quest.self, Todo.self, DailyQuest.self, DailyRecord.self, DailyRecordSet.self, Profile.self, Todo_preset.self]),
//                migrationPlan: RecoraddicMigrationPlan.self,
//                configurations: ModelConfiguration(cloudKitDatabase: .automatic)
//            )
//            print("ModelContainer initialized successfully.")
//            
//        } catch {
//            print("Failed to create ModelContainer: \(error.localizedDescription)")
//            if retryCount < maxRetries {
//                retryCount += 1
//                // Retry after a delay
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.initializeContainer()
//                }
//            } else {
//                // Handle the failure after retries
//                print("Failed to initialize ModelContainer after \(maxRetries) attempts.")
//                // You can update your UI to inform the user or take other appropriate actions
//            }
//        }
//    }
//}
//
//// will be deprecated after 2025
//struct ModelContainerBufferView: View {
//    @Environment(\.modelContext) var modelContext
//    @Query var profiles: [Profile]
//    @Binding var migrationCompleted: Bool
//
//    var body: some View {
//        if profiles.isEmpty {
//            LoadingView()
//                .onAppear() {
//                    migrationCompleted = true
//                }
//        }
//        else  {
//            FbMigrationLoadingView(migrationCompleted:$migrationCompleted)
//        }
//    }
//}
