//
//  VerticalTabBarView.swift
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

protocol VerticalTabBarViewListener: AnyObject {
    func verticalTabBarView(_ verticalTabBarView: VerticalTabBarView, didSelectIndex index: Int)
}

final class VerticalTabBarView: UIView {
    
    weak var listener: VerticalTabBarViewListener?
    
    var items: [UITabBarItem]? {
        didSet {
            updateVerticalTabBarViewButtons()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            buttonAtIndex(oldValue)?.isSelected = false
            buttonAtIndex(selectedIndex)?.isSelected = true
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func updateVerticalTabBarViewButtons() {
        stackView
            .arrangedSubviews
            .forEach { $0.removeFromSuperview() }
        
        let newButtons = items?
            .enumerated()
            .map({ (idx, item) in
                VerticalTabBarViewButton(tabBarItem: item) { [weak self] in
                    guard let self else { return }
                    self.selectedIndex = idx
                    self.listener?.verticalTabBarView(self, didSelectIndex: idx)
                }
            }) ?? []
        newButtons.forEach({ stackView.addArrangedSubview($0) })
        
        // this spacer allows the buttons to hug towards
        // the top of the stack view and this spacer
        // just fills the remaining space
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        
        buttons = newButtons
        selectedIndex = 0
    }
    
    private func buttonAtIndex(_ index: Int) -> VerticalTabBarViewButton? {
        guard index < buttons.count else { return nil }
        return buttons[index]
    }
    
    // MARK: - Private
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 64
        return stackView
    }()
    
    private var buttons: [VerticalTabBarViewButton] = []
}
