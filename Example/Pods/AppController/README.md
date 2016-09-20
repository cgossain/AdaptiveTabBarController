# AppController

[![CI Status](http://img.shields.io/travis/Christian Gossain/AppController.svg?style=flat)](https://travis-ci.org/Christian Gossain/AppController)
[![Version](https://img.shields.io/cocoapods/v/AppController.svg?style=flat)](http://cocoapods.org/pods/AppController)
[![License](https://img.shields.io/cocoapods/l/AppController.svg?style=flat)](http://cocoapods.org/pods/AppController)
[![Platform](https://img.shields.io/cocoapods/p/AppController.svg?style=flat)](http://cocoapods.org/pods/AppController)

## Usage

This project was originaly inspired by the architecture described in [this blog post](http://dev.teeps.org/blog/2015/3/27/how-to-architect-your-ios-app).

The app controller aims to cleanup the code required to manage transitioning between a "logged out" interface and a "logged in" interface using proper iOS view controller containment. Currently it only supports loading the "logged out" and/or "logged in" interfaces from a storyboard file by specifing the storyboard identifiers of the respective interfaces.

The AppController determines the "logged in" state on launch by checking calling a block that you provide. After that, to login or log out you can simply call the corresponding class methods on the AppController and the controller takes care of transitioning to the correct interface.

It is a simple but powerful set of classes. The example project demonstrates the core functionality.

## Requirements

## Installation

AppController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AppController"
```

## Author

Christian Gossain, cgossain@gmail.com

## License

AppController is available under the MIT license. See the LICENSE file for more info.
