//
//  MFTTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-27.
//
//

import UIKit

open class MFTTabBarController: UITabBarController {
    
    open var accessoryButtonDidExpandHandler: (() -> Void)?
    
    fileprivate let dimmingView = MFTTabBarControllerDimmingView()
    
    fileprivate var accessoryButtonEnabled = false
    
    fileprivate var accessoryButton = UIButton(type: .custom)
    
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
    
    // MARK: - Public
    
    open func enableAccessoryButtonWith(_ image: UIImage) {
        accessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.position = .bottomCenter
        accessoryButton.setImage(image, for: UIControlState())
        accessoryButton.sizeToFit()
        accessoryButton.addTarget(self, action: #selector(MFTVerticalTabBarController.accessoryButtonTapped(_:)), for: .touchUpInside)
    }
    
    open func addTabBarAction(_ action: MFTTabBarAction) {
        dimmingView.addTabBarAction(action)
    }
    
    // MARK: - Private
    
    fileprivate func updateLayoutForCurrentCenterButtonState() {
        dimmingView.accessoryButtonSize = accessoryButton.bounds.size
        
        if dimmingView.collapsed {
            dimmingView.removeFromSuperview()
            accessoryButton.center = tabBar.convert(dimmingView.anchor, from:dimmingView)
            tabBar.addSubview(accessoryButton)
        }
        else {
            view.addSubview(dimmingView)
            accessoryButton.center = dimmingView.anchor
            view.addSubview(accessoryButton)
        }
    }
    
    @objc func accessoryButtonTapped(_ sender: UIButton) {
        if dimmingView.collapsed {
            dimmingView.expand(true)
        }
        else {
            dimmingView.collapse(true)
        }
    }
    
}

extension MFTTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForCurrentCenterButtonState()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.transform = CGAffineTransform(rotationAngle: CGFloat(45.0 * M_PI / 180.0))
        }) 
    }
    
    func dimmingViewDidExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        accessoryButtonDidExpandHandler?()
    }
    
    func dimmingViewWillCollapse(_ dimmingView: MFTTabBarControllerDimmingView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.accessoryButton.transform = CGAffineTransform.identity
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
        
        navigationController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            
            if hidesBottomBar {
                self.accessoryButton.alpha = 0.0
            }
            else {
                self.accessoryButton.alpha = 1.0
            }
            
        }, completion: { (context) in
            
            if hidesBottomBar {
                self.accessoryButton.alpha = context.isCancelled ? 1.0 : 0.0
            }
            else {
                self.accessoryButton.alpha = context.isCancelled ? 0.0 : 1.0
            }
            
        })
    }
    
}
