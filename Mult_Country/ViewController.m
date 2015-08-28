//
//  ViewController.m
//  Mult_Country
//
//  Created by Archimedes Lamotte on 8/18/15.
//  Copyright (c) 2015 Archimedes Lamotte. All rights reserved.
//

#import "ViewController.h"
#import "ETPush.h"
#import "ETLocationManagerProxy.h"

@interface ViewController ()

@end



@implementation ViewController 

CLLocation *location;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager requestAlwaysAuthorization];
    self.etlocationMgr = [ETLocationManagerProxy sharedManager];
    [self.etlocationMgr startWatchingLocation];
    [self.manager startUpdatingLocation];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.Pais.font = [UIFont fontWithName:@"System Bold" size:36.0f];
    self.Pais.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Pais"];
    
    [[ETPush pushManager] resetBadgeCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (IBAction)Mudar:(id)sender{

    NSString *tags = nil;
    NSSet *all = nil;
    
    all = [[ETPush pushManager] allTags];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newAppID"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:@"newAppID"];
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:@"IsAppIdReset"];
        [[NSUserDefaults standardUserDefaults] setObject:@"País 1"
                                                  forKey:@"Pais"];
        tags = [[ETPush pushManager] removeTag:@"P2"];
    
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:@"newAppID"];
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:@"IsAppIdReset"];

        [[NSUserDefaults standardUserDefaults] setObject:@"País 2"
                                                  forKey:@"Pais"];
        tags = [[ETPush pushManager] removeTag:@"P1"];
    }
    
     all = [[ETPush pushManager] allTags];
    
    [[ETPush pushManager] updateET];
    
    printf("%s", [tags cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    self.Pais.font = [UIFont fontWithName:@"System Bold" size:36.0f];
    self.Pais.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Pais"];
    

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(CLLocation *)locations
{
    [self.etlocationMgr updateLocationServerWithLocation:locations forAppState:LocationUpdateAppStateBackground];
}


@end
