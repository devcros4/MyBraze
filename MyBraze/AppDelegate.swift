//
//  AppDelegate.swift
//  MyBraze
//
//  Created by Delcros, Jean-Baptiste (Ordinateur) on 2023-02-24.
//

import UIKit
import BrazeKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var braze: Braze? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = Braze.Configuration(apiKey: "b7c72eb2-9817-4af3-93d7-e540b9819c03", endpoint: "sdk.iad-06.braze.com")

        configuration.logger.level = .debug

        let braze = Braze(configuration: configuration)
        AppDelegate.braze = braze


        application.registerForRemoteNotifications()
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories(Braze.Notifications.categories)
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            print("Notification authorization, granted: \(granted), error: \(String(describing: error))")
        }

        AppDelegate.braze?.changeUser(userId: "DDGWdi5XlqPluJRP8JGBOR3I76z1")
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppDelegate.braze?.notifications.register(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if let braze = AppDelegate.braze, braze.notifications.handleBackgroundNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler) { return }

        completionHandler(.noData)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let braze = AppDelegate.braze, braze.notifications.handleUserNotification(
            response: response,
            withCompletionHandler: completionHandler
        ) {
            return
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner])
        } else {
            completionHandler(.alert)
        }
    }

}

// MARK: - BrazeApplicationService: BrazeDelegate
extension AppDelegate: BrazeDelegate {

    func braze(_ braze: Braze, shouldOpenURL context: Braze.URLContext) -> Bool {
        return true
    }

}
