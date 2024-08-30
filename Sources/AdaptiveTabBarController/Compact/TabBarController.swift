//
//  TabBarController.swift
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

final class TabBarController: UITabBarController, TabBarControlling, AdaptiveTabBarControllerDimmingViewListener {
    
    /// Called after the accessory button has finished its expansion animation.
    var accessoryButtonDidExpandHandler: (() -> Void)?
    
    // MARK: - API
    
    func addTabBarAction(_ action: TabBarAction, condition: AdaptiveTabBarController.ConditionHandler? = nil) {
        dimmingView.addTabBarAction(action, condition: condition)
    }
    
    func enableAccessoryButton() {
        isAccessoryButtonEnabled = true
        dimmingView.listener = self
        dimmingView.actionsLayoutMode = .gridCentered(3)
        
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
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.scrollEdgeAppearance = appearance
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
    
    private func updateLayout() {
        dimmingView.frame = view.bounds
        
        if isAccessoryButtonEnabled {
            updateLayoutForAccessoryButton()
        }
    }
    
    private func updateLayoutForAccessoryButton() {
        dimmingView.actionsAnchorView = accessoryButton
        
        if dimmingView.isCollapsed {
            dimmingView.removeFromSuperview()
            tabBar.addSubview(accessoryButton)
            
            let x = tabBar.bounds.midX
            let y = accessoryButton.bounds.height/2 - 7
            let locationInTabBar = CGPoint(x: x, y: y)
            accessoryButton.center = locationInTabBar
        } else {
            view.addSubview(dimmingView)
            view.addSubview(accessoryButton)
            let x = dimmingView.bounds.midX
            let y = dimmingView.bounds.maxY - tabBar.bounds.height + accessoryButton.bounds.height/2 - 7
            let locationInDimmingView = CGPoint(x: x, y: y)
            let locationInView = view.convert(locationInDimmingView, from: dimmingView)
            accessoryButton.center = locationInView
        }
    }
    
    // MARK: - Private
    
    private let dimmingView = AdaptiveTabBarControllerDimmingView()
    private let accessoryButton = AdaptiveTabBarActionButton()
    private var isAccessoryButtonEnabled = false
}
