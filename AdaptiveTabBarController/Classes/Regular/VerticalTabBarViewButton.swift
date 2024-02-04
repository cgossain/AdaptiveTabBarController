//
//  VerticalTabBarViewButton.swift
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

final class VerticalTabBarViewButton: UIView {
    
    var isSelected: Bool {
        get {
            internalButton.isSelected
        }
        set {
            internalButton.isSelected = newValue
        }
    }
        
    // MARK: - Init
    
    init(
        tabBarItem: UITabBarItem,
        handler: @escaping () -> Void
    ) {
        self.tabBarItem = tabBarItem
        self.handler = handler
        super.init(frame: .zero)
        
        internalButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        internalButton.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            
            let image = button.isSelected ? self.tabBarItem.selectedImage : self.tabBarItem.image
            
            var config = UIButton.Configuration.plain()
            config.title = self.tabBarItem.title
            config.image = image?.withRenderingMode(.alwaysTemplate)
            config.imagePlacement = .top
            config.imagePadding = 8
            config.baseBackgroundColor = .clear
            config.baseForegroundColor = button.isSelected ? nil : .label
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
                var attributes = AttributeContainer()
                attributes.font = .systemFont(ofSize: 12)
                return attributes
            }
            
            button.configuration = config
        }
        
        internalButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(internalButton)
        NSLayoutConstraint.activate([
            internalButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            internalButton.topAnchor.constraint(equalTo: topAnchor),
            internalButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            internalButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
        
    @objc
    private func buttonTapped() {
        handler()
    }
    
    // MARK: - Private
    
    private let tabBarItem: UITabBarItem
    private let handler: () -> Void
    private let internalButton = UIButton(type: .custom)
}
