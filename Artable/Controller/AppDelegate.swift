//
//  AppDelegate.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-16.
//

import UIKit
import FirebaseCore
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        STPAPIClient.shared.publishableKey = "pk_test_51QBo5JDNumRv6el770ifDhwT83Tw7sPSleGBMXCGrDhTImedIllWdNU8kL1NfEsHrh7f2LjYoG9CX5Le4P3eZXqq00ENq08GRn"
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
