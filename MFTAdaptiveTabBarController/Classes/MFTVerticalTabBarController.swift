//
//  MFTVerticalTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit

// _MFTTabBarContainerViewController
//////////////////////////////////////////////////////////////////

class _MFTTabBarContainerViewController: UIViewController {
    let tabBar = MFTVerticalTabBar()
    override func loadView() {
        self.view = tabBar
    }
}


// MFTVerticalTabBarController
//////////////////////////////////////////////////////////////////

open class MFTVerticalTabBarController: UISplitViewController {
    
    open var didSelectViewControllerHandler: ((_ viewController: UIViewController) -> Void)?
    
    open var accessoryButtonDidExpandHandler: (() -> Void)?
    
    open var selectedViewController: UIViewController? {
        return tabBarViewControllers?[selectedIndex]
    }
    
    open var selectedIndex: Int = 0 {
        didSet {
            if let viewController = tabBarViewControllers?[selectedIndex] {
                showDetailViewController(viewController, sender: self)
            }
            tabBarContainerViewController.tabBar.selectedItemIndex = selectedIndex
        }
    }
    
    open var tabBarViewControllers: [UIViewController]? {
        didSet {
            // convert to the tab bar item views
            var itemViews = [MFTVerticalTabBarItemView]()
            if let unwrappedViewControllers = tabBarViewControllers {
                for vc in unwrappedViewControllers {
                    let itemView = MFTVerticalTabBarItemView(tabBarItem: vc.tabBarItem)
                    itemViews.append(itemView)
                }
            }
            
            tabBarContainerViewController.tabBar.items = itemViews
            selectedIndex = 0 // select first view controller by default
        }
    }
    
    fileprivate let tabBarContainerViewController: _MFTTabBarContainerViewController = {
        let controller = _MFTTabBarContainerViewController()
        return controller
    }()
    
    fileprivate let dimmingView = MFTTabBarControllerDimmingView()
    fileprivate var accessoryButtonEnabled = false
    fileprivate var accessoryButton = MFTAdaptiveTabBarCentreButton()
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        minimumPrimaryColumnWidth = 108.0
        maximumPrimaryColumnWidth = 108.0
        preferredDisplayMode = .allVisible
        viewControllers = [tabBarContainerViewController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumPrimaryColumnWidth = 108.0
        maximumPrimaryColumnWidth = 108.0
        preferredDisplayMode = .allVisible
        viewControllers = [tabBarContainerViewController]
    }
    
    // MARK: - View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tabBarContainerViewController.tabBar.didSelectItemHandler = { [unowned self] item in
            self.selectedIndex = item.index
            if let viewController = self.tabBarViewControllers?[item.index] {
                self.didSelectViewControllerHandler?(viewController)
            }
        }
    }
    
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
        dimmingView.position = .bottomRight
        
        accessoryButton.sizeToFit()
        accessoryButton.touchUpInsideHandler = { [unowned self] () -> Void in
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
        if dimmingView.collapsed {
            dimmingView.removeFromSuperview()
        }
        else {
            view.addSubview(dimmingView)
        }
        
        dimmingView.accessoryButtonSize = accessoryButton.intrinsicContentSize
        accessoryButton.center = dimmingView.anchor
        view.addSubview(accessoryButton)
    }
    
}

extension MFTVerticalTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView) {
        updateLayoutForCurrentCenterButtonState()
        
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
        updateLayoutForCurrentCenterButtonState()
    }
    
}
