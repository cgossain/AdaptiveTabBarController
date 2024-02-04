//
//  VerticalTabBarController.swift
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

protocol VerticalTabBarControllerDelegate: AnyObject {
    func verticalTabBarController(_ tabBarController: VerticalTabBarController, didSelect viewController: UIViewController)
}

final class VerticalTabBarController: UIViewController, TabBarControlling, VerticalTabBarViewControllerListener, AdaptiveTabBarControllerDimmingViewListener {
    
    weak var delegate: VerticalTabBarControllerDelegate?
    
    var accessoryButtonDidExpandHandler: (() -> Void)?
    
    var viewControllers: [UIViewController]? {
        didSet {
            updateTabBarItems()
            updateSelectedViewController()
        }
    }
    
    var selectedIndex: Int {
        get {
            verticalTabBarViewController.selectedIndex
        }
        set {
            verticalTabBarViewController.selectedIndex = newValue
            updateSelectedViewController()
        }
    }
    
    var selectedViewController: UIViewController? {
        let maxIndex = viewControllers?.count ?? 0
        guard selectedIndex < maxIndex else {
            return nil
        }
        return viewControllers?[selectedIndex]
    }
    
    // MARK: - API
    
    func addTabBarAction(_ action: TabBarAction, condition: AdaptiveTabBarController.ConditionHandler? = nil) {
        dimmingView.addTabBarAction(action, condition: condition)
    }
    
    func enableAccessoryButton() {
        isAccessoryButtonEnabled = true
        dimmingView.listener = self
        dimmingView.actionsLayoutMode = .gridTrailing(2)
        accessoryButton.sizeToFit()
        accessoryButton.touchUpInsideHandler = { [weak self] () -> Void in
            guard let self else {
                return
            }
            
            if self.dimmingView.isCollapsed {
                self.dimmingView.expand(animated: true)
            } else {
                self.dimmingView.collapse(animated: true)
            }
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
            alongsideTransition: { [weak self] context in
                guard let self, !self.dimmingView.isCollapsed else {
                    return
                }
                self.dimmingView.moveActionViewsToExpandedPositions()
            }
        )
    }
    
    // MARK: - VerticalTabBarViewControllerListener
    
    func verticalTabBarViewController(_ verticalTabBarViewController: VerticalTabBarViewController, didSelectIndex index: Int) {
        updateSelectedViewController()
        
        guard let viewController = viewControllers?[index] else { return }
        delegate?.verticalTabBarController(self, didSelect: viewController)
    }
    
    // MARK: - AdaptiveTabBarControllerDimmingViewListener
    
    func dimmingViewWillExpand(_ dimmingView: AdaptiveTabBarControllerDimmingView) {
        updateLayoutForAccessoryButton()
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.accessoryButton.transform = CGAffineTransform(rotationAngle: CGFloat(45.0 * Double.pi / 180.0))
            }
        )
    }
    
    func dimmingViewDidExpand(_ dimmingView: AdaptiveTabBarControllerDimmingView) {
        accessoryButtonDidExpandHandler?()
    }
    
    func dimmingViewWillCollapse(_ dimmingView: AdaptiveTabBarControllerDimmingView) {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.accessoryButton.transform = .identity
            }
        )
    }
    
    func dimmingViewDidCollapse(_ dimmingView: AdaptiveTabBarControllerDimmingView) {
        updateLayoutForAccessoryButton()
    }
    
    // MARK: - Helpers
    
    private func configure() {
        addChild(verticalTabBarViewController)
        view.addSubview(verticalTabBarViewController.view)
        verticalTabBarViewController.didMove(toParent: self)
        
        separatorView.backgroundColor = .separator
        view.addSubview(separatorView)
    }
    
    private func updateTabBarItems() {
        let items = viewControllers?.compactMap(\.tabBarItem)
        verticalTabBarViewController.items = items
    }
    
    private func updateSelectedViewController() {
        guard let selectedViewController else { return }
        setDetailViewController(selectedViewController)
    }
    
    private func updateLayout() {
        let tabBarWidth: CGFloat = 120
        verticalTabBarViewController.view.frame = CGRect(x: 0, y: 0, width: tabBarWidth, height: view.bounds.height)
        
        let separatorWidth = 1.0 / UIScreen.main.scale
        separatorView.frame = CGRect(x: tabBarWidth, y: 0, width: separatorWidth, height: view.bounds.height)
        
        detailViewController?.view.frame = CGRect(x: tabBarWidth, y: 0, width: view.bounds.width - tabBarWidth, height: view.bounds.height)
        
        dimmingView.frame = view.bounds
        
        if isAccessoryButtonEnabled {
            updateLayoutForAccessoryButton()
        }
    }
    
    private func updateLayoutForAccessoryButton() {
        dimmingView.actionsAnchorView = accessoryButton
        
        if dimmingView.isCollapsed {
            dimmingView.removeFromSuperview()
        } else {
            view.addSubview(dimmingView)
        }
        
        view.addSubview(accessoryButton)
        
        let x = view.bounds.maxX - accessoryButton.bounds.width/2 - 24
        let y = view.bounds.maxY - accessoryButton.bounds.height/2 - 56 - view.safeAreaInsets.bottom
        let locationInView = CGPoint(x: x, y: y)
        accessoryButton.center = locationInView
    }
    
    private func setDetailViewController(_ viewController: UIViewController) {
        if let detailViewController, detailViewController != viewController {
            detailViewController.willMove(toParent: nil)
            detailViewController.view.removeFromSuperview()
            detailViewController.removeFromParent()
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        detailViewController = viewController
        updateLayout()
        
        view.bringSubviewToFront(separatorView)
    }
    
    // MARK: - Private
    
    private lazy var verticalTabBarViewController: VerticalTabBarViewController = {
        let viewController = VerticalTabBarViewController()
        viewController.listener = self
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        return viewController
    }()
    private let separatorView = UIView()
    private var detailViewController: UIViewController?
    
    private let dimmingView = AdaptiveTabBarControllerDimmingView()
    private var accessoryButton = AdaptiveTabBarActionButton()
    private var isAccessoryButtonEnabled = false
}
