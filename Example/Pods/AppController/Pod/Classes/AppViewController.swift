//
// AppViewController.swift
//
// Copyright (c) 2017 Christian Gossain
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

import UIKit

open class AppViewController: UIViewController {
    
    /// If `true`, any presented view controller is dismissed during a transition to a new view controller. Defaults to `false`.
    /// - Note: This property defaults to `false` to allow the `AppViewController` to be used as a standalone container view
    ///         controller whitout any special meddling/magic. The `AppController` will set this internally according to its 
    ///         provided Configuration model. The configuration model defaults to `true` for this property.
    var dismissesPresentedViewControllerOnTransition = false
    
    /// Returns the view controller that is currently installed.
    open private(set) var installedViewController: UIViewController?
    
    /// Transitions from the currently installed view controller to the specified view controller. If no view controller is installed, then this method simply loads the specified view controller.
    ///
    /// - Parameter toViewController: The view controller to transition to.
    /// - Parameter duration: The duration of the transition animation.
    /// - Parameter options: The transition animation options
    /// - Parameter willBeginTransition: A block that is called just before the transition actually begins (i.e. after internally dismissing a presented view controller, but before the transition)
    /// - Parameter completion: A block to be executed after the transition completes.
    open func transition(to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions, willBeginTransition: (() -> Void)? = nil, completion: (() -> Void)?) {
        // prevent adding the view controller if it's already our child
        if toViewController.parent == self {
            return
        }
        
        // force the `toViewController` to define the presentation context
        toViewController.definesPresentationContext = true
        
        // notify the transition will begin
        willBeginTransition?()
        
        // add the new controller as a child
        addChildViewController(toViewController)
        toViewController.view.frame = view.bounds
        view.addSubview(toViewController.view)
        
        // if there is a view controller currently installed, transition from it to the new one
        // otherwise if no previous view controller was loaded, we can just load the new one
        // immediately (i.e. first loading of a view controller)
        if let fromViewController = installedViewController {
            // notify the installed view controller that it is about to be removed
            fromViewController.willMove(toParentViewController: nil)
            
            // update the current reference (needs to be updated for the `setNeedsStatusBarAppearanceUpdate()` call in the animation block)
            installedViewController = toViewController
            
            // perform the transition
            transition(from: fromViewController, to: toViewController, duration: duration, options: options, animations: {
                // updating the status bar appearance change within the animation block will animate the status bar color change, if there is one
                self.setNeedsStatusBarAppearanceUpdate()
                
                // fade out the presented view controller if needed
                if let presentedViewController = self.presentedViewController, self.dismissesPresentedViewControllerOnTransition {
                    presentedViewController.view.alpha = 0.0
                }
                
            }, completion: { (finished) in
                // dismiss the presented view controller
                if let presentedViewController = self.presentedViewController, self.dismissesPresentedViewControllerOnTransition {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }
                
                // "decontain" the previous child view controller
                fromViewController.view.removeFromSuperview()
                fromViewController.removeFromParentViewController()
                
                // finish "containing" the new view controller
                toViewController.didMove(toParentViewController: self)
                
                // completion handler
                completion?()
            })
        }
        else {
            // set the current view controller
            installedViewController = toViewController
            
            // update status bar appearance
            setNeedsStatusBarAppearanceUpdate()
            
            // simply finish containing the view controller
            toViewController.didMove(toParentViewController: self)
            
            // completion handler
            completion?()
        }
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return installedViewController
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return installedViewController
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // resize and animate the installed view controllers' view
        coordinator.animate(alongsideTransition: { (context) in
            let newFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.installedViewController?.view.frame = newFrame
        }, completion: nil)
    }
}
