//
//  AdaptiveTabBarController.swift
//
//  Copyright (c) 2024 Christian Gossain
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

protocol TabBarControlling {
    var viewControllers: [UIViewController]? { get set }
    
    var selectedViewController: UIViewController? { get }
}

public protocol AdaptiveTabBarControllerDelegate: NSObjectProtocol {
    func tabBarController(_ tabBarController: AdaptiveTabBarController, didSelect viewController: UIViewController)
}

/// AdaptiveTabBarController is a tab bar view controller that adapts between compact and regular size environments.
public final class AdaptiveTabBarController: UIViewController, UITabBarControllerDelegate, VerticalTabBarControllerDelegate {
    public typealias ConditionHandler = () -> Bool
    
    public weak var delegate: AdaptiveTabBarControllerDelegate?
    
    public var accessoryButtonDidExpandHandler: (() -> Void)?
    
    public var viewControllers: [UIViewController]? {
        didSet {
            activeTabBarController?.viewControllers = viewControllers
        }
    }
    
    public var selectedIndex: Int {
        get {
            if let tabBarController = activeTabBarController as? UITabBarController {
                var offset = 0
                if let viewControllers = tabBarController.viewControllers {
                    for (idx, vc) in viewControllers.enumerated() {
                        if vc is _DummyPlaceholderViewController {
                            offset += 1
                        } else if idx >= tabBarController.selectedIndex {
                            break
                        }
                    }
                }
                return tabBarController.selectedIndex - offset
            } else if let verticalTabBarController = activeTabBarController as? VerticalTabBarController {
                return verticalTabBarController.selectedIndex
            } else {
                return 0
            }
        }
        set {
            if let tabBarController = activeTabBarController as? UITabBarController {
                var offset = 0
                if let viewControllers = tabBarController.viewControllers {
                    for (idx, vc) in viewControllers.enumerated() {
                        if vc is _DummyPlaceholderViewController {
                            offset += 1
                        } else if idx >= newValue + offset {
                            break
                        }
                    }
                }
                tabBarController.selectedIndex = newValue + offset
            } else if let verticalTabBarController = activeTabBarController as? VerticalTabBarController {
                verticalTabBarController.selectedIndex = newValue
            }
        }
    }
    
    public var selectedViewController: UIViewController? {
        activeTabBarController?.selectedViewController
    }
    
    // MARK: - API
    
    public func addTabBarAction(_ action: TabBarAction, condition: AdaptiveTabBarController.ConditionHandler? = nil) {
        let registration = TabBarActionRegistration(action: action, condition: condition)
        actionRegistrations.append(registration)
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureForTraitCollection(traitCollection)
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.configureForTraitCollection(newCollection)
            }
        )
    }
    
    // MARK: - UITabBarControllerDelegate
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        !(viewController is _DummyPlaceholderViewController)
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        delegate?.tabBarController(self, didSelect: viewController)
    }
    
    // MARK: - VerticalTabBarControllerDelegate
    
    func verticalTabBarController(_ tabBarController: VerticalTabBarController, didSelect viewController: UIViewController) {
        delegate?.tabBarController(self, didSelect: viewController)
    }
    
    // MARK: - Helpers
    
    private func configureForTraitCollection(_ newCollection: UITraitCollection) {
        // track of the selected index
        // before transition
        let currentSelectedIndex = selectedIndex
        
        // handle size class
        if newCollection.horizontalSizeClass == .compact {
            transitionToCompactEnvironment()
        } else {
            transitionToRegularEnvironment()
        }
        
        // reselect selected index
        selectedIndex = currentSelectedIndex
    }
    
    private func transitionToCompactEnvironment() {
        removeCurrentChildViewController()

        let tabBarController = TabBarController()
        tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
        tabBarController.delegate = self
        
        var mutableViewControllers = viewControllers ?? []
        if isCenterButtonEnabled {
            if mutableViewControllers.count % 2 == 0 {
                // insert a dummy placeholder view 
                // controller to make room for the
                // action button
                mutableViewControllers.insert(_DummyPlaceholderViewController(), at: (mutableViewControllers.count / 2))
            }
        }
        tabBarController.viewControllers = mutableViewControllers
        
        if isCenterButtonEnabled {
            tabBarController.enableAccessoryButton()
        }
        
        for registration in actionRegistrations {
            tabBarController.addTabBarAction(registration.action, condition: registration.condition)
        }
        
        addChild(tabBarController)
        tabBarController.view.frame = view.bounds
        view.addSubview(tabBarController.view)
        tabBarController.didMove(toParent: self)
        
        activeTabBarController = tabBarController
    }

    private func transitionToRegularEnvironment() {
        removeCurrentChildViewController()

        let tabBarController = VerticalTabBarController()
        tabBarController.accessoryButtonDidExpandHandler = accessoryButtonDidExpandHandler
        tabBarController.delegate = self
        tabBarController.viewControllers = viewControllers
        
        if isCenterButtonEnabled {
            tabBarController.enableAccessoryButton()
        }
        
        for registration in actionRegistrations {
            tabBarController.addTabBarAction(registration.action, condition: registration.condition)
        }
        
        addChild(tabBarController)
        tabBarController.view.frame = view.bounds
        view.addSubview(tabBarController.view)
        tabBarController.didMove(toParent: self)
        
        activeTabBarController = tabBarController
    }
    
    private func removeCurrentChildViewController() {
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }

    // MARK: - Private
    
    private var activeTabBarController: TabBarControlling?
    private var actionRegistrations: [TabBarActionRegistration] = []
    private var isCenterButtonEnabled: Bool {
        actionRegistrations.count > 0
    }
}

/// The `_DummyPlaceholderViewController` is a dummy view controller used to
/// add an untapable tab item behind the circular center accessory button.
fileprivate class _DummyPlaceholderViewController: UIViewController {}
