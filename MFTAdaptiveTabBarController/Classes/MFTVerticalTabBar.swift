//
//  MFTVerticalTabBar.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit

class MFTVerticalTabBar: UIView {
    
    var didSelectItemHandler: ((MFTVerticalTabBarItemView) -> Void)?
    
    var items: [MFTVerticalTabBarItemView]? {
        willSet {
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    item.removeFromSuperview()
                }
            }
        }
        didSet {
            if let unwrappedItems = items {
                for (idx, item) in unwrappedItems.enumerate() {
                    item.translatesAutoresizingMaskIntoConstraints = false
                    item.index = idx
                    item.addTarget(self, action: "tabBarItemTouched:", forControlEvents: .TouchDown)
                    
                    self.addSubview(item)
                }
            }
            
            self.setNeedsUpdateConstraints()
        }
    }
    
    var selectedItemIndex: Int = 0 {
        willSet {
            // deselect the current item
            let currentItem = self.tabBarItemAtIndex(selectedItemIndex)
            currentItem?.selected = false
        }
        didSet {
            // select the new item
            let newItem = self.tabBarItemAtIndex(selectedItemIndex)
            newItem?.selected = true
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    // MARK: Constraints
    
    override func updateConstraints() {
        if let unwrappedItems = items {
            var previousItem: MFTVerticalTabBarItemView?
            for (idx, item) in unwrappedItems.enumerate() {
                item.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
                item.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
                
                if idx == 0 {
                    item.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 64.0).active = true
                }
                else if let p = previousItem {
                    item.topAnchor.constraintEqualToAnchor(p.bottomAnchor).active = true
                }
                
                previousItem = item
            }
        }
        
        super.updateConstraints()
    }
    
    // MARK: Selectors
    
    func tabBarItemTouched(item: MFTVerticalTabBarItemView) {
        self.selectedItemIndex = item.index
        self.didSelectItemHandler?(item)
    }
    
    // MARK: Methods (Private)
    
    func tabBarItemAtIndex(index: Int) -> MFTVerticalTabBarItemView? {
        var item: MFTVerticalTabBarItemView?
        if let unwrappedItems = items {
            for i in unwrappedItems {
                if i.index == index {
                    item = i
                    break
                }
            }
        }
        return item
    }
    
}
