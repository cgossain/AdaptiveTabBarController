//
//  GSSAdaptiveTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit
import AppController

public class GSSAdaptiveTabBarController: AppViewController {
    
    public var tabBarControllerConfigurationBlock: ((tabBarController: UITabBarController) -> Void)?
    
    public var viewControllers: [UIViewController]? {
        didSet {
            if let controller = currentTabBarController as? UITabBarController {
                controller.viewControllers = viewControllers
            } else if let controller = currentTabBarController as? GSSVerticalTabBarController {
                controller.tabBarViewControllers = viewControllers
            }
        }
    }
    
    public var selectedIndex: Int {
        set {
            if let controller = currentTabBarController as? UITabBarController {
                controller.selectedIndex = newValue
            } else if let controller = currentTabBarController as? GSSVerticalTabBarController {
                controller.selectedIndex = newValue
            }
        }
        get {
            if let controller = currentTabBarController as? UITabBarController {
                return controller.selectedIndex
            } else if let controller = currentTabBarController as? GSSVerticalTabBarController {
                return controller.selectedIndex
            } else {
                return 0
            }
        }
    }
    
    public var selectedViewController: UIViewController? {
        if let controller = currentTabBarController as? UITabBarController {
            return controller.selectedViewController
        } else if let controller = currentTabBarController as? GSSVerticalTabBarController {
            return controller.selectedViewController
        } else {
            return nil
        }
    }
    
    private var tabBarControllerClass: UITabBarController.Type?
    private var currentTabBarController: UIViewController?
    
    // MARK: View Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadTabBarControllerForTraitCollection(self.traitCollection)
    }
    
    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in
            self.loadTabBarControllerForTraitCollection(newCollection)
        }, completion: nil)
    }
    
    // MARK: Methods (Public)
    
    public func registerTabBarControllerClass(tabBarControllerClass: UITabBarController.Type) {
        self.tabBarControllerClass = tabBarControllerClass
    }
    
    // MARK: Methods (Private)
    
    private func isCompactForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .Compact
    }
    
    private func loadTabBarControllerForTraitCollection(traitCollection: UITraitCollection) {
        let currentSelectedIndex = selectedIndex
        
        // load the correct tab bar controller based on the horizontal environment
        if isCompactForTraitCollection(traitCollection) {
            let tabBarController: UITabBarController!
            
            // load an instance of UITabBarController
            if let customTabBarClass = self.tabBarControllerClass {
                tabBarController = customTabBarClass.init()
            } else {
                tabBarController = UITabBarController()
            }
            
            // configure the tab bar controller using the configuation block
            tabBarControllerConfigurationBlock?(tabBarController: tabBarController)
            
            // set the view controllers
            tabBarController.viewControllers = viewControllers
            currentTabBarController = tabBarController
            
            self.transitionToViewController(tabBarController, animated: false, completion: nil)
            
        } else {
            // load the GSSVerticalTabBarController
            let tabBarController = GSSVerticalTabBarController()
            tabBarController.tabBarViewControllers = viewControllers
            
            currentTabBarController = tabBarController
            
            self.transitionToViewController(tabBarController, animated: false, completion: nil)
            
        }
        
        // select/reselect the previously loaded view controller
        self.selectedIndex = currentSelectedIndex
    }

}
