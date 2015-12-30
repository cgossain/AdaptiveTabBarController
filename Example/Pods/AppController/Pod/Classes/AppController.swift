//
// AppController.swift
//
// Copyright (c) 2015 Christian R. Gossain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

public class AppController: NSObject {
    
    /// Posts a notification that is handled internally by switching to the login interface.
    public static func didLogin() {
        NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationControllerDidLoginNotification, object: nil)
    }
    
    /// Posts a notification that is handled internally by switching to the main interface.
    public static func didLogout() {
        NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationControllerDidLogoutNotification, object: nil)
    }
    
    /// A block that returns the logged in state. A return value of YES will load the main interface, NO will load the login interface.
    public var isLoggedInBlock: (() -> Bool)?
    
    /** 
     This block is called just before the transition to the main interface begins. The view controller that is about to be presented is passed to the block as the targetViewController.
     */
    public var willLoginBlock: ((targetViewController: UIViewController) -> Void)?
    
    /// This block is called after the transition to the main interface completes.
    public var didLoginBlock: (() -> Void)?
    
    /**
     This block is called just before the transition to the login interface begins. The view controller that is about to be presented is passed to the block as the targetViewController.
     */
    public var willLogoutBlock: ((targetViewController: UIViewController) -> Void)?
    
    /// This block is called after the transition to the login interface completes.
    public var didLogoutBlock: (() -> Void)?
    
    /// The view controller that should be installed as your window's rootViewController.
    public lazy var rootViewController: AppViewController! = {
        let vc = self.storyboard.instantiateInitialViewController() as! AppViewController
        return vc
    }()
    
    private var isLoggedIn: Bool {
        return self.isLoggedInBlock?() ?? false
    }
    
    private let authenticationController = AuthenticationController()
    
    public let storyboard: UIStoryboard
    private let loginInterfaceStoryboardID: String
    private let mainInterfaceStoryboardID: String
    
    private var loginInterfaceViewController: UIViewController! {
        return self.storyboard.instantiateViewControllerWithIdentifier(loginInterfaceStoryboardID)
    }
    
    private var mainInterfaceViewController: UIViewController! {
        return self.storyboard.instantiateViewControllerWithIdentifier(mainInterfaceStoryboardID)
    }
    
    /**
     Initializes the controller using the specified storyboard name, login interface storyboard identifier and main interface storyboard identifier.
     
     - note: The initial view controller in the storyboard should be an instance of AppViewController.
     
     - parameter storyboardName: The name of the storyboard that contains the view controllers.
     - parameter loginInterfaceID: The storyboard identifier of the view controller that should be loaded as the root login view controller.
     - parameter mainInterfaceID: The storyboard identifier of the view controller that should be loaded as the root main view controller.
     */
    public init(storyboardName: String, loginInterfaceID: String, mainInterfaceID: String) {
        storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        loginInterfaceStoryboardID = loginInterfaceID
        mainInterfaceStoryboardID = mainInterfaceID
        
        super.init()
        
        // logout handler
        authenticationController.onLogout = {
            self.transitionToLoginInterface()
        }
        
        // login handler
        authenticationController.onLogin = {
            self.transitionToMainInterface()
        }
    }
    
    /**
     Call this method at some point in the app delegate -application:didFinishLaunchingWithOptions: method. This trggers the app controller to check the -isLoggedInBlock and load the correct interface (i.e. login interface or main interface).
     */
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        if isLoggedIn {
            self.transitionToMainInterface()
        } else {
            self.transitionToLoginInterface()
        }
    }
    
    private func transitionToMainInterface() {
        let target = mainInterfaceViewController
        
        willLoginBlock?(targetViewController: target)
        rootViewController.transitionToViewController(target, animated: true) {
            self.didLoginBlock?()
        }
    }
    
    private func transitionToLoginInterface() {
        let target = loginInterfaceViewController
        
        willLogoutBlock?(targetViewController: target)
        rootViewController.transitionToViewController(target, animated: true) {
            self.didLogoutBlock?()
        }
    }
    
}
