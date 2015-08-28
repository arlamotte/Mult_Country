//
//  ETLocationManagerProxy.h
//  Mult_Country
//
//  Created by Archimedes Lamotte on 8/28/15.
//  Copyright (c) 2015 Archimedes Lamotte. All rights reserved.
//

#ifndef Mult_Country_ETLocationManagerProxy_h
#define Mult_Country_ETLocationManagerProxy_h

#import <Foundation/Foundation.h>
#import "ETLocationManager.h"


@interface ETLocationManagerProxy : NSObject

+(ETLocationManager*)sharedManager;

@end

#endif
