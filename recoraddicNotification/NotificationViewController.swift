//
//  NotificationViewController.swift
//  recoraddicNotification
//
//  Created by 김지호 on 7/10/24.
//

//MARK: 여기는 아예 작동 안하고 있는 중. 나중에 왜 안되는지 파악하기

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        print("this function is executed")
        self.view.backgroundColor = UIColor.orange
//        self.label?.textColor = UIColor.orange
//        self.label?.backgroundColor = UIColor.blue
//        self.view.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)))
//        self.view.subviews.first!.backgroundColor = UIColor.red
    
        
//        super.viewDidLoad()

    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
        print("this function is executed!!")
//        self.viewDidLoad()
    }

}
