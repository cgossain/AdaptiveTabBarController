//
//  MFTTabBarAction.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import Foundation

public struct MFTTabBarAction {
    public let image: UIImage
    public let title: String
    public let handler: (() -> Void)
    
    public init(image: UIImage, title: String, handler: @escaping (() -> Void)) {
        self.image = image
        self.title = title
        self.handler = handler
    }
}

class MFTTabBarActionView: UIView {
    
    var didTapHandler: (() -> Void)?
    
    let action: MFTTabBarAction
    
    fileprivate lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(self.action.image, for: UIControlState())
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
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
        
        let stackView = UIStackView(arrangedSubviews: [button, titleLabel])
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 70)
    }
    
}

fileprivate extension MFTTabBarActionView {
    @objc func actionButtonTapped(_ sender: UIButton) {
        action.handler()
        didTapHandler?()
    }
}
