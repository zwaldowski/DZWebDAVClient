//
//  NSDate+RFC1123.h
//  DZWebDAVClient
//
//  Created by Zachary Waldowski on 1/2/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Based on code by Marcus Rohrmoser. Copyright 2009. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import <Foundation/Foundation.h>

/**
 * Provides extensions to `NSDate` for representing RFC1123-formatted strings.
 * 
 * Based on the [W3 specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) and ["NSDateFormatter & HTTP Header"](http://blog.mro.name/2009/08/nsdateformatter-http-header/).
 */
@interface NSDate (RFC1123)

/**
 Convert a RFC1123 'Full-Date' string (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) into NSDate.
 @param value something like either @"Fri, 14 Aug 2009 14:45:31 GMT" or @"Sunday, 06-Nov-94 08:49:37 GMT" or @"Sun Nov  6 08:49:37 1994"
 @return nil if not parseable.
 */
+ (NSDate *)dateFromRFC1123String:(NSString *)value;

/**
 Convert NSDate into a RFC1123 'Full-Date' string (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1).
 @return something like @"Fri, 14 Aug 2009 14:45:31 GMT"
 */
- (NSString *)RFC1123String;

@end