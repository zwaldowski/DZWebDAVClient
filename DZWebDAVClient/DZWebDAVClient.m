//
//  DZWebDAVClient.m
//  DZWebDAVClient
//

#import "DZWebDAVClient.h"
#import "DZDictionaryRequestOperation.h"
#import "NSDate+RFC1123.h"
#import "NSDate+ISO8601.h"
#import "DZWebDAVLock.h"

NSString const *DZWebDAVContentTypeKey		= @"getcontenttype";
NSString const *DZWebDAVETagKey				= @"getetag";
NSString const *DZWebDAVCTagKey				= @"getctag";
NSString const *DZWebDAVCreationDateKey		= @"creationdate";
NSString const *DZWebDAVModificationDateKey	= @"modificationdate";

@interface DZWebDAVClient()
- (void)mr_listPath:(NSString *)path depth:(NSUInteger)depth success:(void(^)(AFHTTPRequestOperation *, id))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure;

@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation DZWebDAVClient

@synthesize fileManager = _fileManager;

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
		self.fileManager = [NSFileManager new];
        [self registerHTTPOperationClass: [DZDictionaryRequestOperation class]];
    }
    return self;
}

- (AFHTTPRequestOperation *)mr_operationWithRequest:(NSURLRequest *)request success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	return [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success)
			success();
	} failure:failure];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval: 300];
    return request;
}

- (void)copyPath:(NSString *)source toPath:(NSString *)destination success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    NSString *destinationPath = [[self.baseURL URLByAppendingPathComponent:destination] absoluteString];
    NSMutableURLRequest *request = [self requestWithMethod:@"COPY" path:source parameters:nil];
    [request setValue:destinationPath forHTTPHeaderField:@"Destination"];
	[request setValue:@"T" forHTTPHeaderField:@"Overwrite"];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)movePath:(NSString *)source toPath:(NSString *)destination success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    NSString *destinationPath = [[self.baseURL URLByAppendingPathComponent:destination] absoluteString];
    NSMutableURLRequest *request = [self requestWithMethod:@"MOVE" path:source parameters:nil];
    [request setValue:destinationPath forHTTPHeaderField:@"Destination"];
	[request setValue:@"T" forHTTPHeaderField:@"Overwrite"];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:nil];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getPath:(NSString *)remoteSource success:(void(^)(AFHTTPRequestOperation *, id))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath: remoteSource parameters: nil success: success failure: failure];
}

- (void)getPaths:(NSArray *)remoteSources progressBlock:(void(^)(NSUInteger, NSUInteger))progressBlock completionBlock:(void(^)(NSArray *))completionBlock {
	NSMutableArray *requests = [NSMutableArray arrayWithCapacity: remoteSources.count];
	[remoteSources enumerateObjectsUsingBlock:^(NSString *remotePath, NSUInteger idx, BOOL *stop) {
		NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:remotePath parameters:nil];
		[requests addObject:request];
	}];
	[self enqueueBatchOfHTTPRequestOperationsWithRequests:requests progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)mr_listPath:(NSString *)path depth:(NSUInteger)depth success:(void(^)(AFHTTPRequestOperation *, id))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	NSParameterAssert(success);
	NSMutableURLRequest *request = [self requestWithMethod:@"PROPFIND" path:path parameters:nil];
	NSString *depthHeader = nil;
	if (depth <= 0)
		depthHeader = @"0";
	else if (depth == 1)
		depthHeader = @"1";
	else
		depthHeader = @"infinity";
    [request setValue: depthHeader forHTTPHeaderField: @"Depth"];
    [request setHTTPBody:[@"<?xml version=\"1.0\" encoding=\"utf-8\" ?><D:propfind xmlns:D=\"DAV:\"><D:allprop/></D:propfind>" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		id checkItems = [responseObject valueForKeyPath:@"multistatus.response.propstat.prop"];
        id checkHrefs = [responseObject valueForKeyPath:@"multistatus.response.href"];
		
		NSArray *objects = [checkItems isKindOfClass:[NSArray class]] ? checkItems : @[ checkItems ],
		*keys = [checkHrefs isKindOfClass:[NSArray class]] ? checkHrefs : @[ checkHrefs ];
		
		NSDictionary *unformattedDict = [NSDictionary dictionaryWithObjects: objects forKeys: keys];
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: unformattedDict.count];
		
		[unformattedDict enumerateKeysAndObjectsUsingBlock:^(NSString *absoluteKey, NSDictionary *unformatted, BOOL *stop) {
			// filter out Finder thumbnail files (._filename), they get us screwed up.
			if ([absoluteKey.lastPathComponent hasPrefix: @"._"])
				return;
			
			// Replace an absolute path with a relative one
			NSString *key = [absoluteKey stringByReplacingOccurrencesOfString:self.baseURL.path withString:@""];
			if ([[key substringToIndex:1] isEqualToString:@"/"])
				key = [key substringFromIndex:1];
			
			// reformat the response dictionaries into usable values
			NSMutableDictionary *object = [NSMutableDictionary dictionaryWithCapacity: 5];
			
			NSString *origCreationDate = [unformatted objectForKey: DZWebDAVCreationDateKey];
            NSDate *creationDate = [NSDate dateFromRFC1123String: origCreationDate] ?: [NSDate dateFromISO8601String: origCreationDate] ?: nil;
			
			NSString *origModificationDate = [unformatted objectForKey: DZWebDAVModificationDateKey] ?: [unformatted objectForKey: @"getlastmodified"];
			NSDate *modificationDate = [NSDate dateFromRFC1123String: origModificationDate] ?: [NSDate dateFromISO8601String: origModificationDate] ?: nil;
			
			[object setObject: [unformatted objectForKey: DZWebDAVETagKey] forKey: DZWebDAVETagKey];
			[object setObject: [unformatted objectForKey: DZWebDAVCTagKey] forKey: DZWebDAVCTagKey];
			[object setObject: [unformatted objectForKey: DZWebDAVContentTypeKey] ?: [unformatted objectForKey: @"contenttype"] forKey: DZWebDAVContentTypeKey];
            [object setObject: creationDate forKey: DZWebDAVCreationDateKey];
			[object setObject: modificationDate forKey: DZWebDAVModificationDateKey];
			
			[dict setObject: object forKey: key];
		}];
		
		if (success)
			success(operation, dict);
	} failure:failure];
	[self enqueueHTTPRequestOperation:operation];
}

- (void)propertiesOfPath:(NSString *)path success:(void(^)(AFHTTPRequestOperation *, id ))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	[self mr_listPath:path depth:0 success:success failure:failure];
}

- (void)listPath:(NSString *)path success:(void(^)(AFHTTPRequestOperation *, id))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	[self mr_listPath:path depth:1 success:success failure:failure];
}

- (void)recursiveListPath:(NSString *)path success:(void(^)(AFHTTPRequestOperation *, id))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	[self mr_listPath:path depth:2 success:success failure:failure];
}

- (void)downloadPath:(NSString *)remoteSource toURL:(NSURL *)localDestination success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	if ([self.fileManager respondsToSelector:@selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:) ]) {
		[self.fileManager createDirectoryAtURL: [localDestination URLByDeletingLastPathComponent] withIntermediateDirectories: YES attributes: nil error: NULL];
	} else {
		[self.fileManager createDirectoryAtPath: [localDestination.path stringByDeletingLastPathComponent] withIntermediateDirectories: YES attributes: nil error: NULL];
	}
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:remoteSource parameters:nil];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
	operation.outputStream = [NSOutputStream outputStreamWithURL: localDestination append: NO];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)downloadPaths:(NSArray *)remoteSources toURL:(NSURL *)localFolder progressBlock:(void(^)(NSUInteger, NSUInteger))progressBlock completionBlock:(void(^)(NSArray *))completionBlock {
	BOOL hasURL = YES;
	if ([self.fileManager respondsToSelector:@selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)]) {
		[self.fileManager createDirectoryAtURL: localFolder withIntermediateDirectories: YES attributes: nil error: NULL];
	} else {
		[self.fileManager createDirectoryAtPath: localFolder.path withIntermediateDirectories: YES attributes: nil error: NULL];
		hasURL = NO;
	}
	NSMutableArray *operations = [NSMutableArray arrayWithCapacity: remoteSources.count];
	[remoteSources enumerateObjectsUsingBlock:^(NSString *remotePath, NSUInteger idx, BOOL *stop) {
		NSURL *localDestination = hasURL ? [localFolder URLByAppendingPathComponent: remotePath isDirectory: [remotePath hasSuffix:@"/"]] : [NSURL URLWithString: remotePath relativeToURL: localFolder];
		NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:remotePath parameters:nil];
		AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:NULL failure:NULL];
		operation.outputStream = [NSOutputStream outputStreamWithURL:localDestination append:NO];
		[operations addObject:operation];
	}];
	[self enqueueBatchOfHTTPRequestOperations:operations progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)makeCollection:(NSString *)path success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
	NSURLRequest *request = [self requestWithMethod:@"MKCOL" path:path parameters:nil];	
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)put:(NSData *)data path:(NSString *)remoteDestination success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:remoteDestination parameters:nil];
	[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", data.length] forHTTPHeaderField:@"Content-Length"];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
	operation.inputStream = [NSInputStream inputStreamWithData:data];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)putURL:(NSURL *)localSource path:(NSString *)remoteDestination success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:remoteDestination parameters:nil];
	[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
	operation.inputStream = [NSInputStream inputStreamWithURL:localSource];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)lockPath:(NSString *)path exclusive:(BOOL)exclusive recursive:(BOOL)recursive timeout:(NSTimeInterval)timeout success:(void(^)(AFHTTPRequestOperation *operation, DZWebDAVLock *lock))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSParameterAssert(success);
    NSMutableURLRequest *request = [self requestWithMethod: @"LOCK" path: path parameters: nil];
    [request setValue: @"application/xml" forHTTPHeaderField: @"Content-Type"];
    [request setValue: timeout ? [NSString stringWithFormat: @"Second-%f", timeout] : @"Infinite, Second-4100000000" forHTTPHeaderField: @"Timeout"];
	[request setValue: recursive ? @"Infinity" : @"0" forHTTPHeaderField: @"Depth"];
    NSString *bodyData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"utf-8\"?><D:lockinfo xmlns:D=\"DAV:\"><D:lockscope><D:%@/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockinfo>", exclusive ? @"exclusive" : @"shared"];
    [request setHTTPBody: [bodyData dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest: request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, [[DZWebDAVLock alloc] initWithURL: operation.request.URL responseObject: responseObject]);
    } failure: failure];
    [self enqueueHTTPRequestOperation: operation];
}

- (void)refreshLock:(DZWebDAVLock *)lock success:(void(^)(AFHTTPRequestOperation *operation, DZWebDAVLock *lock))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableURLRequest *request = [self requestWithMethod: @"LOCK" path: lock.URL.path parameters: nil];
    [request setValue: [NSString stringWithFormat:@"(<%@>)", lock.token] forHTTPHeaderField: @"If"];
    [request setValue: lock.timeout ? [NSString stringWithFormat: @"Second-%f", lock.timeout] : @"Infinite, Second-4100000000" forHTTPHeaderField: @"Timeout"];
	[request setValue: lock.recursive ? @"Infinity" : @"0" forHTTPHeaderField: @"Depth"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest: request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [lock updateFromResponseObject: responseObject];
        success(operation, lock);
    } failure: failure];
    [self enqueueHTTPRequestOperation: operation];
}

- (void)unlock:(DZWebDAVLock *)lock success:(void(^)(void))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableURLRequest *request = [self requestWithMethod: @"UNLOCK" path: lock.URL.path parameters: nil];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"<%@>", lock.token] forHTTPHeaderField:@"Lock-Token"];
    AFHTTPRequestOperation *operation = [self mr_operationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end
