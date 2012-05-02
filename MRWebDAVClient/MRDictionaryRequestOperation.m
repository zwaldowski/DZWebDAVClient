//
//  MRDictionaryRequestOperation.m
//  Markable
//
//  Created by Zachary Waldowski on 1/27/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "MRDictionaryRequestOperation.h"
#import "MRXMLReader.h"

static dispatch_queue_t mr_xml_request_operation_processing_queue;
static dispatch_queue_t xml_request_operation_processing_queue() {
    if (mr_xml_request_operation_processing_queue == NULL) {
        mr_xml_request_operation_processing_queue = dispatch_queue_create("com.dizzytechnology.networking.xml-request.processing", 0);
    }
    
    return mr_xml_request_operation_processing_queue;
}

@interface MRDictionaryRequestOperation ()
@property (readwrite, nonatomic, strong) NSDictionary *responseDictionary;
@property (readwrite, nonatomic, strong) NSError *parseError;
@end

@implementation MRDictionaryRequestOperation

@synthesize responseDictionary = _responseDictionary, parseError = _parseError;

- (NSDictionary *)responseDictionary {
	if (!_responseDictionary && self.responseData.length && self.isFinished) {
		NSError *error = nil;
		self.responseDictionary = [MRXMLReader dictionaryForXMLParser:self.responseXMLParser error:&error];		
		self.parseError = error;
	}
	return _responseDictionary;
}

- (NSError *)error {
    if (_parseError) {
        return _parseError;
    } else {
        return [super error];
    }
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	__weak MRDictionaryRequestOperation *safeOp = self;
    self.completionBlock = ^ {
        if ([safeOp isCancelled]) {
            return;
        }
        
        dispatch_async(xml_request_operation_processing_queue(), ^(void) {
            if (self.error) {
                if (failure) {
                    dispatch_async(self.failureCallbackQueue ? self.failureCallbackQueue : dispatch_get_main_queue(), ^{
                        failure(safeOp, safeOp.error);
                    });
                }
            } else {
                if (success) {
                    NSDictionary *XML = safeOp.responseDictionary;

                    dispatch_async(self.successCallbackQueue ? self.successCallbackQueue : dispatch_get_main_queue(), ^{
                        if (safeOp.parseError && failure) {
                            failure(safeOp, safeOp.parseError);
                        } else if (!safeOp.parseError && success) {
                            success(safeOp, XML);
                        }
                    });
                } 
            }
        });
    };    
}



@end
