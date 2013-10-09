//
//  BeaconBridge.h
//  AioSample
//
//  Created by nori on 2013/10/07.
//  Copyright (c) 2013年 Noritaka Kamiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconBridge : NSObject
@property (nonatomic, readwrite) CLBeaconMajorValue majorValue;
@property (nonatomic, readwrite) CLBeaconMinorValue minorValue;
@property (nonatomic, strong) NSUUID *uuid;
+ (instancetype) sharedInstance;
- (void)start;
- (void)stop;
@end
