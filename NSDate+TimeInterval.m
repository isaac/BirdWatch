#import "NSDate+TimeInterval.h"

#import <math.h>

@implementation NSDate (TimeInterval)

- (NSString *)stringForTimeIntervalSinceNow
{
  NSTimeInterval intervalInSeconds = fabs(self.timeIntervalSinceNow);
  double intervalInMinutes = round(intervalInSeconds/60.0);
  
  if (intervalInMinutes >= 0 && intervalInMinutes <= 1)
  {
    return intervalInMinutes == 0 ? @"less than a minute" : @"1 minute";
  }
  else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) return [NSString stringWithFormat:@"%.0f minutes", intervalInMinutes];
  else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) return @"1 hour";
  else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) return [NSString stringWithFormat:@"%.0f hours", round(intervalInMinutes/60.0)];
  else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) return @"1 day";
  else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) return [NSString stringWithFormat:@"%.0f days", round(intervalInMinutes/1440.0)];
  else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) return @"1 month";
  else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) return [NSString stringWithFormat:@"%.0f months", round(intervalInMinutes/43200.0)];
  else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) return @"1 year";
  else
    return [NSString stringWithFormat:@"over %.0f years", round(intervalInMinutes/525600.0)];    
}

@end
