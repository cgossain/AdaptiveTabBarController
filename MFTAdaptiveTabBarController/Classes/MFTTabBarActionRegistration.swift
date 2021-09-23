//
//  MFTTabBarActionRegistration.swift
//  MFTAdaptiveTabBarController
//
//  Created by Christian Gossain on 2021-09-22.
//

import Foundation

final class MFTTabBarActionRegistration {
    /// The action.
    let action: MFTTabBarAction
    
    /// The condition.
    let condition: MFTAdaptiveTabBarController.ConditionHandler?
    
    /// Creates and returns a new action registration.
    init(action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        self.action = action
        self.condition = condition
    }
}
