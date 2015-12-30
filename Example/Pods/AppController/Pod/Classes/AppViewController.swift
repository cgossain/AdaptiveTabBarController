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

public class AppViewController: UIViewController {
    
    /// Returns the view controller that is currently installed.
    public var installedViewController: UIViewController? {
        return self.currentRootViewController
    }
    
    private var currentRootViewController: UIViewController?
    
    /**
     Transitions from the currently installed view controller to the specified view controller. If no view controller is installed, then this method simply loads the specified view controller.
     
     - parameter toViewController: The view controller to transition to.
     - parameter animated: true if the transition should be animated, false otherwise.
     - parameter completion: A block to be executed after the transition completes.
     */
    public func transitionToViewController(toViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        // add the new controller as a child
        self.addChildViewController(toViewController)
        toViewController.view.frame = self.view.bounds
        self.view.addSubview(toViewController.view)
        
        // if there is a current view controller, transition from it to the new one
        if self.currentRootViewController != nil {
            self.currentRootViewController?.willMoveToParentViewController(nil)
            
            // perform the transition
            let d = animated ? 0.65 : 0.0;
            
            self.transitionFromViewController(self.currentRootViewController!, toViewController: toViewController, duration: d, options: .TransitionCrossDissolve, animations: nil) { finished in
                // "decontain" the old child view controller
                self.currentRootViewController?.view.removeFromSuperview()
                self.currentRootViewController?.removeFromParentViewController()
                
                // set the new current view controller and finish "containing" it
                self.currentRootViewController = toViewController
                toViewController.didMoveToParentViewController(self)
                
                // completion handler
                completion?()
            }
        }
        else {
            // simply finish containing the view controller
            toViewController.didMoveToParentViewController(self)
            
            // set the current view controller
            self.currentRootViewController = toViewController
            
            // completion handler
            completion?()
        }
    }
    
    public override func viewWillLayoutSubviews() {
        self.currentRootViewController?.view.frame = self.view.bounds
    }
}
