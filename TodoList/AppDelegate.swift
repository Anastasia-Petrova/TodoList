import UIKit
import UserNotifications
import EasyCoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNotifications()
        printCoreDataPath()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func scheduleNotification(notificationBody: String, notificationDate: Date, userInfo: [String : String]) {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = notificationBody
        content.sound = UNNotificationSound.default
        content.badge = 1 //TODO: add to current badge value
        content.categoryIdentifier = "ReminderCategory"
        content.userInfo = userInfo
        let date = notificationDate
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        let identifier = "LocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                // Something went wrong
            }
        })
    }
    
    private func setupNotifications() {
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze", options: [])
        let completeAction = UNNotificationAction(identifier: "CompleteAction",
                                                title: "Mark as completed", options: [])
        let category = UNNotificationCategory(identifier: "ReminderCategory",
                                              actions: [snoozeAction, completeAction],
                                              intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    private func printCoreDataPath() {
        // Override point for customization after application launch.
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("DOCUMENTS: " + documentsPath)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "CompleteAction":
            if let urlString = response.notification.request.content.userInfo["url"] as? String,
                let url = URL(string: urlString) {
                let coreDataController = CoreDataController<TodoItem, TodoItemViewModel>.init(entityName: "TodoItem")
                coreDataController.updateModels(urls: [url]) { (items) in
                    items.first?.isChecked = true
                }
            }
            print("CompleteAction")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}

