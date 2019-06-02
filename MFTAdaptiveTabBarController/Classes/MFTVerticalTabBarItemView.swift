//
//  MFTVerticalTabBarItemView.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit

class MFTVerticalTabBarItemView: UIControl {
    
    fileprivate var tabBarItem: UITabBarItem?
    
    var index: Int = 0
    
    override var isSelected: Bool {
        didSet { self.updateSelection() }
    }
    
    override var isHighlighted: Bool {
        didSet { self.updateSelection() }
    }
    
    fileprivate let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .lightGray
        return label
    }()
    
    fileprivate let containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = false
        return container
    }()
    
    // MARK: Initialization
    
    init(tabBarItem item: UITabBarItem) {
        tabBarItem = item
        super.init(frame: .zero)
        iconImageView.image = item.image?.withRenderingMode(.automatic)
        iconImageView.highlightedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = item.title
        titleLabel.highlightedTextColor = tintColor
        commonInit()
        setNeedsUpdateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        // constraints
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6.0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
//        self.layer.borderColor = UIColor.greenColor().CGColor
//        self.layer.borderWidth = 1.0
//        containerView.layer.borderColor = UIColor.purpleColor().CGColor
//        containerView.layer.borderWidth = 1.0
    }
    
    // MARK: Constraints
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 72.0)
    }
    
    // MARK: Methods (Private)
    
    private func updateSelection() {
        let isSelected = self.isSelected || self.isHighlighted
        iconImageView.isHighlighted = isSelected
        titleLabel.isHighlighted = isSelected
    }
    
    // MARK: - Overrides
    
    override func tintColorDidChange() {
        iconImageView.tintColor = tintColor
        titleLabel.highlightedTextColor = tintColor
    }

}
