//
//  MFTAdaptiveTabBarController.swift
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
import AppController

public protocol MFTAdaptiveTabBarControllerDelegate: NSObjectProtocol {
    func tabBarController(_ tabBarController: MFTAdaptiveTabBarController, didSelectViewController viewController: UIViewController)
}

/// _AdaptivePlaceholderViewController is a dummy view controller used to
/// add untapable tab item behind the circular center accessory button.
private class _AdaptivePlaceholderViewController: UIViewController {}

/// MFTAdaptiveTabBarController is a tab bar view controller that adapts between compact and regular size environments.
open class MFTAdaptiveTabBarController: AppViewController {
    public typealias ConditionHandler = () -> Bool
    
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
        }
        else if let controller = currentTabBarController as? MFTVerticalTabBarController {
            return controller.selectedViewController
        }
        else {
            return nil
        }
    }
    
    
    // MARK: - Private Properties
    
    private var currentTabBarController: UIViewController?
    private var actionRegistrations = [MFTTabBarActionRegistration]()
    private var isCenterButtonEnabled: Bool { return actionRegistrations.count > 0 }
    
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        loadTabBarController(for: traitCollection)
    }
    
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
    
    open func addTabBarAction(_ action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        let registration = MFTTabBarActionRegistration(action: action, condition: condition)
        actionRegistrations.append(registration)
    }

}

extension MFTAdaptiveTabBarController {
    private func loadTabBarController(for traitCollection: UITraitCollection) {
        let currentSelectedIndex = selectedIndex
        
        // load the correct tab bar controller based on the horizontal environment
        switch traitCollection.horizontalSizeClass {
        case .compact:
            let tabBarController = MFTTabBarController()
            tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
            tabBarController.delegate = self
            
            if isCenterButtonEnabled {
                tabBarController.enableAccessoryButton()
            }
            
            for registration in actionRegistrations {
                tabBarController.addTabBarAction(registration.action, condition: registration.condition)
            }
            
            // set the view controllers
            if let viewControllers = viewControllers {
                // cleanup: remove from old hierarchy
                viewControllers.forEach { (vc) in
                    vc.willMove(toParent: nil)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                }
                
                // inject dummy view controller behind the center button if enabled
                var mutableViewControllers = viewControllers
                if isCenterButtonEnabled {
                    if mutableViewControllers.count == 2 || mutableViewControllers.count == 4 {
                        // insert a placeholder view controller to make room for the center button
                        mutableViewControllers.insert(_AdaptivePlaceholderViewController(), at: (mutableViewControllers.count/2))
                    }
                }
                tabBarController.viewControllers = mutableViewControllers
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
            
            for registration in actionRegistrations {
                tabBarController.addTabBarAction(registration.action, condition: registration.condition)
            }
            
            // set the view controllers
            if let viewControllers = viewControllers {
                // cleanup: remove from old hierarchy
                viewControllers.forEach { (vc) in
                    vc.willMove(toParent: nil)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                }
                
                tabBarController.tabBarViewControllers = viewControllers
            }
            
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
