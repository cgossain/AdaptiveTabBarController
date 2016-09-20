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

open class AppController: NSObject {
    
    /// Posts a notification that is handled internally by switching to the login interface.
    open static func didLogin() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthenticationControllerDidLoginNotification), object: nil)
    }
    
    /// Posts a notification that is handled internally by switching to the main interface.
    open static func didLogout() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthenticationControllerDidLogoutNotification), object: nil)
    }
    
    /// A block that returns the logged in state. A return value of YES will load the main interface, NO will load the login interface.
    open var isLoggedInBlock: (() -> Bool)?
    
    /** 
     This block is called just before the transition to the main interface begins. The view controller that is about to be presented is passed to the block as the targetViewController.
     */
    open var willLoginBlock: ((_ targetViewController: UIViewController) -> Void)?
    
    /// This block is called after the transition to the main interface completes.
    open var didLoginBlock: (() -> Void)?
    
    /**
     This block is called just before the transition to the login interface begins. The view controller that is about to be presented is passed to the block as the targetViewController.
     */
    open var willLogoutBlock: ((_ targetViewController: UIViewController) -> Void)?
    
    /// This block is called after the transition to the login interface completes.
    open var didLogoutBlock: (() -> Void)?
    
    /// The view controller that should be installed as your window's rootViewController.
    open lazy var rootViewController: AppViewController = {
        if let storyboard = self.storyboard {
            // get the rootViewController from the storyboard
            return storyboard.instantiateInitialViewController() as! AppViewController
        }
        
        // if there is no storyboard, just create an instance of the app view controller
        return AppViewController()
    }()
    
    /// If the controller was initialized with a storyboard name, this represents the loaded storyboad instance. This value is nil if there is no storyboad.
    open var storyboard: UIStoryboard?
    
    fileprivate var isLoggedIn: Bool {
        return self.isLoggedInBlock?() ?? false
    }
    
    fileprivate let authenticationController = AuthenticationController()
    fileprivate var loginInterfaceProvider: ((Void) -> UIViewController)
    fileprivate var mainInterfaceProvider: ((Void) -> UIViewController)
    
    /**
     Initializes the controller using the specified storyboard name, login interface storyboard identifier and main interface storyboard identifier.
     
     - note: The initial view controller in the storyboard should be an instance of AppViewController.
     
     - parameter storyboardName: The name of the storyboard that contains the view controllers.
     - parameter loginInterfaceID: The storyboard identifier of the view controller that should be loaded as the root login view controller.
     - parameter mainInterfaceID: The storyboard identifier of the view controller that should be loaded as the root main view controller.
     */
    public convenience init(storyboardName: String, loginInterfaceID: String, mainInterfaceID: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        // create a closure that instantiates the login view controller from the storyboard
        let loginProvider: ((Void) -> UIViewController) = {
            return storyboard.instantiateViewController(withIdentifier: loginInterfaceID)
        }
        
        // create a closure that instantiates the main view controller from the storyboard
        let mainProvider: ((Void) -> UIViewController) = {
            return storyboard.instantiateViewController(withIdentifier: mainInterfaceID)
        }
        
        self.init(loginInterfaceProvider: loginProvider, mainInterfaceProvider: mainProvider)
        self.storyboard = storyboard
    }
    
    /**
     Initializes the controller with a _loginInterfaceProvider_ closure and a _mainInterfaceProvider_ block.
     
     - parameter loginInterfaceProvider: A closure that is called when ever the controller is requesting the view controller that should be installed as the login interface.
     - parameter mainInterfaceProvider: A closure that is called when ever the controller is requesting the view controller that should be installed as the main interface.
     */
    public init(loginInterfaceProvider loginProvider: @escaping ((Void) -> UIViewController), mainInterfaceProvider mainProvider: @escaping ((Void) -> UIViewController)) {
        loginInterfaceProvider = loginProvider
        mainInterfaceProvider = mainProvider
        super.init()
        authenticationController.onLogin = { self.transitionToMainInterface() }
        authenticationController.onLogout = { self.transitionToLoginInterface() }
    }
    
    // MARK: - Public
    
    /**
     Call this method at some point in the app delegate -application:didFinishLaunchingWithOptions: method. This trggers the app controller to check the -isLoggedInBlock and load the correct interface (i.e. login interface or main interface).
     */
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        if isLoggedIn {
            transitionToMainInterface()
        }
        else {
            transitionToLoginInterface()
        }
    }
    
    // MARK: - Private
    
    fileprivate func transitionToMainInterface() {
        let target = mainInterfaceViewController()
        willLoginBlock?(target)
        rootViewController.transitionToViewController(target, animated: true) { [unowned self] in
            self.didLoginBlock?()
        }
    }
    
    fileprivate func transitionToLoginInterface() {
        let target = loginInterfaceViewController()
        willLogoutBlock?(target)
        rootViewController.transitionToViewController(target, animated: true) { [unowned self] in
            self.didLogoutBlock?()
        }
    }
    
    fileprivate func mainInterfaceViewController() -> UIViewController {
        return mainInterfaceProvider()
    }
    
    fileprivate func loginInterfaceViewController() -> UIViewController {
        return loginInterfaceProvider()
    }
    
}
