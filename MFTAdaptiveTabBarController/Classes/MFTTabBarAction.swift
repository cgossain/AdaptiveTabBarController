//
//  MFTTabBarAction.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import Foundation
import SnapKit

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
        label.textColor = UIColor.white
        return label
    }()
    
    let action: MFTTabBarAction
    var didTapHandler: (() -> Void)?
    
    public init(action: MFTTabBarAction) {
        self.action = action
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 70.0, height: 70.0))
        addSubview(button)
        addSubview(titleLabel)
        
//        snp_makeConstraints { (make) in
//            make.width.greaterThanOrEqualTo(button)
//        }
        
        button.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(titleLabel.snp_top)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        action.handler()
        didTapHandler?()
    }
    
}
