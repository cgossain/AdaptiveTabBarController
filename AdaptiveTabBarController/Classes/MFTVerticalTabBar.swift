//
//  MFTVerticalTabBar.swift
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

final class MFTVerticalTabBar: UIView {
    
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
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
    }
    
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
    
}

extension MFTVerticalTabBar {
    @objc
    private func tabBarItemTouched(_ item: MFTVerticalTabBarItemView) {
        selectedItemIndex = item.index
        didSelectItemHandler?(item)
    }
}

extension MFTVerticalTabBar {
    private func tabBarItemAtIndex(_ index: Int) -> MFTVerticalTabBarItemView? {
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
