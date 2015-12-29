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
    
    public var selectedViewController: UIViewController? {
        return tabBarViewControllers?[selectedIndex]
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            if let viewController = tabBarViewControllers?[selectedIndex] {
                self.showDetailViewController(viewController, sender: self)
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
            self.selectedIndex = 0 // select first view controller by default
        }
    }
    
    private let tabBarContainerViewController: _GSSTabBarContainerViewController = {
        let controller = _GSSTabBarContainerViewController()
        return controller
    }()
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.minimumPrimaryColumnWidth = 96.0;
        self.maximumPrimaryColumnWidth = 96.0;
        self.preferredDisplayMode = .AllVisible;
        
        self.viewControllers = [tabBarContainerViewController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.minimumPrimaryColumnWidth = 96.0;
        self.maximumPrimaryColumnWidth = 96.0;
        self.preferredDisplayMode = .AllVisible;
        
        self.viewControllers = [tabBarContainerViewController]
    }
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarContainerViewController.tabBar.didSelectItemHandler = {item in
            self.selectedIndex = item.index
        }
    }
}