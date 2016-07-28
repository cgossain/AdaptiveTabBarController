//
//  GSSVerticalTabBarController.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit

// _GSSTabBarContainerViewController
//////////////////////////////////////////////////////////////////

class _GSSTabBarContainerViewController: UIViewController {
    let tabBar = GSSVerticalTabBar()
    override func loadView() {
        self.view = tabBar
    }
}


// GSSVerticalTabBarController
//////////////////////////////////////////////////////////////////

public class GSSVerticalTabBarController: UISplitViewController {
    
    public var didSelectViewControllerHandler: ((viewController: UIViewController) -> Void)?
    
    public var accessoryButtonDidExpandHandler: (() -> Void)?
    
    public var selectedViewController: UIViewController? {
        return tabBarViewControllers?[selectedIndex]
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            if let viewController = tabBarViewControllers?[selectedIndex] {
                showDetailViewController(viewController, sender: self)
            }
            tabBarContainerViewController.tabBar.selectedItemIndex = selectedIndex
        }
    }
    
    public var tabBarViewControllers: [UIViewController]? {
        didSet {
            // convert to the tab bar item views
            var itemViews = [GSSVerticalTabBarItemView]()
            if let unwrappedViewControllers = tabBarViewControllers {
                for vc in unwrappedViewControllers {
                    let itemView = GSSVerticalTabBarItemView(tabBarItem: vc.tabBarItem)
                    itemViews.append(itemView)
                }
            }
            
            tabBarContainerViewController.tabBar.items = itemViews
            selectedIndex = 0 // select first view controller by default
        }
    }
    
    private let tabBarContainerViewController: _GSSTabBarContainerViewController = {
        let controller = _GSSTabBarContainerViewController()
        return controller
    }()
    
    private let dimmingView = MFTTabBarControllerDimmingView()
    
    private var accessoryButtonEnabled = false
    
    private var accessoryButton = UIButton(type: .Custom)
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        minimumPrimaryColumnWidth = 108.0
        maximumPrimaryColumnWidth = 108.0
        preferredDisplayMode = .AllVisible
        viewControllers = [tabBarContainerViewController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumPrimaryColumnWidth = 108.0
        maximumPrimaryColumnWidth = 108.0
        preferredDisplayMode = .AllVisible
        viewControllers = [tabBarContainerViewController]
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tabBarContainerViewController.tabBar.didSelectItemHandler = { [unowned self] item in
            self.selectedIndex = item.index
            if let viewController = self.tabBarViewControllers?[item.index] {
                self.didSelectViewControllerHandler?(viewController: viewController)
            }
        }
    }
    
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
        dimmingView.position = .BottomRight
        accessoryButton.setImage(image, forState: .Normal)
        accessoryButton.sizeToFit()
        accessoryButton.addTarget(self, action: #selector(GSSVerticalTabBarController.accessoryButtonTapped(_:)), forControlEvents: .TouchUpInside)
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

extension GSSVerticalTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
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