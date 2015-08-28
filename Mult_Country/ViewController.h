//
//  ViewController.h
//  Mult_Country
//
//  Created by Archimedes Lamotte on 8/18/15.
//  Copyright (c) 2015 Archimedes Lamotte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *Mudar;
@property (weak, nonatomic) IBOutlet UILabel *Pais;
@property (weak, nonatomic) CLLocationManager *manager;
@property (weak, nonatomic) ETLocationManager *etlocationMgr;

@end

