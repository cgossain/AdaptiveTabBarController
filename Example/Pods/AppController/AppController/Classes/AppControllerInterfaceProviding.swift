//
//  AppControllerInterfaceProviding.swift
//
//  Copyright (c) 2021 Christian Gossain
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

public protocol AppControllerInterfaceProviding {
    /// Return a configuration object describing the transition parameters.
    ///
    /// - Parameters:
    ///     - controller: The app controller instance requesting the configuration.
    ///     - traitCollection: The current trait collection of the root view controller.
    /// - Returns: A configuration model describing the transition parameters.
    func configuration(for controller: AppController, traitCollection: UITraitCollection) -> AppController.Configuration
    
    /// Return the view controller to be installed as the "logged out" interface.
    ///
    /// - Parameters:
    ///     - controller: The app controller instance requesting the configuration.
    /// - Returns: A view controller to install as the logged out interface.
    ///
    func loggedOutInterfaceViewController(for controller: AppController) -> UIViewController
    
    /// Return the view controller to be installed as the "logged in" interface.
    ///
    /// - Parameters:
    ///     - controller: The app controller instance requesting the configuration.
    /// - Returns: A view controller to install as the logged in interface.
    ///
    func loggedInInterfaceViewController(for controller: AppController) -> UIViewController
    
    /// Return true if the "logged in" interface should be initially loaded, or false if the "logged out" interface is initially loaded.
    ///
    /// - Parameters:
    ///     - controller: The app controller instance requesting the configuration.
    /// - Returns: `true` if the logged in interface should be initially presented, `false` otherwise.
    ///
    func isInitiallyLoggedIn(for controller: AppController) -> Bool
}
