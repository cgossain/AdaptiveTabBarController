//
//  TabBarActionButton.swift
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

final class TabBarActionButton: UIView {
    
    /// The action.
    let action: TabBarAction
    
    /// The condition that determines if the action should be shown or not.
    ///
    /// This called whenever used by the `canShow` property is used.
    let condition: AdaptiveTabBarController.ConditionHandler?
    
    /// Called when the button is tapped.
    var didTapHandler: (() -> Void)?
    
    /// Indicates if the item should be shown.
    var canShow: Bool {
        condition?() ?? true
    }
    
    // MARK: - Init
    
    public init(
        action: TabBarAction,
        condition: AdaptiveTabBarController.ConditionHandler? = nil
    ) {
        self.action = action
        self.condition = condition
        super.init(frame: .zero)
        
        let diameter: CGFloat = 56
        
        internalButton.addTarget(self, action: #selector(TabBarActionButton.buttonTapped), for: .touchUpInside)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.image = action.image.withRenderingMode(.alwaysTemplate)
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        internalButton.configuration = config
        
        internalButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(internalButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            internalButton.topAnchor.constraint(equalTo: topAnchor),
            internalButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            internalButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            internalButton.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            internalButton.widthAnchor.constraint(equalToConstant: diameter),
            internalButton.heightAnchor.constraint(equalToConstant: diameter),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // add "new" badge if enabled
        if action.isNew {
            let newBadge = TabBarActionButtonNewBadge()
            newBadge.tintColor = .systemBlue
            newBadge.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newBadge)
            NSLayoutConstraint.activate([
                newBadge.topAnchor.constraint(equalTo: internalButton.topAnchor, constant: -4),
                newBadge.trailingAnchor.constraint(equalTo: internalButton.trailingAnchor, constant: 4)
            ])
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return fittingSize
    }
    
    // MARK: - Helpers
    
    @objc
    private func buttonTapped() {
        action.handler()
        didTapHandler?()
    }
    
    // MARK: - Private
    
    private let internalButton = UIButton(type: .custom)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .white
        label.text = action.title
        return label
    }()
}
