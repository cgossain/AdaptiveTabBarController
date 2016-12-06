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
    fileprivate var centerButtonPreviewInteraction: UIPreviewInteraction?
    
    // MARK: - Lifecycle
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        centerButtonPreviewInteraction = UIPreviewInteraction(view: view)
        centerButtonPreviewInteraction?.delegate = self
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dimmingView.frame = view.bounds
        if accessoryButtonEnabled {
            updateLayoutForCurrentCenterButtonState()
        }
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
            accessoryButton.center = tabBar.convert(dimmingView.anchor, from:dimmingView)
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
            self.updateForPreview(forProgress: 1.0)
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
    
    func updateForPreview(forProgress progress: Double) {
        var normalizedProgress = progress
        
        if progress < 0 {
            normalizedProgress = 0
        }
        
        if progress > 1 {
            normalizedProgress = 1
        }
        
        let angle = 45.0 * M_PI / 180.0 * normalizedProgress
        accessoryButton.plusImageView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
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

extension MFTTabBarController: UIPreviewInteractionDelegate {
    
    public func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        updateForPreview(forProgress: Double(transitionProgress))
        
        if ended {
            dimmingView.expand(true)
        }
    }
    
    public func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        dimmingView.collapse(true)
    }
    
//    public func previewInteractionShouldBegin(_ previewInteraction: UIPreviewInteraction) -> Bool {
//        let location = previewInteraction.location(in: accessoryButton)
//        let contains = accessoryButton.point(inside: location, with: nil)
//        return contains
//    }
    
}
