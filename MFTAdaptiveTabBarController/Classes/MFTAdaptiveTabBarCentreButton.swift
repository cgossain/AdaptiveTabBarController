//
//  MFTAdaptiveTabBarCentreButton.swift
//  Pods
//
//  Created by Christian Gossain on 2016-10-01.
//
//

import UIKit

class MFTAdaptiveTabBarCentreButton: UIView {
    
    var touchUpInsideHandler: ((Void) -> Void)?
    
    fileprivate lazy var bundle: Bundle = {
        return Bundle(for: MFTAdaptiveTabBarCentreButton.classForCoder())
    }()
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let image = UIImage(named: "tab-bar-centre-button", in: self.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    lazy var plusImageView: UIImageView = {
        let image = UIImage(named: "tab-bar-centre-button-plus", in: self.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let overlayButton = UIButton(type: .custom)
    
    let preferredSize = CGSize(width: 56, height: 56)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
//        backgroundImageView.layer.cornerRadius = preferredSize.width / 2
//        backgroundImageView.layer.borderColor = UIColor.white.cgColor
//        backgroundImageView.layer.borderWidth = 1.0
//        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(backgroundImageView)
        
        let image = UIImage(named: "tab-bar-centre-button", in: self.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        overlayButton.setBackgroundImage(image, for: .normal)
        overlayButton.layer.cornerRadius = preferredSize.width / 2
        overlayButton.layer.borderColor = UIColor.white.cgColor
        overlayButton.layer.borderWidth = 1.0
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayButton)
        
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.tintColor = .white
        addSubview(plusImageView)
        
        // constraints
//        topAnchor.constraint(equalTo: backgroundImageView.topAnchor).isActive = true
//        leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor).isActive = true
//        bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor).isActive = true
//        trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor).isActive = true
        plusImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        topAnchor.constraint(equalTo: overlayButton.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: overlayButton.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: overlayButton.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: overlayButton.trailingAnchor).isActive = true
        
        overlayButton.addTarget(self, action: #selector(MFTAdaptiveTabBarCentreButton.overlayButtonTapped(_:)), for: .touchUpInside)
    }
    
    override var intrinsicContentSize: CGSize {
        return preferredSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return preferredSize
    }
    
    override func tintColorDidChange() {
        backgroundImageView.tintColor = tintColor
    }
    
    @objc func overlayButtonTapped(_ sender: UIButton) {
        touchUpInsideHandler?()
    }
    
}
