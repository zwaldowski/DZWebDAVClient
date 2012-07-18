//
//  DZWebDAVClient.h
//  DZWebDAVClient
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import "AFHTTPClient.h"

/** The key for a uniform (MIME) type identifier returned from the property request methods. */
extern NSString *DZWebDAVContentTypeKey;

/** The key for a unique entity identifier returned from the property request methods. */
extern NSString *DZWebDAVETagKey;

/** The key for a content identifier tag returned from the property request methods. This is only supported on some servers, and usually defines whether the contents of a collection (folder) have changed. */
extern NSString *DZWebDAVCTagKey;

/** The key for the creation date of an entity. */
extern NSString *DZWebDAVCreationDateKey;

/** The key for last modification date of an entity. */
extern NSString *DZWebDAVModificationDateKey;

@class DZWebDAVLock;

@interface DZWebDAVClient : AFHTTPClient

/**
 Enqueues an operation to copy the object at a path to another path using a `COPY` request.
 
 @param source The path to copy.
 @param destination The path to copy the item to.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of the request, with two arguments: the request operation and the network error that occurred.
 */
- (void)copyPath:(NSString *)source
		  toPath:(NSString *)destination
		 success:(void(^)(void))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to move the object at a path to another path using a `MOVE` request.
 
 @param source The path to move.
 @param destination The path to move the item to.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of the request, with two arguments: the request operation and the network error that occurred.
 */
- (void)movePath:(NSString *)source
		  toPath:(NSString *)destination
		 success:(void(^)(void))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to delete the object at a path using a `DELETE` request.
 
 @param path The path for which to create a directory.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of the request, with two arguments: the request operation and the network error that occurred.
 */
- (void)deletePath:(NSString *)path
		   success:(void(^)(void))success
		   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to load the contents of a remote file into memory using a `GET` request.
 
 @param remoteSource The path to be fetched, relative to the HTTP client's base URL.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and the object created from the request's response data.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see getPath:parameters:success:failure:
 @see downloadPath:toURL:success:failure:
 */
- (void)getPath:(NSString *)remoteSource
		success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
		failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues a group of multiple operations to load the contents of multiple
 remote files into memory using a `GET` request.
 
 @param remoteSources The paths to be fetched, all relative to the HTTP client's base URL.
 @param progressBlock A block callback, to be fired upon the completion of each request operation in the batch, with two arguments: the number of operations that are completed, and the total number of operations.
 @param completionBlock A block callback, to be fired upon successful completion of all request operations in the batch, with a single argument of the array of request operations.
 
 @see getPath:success:failure:
 @see enqueueBatchOfHTTPRequestOperationsWithRequests:progressBlock:completionBlock:
 */
- (void)getPaths:(NSArray *)remoteSources
   progressBlock:(void(^)(NSUInteger completed, NSUInteger total))progressBlock
 completionBlock:(void(^)(NSArray *completedRequests))completionBlock;

/**
 Enqueues a request to list the properties of a single entity using a `PROPFIND` request for the specified path.
 
 @param path The path for which to list the properties.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and a dictionary with the properties of the entity.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see listPath:success:failure:
 @see recursiveListPath:success:failure:
 */
- (void)propertiesOfPath:(NSString *)path
				 success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
				 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues a request to list the contents of a single collection and
 the properties of each object, including the properties of the
 collection itself, using a `PROPFIND` request.
 
 @param path The directory for which to list the contents.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and a dictionary with the properties of the directory and its contents.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see propertiesOfPath:success:failure:
 @see recursiveListPath:success:failure:
 */
- (void)listPath:(NSString *)path
		 success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
		 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues a request to list the contents of a collection, all
 subsequent objects, and the properties of each object, including
 the parent collection, using a `PROPFIND` request.
 
 @param path The directory for which to list all contents.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and a dictionary with the properties of the directory and all contents.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see propertiesOfPath:success:failure:
 @see listPath:success:failure:
 */
- (void)recursiveListPath:(NSString *)path
				  success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
				  failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to download the contents of a file directly to disk using a `GET` request.
 
 @param remoteSource The path to be fetched, relative to the HTTP client's base URL.
 @param localDestination A local URL to save the contents of a remote file to.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of the request, with two arguments: the request operation and the network error that occurred.
 
 @see getPath:success:failure:
 */
- (void)downloadPath:(NSString *)remoteSource
			   toURL:(NSURL *)localDestination
			 success:(void(^)(void))success
			 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues a group of multiple operations to download the contents of
 a file directly to disk using a `GET` request.
 
 @param remoteSources The paths to be fetched, all relative to the HTTP client's base URL.
 @param localFolder A local directory to save the downloaded objects to.
 @param progressBlock A block callback, to be fired upon the completion of each request operation in the batch, with two arguments: the number of operations that are completed, and the total number of operations.
 @param completionBlock A block callback, to be fired upon successful completion of all request operations in the batch, with a single argument of the array of request operations.
 
 @see getPaths:progressBlock:completionBlock
 */
- (void)downloadPaths:(NSArray *)remoteSources
				toURL:(NSURL *)localFolder
		progressBlock:(void(^)(NSUInteger completed, NSUInteger total))progressBlock
	  completionBlock:(void(^)(NSArray *completedRequests))completionBlock;

/**
 Enqueues a request to creates a directory using a `MKCOL` request for the specified path.
 
 @param path The path for which to create a directory.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of the request, with two arguments: the request operation and the network error that occurred.
 */
- (void)makeCollection:(NSString *)path
			   success:(void(^)(void))success
			   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to upload the specified data to a remote path using a `PUT` request.
 
 @param data The data to write to the server.
 @param remoteDestination A remote path, relative to the HTTP client's base URL, to write the data to.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see putURL:path:success:failure:
 */
- (void)put:(NSData *)data
	   path:(NSString *)remoteDestination
	success:(void(^)(void))success
	failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to upload the contents of a specified local
 file to a remote path using a `PUT` request.
 
 @param localSource A URL for a local file whose contents will be written the server.
 @param remoteDestination A remote path, relative to the HTTP client's base URL, to write the data to.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see putURL:path:success:failure:
 */
- (void)putURL:(NSURL *)localSource
		  path:(NSString *)remoteDestination
	   success:(void(^)(void))success
	   failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to lock the collection or file
 at a remote path using a `LOCK` request.
 
 @param path A remote path, relative to the HTTP client's base URL, to lock.
 @param exclusive If YES, other clients will be prevented accessing the same content.
 @param recursive If YES, the contents of a collection will be locked as well.
 @param timeout If provided, the lock will expire after the given number of seconds.
 If the timeout is 0, the lock will be infinite, or for 130 years, whichever the server honors.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and an object representing the achieved lock.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see refreshLock:success:failure:
 @see unlock:success:failure:
 */
- (void)lockPath:(NSString *)path
       exclusive:(BOOL)exclusive
       recursive:(BOOL)recursive
         timeout:(NSTimeInterval)timeout
         success:(void(^)(AFHTTPRequestOperation *operation, DZWebDAVLock *lock))success
         failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to re-lock a collection or file
 at a remote path using a `LOCK` request.
 
 @param lock A lock object, as returned from a successful call to lockPath:exclusive:recursive:timeout:success:failure:.
 @param success A block callback, to be fired upon successful completion, with two arguments: the request operation and an object representing the updated lock.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see lockPath:exclusive:recursive:timeout:success:failure:
 @see unlock:success:failure:
 */
- (void)refreshLock:(DZWebDAVLock *)lock
            success:(void(^)(AFHTTPRequestOperation *operation, DZWebDAVLock *lock))success
            failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Enqueues an operation to unlock a collection or file
 at a remote path using a `UNLOCK` request.
 
 @param lock A lock object, as returned from a successful call to lockPath:exclusive:recursive:timeout:success:failure:.
 @param success A block callback, to be fired upon successful completion, with no arguments.
 @param failure A block callback, to be fired upon the failure of either the request or the parsing of the request's data, with two arguments: the request operation and the network or parsing error that occurred.
 
 @see lockPath:exclusive:recursive:timeout:success:failure:
 @see refreshLock:success:failure:
 */
- (void)unlock:(DZWebDAVLock *)lock
       success:(void(^)(void))success
       failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
