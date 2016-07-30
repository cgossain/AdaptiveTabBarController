//
//  MFTTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-27.
//
//

import UIKit

public class MFTTabBarController: UITabBarController {
    
    public var accessoryButtonDidExpandHandler: (() -> Void)?
    
    private let dimmingView = MFTTabBarControllerDimmingView()
    
    private var accessoryButtonEnabled = false
    
    private var accessoryButton = UIButton(type: .Custom)
    
    private var selectedNavigationController: UINavigationController?
    
    // MARK: - Override
    
    override public var selectedViewController: UIViewController? {
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
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dimmingView.frame = view.bounds
        if accessoryButtonEnabled {
            updateLayoutForCurrentCenterButtonState()
        }
    }
    
    // MARK: - Public
    
    public func enableAccessoryButtonWith(image: UIImage) {
        accessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.position = .BottomCenter
        accessoryButton.setImage(image, forState: .Normal)
        accessoryButton.sizeToFit()
        accessoryButton.addTarget(self, action: #selector(MFTVerticalTabBarController.accessoryButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    public func addTabBarAction(action: MFTTabBarAction) {
        dimmingView.addTabBarAction(action)
    }
    
    // MARK: - Private
    
    private func updateLayoutForCurrentCenterButtonState() {
        if dimmingView.collapsed {
            dimmingView.removeFromSuperview()
        }
        else {
            view.addSubview(dimmingView)
        }
        
        dimmingView.accessoryButtonSize = accessoryButton.bounds.size
        accessoryButton.center = dimmingView.anchor
        view.addSubview(accessoryButton)
    }
    
    @objc func accessoryButtonTapped(sender: UIButton) {
        if dimmingView.collapsed {
            dimmingView.expand(true)
        }
        else {
            dimmingView.collapse(true)
        }
    }
    
}

extension MFTTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
    func dimmingViewWillExpand(dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForCurrentCenterButtonState()
        
        UIView.animateWithDuration(0.2) {
            self.accessoryButton.transform = CGAffineTransformMakeRotation(CGFloat(45.0 * M_PI / 180.0))
        }
    }
    
    func dimmingViewDidExpand(dimmingView: MFTTabBarControllerDimmingView) {
        accessoryButtonDidExpandHandler?()
    }
    
    func dimmingViewWillCollapse(dimmingView: MFTTabBarControllerDimmingView) {
        UIView.animateWithDuration(0.2) {
            self.accessoryButton.transform = CGAffineTransformIdentity
        }
    }
    
    func dimmingViewDidCollapse(dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForCurrentCenterButtonState()
    }
    
}

extension MFTTabBarController: UINavigationControllerDelegate {
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        var hidesBottomBar = false
        for vc in navigationController.viewControllers.reverse() {
            if vc.hidesBottomBarWhenPushed {
                hidesBottomBar = true
                break
            }
        }
        
        navigationController.transitionCoordinator()?.animateAlongsideTransition({ (context) in
            
            if hidesBottomBar {
                self.accessoryButton.alpha = 0.0
            }
            else {
                self.accessoryButton.alpha = 1.0
            }
            
        }, completion: { (context) in
            
            if hidesBottomBar {
                self.accessoryButton.alpha = context.isCancelled() ? 1.0 : 0.0
            }
            else {
                self.accessoryButton.alpha = context.isCancelled() ? 0.0 : 1.0
            }
            
        })
    }
    
}