//
//  MFTTabBarActionView.swift
//  MooveFitCoreKit
//
//  Created by Christian Gossain on 2019-12-07.
//

import UIKit

class MFTTabBarActionView: UIView {
    let action: MFTTabBarAction
    
    let condition: MFTAdaptiveTabBarController.ConditionHandler?
    
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
    
    
    // MARK: - Private
    @objc private func buttonTapped(_ sender: UIButton) {
        action.handler()
        didTapHandler?()
    }
}

private class MFTTabBarActionViewNewBadge: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: MFTTabBarActionView.classForCoder())
        let newBadgeImage = UIImage(named: "tab-bar-action-badge-new", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let newBadgeImageView = UIImageView(image: newBadgeImage)
        addSubview(newBadgeImageView)
        newBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newBadgeImageView.topAnchor.constraint(equalTo: topAnchor),
            newBadgeImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newBadgeImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            newBadgeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newBadgeImageView.widthAnchor.constraint(equalToConstant: 22),
            newBadgeImageView.heightAnchor.constraint(equalToConstant: 22),
        ])
        
        let newLabel = UILabel()
        newLabel.text = "NEW"
        newLabel.textAlignment = .center
        newLabel.textColor = .white
        newLabel.font = UIFont.boldSystemFont(ofSize: 8)
        newLabel.adjustsFontSizeToFitWidth = true
        addSubview(newLabel)
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newLabel.centerYAnchor.constraint(equalTo: newBadgeImageView.centerYAnchor),
            newLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            newLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}
