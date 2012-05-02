//
//  DZDictionaryRequestOperation.h
//  DZWebDAVClient
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import "AFXMLRequestOperation.h"

/**
 `DZDictionaryRequestOperation` is a subclass of `AFXMLRequestOperation` for downloading and working with XML response data as an NSDictionary.
 
 ## Acceptable Content Types
 
 By default, `DZDictionaryRequestOperation` accepts the following MIME types, which includes the official standard, `application/xml`, as well as other commonly-used types:
 
 - `application/xml`
 - `text/xml`
 
 ## Use With AFHTTPClient
 
 When `DZDictionaryRequestOperation` is registered with `AFHTTPClient`, the response object in the success callback of `HTTPRequestOperationWithRequest:success:failure:` will be an instance of `NSDictionary`. While the `AFXMLRequestOperation` properties `responseXMLParser` and `responseXMLDocument` are available, their use is not recommended to avoid parsing twice.
 */
@interface DZDictionaryRequestOperation : AFXMLRequestOperation

/** An `NSDictionary` object parsed from the response data. */
@property (readonly, nonatomic, strong) NSDictionary *responseDictionary;

/**
 Creates and returns an `DZDictionaryRequestOperation` object and sets the specified success and failure callbacks.
 
 @param urlRequest The request object to be loaded asynchronously during execution of the operation
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes two arguments: the request operation sent from the client and the parsed response received from the server.
 @param failure A block object to be executed when the operation finishes unsuccessfully. This block has no return value and takes two arguments: the request operation sent from the client and the error describing the network error that occurred.
 
 @return A new XML dictionary request operation
 */
+ (DZDictionaryRequestOperation *)dictionaryRequestOperationWithRequest:(NSURLRequest *)urlRequest
																success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success
																failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
