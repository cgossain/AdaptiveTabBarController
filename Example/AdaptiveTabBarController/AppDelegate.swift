//
//  AppDelegate.swift
//
//  Copyright (c) 2021 Christian Gossain
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import AdaptiveTabBarController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let adaptiveTabBarViewController = AdaptiveTabBarController()
        
        let vc1 = ViewController()
        vc1.view.backgroundColor = .red
        vc1.tabBarItem = UITabBarItem(title: "Item 1", image: UIImage(named: "book"), selectedImage: UIImage(named: "book-selected"))
        
        let vc2 = ViewController()
        vc2.view.backgroundColor = .green
        vc2.tabBarItem = UITabBarItem(title: "Item 2", image: UIImage(named: "book"), selectedImage: UIImage(named: "book-selected"))
        
        adaptiveTabBarViewController.viewControllers = [vc1, vc2]
                
        adaptiveTabBarViewController.addTabBarAction(
            TabBarAction(
                title: "Action 1",
                image: UIImage(named: "book-selected")!,
                handler: {
                    // no-op
                }
            )
        )
        
        adaptiveTabBarViewController.addTabBarAction(
            TabBarAction(
                title: "Action 2",
                image: UIImage(named: "book-selected")!,
                handler: {
                    // no-op
                }
            )
        )
        
        adaptiveTabBarViewController.addTabBarAction(
            TabBarAction(
                title: "Action 3",
                image: UIImage(named: "book-selected")!,
                handler: {
                    // no-op
                }
            )
        )
        
        self.window = UIWindow()
        self.window?.rootViewController = adaptiveTabBarViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
