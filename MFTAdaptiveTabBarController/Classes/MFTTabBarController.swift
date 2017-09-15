//
//  MFTTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-27.
//
//

import UIKit

open class MFTTabBarController: UITabBarController {
    
    var accessoryButtonDidExpandHandler: (() -> Void)?
    
    fileprivate let dimmingView = MFTTabBarControllerDimmingView()
    fileprivate var accessoryButtonEnabled = false
    fileprivate var accessoryButton = MFTAdaptiveTabBarCentreButton()
    fileprivate var selectedNavigationController: UINavigationController?
    
    // MARK: - Override
    
    override open var selectedViewController: UIViewController? {
        didSet {
            if accessoryButtonEnabled {
                if let vc = selectedViewController as? UINavigationController {
                    vc.delegate = self
                    selectedNavigationController = vc
                }
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dimmingView.frame = view.bounds
        if accessoryButtonEnabled {
            updateLayoutForCurrentCenterButtonState()
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            if !self.dimmingView.collapsed {
                self.dimmingView.moveActionViewsToExpandedPositions()
            }
        }, completion: nil)
    }
    
    // MARK: - Public
    
    open func enableAccessoryButton() {
        accessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.position = .bottomCenter
        
        accessoryButton.sizeToFit()
        accessoryButton.touchUpInsideHandler = { [unowned self] in
            if self.dimmingView.collapsed {
                self.dimmingView.expand(true)
            }
            else {
                self.dimmingView.collapse(true)
            }
        }
    }
    
    open func addTabBarAction(_ action: MFTTabBarAction) {
        dimmingView.addTabBarAction(action)
    }
    
    // MARK: - Private
    
    fileprivate func updateLayoutForCurrentCenterButtonState() {
        dimmingView.accessoryButtonSize = accessoryButton.bounds.size
        
        if dimmingView.collapsed {
            dimmingView.removeFromSuperview()
            accessoryButton.center = tabBar.convert(dimmingView.anchor, from:view)
            tabBar.addSubview(accessoryButton)
        }
        else {
            view.addSubview(dimmingView)
            accessoryButton.center = dimmingView.anchor
            view.addSubview(accessoryButton)
        }
    }
    
}

extension MFTTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForCurrentCenterButtonState()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.plusImageView.transform = CGAffineTransform(rotationAngle: CGFloat(45.0 * M_PI / 180.0))
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
        updateLayoutForCurrentCenterButtonState()
    }
    
}

extension MFTTabBarController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        var hidesBottomBar = false
        for vc in navigationController.viewControllers.reversed() {
            if vc.hidesBottomBarWhenPushed {
                hidesBottomBar = true
                break
            }
        }
        
//        navigationController.transitionCoordinator?.animate(alongsideTransition: { (context) in
//            if hidesBottomBar {
//                self.accessoryButton.alpha = 0.0
//            }
//            else {
//                self.accessoryButton.alpha = 1.0
//            }
//            
//        }, completion: { (context) in
//            
//            if hidesBottomBar {
//                self.accessoryButton.alpha = context.isCancelled ? 1.0 : 0.0
//            }
//            else {
//                self.accessoryButton.alpha = context.isCancelled ? 0.0 : 1.0
//            }
//            
//        })
    }
    
}
