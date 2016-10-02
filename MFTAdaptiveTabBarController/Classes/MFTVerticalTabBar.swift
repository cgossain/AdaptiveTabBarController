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
                for (idx, item) in unwrappedItems.enumerated() {
                    item.translatesAutoresizingMaskIntoConstraints = false
                    item.index = idx
                    item.addTarget(self, action: #selector(MFTVerticalTabBar.tabBarItemTouched(_:)), for: .touchDown)
                    addSubview(item)
                }
            }
            
            setNeedsUpdateConstraints()
        }
    }
    
    var selectedItemIndex: Int = 0 {
        willSet {
            // deselect the current item
            let currentItem = self.tabBarItemAtIndex(selectedItemIndex)
            currentItem?.isSelected = false
        }
        didSet {
            // select the new item
            let newItem = self.tabBarItemAtIndex(selectedItemIndex)
            newItem?.isSelected = true
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
    }
    
    // MARK: - Constraints
    
    override func updateConstraints() {
        if let unwrappedItems = items {
            var previousItem: MFTVerticalTabBarItemView?
            for (idx, item) in unwrappedItems.enumerated() {
                item.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                item.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                
                if idx == 0 {
                    item.topAnchor.constraint(equalTo: self.topAnchor, constant: 64.0).isActive = true
                }
                else if let p = previousItem {
                    item.topAnchor.constraint(equalTo: p.bottomAnchor).isActive = true
                }
                
                previousItem = item
            }
        }
        super.updateConstraints()
    }
    
    // MARK: - Selectors
    
    func tabBarItemTouched(_ item: MFTVerticalTabBarItemView) {
        selectedItemIndex = item.index
        didSelectItemHandler?(item)
    }
    
    // MARK: - Methods (Private)
    
    func tabBarItemAtIndex(_ index: Int) -> MFTVerticalTabBarItemView? {
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
