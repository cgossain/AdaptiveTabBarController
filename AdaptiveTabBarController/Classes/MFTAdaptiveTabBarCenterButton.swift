//
//  MFTAdaptiveTabBarCenterButton.swift
//
//  Copyright (c) 2021 Christian Gossain
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
        let circleImage = UIImage(named: "tab-bar-centre-button", in: .lib, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        overlayButton.setBackgroundImage(circleImage, for: .normal)
        overlayButton.layer.cornerRadius = preferredSize.width / 2
        overlayButton.layer.borderColor = UIColor.white.cgColor
        overlayButton.layer.borderWidth = 1.0
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayButton)
        
        let plusImage = UIImage(named: "tab-bar-centre-button-plus", in: .lib, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
