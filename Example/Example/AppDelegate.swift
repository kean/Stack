//
//  AppDelegate.swift
//  Example
//
//  Created by Alexander Grebenyuk on 01/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    let tabBarController = UITabBarController()
    let controller1 = ArrangedViewController()
    let controller2 = StackViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        controller1.tabBarItem = UITabBarItem(title: "Arranged.StackView", image: UIImage(named: "tabBarIcon"), tag: 0)
        controller2.tabBarItem = UITabBarItem(title: "UIStackView", image: UIImage(named: "tabBarIcon"), tag: 0)
        tabBarController.viewControllers = [controller1, controller2]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
}

