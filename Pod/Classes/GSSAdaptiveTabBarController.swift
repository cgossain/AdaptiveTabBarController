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
    
    public var viewControllers: [UIViewController]?
    
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
    
    // MARK: Methods (Private)
    
    func isCompactForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .Compact
    }
    
    func loadTabBarControllerForTraitCollection(traitCollection: UITraitCollection) {
        let currentSelectedIndex = selectedIndex
        
        // load the correct tab bar controller based on the horizontal environment
        if isCompactForTraitCollection(traitCollection) {
            // load the UITabBarController
            let tabBarController = UITabBarController()
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
