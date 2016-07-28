//
//  GSSAdaptiveTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit
import AppController

public enum AccessoryButtonPosition {
    case BottomRight
    case BottomCenter
}

private class _AdaptivePlaceholderViewController: UIViewController {}

public protocol GSSAdaptiveTabBarControllerDelegate: NSObjectProtocol {
    func tabBarController(tabBarController: GSSAdaptiveTabBarController, didSelectViewController viewController: UIViewController)
}

public class GSSAdaptiveTabBarController: AppViewController {
    
    public weak var delegate: GSSAdaptiveTabBarControllerDelegate?
    
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
    private var centerButtonImage: UIImage?
    private var registeredActions = [MFTTabBarAction]()
    private var accessoryButtonDidExpandHandler: (() -> Void)?
    
    // MARK: View Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadTabBarControllerForTraitCollection(traitCollection)
    }
    
    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in
            self.loadTabBarControllerForTraitCollection(newCollection)
        }, completion: nil)
    }
    
    // MARK: Public
    
    public func enableAccessoryButtonWith(image: UIImage, didExpandHandler: (() -> Void)?) {
        centerButtonImage = image
        accessoryButtonDidExpandHandler = didExpandHandler
    }
    
    public func addTabBarAction(action: MFTTabBarAction) {
        registeredActions.append(action)
    }
    
    // MARK: Private
    
    private func isCompactForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .Compact
    }
    
    private func loadTabBarControllerForTraitCollection(traitCollection: UITraitCollection) {
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
                        controllers.insert(_AdaptivePlaceholderViewController(), atIndex: (controllers.count/2))
                    }
                }
                tabBarController.viewControllers = controllers
            }
            
            currentTabBarController = tabBarController
            transitionToViewController(tabBarController, animated: false, completion: nil)
            
        } else {
            // load the GSSVerticalTabBarController
            let tabBarController = GSSVerticalTabBarController()
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

extension GSSAdaptiveTabBarController: UITabBarControllerDelegate {
    
    public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return !(viewController is _AdaptivePlaceholderViewController) // prevent the placeholder view controller from beign selected
    }
    
    public func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        delegate?.tabBarController(self, didSelectViewController: viewController)
    }
    
}