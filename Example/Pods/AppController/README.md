# AppController

AppController was originaly inspired by the architecture described in [this blog post](http://dev.teeps.org/blog/2015/3/27/how-to-architect-your-ios-app).

The AppController is a lightweight controller for managing transitions between "unauthenticated" and "authenticated" interfaces on iOS. Many apps implement this lazily by presenting an authentication sheet above the main app interface. This is fine for some applications, however if you're looking for something more robust, the structure implemented by AppController offers a clean and clear separation of concerns between interfaces for each authentication state. It manages interface transitions using Apple approved view controller containment API, and removes the unused view hierarchy from memory once the transition is complete. 

By keeping your "unauthenticated"  and "authenticated" view hierarchies completely separate, you can write cleaner code and build more compelling onboarding experiences.

The included example project showcases the core functionality of this library.

[![CI Status](https://img.shields.io/travis/cgossain/AppController.svg?style=flat)](https://travis-ci.org/cgossain/AppController)
[![Version](https://img.shields.io/cocoapods/v/AppController.svg?style=flat)](https://cocoapods.org/pods/AppController)
[![License](https://img.shields.io/cocoapods/l/AppController.svg?style=flat)](https://cocoapods.org/pods/AppController)
[![Platform](https://img.shields.io/cocoapods/p/AppController.svg?style=flat)](https://cocoapods.org/pods/AppController)

## Requirements
* iOS 10.3
* Swift 5.0

## Installation

AppController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AppController"
```

## Usage

### AppControllerInterfaceProviding

`AppControllerInterfaceProviding` is a protocol that vends your view hierarchies for the `unauthenticated` and `authenticated` states. It also provides configuration settings for the transition.

```
class MyAwesomeInterfaceProvider: AppControllerInterfaceProviding {

    func configuration(for appController: AppController, traitCollection: UITraitCollection) -> AppController.Configuration {
      // return a configuration model for the transition
      // note that the default configuration is being returned here, but it can be further configured
      return AppController.Configuration()
    }

    func loggedOutInterfaceViewController(for appController: AppController) -> UIViewController {
        // create and return your logged out interface view controller
        let welcomeViewController = WelcomeViewController()
        return welcomeViewController
    }

    func loggedInInterfaceViewController(for appController: AppController) -> UIViewController {
        // create and return your logged in interface view controller
        let tabBarController = UITabBarController()
        return tabBarController
    }

    func isInitiallyLoggedIn(for: AppController) -> Bool {
        // return `true` if the "logged in" interface should be initially loaded instead
        return false
    }

}
```

### AppViewController

`AppViewController` is a custom container view controller where transitions between your `unauthenticated` and `authenticated` states are performed.

You do not need to interact with this view controller directly.

### AppController

`AppController` is the object that manages the entire transition. 

You create an instance of AppController, and then call its `installRootViewController(in:)` method passing in your window object. This installs an instance of `AppViewController` (that is managed by the AppController) as the root view controller of your window object.

```
import UIKit
import AppController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let myAwesomeInterfaceProvider = MyAwesomeInterfaceProvider()

    lazy var appController: AppController = {
        let controller = AppController(interfaceProvider: self.myAwesomeInterfaceProvider)

        // do stuff just before login transition...
        controller.willLoginHandler = { [unowned self] (targetViewController) in

        }

        // do stuff right after login transition...
        controller.didLoginHandler = { [unowned self] in

        }

        // do stuff just before logout transition...
        controller.willLogoutHandler = { [unowned self] (targetViewController) in

        }

        // do stuff right after logout transition...
        controller.didLogoutHandler = { [unowned self] in

        }

        return controller
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let myWindow = UIWindow()
        window = myWindow

        // install the app controllers' root view controller as the root view controller of the window
        appController.installRootViewController(in: myWindow)

        return true
    }

}
```

### Performing the Transitions

Transition to the `authenticated` view hierarchy:

```
AppController.login()
```

Transition to the `unauthenticated` view hierarchy:

```
AppController.logout()
```

### Storyboard Support

If you use a storyboard file, you can easily configure the AppController to use it. Just ensure the `initialViewController` is an `AppViewController`, and add Storyboard IDs for you're "logged out" and "logged in" interfaces contained in storyboard file.

```
import UIKit
import AppController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var appController: AppController = {
        return AppController(storyboardName: "Main", loggedOutInterfaceID: "<Storyboad ID of `unauthenticated` view hierarchy>", loggedInInterfaceID: "<Storyboad ID of `authenticated` view hierarchy>")
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // install the app controllers' root view controller as the root view controller of the window
        appController.installRootViewController(in: window!)

        return true
    }

}
```

## Author

Christian Gossain, cgossain@gmail.com

## License

AppController is available under the MIT license. See the LICENSE file for more info.
