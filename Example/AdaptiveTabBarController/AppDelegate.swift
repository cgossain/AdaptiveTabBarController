//
//  AppDelegate.swift
//  AdaptiveTabBarController
//
//  Created by cgossain on 09/23/2021.
//  Copyright (c) 2021 cgossain. All rights reserved.
//

import UIKit
import AdaptiveTabBarController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let adaptiveTabBarViewController = AdaptiveTabBarController()
        
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor.red
        vc1.tabBarItem = UITabBarItem(title: "An Item 1", image: UIImage(named: "book"), selectedImage: UIImage(named: "book-selected"))
        
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor.green
        vc2.tabBarItem = UITabBarItem(title: "An Item 1", image: UIImage(named: "book"), selectedImage: UIImage(named: "book-selected"))
        
        adaptiveTabBarViewController.viewControllers = [vc1, vc2]
                
        adaptiveTabBarViewController.addTabBarAction(TabBarAction(title: "Action 1", image: UIImage(named: "book-selected")!, handler: {
            
        }))
        
        adaptiveTabBarViewController.addTabBarAction(TabBarAction(title: "Action 2", image: UIImage(named: "book-selected")!, handler: {
            
        }))
        
        adaptiveTabBarViewController.addTabBarAction(TabBarAction(title: "Action 3", image: UIImage(named: "book-selected")!, handler: {
            
        }))
        
        self.window = UIWindow()
        self.window?.rootViewController = adaptiveTabBarViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
