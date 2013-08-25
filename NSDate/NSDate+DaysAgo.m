//
//  NSDate+DaysAgo.m
//  EVEUniverse
//
//  Created by Artem Shimanski on 05.11.12.
//
//

#import "NSDate+DaysAgo.h"

@implementation NSDate (DaysAgo)

- (NSInteger) daysAgo {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSTimeZoneCalendarUnit fromDate:self];
	NSDate* midnight = [calendar dateFromComponents:components];
	return [calendar components:NSDayCalendarUnit fromDate:midnight toDate:[NSDate date] options:0].day;
}

+ (NSString*) stringWithDaysAgo:(NSInteger) days {
	if (days == 0)
		return NSLocalizedString(@"Today", @"Today");
	else if (days == 1)
		return NSLocalizedString(@"Yesterday", @"Yesterday");
	else
		return [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @"%d days ago"), days];
}

- (NSString*) daysAgoStringWithTime:(BOOL) printTime {
	int days = [self daysAgo];
	NSString* timeString = nil;
	if (printTime) {
		static NSDateFormatter* dateFormatter = nil;
		if (!dateFormatter) {
			dateFormatter = [NSDateFormatter new];
			[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
			//[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			[dateFormatter setDateFormat:@"HH:mm:ss"];
		}
		timeString = [dateFormatter stringFromDate:self];
	}

	NSString* s;
	if (days == 0)
		s = NSLocalizedString(@"Today", @"Today");
	else if (days == 1)
		s = NSLocalizedString(@"Yesterday", @"Yesterday");
	else
		s = [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @"%d days ago"), days];
	
	if (timeString)
		return [NSString stringWithFormat:NSLocalizedString(@"%@ at %@", nil), s, timeString];
	else
		return s;
}

@end
