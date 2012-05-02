//
//  DZXMLReader.h
//  DZWebDAVClient
//
//  Created by Zachary Waldowski on 1/2/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Based on code by Troy Brant. Copyright 2010. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//


#import <Foundation/Foundation.h>

@interface DZXMLReader : NSObject

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error;
+ (NSDictionary *)dictionaryForXMLFileAtPath:(NSString *)path error:(NSError **)error;
+ (NSDictionary *)dictionaryForXMLFileAtURL:(NSURL *)URL error:(NSError **)error;
+ (NSDictionary *)dictionaryForXMLParser:(NSXMLParser *)parser error:(NSError **)error;

- (id)initWithParser:(NSXMLParser *)parser;

- (BOOL)parse;

@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) NSError *error;

@end
