//
//  SceneDelegate.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/13.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let vc = QiitaUserSearchViewController.getInstance()
        let navigation = UINavigationController(rootViewController: vc)
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }
}

