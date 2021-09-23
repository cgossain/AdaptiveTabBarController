//
//  MFTTabBarActionViewNewBadge.swift
//  MFTAdaptiveTabBarController
//
//  Created by Christian Gossain on 2021-09-22.
//

import UIKit

final class MFTTabBarActionViewNewBadge: UIView {
    
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
