//
//  MFTTabBarController.swift
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

final public class MFTTabBarController: UITabBarController {
    
    /// Called after the accessory button has finished its expansion animation.
    var accessoryButtonDidExpandHandler: (() -> Void)?
    
    
    // MARK: - Private Properties
    
    private let dimmingView = MFTTabBarControllerDimmingView()
    private let accessoryButton = MFTAdaptiveTabBarCenterButton()
    private var isAccessoryButtonEnabled = false
    
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dimmingView.frame = view.bounds
        
        if isAccessoryButtonEnabled {
            updateLayoutForAccessoryButton()
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // if expanded, update the positions of the tab bar actions
            if !self.dimmingView.isCollapsed {
                self.dimmingView.moveActionViewsToExpandedPositions()
            }
        }, completion: nil)
    }
    
}

extension MFTTabBarController {
    // MARK: - Internal
    
    func addTabBarAction(_ action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        dimmingView.addTabBarAction(action, condition: condition)
    }
    
    func enableAccessoryButton() {
        isAccessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.actionsLayoutMode = .gridCentered(3)
        
        accessoryButton.sizeToFit()
        accessoryButton.touchUpInsideHandler = { [unowned self] () -> Void in
            if self.dimmingView.isCollapsed {
                self.dimmingView.expand(animated: true)
            }
            else {
                self.dimmingView.collapse(animated: true)
            }
        }
    }
}

extension MFTTabBarController {
    private func updateLayoutForAccessoryButton() {
        dimmingView.actionsAnchorView = accessoryButton
        
        if dimmingView.isCollapsed {
            dimmingView.removeFromSuperview()
            tabBar.addSubview(accessoryButton)
            
            var x = tabBar.bounds.midX
            var y = accessoryButton.bounds.height/2 - 7
            let locationInTabBar = CGPoint(x: x, y: y)
            accessoryButton.center = locationInTabBar
        }
        else {
            view.addSubview(dimmingView)
            view.addSubview(accessoryButton)
            var x = dimmingView.bounds.midX
            var y = dimmingView.bounds.maxY - tabBar.bounds.height + accessoryButton.bounds.height/2 - 7
            let locationInDimmingView = CGPoint(x: x, y: y)
            let locationInView = view.convert(locationInDimmingView, from: dimmingView)
            accessoryButton.center = locationInView
        }
    }
}

extension MFTTabBarController: MFTTabBarControllerDimmingViewDelegate {
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForAccessoryButton()
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.transform = CGAffineTransform(rotationAngle: CGFloat(45.0 * Double.pi / 180.0))
        })
    }
    
    func dimmingViewDidExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        accessoryButtonDidExpandHandler?()
    }
    
    func dimmingViewWillCollapse(_ dimmingView: MFTTabBarControllerDimmingView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.transform = .identity
        })
    }
    
    func dimmingViewDidCollapse(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForAccessoryButton()
    }
}
