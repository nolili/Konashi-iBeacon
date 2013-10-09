//
//  BeaconBridge.m
//  AioSample
//
//  Created by nori on 2013/10/07.
//  Copyright (c) 2013年 Noritaka Kamiya. All rights reserved.
//

#import "BeaconBridge.h"

// 1.open terminal.app
// 2.type uuidgen
// 3.copy and paste UUID to placeholder

//#error generate uuid!!
#define kBeaconSharedUUID @"114A6655-1623-464B-9DB3-052CB6BAE08B"
#define kBeaconSharedIDString @"li.noli.*"

@interface BeaconBridge ()<CBPeripheralManagerDelegate>
{
    CBPeripheralManager *_peripheralManager;
    __weak NSTimer *_timer;
}
@end

@implementation BeaconBridge

+ (instancetype) sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"%s", __FUNCTION__);
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startAdvertising];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"peripheral Manager is not ready, code = %d", peripheral.state);
        });
    }
}

#pragma mark - Setup/Teardown
- (void)setup
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // setup peripheralManager/iBeacon
    _uuid = [[NSUUID alloc] initWithUUIDString:kBeaconSharedUUID];
    _majorValue = 0;
    _minorValue = 0;
    
    if (!_peripheralManager){
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:mainQueue options:nil];
        
        // !!! KVOでisAdvertisingの変更をキャッチできない．タイマーで状態をチェックする
        //[_peripheralManager addObserver:self forKeyPath:@"isAdvertising" options:NSKeyValueObservingOptionNew context:NULL];
        [self start];
    }
}

- (void)teardown
{
    [self stopAdvertising];
    _peripheralManager.delegate = nil;
}

- (void)dealloc
{
    [self teardown];
}

- (void)onTimer
{
    [self updateBeaconValue];
    [self startAdvertising];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"isAdvertising is changed");
}

- (void)startAdvertising
{
    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn){
        NSLog(@"peripheralManager is not avaiable");
        return;
    }
    
    if ( !_peripheralManager.isAdvertising ){
        NSMutableDictionary *peripheralData = [NSMutableDictionary dictionary];
        NSUUID *proximityUUID = [_uuid copy];
        
        CLBeaconMajorValue major = _majorValue;
        CLBeaconMinorValue minor = _minorValue;
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:kBeaconSharedIDString];
        
        // MeasuredPower ビーコンとスキャナ間の距離が，1mのときのRSSIを渡すことで，正確性が増す．
        peripheralData = [region peripheralDataWithMeasuredPower:@(-59)];
        
        // peripheral Managerでアドバタイジングを開始
        [_peripheralManager startAdvertising:peripheralData];
    }
    else{
        NSLog(@"periphralManager is advertising.");
    }
}

- (void)stopAdvertising
{
    if ([_peripheralManager isAdvertising]){
        [_peripheralManager stopAdvertising];
    }
}

- (void)updateBeaconValue
{
    [self stopAdvertising];
}

- (void)setUuid:(NSUUID *)uuid
{
    _uuid = uuid;
    [self updateBeaconValue];
}

- (void)setMajorValue:(CLBeaconMajorValue)majorValue
{
    _majorValue = majorValue;
    [self updateBeaconValue];
}

- (void)setMinorValue:(CLBeaconMinorValue)minorValue
{
    _minorValue = minorValue;
    [self updateBeaconValue];
}

- (void)start
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void)stop
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

@end
