# CRDLog
[![Build Status](https://travis-ci.org/cdisdero/CRDLog.svg?branch=master)](https://travis-ci.org/cdisdero/CRDLog)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CRDLog.svg)](https://img.shields.io/cocoapods/v/CRDLog.svg)
[![Platform](https://img.shields.io/cocoapods/p/CRDLog.svg?style=flat)](http://cocoadocs.org/docsets/CRDLog)

Simple straightforward Swift-based logging facility for iOS, macOS, watchOS, and tvOS apps

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Conclusion](#conclusion)
- [License](#license)

## Overview
A common need in apps you make is to log important activities in the app to a log file and provide the app user with a way to send that log to you to diagnose and troubleshoot problems that might occur in the field. I've written several solutions to the logging problem over the years, but decided to write another solution that's simple and easy to use for Swift-based projects.

## Requirements
- iOS 9.0+ / macOS 10.12+ / watchOS 3.0+ / tvOS 9.0+
- Xcode 10.1+
- Swift 4.0+

## Installation
You can simply copy the following files from the GitHub tree into your project:

  * `CRDLog.swift`
    - Class that implements a complete logging facility for your app.

  * `CRDLogDelegate.swift`
    - Protocol that a class can implement to provide the header content for a log file written out the first time you write a message to the log file.

### CocoaPods
Alternatively, you can install it as a Cocoapod

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build CRDLog.

To integrate CRDLog into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target 'MyApp' do
  use_frameworks!

  # Pods for MyApp
  pod 'CRDLog'
end
```

Then, run the following command:

```bash
$ pod install
```
### Carthage
You can use Carthage to add this framework to your project:
1. Add a `Cartfile` to the directory where your xcodeproj file is located.
2. Edit this file to specify the 1.0.1 release or higher of this framework:
```
github "cdisdero/CRDLog" >= 1.0.1
```
3. Run Carthage to add the framework sources and build this framework:
```
carthage update
```
4. In the General tab of your Xcode project app target, drag and drop the Carthage-built framework for your target type onto the Linked Frameworks and Libraries list at the bottom.  You can find the built framework in your project folder in the subfolder Carthage/Build/[target]/CRDLog.framework, where [target] is something like 'iOS', etc.
5. To make sure that the framework is properly stripped of extraneous CPU types for your release app, add the following Run Script build phase to your app target:
```
/usr/local/bin/carthage copy-frameworks
```
This assumes Carthage is installed in `/usr/local/bin` on your system.  Also specify the following Input Files in the same Run Script build phase:
```
$(SRCROOT)/Carthage/Build/iOS/CRDLog.framework
```

## Usage
The library is easy to use.  Just import CRDLog and create an instance of the logging class:

```
let log = CRDLog(logDelegate: self)
```

The `delegate` parameter allows you to pass an instance of a class which implements the protocol CRDLogDelegate.  This is used to provide the text of the header to the log whenever we write the initial contents to a log which is empty.

You can also construct an instance of CRDLog by specifying the log file name as well:

```
let log = CRDLog(logFileName: "myapp.log", logDelegate: self)
```

The default for `logFileName` is 'app.log', if not specified.  The log file name is appended to the path for the discardable cache files (which is typically Library/Caches) to form the pathname to the log file in storage.

Then we can use the methods to write messages to the log, for example:

```
log.info("This is a log message")
log.warn("This is a warning")
log.error("This is an error")
```

You can use the `info` method to log an informational message with the INFO tag, the `warn` method to log a warning message which will have the tag WARN in the log, and `error` to log an error with the tag ERROR.

The first message you write to the log will be preceeded by a header.  To supply the header used by the log, you should implement the `CRDLogDelegate` protocol in the class which instances CRDLog.

In the above examples, we do this when we create the instance `log` as in:

```
let log = CRDLog(logDelegate: self)
```

We need to implement the CRDLogDelegate method `logHeader()` in the class of the instance that we pass in as the logDelegate:

```
func logHeader() -> String? {

   return "This is my header"
}
```

CRDLog calls this instance method whenever it needs to write the header to the log.

At any time, you can clear the contents of the log:

```
log.clear()
```

After a clear, the next message you write will be preceeded by a header, if available, via the CRDLogDelegate method `logHeader()`, as discussed above.

You can also get the current contents of the log at any time by calling:

```
log?.contentsWithCompletion { (result: String?) in

  print("The contents of the log is:\r\n\(result)")
}
```
You can enable/disable logging to the file at any time by setting the `enableLogging` property:

```
log?.enableLogging = true // Enables logging to the file.
...
log?.enableLogging = false // Disables logging to the file.
```

Even when `enableLogging` is false, all the log output is still sent to the debug console in Xcode.


## Conclusion
I hope this small library/framework is helpful to you in your next Swift project.  I'll be updating as time and inclination permits and of course I welcome all your feedback.

## License
CRDLog is released under an Apache 2.0 license. See LICENSE for details.
