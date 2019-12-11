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
        let flexibleStackView = UIStackView(arrangedSubviews: [button])
        flexibleStackView.axis = .vertical
        flexibleStackView.alignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [flexibleStackView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: topAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     button.widthAnchor.constraint(equalToConstant: diameter),
                                     button.heightAnchor.constraint(equalToConstant: diameter)])
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
