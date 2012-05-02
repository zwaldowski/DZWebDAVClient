//
//  NSDate+RFC1123.h
//
//  Created by Marcus Rohrmoser on 19.08.09.
//
//  Category on NSDate to add rfc1123 dates.
//  http://blog.mro.name/2009/08/nsdateformatter-http-header/ and
//  http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC1123)

/**
 Convert a RFC1123 'Full-Date' string (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) into NSDate.
 @param value_ something like either @"Fri, 14 Aug 2009 14:45:31 GMT" or @"Sunday, 06-Nov-94 08:49:37 GMT" or @"Sun Nov  6 08:49:37 1994"
 @return nil if not parseable.
 */
+ (NSDate *)dateFromRFC1123String:(NSString *)value;

/**
 Convert NSDate into a RFC1123 'Full-Date' string (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1).
 @return something like @"Fri, 14 Aug 2009 14:45:31 GMT"
 */
- (NSString *)RFC1123String;

@end