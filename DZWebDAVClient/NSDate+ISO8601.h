//
//  NSDate+ISO8601.h
//  DZWebDAVClient
//
//  Created by Zachary Waldowski on 1/2/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Based on code by Sam Soffes. Copyright 2010. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import <Foundation/Foundation.h>

/**
 Provides extensions to `NSDate` for representing ISO8601-formatted strings.
 */
@interface NSDate (ISO8601)

/**
 Returns a new date represented by an ISO8601 string.
 
 @param iso8601String An ISO8601 string
 
 @return Date represented by the ISO8601 string
 
 @bug [Issue #56](https://github.com/samsoffes/sstoolkit/issues/56): Currently this method doesn't work with
 strings that include a timezone as anything other than "Z" like this one
 "2011-02-01T10:57:55-08:00".
 */
+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String;

/**
 Returns a string representation of the receiver in ISO8601 format.
 
 @return A string representation of the receiver in ISO8601 format.
 */
- (NSString *)ISO8601String;

@end
