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
    
    open weak var delegate: MFTAdaptiveTabBarControllerDelegate?
    
    open var viewControllers: [UIViewController]? {
        didSet {
            if let controller = currentTabBarController as? UITabBarController {
                controller.viewControllers = viewControllers
            } else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                controller.tabBarViewControllers = viewControllers
            }
        }
    }
    
    open var selectedIndex: Int {
        set {
            if let controller = currentTabBarController as? UITabBarController {
                controller.selectedIndex = newValue
            } else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                controller.selectedIndex = newValue
            }
        }
        get {
            if let controller = currentTabBarController as? UITabBarController {
                return controller.selectedIndex
            } else if let controller = currentTabBarController as? MFTVerticalTabBarController {
                return controller.selectedIndex
            } else {
                return 0
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
    fileprivate var centerButtonImage: UIImage?
    fileprivate var registeredActions = [MFTTabBarAction]()
    fileprivate var accessoryButtonDidExpandHandler: (() -> Void)?
    
    // MARK: View Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTabBarControllerForTraitCollection(traitCollection)
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.loadTabBarControllerForTraitCollection(newCollection)
        }, completion: nil)
    }
    
    // MARK: Public
    
    open func enableAccessoryButtonWith(_ image: UIImage, didExpandHandler: (() -> Void)?) {
        centerButtonImage = image
        accessoryButtonDidExpandHandler = didExpandHandler
    }
    
    open func addTabBarAction(_ action: MFTTabBarAction) {
        registeredActions.append(action)
    }
    
    // MARK: Private
    
    fileprivate func isCompactForTraitCollection(_ traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .compact
    }
    
    fileprivate func loadTabBarControllerForTraitCollection(_ traitCollection: UITraitCollection) {
        let currentSelectedIndex = selectedIndex
        
        // load the correct tab bar controller based on the horizontal environment
        if isCompactForTraitCollection(traitCollection) {
            let tabBarController = MFTTabBarController()
            tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
            tabBarController.delegate = self
            
            if let image = centerButtonImage {
                tabBarController.enableAccessoryButtonWith(image)
            }
            
            for action in registeredActions {
                tabBarController.addTabBarAction(action)
            }
            
            // set the view controllers
            if let viewControllers = viewControllers {
                var controllers = viewControllers
                if centerButtonImage != nil {
                    if controllers.count == 2 || controllers.count == 4 {
                        // insert a placeholder view controller to make room for the center button
                        controllers.insert(_AdaptivePlaceholderViewController(), at: (controllers.count/2))
                    }
                }
                tabBarController.viewControllers = controllers
            }
            
            currentTabBarController = tabBarController
            transitionToViewController(tabBarController, animated: false, completion: nil)
            
        } else {
            let tabBarController = MFTVerticalTabBarController()
            tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
            tabBarController.didSelectViewControllerHandler = { [unowned self] viewController in
                self.delegate?.tabBarController(self, didSelectViewController: viewController)
            }
            
            if let image = centerButtonImage {
                tabBarController.enableAccessoryButtonWith(image)
            }
            
            for action in registeredActions {
                tabBarController.addTabBarAction(action)
            }
            
            tabBarController.tabBarViewControllers = viewControllers
            currentTabBarController = tabBarController
            
            transitionToViewController(tabBarController, animated: false, completion: nil)
            
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
