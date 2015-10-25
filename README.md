# honeyqa-iOS

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
