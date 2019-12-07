//
//  MFTTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-27.
//
//

import UIKit

final public class MFTTabBarController: UITabBarController {
    
    var accessoryButtonDidExpandHandler: (() -> Void)?
    
    
    // MARK: - Private Properties
    private let dimmingView = MFTTabBarControllerDimmingView()
    private var isAccessoryButtonEnabled = false
    private var accessoryButton = MFTAdaptiveTabBarCentreButton()
    
    
    // MARK: - View Lifecycle
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
            if !self.dimmingView.isCollapsed {
                self.dimmingView.moveActionViewsToExpandedPositions()
            }
        }, completion: nil)
    }
    
    
    // MARK: - Public
    public func enableAccessoryButton() {
        isAccessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.actionsLayoutMode = .grid
        
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
    
    public func addAction(_ action: MFTTabBarAction) {
        dimmingView.addAction(action)
    }
    
    
    // MARK: - Private
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
            self.accessoryButton.plusImageView.transform = CGAffineTransform(rotationAngle: CGFloat(45.0 * Double.pi / 180.0))
        }) 
    }
    
    func dimmingViewDidExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        accessoryButtonDidExpandHandler?()
    }
    
    func dimmingViewWillCollapse(_ dimmingView: MFTTabBarControllerDimmingView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.plusImageView.transform = .identity
        }) 
    }
    
    func dimmingViewDidCollapse(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForAccessoryButton()
    }
}
