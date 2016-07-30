//
//  MFTVerticalTabBarItemView.swift
//  Pods
//
//  Created by Christian Gossain on 2015-12-28.
//
//

import UIKit

class MFTVerticalTabBarItemView: UIControl {
    
    private var tabBarItem: UITabBarItem?
    
    var index: Int = 0
    
    override var selected: Bool {
        didSet { self.updateSelection() }
    }
    
    override var highlighted: Bool {
        didSet { self.updateSelection() }
    }
    
    private let imageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.userInteractionEnabled = false
        
        return i
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.userInteractionEnabled = false
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12.0)
        label.textColor = UIColor.lightGrayColor()
        
        return label
        
    }()
    
    private let containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.userInteractionEnabled = false
        
        return container
    }()
    
    // MARK: Initialization
    
    init(tabBarItem item: UITabBarItem) {
        tabBarItem = item
        super.init(frame: CGRectZero)
        
        imageView.image = item.image?.imageWithRenderingMode(.Automatic)
        imageView.highlightedImage = item.selectedImage?.imageWithRenderingMode(.AlwaysTemplate)
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
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 72.0)
    }
    
    override func updateConstraints() {
        containerView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        containerView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        containerView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        
        imageView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        imageView.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
        
        titleLabel.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor, constant: 6.0).active = true
        titleLabel.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor).active = true
        titleLabel.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true
        titleLabel.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor).active = true
        
        super.updateConstraints()
    }
    
    // MARK: Methods (Private)
    
    func updateSelection() {
        let isSelected = self.selected || self.highlighted
        imageView.highlighted = isSelected
    }

}
