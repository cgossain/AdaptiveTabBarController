//
//  MFTAdaptiveTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit
import AppController

public enum AccessoryButtonPosition {
    case bottomRight
    case bottomCenter
}

private class _AdaptivePlaceholderViewController: UIViewController {}

public protocol MFTAdaptiveTabBarControllerDelegate: NSObjectProtocol {
    func tabBarController(_ tabBarController: MFTAdaptiveTabBarController, didSelectViewController viewController: UIViewController)
}

open class MFTAdaptiveTabBarController: AppViewController {
    
    open var accessoryButtonDidExpandHandler: (() -> Void)?
    
    open weak var delegate: MFTAdaptiveTabBarControllerDelegate?
    
    open var viewControllers: [UIViewController]? {
        didSet {
            if let controller = currentTabBarController as? UITabBarController {
                controller.viewControllers = viewControllers
            }
            else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                controller.tabBarViewControllers = viewControllers
            }
        }
    }
    
    open var selectedIndex: Int {
        get {
            if let controller = currentTabBarController as? UITabBarController {
                var offset = 0
                if let viewControllers = controller.viewControllers {
                    for (idx, vc) in viewControllers.enumerated() {
                        if vc is _AdaptivePlaceholderViewController {
                            offset += 1
                        }
                        else if idx >= controller.selectedIndex {
                            break
                        }
                    }
                }
                return controller.selectedIndex - offset
            }
            else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                return controller.selectedIndex
            }
            else {
                return 0
            }
        }
        set {
            if let controller = currentTabBarController as? UITabBarController {
                var offset = 0
                if let viewControllers = controller.viewControllers {
                    for (idx, vc) in viewControllers.enumerated() {
                        if vc is _AdaptivePlaceholderViewController {
                            offset += 1
                        }
                        else if idx >= newValue + offset {
                            break
                        }
                    }
                }
                controller.selectedIndex = newValue + offset
            }
            else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                controller.selectedIndex = newValue
            }
        }
    }
    
    open var selectedViewController: UIViewController? {
        if let controller = currentTabBarController as? UITabBarController {
            return controller.selectedViewController
        } else if let controller = currentTabBarController as? MFTVerticalTabBarController {
            return controller.selectedViewController
        } else {
            return nil
        }
    }
    
    fileprivate var tabBarControllerClass: UITabBarController.Type?
    fileprivate var currentTabBarController: UIViewController?
    fileprivate var registeredActions = [MFTTabBarAction]()
    fileprivate var isCenterButtonEnabled: Bool { return registeredActions.count > 0 }
    
    
    // MARK: - Lifecycle
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadTabBarController(for: traitCollection)
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.loadTabBarController(for: newCollection)
        }, completion: nil)
    }
    
    
    // MARK: - Public
    
    open func addTabBarAction(_ action: MFTTabBarAction) {
        registeredActions.append(action)
    }

}

fileprivate extension MFTAdaptiveTabBarController {
    
    func loadTabBarController(for traitCollection: UITraitCollection) {
        let currentSelectedIndex = selectedIndex
        
        // load the correct tab bar controller based on the horizontal environment
        switch traitCollection.horizontalSizeClass {
        case .compact:
            let tabBarController = MFTTabBarController()
            tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
            tabBarController.delegate = self
//            tabBarController.tabBar.isTranslucent = false
            
            if isCenterButtonEnabled {
                tabBarController.enableAccessoryButton()
            }
            
            for action in registeredActions {
                tabBarController.addTabBarAction(action)
            }
            
            // set the view controllers
            if let viewControllers = viewControllers {
                var controllers = viewControllers
                if isCenterButtonEnabled {
                    if controllers.count == 2 || controllers.count == 4 {
                        // insert a placeholder view controller to make room for the center button
                        controllers.insert(_AdaptivePlaceholderViewController(), at: (controllers.count/2))
                    }
                }
                tabBarController.viewControllers = controllers
            }
            
            currentTabBarController = tabBarController
            
            // transition
            let configuration = AppController.Configuration(dismissesPresentedViewControllerOnTransition: false)
            transition(to: tabBarController, configuration: configuration, completionHandler: nil)
            
        default:
            let tabBarController = MFTVerticalTabBarController()
            tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
            tabBarController.didSelectViewControllerHandler = { [unowned self] viewController in
                self.delegate?.tabBarController(self, didSelectViewController: viewController)
            }
            
            if isCenterButtonEnabled {
                tabBarController.enableAccessoryButton()
            }
            
            for action in registeredActions {
                tabBarController.addTabBarAction(action)
            }
            
            tabBarController.tabBarViewControllers = viewControllers
            currentTabBarController = tabBarController
            
            // transition
            let configuration = AppController.Configuration(dismissesPresentedViewControllerOnTransition: false)
            transition(to: tabBarController, configuration: configuration, completionHandler: nil)
        }
        
        // select/reselect the previously loaded view controller
        selectedIndex = currentSelectedIndex
    }
    
}

extension MFTAdaptiveTabBarController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !(viewController is _AdaptivePlaceholderViewController) // prevent the placeholder view controller from beign selected
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        delegate?.tabBarController(self, didSelectViewController: viewController)
    }
    
}
