//
//  AdaptiveTabBarActionButton.swift
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

final class AdaptiveTabBarActionButton: UIView {
    
    /// Called when the receiver is tapped.
    var touchUpInsideHandler: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height))
        
        let circleImage = UIImage(named: "tab-bar-center-button-circle", in: .lib, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        internalButton.setBackgroundImage(circleImage, for: .normal)
        internalButton.layer.cornerRadius = preferredSize.width / 2
        internalButton.layer.borderColor = UIColor.white.cgColor
        internalButton.layer.borderWidth = 1.0
        internalButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(internalButton)
        
        let plusImage = UIImage(named: "tab-bar-center-button-plus", in: .lib, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        plusImageView.image = plusImage
        plusImageView.tintColor = .white
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusImageView)
        
        plusImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        topAnchor.constraint(equalTo: internalButton.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: internalButton.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: internalButton.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: internalButton.trailingAnchor).isActive = true
        
        internalButton.addTarget(self, action: #selector(AdaptiveTabBarActionButton.overlayButtonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override var intrinsicContentSize: CGSize {
        preferredSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        preferredSize
    }
    
    // MARK: - Helpers
    
    @objc
    private func overlayButtonTapped(_ sender: UIButton) {
        touchUpInsideHandler?()
    }
    
    // MARK: - Private
    
    private let internalButton = UIButton(type: .custom)
    private let plusImageView = UIImageView()
    private let preferredSize = CGSize(width: 56, height: 56)
}
