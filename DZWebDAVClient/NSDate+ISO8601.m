//
//  NSDate+ISO8601.m
//  DZWebDAVClient
//

#import "NSDate+ISO8601.h"
#include <time.h>

@implementation NSDate (ISO8601)

+ (NSDate *)dateFromISO8601String:(NSString *)value {
	if (!value.length)
		return nil;
	
	struct tm tm;
	strptime(value.UTF8String, "%Y-%m-%dT%H:%M:%S%z", &tm);
	time_t t = mktime(&tm);
	
	return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
}


- (NSString *)ISO8601String {
	struct tm *timeinfo;
	char buffer[80];
	
	time_t rawtime = (time_t)[self timeIntervalSince1970];
	timeinfo = gmtime(&rawtime);
	
	strftime(buffer, 80, "%Y-%m-%dT%H:%M:%SZ", timeinfo);
	
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}


@end
