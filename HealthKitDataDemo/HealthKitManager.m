//
//  HealthKitManager.m
//  HealthKitDataDemo
//
//  Created by Minhaz on 08/05/18.
//  Copyright © 2018 com.aub.healthkitdatademo. All rights reserved.
//

#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>

@interface HealthKitManager ()
@property (nonatomic, retain) HKHealthStore *healthStore;
@end

@implementation HealthKitManager
// shared instance
+ (HealthKitManager *)sharedInstance {
    static HealthKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthKitManager alloc] init];
    });
    return instance;
}

// init
- (id)init {
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc] init];
    }
    return self;
}

- (void)requestToWriteDataWithFinishBlock:(void (^)(NSError *error))finishBlock
{
    // write permission
    NSArray *writeTypes = @[
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                            ];
    
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
                                             readTypes:nil
                                            completion:^(BOOL success, NSError * _Nullable error) {
                                                
                                                dispatch_sync(dispatch_get_main_queue(), ^{
                                                    
                                                    if (error) {
                                                        finishBlock(error);
                                                    } else {
                                                        finishBlock(nil);
                                                    }
                                                });
                                            }];
}

/**
    Write Steps
 */
- (void)writeSteps:(NSInteger)steps
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
   withFinishBlock:(void (^)(NSError *error))finishBlock
{
    // write steps
    // quantity type :  steps
    HKQuantityType *stepsQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    // generate count unit
    HKUnit *unit = [HKUnit countUnit];
    // generate quantity object with step count value
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:steps];
    // generate quantity sample object
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:stepsQuantityType quantity:quantity startDate:startDate endDate:endDate];
    // save sample object using health-store object
    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"Saving steps to healthStore - success: %@", success ? @"YES" : @"NO");        
        dispatch_sync(dispatch_get_main_queue(), ^{
            finishBlock(error);
        });
    }];
}

/**
 Request to read data from health application.
 */
- (void)requestToReadDataWithFinishBlock:(void (^)(NSError *error))finishBlock
{
    // read permission
    NSArray *readTypes = @[
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling]
                           ];
    
    [self.healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:[NSSet setWithArray:readTypes]
                                            completion:^(BOOL success, NSError * _Nullable error) {
                                                
                                                dispatch_sync(dispatch_get_main_queue(), ^{
                                                    
                                                    if (error) {
                                                        finishBlock(error);
                                                    } else {
                                                        finishBlock(nil);
                                                    }
                                                });
                                            }];
}

/**
 Read Cycling Distance
 */
- (void)readCyclingDistanceWithFinishBlock:(void (^)(NSError *error, NSNumber *value))finishBlock
{
    // start date
    NSDate *startDate = [self dateFromString:@"2018-05-08T00:00:00"];
    
    // end date
    NSDate *endDate = [self dateFromString:@"2018-05-08T23:59:59"];
    
    // Sample type
    HKSampleType *sampleCyclingDistance = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    
    // Predicate
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate
                                                               endDate:endDate
                                                               options:HKQueryOptionStrictStartDate];
    
    // valud
    __block float dailyValue = 0;
    
    // query
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: sampleCyclingDistance
                                                           predicate: predicate
                                                               limit: 0
                                                     sortDescriptors: nil
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          
                                                          dispatch_sync(dispatch_get_main_queue(), ^{
                                                              if (error) {
                                                                  
                                                                  NSLog(@"error");
                                                                  finishBlock(error, nil);
                                                                  
                                                              } else {
                                                                  
                                                                  for(HKQuantitySample *samples in results)
                                                                  {
                                                                      dailyValue += [[samples quantity] doubleValueForUnit:[HKUnit mileUnit]];
                                                                  }
                                                                  
                                                                  finishBlock(nil, @(dailyValue));
                                                              }
                                                          });
                                                      }
                            ];
    
    // execute query
    [self.healthStore executeQuery:query];
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSString *dt_format_string = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDateFormatter *dtFormat = [[NSDateFormatter alloc]init];
    [dtFormat setDateFormat:dt_format_string];
    NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    dtFormat.calendar = gregorian;
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dtFormat.locale = enUSPOSIXLocale;
    
    NSDate *date = [dtFormat dateFromString:dateString];
    return date;
}

@end
