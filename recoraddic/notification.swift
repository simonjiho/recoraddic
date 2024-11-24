//
//  notification.swift
//  recoraddic
//
//  Created by 김지호 on 7/10/24.
//

import Foundation
import UserNotifications


func scheduleNotification(at date: Date, for questName: String, goal: Int?) {
    let content = UNMutableNotificationContent()
    content.title = questName
//    content.subtitle = String(describing: date)
    if let goal_nonNil = goal {
        content.body = "목표: \(goal_nonNil.hhmmFormat)"
    }
    content.sound = .default

    content.categoryIdentifier = "dailyQuestNotification"


    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error adding notification: \(error.localizedDescription)")
        }
    }
}

func removeNotification(at date: Date, for questName: String) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (requests) in
        let identifiersToRemove = requests.filter { request in
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                let content = request.content
                let calendar = Calendar.current
                let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
                let inputDateComponents = calendar.dateComponents(components, from: date)
                return content.categoryIdentifier == "dailyQuestNotification" && content.title == questName && trigger.dateComponents == inputDateComponents
            }
            return false
        }.map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
}

func removeNotification(for questName: String) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (requests) in
        let identifiersToRemove = requests.filter { request in
            if let _ = request.trigger as? UNCalendarNotificationTrigger {
                let content = request.content
                return content.categoryIdentifier == "dailyQuestNotification" && content.title == questName
            }
            return false
        }.map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
}


//import Combine
//
//class NotificationManager: ObservableObject {
//    @Published var notificationData: [AnyHashable: Any]? = nil
//
//    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("NotificationReceived"), object: nil)
//    }
//
//    @objc private func handleNotification(_ notification: Notification) {
//        if let userInfo = notification.userInfo {
//            self.notificationData = userInfo
//        }
//    }
//}
