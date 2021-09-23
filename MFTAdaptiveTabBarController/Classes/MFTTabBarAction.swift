//
//  MFTTabBarAction.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import Foundation

public struct MFTTabBarAction {
    
    public let title: String
    
    public let image: UIImage
    
    public let handler: (() -> Void)
    
    public var isNew = false
    
    public init(title: String, image: UIImage, isNew: Bool = false, handler: @escaping (() -> Void)) {
        self.title = title
        self.image = image
        self.isNew = isNew
        self.handler = handler
    }
}
