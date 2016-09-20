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
    
    fileprivate var accessoryButton = UIButton(type: .custom)
    
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
    
    // MARK: - Public
    
    open func enableAccessoryButtonWith(_ image: UIImage) {
        accessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.position = .bottomRight
        accessoryButton.setImage(image, for: UIControlState())
        accessoryButton.sizeToFit()
        accessoryButton.addTarget(self, action: #selector(MFTVerticalTabBarController.accessoryButtonTapped(_:)), for: .touchUpInside)
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
        
        dimmingView.accessoryButtonSize = accessoryButton.bounds.size
        accessoryButton.center = dimmingView.anchor
        view.addSubview(accessoryButton)
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

extension MFTVerticalTabBarController: MFTTabBarControllerDimmingViewDelegate {
    
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
