//
//  TabBarActionButtonNewBadge.swift
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

final class TabBarActionButtonNewBadge: UIView {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let newBadgeImage = UIImage(named: "tab-bar-center-button-action-new-badge", in: .lib, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
