//
//  URQANetworkObject.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQAConfig.h"
#import "URQADefines.h"

#import "AFNetworking.h"
#import "URQANetworkObject.h"
#import "URQAParser.h"

@interface URQANetworkObject()
{
    NSMutableArray          *_nextRequestList;
    URQAParser            *_dataParser;

    AFHTTPRequestOperation  *_asyncOperation;
}

@end

@implementation URQANetworkObject

- (id)init
{
    self = [super init];
    if(self)
    {
        _dataParser = [URQAParser defaultParser];

        requestURL = nil;
        requestMethod = @"POST";
        requestHeader = nil;
        requestData = nil;

        _arguments = [[NSMutableArray alloc] init];
        _nextRequestList = [[NSMutableArray alloc] init];

        _asyncOperation = nil;
    }

    return self;
}

- (NSInteger)addNextRequest:(URQANextRequest *)request
{
    if(![request isKindOfClass:[URQANextRequest class]])
        [_nextRequestList addObject:request];
    return [_nextRequestList count] - 1;
}

- (void)removeNextRequestAtIndex:(NSInteger)index
{
    [_nextRequestList removeObjectAtIndex:index];
}

- (BOOL)sendRequest:(void (^)(id))success
            failure:(void (^)(void))failure
         completion:(void (^)(void))completion
{
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0f];
    [req setHTTPMethod:requestMethod];
    [req setValue:[NSString stringWithFormat:@"application/%@", [URQA_REQUST_TYPE lowercaseString]] forHTTPHeaderField:@"Content-Type"];
    if(requestHeader)
    {
        for(int i = 0; i < [requestHeader count]; i ++)
        {
            if([[requestHeader allValues][i] isKindOfClass:[NSString class]] &&
               [[requestHeader allKeys][i] isKindOfClass:[NSString class]])
                [req setValue:[requestHeader allValues][i] forHTTPHeaderField:[requestHeader allKeys][i]];
        }
    }
    [req setHTTPBody:[_dataParser parseObject:requestData]];
#if JQA_ENABLE_REQUEST_LOG
    URQALog(@"%@", [[NSString alloc] initWithData:[_dataParser parseObject:requestData] encoding:NSUTF8StringEncoding]);
#endif
    void(^__block successProc)(id) = ^(id resObject)
    {
        __block NSInteger successCount = 0;
        __block NSInteger requestCount = [_nextRequestList count];

        // 연결된 Request가 완료되었을시 처리
        void(^__block successEvent)(id) = ^(id object){
            successCount ++;
            if(successCount >= requestCount)
            {
                if (success)
                    success(object);
                if (completion)
                    completion();
            }
        };
        // 연결된 Request가 실패했을때 처리
        void(^__block failedEvent)(void) = ^{
            if(requestCount != -1)
            {
                if (failure)
                    failure();
                if (completion)
                    completion();
                requestCount = -1;
            }
        };

        // 연결된 Request가 없을 경우 처리
        if([_nextRequestList count] == 0)
        {
            successEvent(resObject);
            return;
        }

        // 연결된 Request 처리
        for(URQANextRequest *nReq in _nextRequestList)
        {
            if(![nReq.requestClass isSubclassOfClass:[URQANetworkObject class]]) continue;

            @try
            {
                // 요청할 Request와 인자값을 저장할 변수를 초기화한다.
                URQANetworkObject *nObj = [[nReq.requestClass alloc] init];
                NSMutableArray *nArgu = [[NSMutableArray alloc] init];
                for(URQANextRequestArgument *argument in nReq.arguments)
                {
                    NSString *arguName = argument.argumentName;
                    ARGUMENT_TYPE arguType = argument.argumentType;

                    // 이전 요청에서 받은 인자값을 그대로 보낸다.
                    if(arguType == ARGUMENT_TYPE_PREVIOUS_INDEX)
                        [nArgu addObject:_arguments[arguName.integerValue]];

                    // 모든 Response Object를 보낸다.
                    else if(arguType == ARGUMENT_TYPE_RESPONSE_ALL_OBJECT)
                        [nArgu addObject:resObject];

                    // Response Object의 특정 Object만 보낸다.
                    else if(arguType == ARGUMENT_TYPE_RESPONSE_VALUE)
                    {
                        // arguName의 규칙은 다음과 같다.
                        // Ex) [eventpaths][3][datetime]
                        id recObject = resObject;
                        NSArray *componentArray = [arguName componentsSeparatedByString:@"]["];
                        for(NSInteger index = 0; index < [componentArray count]; index ++)
                        {
                            id lastRecObject = recObject;
                            NSString *compStyle = componentArray[index];
                            if(index == 0)
                                compStyle = [compStyle stringByReplacingCharactersInRange:(NSRange){0,1} withString:@""];
                            if(index == [componentArray count] - 1)
                                compStyle = [compStyle stringByReplacingCharactersInRange:(NSRange){compStyle.length-1,1} withString:@""];

                            if(isDigit(compStyle))
                            {
                                if([recObject isKindOfClass:[NSArray class]])
                                    recObject = [(NSArray *)recObject objectAtIndex:compStyle.integerValue];
                                else if([recObject isKindOfClass:[NSDictionary class]])
                                {
                                    recObject = [(NSDictionary *)recObject valueForKey:compStyle];
                                    if(lastRecObject == recObject)
                                        recObject = [(NSDictionary *)recObject allValues][compStyle.integerValue];
                                }
                            }
                            else
                            {
                                if([recObject isKindOfClass:[NSDictionary class]])
                                    recObject = [(NSDictionary *)recObject valueForKey:compStyle];
                            }
                            if(lastRecObject == recObject)
                            {
                                [NSException raise:@"EXCEPTION" format:@"PARSING ERROR"];
                            }
                        }
                        [nArgu addObject:recObject];
                    }
                }

                nObj.arguments = [NSMutableArray arrayWithArray:nArgu];
                [nObj sendRequest:successEvent failure:failedEvent completion:nil];
            }
            @catch (NSException *exception)
            {
#if URQA_ENABLE_ERROR_LOG
                URQALog(@"Error, Sending crash reports: %@", exception);
#endif

                failedEvent();
                return;
            }
        }
    };

    void(^__block currentSuccessProc)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSData *responseData = nil;
        if([responseObject isKindOfClass:[NSData class]])
            responseData = responseObject;

        else if([responseObject isKindOfClass:[NSDictionary class]] ||
                [responseObject isKindOfClass:[NSArray class]])
            responseData = [_dataParser parseObject:responseObject];

        else if([responseObject isKindOfClass:[NSString class]])
            responseData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];

        URQAResponse *response = [[URQAResponse alloc] init];
        [response setResponseCode:operation.response.statusCode];
        [response setResponseData:responseData];

        if(responseData && [self checkSuccess:response])
            successProc([_dataParser parseData:responseData]);
    };
    _asyncOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    [_asyncOperation setCompletionBlockWithSuccess:currentSuccessProc failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
#if URQA_ENABLE_ERROR_LOG
         URQALog(@"Error, Sending crash reports: %@", error);
#endif

         if (failure)
             failure();
         if (completion)
             completion();
     }];
    [_asyncOperation start];

    return YES;
}

- (void)cancelRequest
{
    if (!_asyncOperation)
        return;

    [_asyncOperation cancel];
}

- (BOOL)checkSuccess:(URQAResponse *)response
{
    if(response.responseCode == 200)
        return YES;

    return NO;
}

- (NSArray *)nextRequestList
{
    return [NSArray arrayWithArray:_nextRequestList];
}

@end
