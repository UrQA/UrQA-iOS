# HQAClient

[![Version](https://img.shields.io/cocoapods/v/HQAClient.svg?style=flat)](http://cocoapods.org/pods/HQAClient)
[![License](https://img.shields.io/cocoapods/l/HQAClient.svg?style=flat)](http://cocoapods.org/pods/HQAClient)
[![Platform](https://img.shields.io/cocoapods/p/HQAClient.svg?style=flat)](http://cocoapods.org/pods/HQAClient)

## Usage

1. Initialize in didFinishLaunchingWithOptions (AppDelegate)

   ```[HQAClient sharedControllerWithAPIKey:@"YOUR_API_Key"]```
2. If Application crashed, HQAClient will send crash data to HoneyQA Server
3. Or, you can send exception information manually by using

   ```[HQAClient logException:(NSException *)]```
   
   ```[HQAClient logException:(NSException *) withTag:@"Tag name"]```
   
   ```[HQAClient logException:(NSException *) withTag:@"Tag name" andErrorRank:(HQAErrorRank)]```
   
4. If you using `leaveBreadcrumb`, you can track user pattern untill application crash or exception

   ```[HQAClient leaveBreadcrumb:(Integer : Linenumber)]```
   
   ```[HQAClient logException:(NSException *)]```
   
   ```[HQAClient logException:(NSException *)]```

## route

* Session
    * `/api/ios/client/session`
* Exception
    * `/api/ios/client/exception`

## Exception Data

* `hqaData`
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

* [atosl-java](https://github.com/honeyqa/atosl-java)
