//
//  AppDelegate.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/13.
//

import UIKit
import SwiftData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private(set) var databaseContainer: ModelContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        databaseContainer = ContainerFactory.initialize()
        
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

extension AppDelegate {
    
    /// AppDelegateに登録されているDBのContainerインスタンスを取得する
    static func getDatabaseContainer() -> ModelContainer? {
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate,
              let container = delegate.databaseContainer else { return nil }
        return container
    }
}
