//
//  MFTAdaptiveTabBarCenterButton.swift
//  Pods
//
//  Created by Christian Gossain on 2016-10-01.
//
//

import UIKit

final class MFTAdaptiveTabBarCenterButton: UIView {
    
    /// Called when the receiver is tapped.
    var touchUpInsideHandler: (() -> Void)?
    
    
    // MARK: - Private Properties
    
    private let overlayButton = UIButton(type: .custom)
    private let plusImageView = UIImageView()
    private let preferredSize = CGSize(width: 56, height: 56)
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        let bundle = Bundle(for: MFTAdaptiveTabBarCenterButton.self)
        
        let circleImage = UIImage(named: "tab-bar-centre-button", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        overlayButton.setBackgroundImage(circleImage, for: .normal)
        overlayButton.layer.cornerRadius = preferredSize.width / 2
        overlayButton.layer.borderColor = UIColor.white.cgColor
        overlayButton.layer.borderWidth = 1.0
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayButton)
        
        let plusImage = UIImage(named: "tab-bar-centre-button-plus", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        plusImageView.image = plusImage
        plusImageView.tintColor = .white
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusImageView)
        
        // constraints
        plusImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        topAnchor.constraint(equalTo: overlayButton.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: overlayButton.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: overlayButton.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: overlayButton.trailingAnchor).isActive = true
        
        overlayButton.addTarget(self, action: #selector(MFTAdaptiveTabBarCenterButton.overlayButtonTapped(_:)), for: .touchUpInside)
    }
    
    override var intrinsicContentSize: CGSize {
        return preferredSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return preferredSize
    }
    
}

extension MFTAdaptiveTabBarCenterButton {
    @objc
    private func overlayButtonTapped(_ sender: UIButton) {
        touchUpInsideHandler?()
    }
}
