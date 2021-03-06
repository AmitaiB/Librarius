//
//  NSString+dateValue.m
//  Librarius
//
// From: https://github.com/eppz/eppz-kit/blob/master/eppz!kit/NSString%2BEPPZKit.h
//
//

#import "NSString+dateValue.h"

@implementation NSString (dateValue)

    //!!!: Grok this!
-(NSDate*)dateValue
{
    __block NSDate *detectedDate;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
    [detector enumerateMatchesInString:self
                               options:kNilOptions
                                 range:NSMakeRange(0, [self length])
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                detectedDate = result.date;
                            }];
    return detectedDate;
}

+(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}


@end
