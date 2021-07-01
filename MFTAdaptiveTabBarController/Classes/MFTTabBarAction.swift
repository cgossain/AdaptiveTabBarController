//
//  MFTTabBarAction.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import Foundation

public struct MFTTabBarAction {
    public enum Style {
        case dark
        case light
    }
    
    public let style: Style
    
    public let title: String
    
    public let image: UIImage
    
    public let handler: (() -> Void)
    
    public var isNew = false
    
    public init(title: String, image: UIImage, style: Style = .dark, isNew: Bool = false, handler: @escaping (() -> Void)) {
        self.style = style
        self.title = title
        self.image = image
        self.isNew = isNew
        self.handler = handler
    }
}
