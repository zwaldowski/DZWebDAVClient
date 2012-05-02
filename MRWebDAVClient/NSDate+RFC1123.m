//
//  NSDate+RFC1123.h
//  MRWebDAVClient
//

#import "NSDate+RFC1123.h"

static NSDateFormatter *RFC1123Formatter(void) {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss z";
	});
	return formatter;
}

static NSDateFormatter *RFC850Formatter(void) {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        formatter.dateFormat = @"EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z";
	});
	return formatter;
}

static NSDateFormatter *ASCTimeFormatter(void) {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        formatter.dateFormat = @"EEE MMM d HH':'mm':'ss yyyy";
	});
	return formatter;
}

@implementation NSDate (RFC1123)

+ (NSDate *)dateFromRFC1123String:(NSString *)value_ {
    if(value_ == nil)
        return nil;
	
	return [RFC1123Formatter() dateFromString:value_] ?: [RFC850Formatter() dateFromString:value_] ?: [ASCTimeFormatter() dateFromString:value_];
}

- (NSString *)RFC1123String {
	return [RFC1123Formatter() stringFromDate: self];
}

@end