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
    
    fileprivate let imageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.isUserInteractionEnabled = false
        
        return i
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor.lightGray
        
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
        super.init(frame: CGRect.zero)
        
        imageView.image = item.image?.withRenderingMode(.automatic)
        imageView.highlightedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = item.title
        
        self.commonInit()
        self.setNeedsUpdateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        
//        self.layer.borderColor = UIColor.greenColor().CGColor
//        self.layer.borderWidth = 1.0
//        
//        containerView.layer.borderColor = UIColor.purpleColor().CGColor
//        containerView.layer.borderWidth = 1.0
    }
    
    // MARK: Constraints
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 72.0)
    }
    
    override func updateConstraints() {
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6.0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        super.updateConstraints()
    }
    
    // MARK: Methods (Private)
    
    func updateSelection() {
        let isSelected = self.isSelected || self.isHighlighted
        imageView.isHighlighted = isSelected
    }

}
