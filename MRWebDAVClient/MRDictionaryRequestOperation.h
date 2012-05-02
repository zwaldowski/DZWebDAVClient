//
//  MRDictionaryRequestOperation.h
//  MRWebDAVClient
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//
//  Licensed under MIT. See LICENSE.
//

#import "AFXMLRequestOperation.h"

@interface MRDictionaryRequestOperation : AFXMLRequestOperation

@property (readonly, nonatomic, strong) NSDictionary *responseDictionary;

@end
