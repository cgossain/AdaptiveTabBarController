//
//  MFTTabBarActionView.swift
//  MooveFitCoreKit
//
//  Created by Christian Gossain on 2019-12-07.
//

import UIKit

class MFTTabBarActionView: UIView {
    let action: MFTTabBarAction
    
    var didTapHandler: (() -> Void)?
    
    
    // MARK: - Private Properties
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
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
        return label
    }()
    
    
    // MARK: - Lifecycle
    public init(action: MFTTabBarAction) {
        self.action = action
        super.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        let stackView = UIStackView(arrangedSubviews: [button, titleLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: topAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor)])
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    
    // MARK: - Private
    @objc private func buttonTapped(_ sender: UIButton) {
        action.handler()
        didTapHandler?()
    }
}
