//
//  DZWebDAVLock.m
//  Pods
//
//  Created by Zachary Waldowski on 7/17/12.
//
//

#import "DZWebDAVLock.h"

@implementation DZWebDAVLock

@synthesize exclusive = _exclusive, recursive = _recursive, timeout = _timeout, token = _token;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        _URL = [NSURL URLWithString: [aDecoder decodeObjectForKey: @"URL"]];
        _exclusive = [aDecoder decodeBoolForKey: @"exclusive"];
        _recursive = [aDecoder decodeBoolForKey: @"recursive"];
        _timeout = [aDecoder decodeFloatForKey: @"timeout"];
        _token = [[aDecoder decodeObjectForKey: @"token"] copy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL responseObject:(id)object {
    if ((self = [super init])) {
        _URL = URL;
        _exclusive = !![object valueForKey: @"exclusive"];
        _recursive = [[object valueForKey: @"depth"] isEqualToString: @"Infinity"];
        _timeout = [[[[object valueForKey: @"timeout"] componentsSeparatedByString:@"-"] lastObject] floatValue];
        _token = [[object valueForKey: @"locktoken"] copy];
    }
    return self;
}

- (id)updateFromResponseObject:(id)object {
    if ([object valueForKey: @"exclusive"])
        _exclusive = YES;
    if ([object valueForKey: @"depth"])
        _recursive = [[object valueForKey: @"depth"] isEqualToString: @"Infinity"];
    if ([object valueForKey: @"timeout"])
        _timeout = [[[[object valueForKey: @"timeout"] componentsSeparatedByString:@"-"] lastObject] floatValue];
    if ([object valueForKey: @"locktoken"])
        _token = [[object valueForKey: @"locktoken"] copy];
    return object;
}

- (id)copyWithZone:(NSZone *)zone {
    DZWebDAVLock *new = [[[self class] alloc] init];
    new->_URL = [_URL copy];
    new->_exclusive = _exclusive;
    new->_recursive = _recursive;
    new->_timeout = _timeout;
    new->_token = [_token copy];
    return new;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: [_URL path] forKey: @"URL"];
    [aCoder encodeBool: _exclusive forKey: @"exclusive"];
    [aCoder encodeBool: _recursive forKey: @"recursive"];
    [aCoder encodeFloat: _timeout forKey: @"timeout"];
    [aCoder encodeObject: _token forKey: @"token"];
}

@end
