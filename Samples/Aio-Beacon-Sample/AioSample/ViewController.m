//
//  ViewController.m
//  AioSample
//
//  Created on 12/26/12.
//  Copyright (c) 2012 Yukai Engineering. All rights reserved.
//
//  Modified Noritaka Kamiya.

#import "ViewController.h"
#import "Konashi.h"
#import "BeaconBridge.h"
@interface ViewController ()
{
    BeaconBridge *_beaconBridge;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [Konashi initialize];
    
    [Konashi addObserver:self selector:@selector(connected) name:KONASHI_EVENT_CONNECTED];
    [Konashi addObserver:self selector:@selector(ready) name:KONASHI_EVENT_READY];
    [Konashi addObserver:self selector:@selector(readAio) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE];
    [Konashi addObserver:self selector:@selector(readAio0) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO0];
    _beaconBridge = [BeaconBridge sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)find:(id)sender {
    [Konashi find];
}

- (IBAction)setVoltage1000:(id)sender {
    // [Konashi analogWrite:AIO1 milliVolt:1000];
}

- (IBAction)requestReadAio0:(id)sender {
    [Konashi analogReadRequest:AIO0];
}

- (void) connected
{
    NSLog(@"CONNECTED");
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestReadAio0:) userInfo:nil repeats:NO];
}

- (void) ready
{
    NSLog(@"READY");
    
    self.statusMessage.hidden = FALSE;
}

- (void) readAio
{
    NSLog(@"READ_AIO");
}

- (void) readAio0
{
    NSLog(@"READ_AIO0: %d", [Konashi analogRead:AIO0]);
    self.adcValue.text = [NSString stringWithFormat:@"%.3f", (float)[Konashi analogRead:AIO0]/1000];
    
    [_beaconBridge setMajorValue:(CLBeaconMajorValue)[Konashi analogRead:AIO0]];
    [_beaconBridge start];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestReadAio0:) userInfo:nil repeats:NO];
    
}

@end
