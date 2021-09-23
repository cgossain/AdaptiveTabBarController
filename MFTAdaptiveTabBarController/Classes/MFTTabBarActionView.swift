//
//  MFTTabBarActionView.swift
//  MooveFitCoreKit
//
//  Created by Christian Gossain on 2019-12-07.
//

import UIKit

final class MFTTabBarActionView: UIView {
    
    /// The action.
    let action: MFTTabBarAction
    
    /// The condition that determines if the action should be shown or not.
    ///
    /// This called whenever used by the `canShow` property is used.
    let condition: MFTAdaptiveTabBarController.ConditionHandler?
    
    /// Called when the button is tapped.
    var didTapHandler: (() -> Void)?
    
    /// Indicates if the item should be shown.
    var canShow: Bool { return condition?() ?? true }
    
    
    // MARK: - Private Properties
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.showsTouchWhenHighlighted = true
        button.setImage(self.action.image, for: .normal)
        button.addTarget(self, action: #selector(MFTTabBarActionView.buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = self.action.title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    public init(action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        self.action = action
        self.condition = condition
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        let diameter: CGFloat = 56
        button.layer.cornerRadius = diameter/2
        button.backgroundColor = .white
        
        addSubview(button)
        addSubview(titleLabel)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            button.widthAnchor.constraint(equalToConstant: diameter),
            button.heightAnchor.constraint(equalToConstant: diameter),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // show "new" badge
        if action.isNew {
            let newBadge = MFTTabBarActionViewNewBadge()
            newBadge.tintColor = .systemBlue
            addSubview(newBadge)
            newBadge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newBadge.topAnchor.constraint(equalTo: button.topAnchor, constant: -4),
                newBadge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 4)
            ])
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return fittingSize
    }
    
}

extension MFTTabBarActionView {
    @objc
    private func buttonTapped(_ sender: UIButton) {
        action.handler()
        didTapHandler?()
    }
}
