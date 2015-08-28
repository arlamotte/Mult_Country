//
//  ETLocationManagerProxy.m
//  Mult_Country
//
//  Created by Archimedes Lamotte on 8/28/15.
//  Copyright (c) 2015 Archimedes Lamotte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETLocationManagerProxy.h"

@implementation ETLocationManagerProxy

+ (ETLocationManager*)sharedManager
{
    return [ETLocationManager locationManager];
}

@end