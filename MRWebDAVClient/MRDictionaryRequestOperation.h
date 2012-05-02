//
//  MRDictionaryRequestOperation.h
//  Markable
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "AFXMLRequestOperation.h"

@interface MRDictionaryRequestOperation : AFXMLRequestOperation

@property (readonly, nonatomic, strong) NSDictionary *responseDictionary;

@end
