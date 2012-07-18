//
//  DZWebDAVLock.h
//  Pods
//
//  Created by Zachary Waldowski on 7/17/12.
//
//

#import <Foundation/Foundation.h>

@interface DZWebDAVLock : NSObject <NSCopying, NSCoding>

- (id)initWithURL:(NSURL *)URL responseObject:(id)object;
- (id)updateFromResponseObject:(id)object;

@property (nonatomic, readonly) NSURL *URL;

@property (nonatomic, readonly) BOOL exclusive;
@property (nonatomic, readonly) BOOL recursive;
@property (nonatomic, readonly) NSTimeInterval timeout;
@property (nonatomic, copy, readonly) NSString *token;

@end
