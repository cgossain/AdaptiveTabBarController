//
// AuthenticationController.swift
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

let AuthenticationControllerDidLoginNotification = "AuthenticationControllerDidLoginNotification"
let AuthenticationControllerDidLogoutNotification = "AuthenticationControllerDidLogoutNotification"

class AuthenticationController: NSObject {
    
    internal var onLogin: (() -> Void)?
    internal var onLogout: (() -> Void)?
    
    internal var loginNotificationObserver: NSObjectProtocol?
    internal var logoutNotificationObserver: NSObjectProtocol?
    
    // MARK: Initialization
    
    override init() {
        super.init()
        beginListeningForNotifications()
    }
    
    deinit {
        endListeningForNotifications()
    }
    
    // MARK: Methods (Private)
    
    fileprivate func beginListeningForNotifications() {
        loginNotificationObserver =
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AuthenticationControllerDidLoginNotification),
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                // call the login handler
                self.onLogin?()
        })
        
        logoutNotificationObserver =
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AuthenticationControllerDidLogoutNotification),
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                // call the login handler
                self.onLogout?()
        })
    }
    
    fileprivate func endListeningForNotifications() {
        if let note = loginNotificationObserver {
            NotificationCenter.default.removeObserver(note)
        }
        
        if let note = logoutNotificationObserver {
            NotificationCenter.default.removeObserver(note)
        }
    }
    
}
