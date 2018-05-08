//
//  ViewController.m
//  HealthKitDataDemo
//
//  Created by Minhaz Panara on 08/05/18.
//  Copyright © 2018 com.aub.healthkitdatademo. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"

@interface ViewController ()
{
    __weak IBOutlet UILabel *lblCyclingDistance;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Events
/**
 On connect button action
 */
- (IBAction)onConnectBtAction:(id)sender
{
    // requesting to authorize for write-permission
    [[HealthKitManager sharedInstance] requestToWriteDataWithFinishBlock:^(NSError *error) {
        if (error) {
            NSLog(@"error : %@",error);
        } else {
            
        }
    }];
}

/**
 On Write Steps Action
 */
- (IBAction)onWriteStepsAction:(id)sender {
    
    // Steps
    NSInteger steps = 100;
    
    // Get date
    NSDate *now = [NSDate date];
    
    // Get startdate (before 60 seconds from now)
    NSDate *startDate = [now dateByAddingTimeInterval:-60];
    
    // Set end date
    NSDate *endDate = now;
    
    // Write steps with startdate, enddate
    [[HealthKitManager sharedInstance] writeSteps:steps
                                        startDate:startDate
                                          endDate:endDate withFinishBlock:^(NSError *error) {
                                              // result block
                                              if (error) {
                                                  // handle error
                                                  NSLog(@"error : %@",error);
                                              } else {
                                                  // success writing steps
                                              }
    }];
}

/**
 On Read Permission Action
 */
- (IBAction)onReadPermissionAction:(id)sender {
    
    // requesting to authorize for write-permission
    [[HealthKitManager sharedInstance] requestToReadDataWithFinishBlock:^(NSError *error) {
        if (error) {
            NSLog(@"error : %@",error);
        } else {
            
        }
    }];
}

/**
 Read Cycling Distance
 */
- (IBAction)onReadCylingDistanceAction:(id)sender
{
    __block UILabel *lblValue = lblCyclingDistance;
    [[HealthKitManager sharedInstance] readCyclingDistanceWithFinishBlock:^(NSError *error, NSNumber *value) {
        if (error) {
            // handle error
            NSLog(@"error : %@",error);
        } else {
            // value
            NSLog(@"value: %@",value);
            lblValue.text = [NSString stringWithFormat:@"%@ miles",value.stringValue];
        }
    }];
}

@end
