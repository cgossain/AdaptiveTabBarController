//
// AppViewController.swift
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

open class AppViewController: UIViewController {
    
    /// Returns the view controller that is currently installed.
    open var installedViewController: UIViewController? { return self.currentRootViewController }
    
    /// Internal reference to the installed view controller
    fileprivate var currentRootViewController: UIViewController?
    
    /**
     Transitions from the currently installed view controller to the specified view controller. If no view controller is installed, then this method simply loads the specified view controller.
     - parameter toViewController: The view controller to transition to.
     - parameter animated: true if the transition should be animated, false otherwise.
     - parameter completion: A block to be executed after the transition completes.
     */
    open func transitionToViewController(_ toViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if toViewController.parent == self {
            return
        }
        
        // add the new controller as a child
        addChildViewController(toViewController)
        toViewController.view.frame = view.bounds
        view.addSubview(toViewController.view)
        
        // if there is a current view controller, transition from it to the new one
        if let current = currentRootViewController {
            current.willMove(toParentViewController: nil)
            
            // update the current reference
            currentRootViewController = toViewController
            
            // perform the transition
            let d = animated ? 0.65 : 0.0;
            transition(from: current, to: toViewController, duration: d, options: .transitionCrossDissolve, animations: {
                // animate the status bar apperance change
                self.setNeedsStatusBarAppearanceUpdate()
            }) { finished in
                // "decontain" the old child view controller
                current.view.removeFromSuperview()
                current.removeFromParentViewController()
                
                // finish "containing" the new view controller
                toViewController.didMove(toParentViewController: self)
                
                // completion handler
                completion?()
            }
        }
        else {
            // simply finish containing the view controller
            toViewController.didMove(toParentViewController: self)
            
            // set the current view controller
            currentRootViewController = toViewController
            
            // update status bar appearance
            setNeedsStatusBarAppearanceUpdate()
            
            // completion handler
            completion?()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        self.currentRootViewController?.view.frame = self.view.bounds
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return installedViewController
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return installedViewController
    }
}
