//
//  MRWebDAVClient.h
//  MRWebDAVClient
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import "AFHTTPClient.h"

extern NSString *MRWebDAVContentTypeKey;
extern NSString *MRWebDAVETagKey;
extern NSString *MRWebDAVCTagKey;
extern NSString *MRWebDAVCreationDateKey;
extern NSString *MRWebDAVModificationDateKey;

@interface MRWebDAVClient : AFHTTPClient

- (void)copyPath:(NSString *)source
		  toPath:(NSString *)destination
		 success:(void(^)(void))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)movePath:(NSString *)source
		  toPath:(NSString *)destination
		 success:(void(^)(void))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)deletePath:(NSString *)path
		   success:(void(^)(void))success
		   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getPath:(NSString *)remoteSource
		success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
		failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getPaths:(NSArray *)remoteSources
   progressBlock:(void(^)(NSUInteger completed, NSUInteger total))progressBlock
 completionBlock:(void(^)(NSArray *completedRequests))completionBlock;

- (void)listPath:(NSString *)path
		 success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)listPath:(NSString *)path
		   depth:(NSUInteger)depth
		 success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)recursiveListPath:(NSString *)path
				  success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
				  failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)downloadPath:(NSString *)remoteSource
			   toURL:(NSURL *)localDestination
			 success:(void(^)(void))success
			 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)downloadPaths:(NSArray *)remoteSources
				toURL:(NSURL *)localFolder
		progressBlock:(void(^)(NSUInteger completed, NSUInteger total))progressBlock
	  completionBlock:(void(^)(NSArray *completedRequests))completionBlock;

- (void)makeCollection:(NSString *)path
			   success:(void(^)(void))success
			   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)put:(NSData *)data
	   path:(NSString *)remoteDestination
	success:(void(^)(void))success
	failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)putURL:(NSURL *)localSource
		  path:(NSString *)remoteDestination
	   success:(void(^)(void))success
	   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
