# UrQAClient

[![Version](https://img.shields.io/cocoapods/v/URQAClient.svg?style=flat)](http://cocoapods.org/pods/URQAClient)
[![License](https://img.shields.io/cocoapods/l/URQAClient.svg?style=flat)](http://cocoapods.org/pods/URQAClient)
[![Platform](https://img.shields.io/cocoapods/p/URQAClient.svg?style=flat)](http://cocoapods.org/pods/URQAClient)

## Overview

iOS Client for open source crash report service [honeyqa](https://honeyqa.io)

## Installation

Available through [CocoaPods](https://cocoapods.org/pods/URQAClient).

``` pod 'URQAClient' ```

Also, you should add `use_frameworks!` to `Podfile`

## Usage

1. Initialize in didFinishLaunchingWithOptions (AppDelegate)

   ```[URQAClient sharedControllerWithAPIKey:@"YOUR_API_Key"]```
2. If Application crashed, URQAClient will send crash data to HoneyQA Server
3. Or, you can send exception information manually by using

   ```[URQAClient logException:(NSException *)]```

   ```[URQAClient logException:(NSException *) withTag:@"Tag name"]```

   ```[URQAClient logException:(NSException *) withTag:@"Tag name" andErrorRank:(URQAErrorRank)]```

4. If you using `leaveBreadcrumb`, you can track user pattern untill application crash or exception

   ```[URQAClient leaveBreadcrumb:(Integer : Linenumber)]```

   ```[URQAClient logException:(NSException *)]```

   ```[URQAClient logException:(NSException *)]```

### iOS 9
---
Please edit your `.plist` file for send crash data to UrQA server.

There are 2 options,

* add `Dictionary` named `NSAppTransportSecurity`
   * add `Boolean | Yes` `NSAllowsArbitraryLoads` to `NSAppTransportSecurity`
   * Or, add `Dictionary` named `NSExceptionDomains` to `NSAppTransportSecurity`
      *  then, add `Dictionary` named `api3.honeyqa.io` to `NSExceptionDomains`

## route

* Session
    * `/api/ios/client/session`
* Exception
    * `/api/ios/client/exception`

## Exception Data
* `buildid` : Symbol UUID
* `URQAData`
    * `arch` : Object
        * `osName` : String
            * device OS name
        * `codeType` : String
            * architecture information
    * `process` : Object
        * `processPath` : String
            * for extract Application name
    * `register` : Object
        * `register name` : `register value`
            * String : String
    * `thread` : Array
        * Object
            * `frame` : Array
                * Object
                    * `imageName` : String
                    * `baseAddress` : String
                        * [!] when **symbol information is not null**, object will not contain `baseAddress`
                    * `symbolName` : String
                        * [!] when **symbol information is null**, object will not contain `symbolName`
                    * `frameIndex` : String
                    * `offset` : String
            * `isCrashed` : String
                * `"1"` : crashed
                * `"0"` : not crashed

## Symbolication

* [atosl-java](https://github.com/UrQA/atosl-java)

## Reference

* [UrQA-Client-iOS](https://github.com/UrQA/UrQA-Client-iOS)
