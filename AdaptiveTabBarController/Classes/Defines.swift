//
//  Defines.swift
//  AdaptiveTabBarController
//
//  Created by Christian Gossain on 2021-09-23.
//

import Foundation


// MARK: - Bundle

extension Bundle {
    /// Returns the bundle object for the `AdaptiveTabBarController` library.
    static var lib: Bundle {
        let bundlePath = Bundle(for: AdaptiveTabBarController.self).path(forResource: "LibAssets", ofType: "bundle")
        let bundle = Bundle(path: bundlePath!)
        return bundle!
    }
}
