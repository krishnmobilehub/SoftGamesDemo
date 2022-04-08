//
//  CreateLocalNotification.swift
//  SoftgamesTest
//

import Foundation
import UserNotifications

let uuidString = UUID().uuidString
let notificationTime = TimeInterval(07)

//MARK: - Create Local Notification
func createNotification() {
    UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
        switch notificationSettings.authorizationStatus {
        case .notDetermined:
            requestAuthorization(completionHandler: { (success) in
                guard success else { return }
                // Schedule Local Notification
                scheduleLocalNotification()
            })
        case .authorized, .provisional, .ephemeral:
        // Schedule Local Notification
            scheduleLocalNotification()
        case .denied:
            debugPrint("Application Not Allowed to Display Notifications")
            
        @unknown default:
            break
        }
    }
}

private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
        if let error = error {
//                self.showAlert(withMessage: error.localizedDescription, completion:{})
            debugPrint("Request Authorization Failed (\(error), \(error.localizedDescription))")
        }
        completionHandler(success)
    }
}

private func scheduleLocalNotification() {
    // Create Notification Content
    let notificationContent = UNMutableNotificationContent()

    // Configure Notification Content
    notificationContent.title = "Solitaire smash"
    notificationContent.body = "Play again to smash your top score."

    // Add Trigger
    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationTime, repeats: false)

    // Create Notification Request
    let notificationRequest = UNNotificationRequest(identifier: uuidString, content: notificationContent, trigger: notificationTrigger)

    // Add Request to User Notification Center
    UNUserNotificationCenter.current().add(notificationRequest) { (error) in
        if let error = error {
//                self.showAlert(withMessage: error.localizedDescription, completion:{})
            debugPrint("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
        } else {
            debugPrint("Notification has been added.")
        }
    }
}

//MARK: - Remove Local Notification
func removeLocalNotification() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
        for request in requests {
            if request.identifier == uuidString {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuidString])
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [uuidString])
            }
        }
    }
}
