//
//  MFTVerticalTabBarController.swift
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

final public class MFTVerticalTabBarController: UISplitViewController {
    
    public var accessoryButtonDidExpandHandler: (() -> Void)?
    
    public var didSelectViewControllerHandler: ((_ viewController: UIViewController) -> Void)?
    
    public var selectedViewController: UIViewController? { return tabBarViewControllers?[selectedIndex] }
    
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
    
    
    // MARK: - Private Properties
    
    private let dimmingView = MFTTabBarControllerDimmingView()
    private var accessoryButton = MFTAdaptiveTabBarCenterButton()
    private let tabBarContainerViewController = _MFTTabBarContainerViewController()
    private var isAccessoryButtonEnabled = false
    
    
    // MARK: - Lifecycle
    
    @available(iOS 14.0, *)
    public override init(style: UISplitViewController.Style) {
        super.init(style: .unspecified)
        commonInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        minimumPrimaryColumnWidth = 108.0
        maximumPrimaryColumnWidth = 108.0
        preferredDisplayMode = .allVisible
        viewControllers = [tabBarContainerViewController]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tabBarContainerViewController.tabBar.didSelectItemHandler = { [unowned self] item in
            self.selectedIndex = item.index
            if let viewController = self.tabBarViewControllers?[item.index] {
                self.didSelectViewControllerHandler?(viewController)
            }
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

extension MFTVerticalTabBarController {
    // MARK: - Internal
    
    func addTabBarAction(_ action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        dimmingView.addTabBarAction(action, condition: condition)
    }
    
    func enableAccessoryButton() {
        isAccessoryButtonEnabled = true
        dimmingView.delegate = self
        dimmingView.actionsLayoutMode = .gridTrailing(2)
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

extension MFTVerticalTabBarController {
    private func updateLayoutForAccessoryButton() {
        dimmingView.actionsAnchorView = accessoryButton
        
        if dimmingView.isCollapsed {
            dimmingView.removeFromSuperview()
        }
        else {
            view.addSubview(dimmingView)
        }
        
        view.addSubview(accessoryButton)
        let x = view.bounds.maxX - accessoryButton.bounds.width/2 - 24
        let y = view.bounds.maxY - accessoryButton.bounds.height/2 - 48
        let locationInView = CGPoint(x: x, y: y)
        accessoryButton.center = locationInView
    }
}

extension MFTVerticalTabBarController: MFTTabBarControllerDimmingViewDelegate {
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

class _MFTTabBarContainerViewController: UIViewController {
    let tabBar = MFTVerticalTabBar()
    override func loadView() {
        self.view = tabBar
    }
}
