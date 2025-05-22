//
//  AppDelegate.swift
//  Tracker
//
//  Created by User on 20.03.2025.
//

import UIKit
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

       func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
           
           guard let configuration = YMMYandexMetricaConfiguration(apiKey: "1c4b3b9c-e92e-4fc6-8e47-161cdd91a764") else { 
                   return true
               }
           YMMYandexMetrica.activate(with: configuration)
           window = UIWindow(frame: UIScreen.main.bounds)
           window?.rootViewController = UINavigationController(rootViewController: TrackersViewController())
           window?.makeKeyAndVisible()
           return true
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

