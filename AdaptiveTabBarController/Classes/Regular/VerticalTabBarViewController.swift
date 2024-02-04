//
//  VerticalTabBarViewController.swift
//
//  Copyright (c) 2024 Christian Gossain
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

protocol VerticalTabBarViewControllerListener: AnyObject {
    func verticalTabBarViewController(_ verticalTabBarViewController: VerticalTabBarViewController, didSelectIndex index: Int)
}

final class VerticalTabBarViewController: UIViewController, VerticalTabBarViewListener {
    
    weak var listener: VerticalTabBarViewControllerListener?
    
    var items: [UITabBarItem]? {
        get {
            internalView.items
        }
        set {
            internalView.items = newValue
        }
    }
    
    var selectedIndex: Int {
        get {
            internalView.selectedIndex
        }
        set {
            internalView.selectedIndex = newValue
        }
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = internalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        internalView.listener = self
    }
    
    // MARK: - VerticalTabBarViewListener
    
    func verticalTabBarView(_ verticalTabBarView: VerticalTabBarView, didSelectIndex index: Int) {
        listener?.verticalTabBarViewController(self, didSelectIndex: index)
    }
    
    // MARK: - Private
    
    private let internalView = VerticalTabBarView()
}
