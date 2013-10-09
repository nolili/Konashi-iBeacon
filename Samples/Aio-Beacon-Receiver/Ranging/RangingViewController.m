//
//  ViewController.m
//  Ranging
//
//  Created by nori on 2013/07/04.
//  Copyright (c) 2013年 nori. All rights reserved.
//

#import "RangingViewController.h"
#import "SharedID.h"
@import CoreLocation;
@interface RangingViewController () <CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
}

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;

@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;

@property (weak, nonatomic) IBOutlet UILabel *largeMajorLabel;

@end

@implementation RangingViewController

- (void)setup
{
    if ( [CLLocationManager isRangingAvailable] ){
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconSharedUUID];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kBeaconSharedIDString];
        
        [_locationManager startRangingBeaconsInRegion:beaconRegion];
    }
    
    else {
        NSLog(@"このデバイスは，位置情報のモニタリング, iBeaconを使った近接距離計測に対応していません．");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
    // rangingに必要なLocationManagerを初期化
    [self setup];
}

- (void)dealloc
{
    _locationManager.delegate = nil;
}

- (void)setupUI
{
    self.proximityLabel.text = @"";
    self.uuidLabel.text = @"";
    self.majorLabel.text = @"";
    self.minorLabel.text = @"";
    self.accuracyLabel.text = @"";
    self.countLabel.text = @"0";
    self.largeMajorLabel.text = @"";
}

// ビーコンとの距離を計測した
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    BLog();
    
    // ビーコンのリストを出力
    NSLog(@"計測中のビーコンリスト");
    for (CLBeacon *beacon in beacons) {
        NSLog(@"%@",beacon);
    }
    NSLog(@"-------------");
    
    // ビーコンのリストからProximityがCLProximityUnknownの要素をフィルタリングする．
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown];
    NSArray *filterdArray = [beacons filteredArrayUsingPredicate:filter];
    
    if (!filterdArray.count){
        [self setupUI];
        return;
    }
    
    // 一番近くにあるビーコンを取得
    CLBeacon *nearlestBeacon = [filterdArray firstObject];
    CLProximity proximity = nearlestBeacon.proximity;
    
    switch (proximity) {
        case CLProximityFar:
            // 遠いよ
            NSLog(@"CLProximityFar");
            self.proximityLabel.text = @"CLProximityFar";
            break;
            
        case CLProximityNear:
            // 近くだよ
            NSLog(@"CLProximityNear");
            self.proximityLabel.text = @"CLProximityNear";
            break;
            
        case CLProximityImmediate:
            // 一番近くだよ
            NSLog(@"CLProximityImmidiate");
            self.proximityLabel.text = @"CLProximityImmidiate";
            break;
            
        case CLProximityUnknown:
            // わからない
            NSLog(@"CLProximityUnknown");
            self.proximityLabel.text = @"CLProximityUnknown";
            break;
            
        default:
            break;
    }
    NSLog(@"Accuracy %f", nearlestBeacon.accuracy);
    
    // ラベルの更新
    self.uuidLabel.text = [region.proximityUUID UUIDString];
    self.majorLabel.text = [nearlestBeacon.major description];
    self.minorLabel.text = [nearlestBeacon.minor description];
    self.countLabel.text = [NSString stringWithFormat:@"%d", filterdArray.count];
    self.largeMajorLabel.text = [self.majorLabel.text copy];
    
    float voltage = (float)nearlestBeacon.major.intValue / 1000;
    self.largeMajorLabel.text = [NSString stringWithFormat:@"%.3fV", voltage];
    
    // accuracyはビーコンとの距離を示すが，絶対値ではない．位置の特定には使用しない．
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.4f m", nearlestBeacon.accuracy];
    
}

// 計測に失敗した
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    BLog();
}

// 位置情報サービスが使えるか，使えないかの状態が変化した．
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    BLog();
}

// 位置情報サービスのエラーが起きた．
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    BLog();
    // TODO:すべての位置情報サービスを停止させ，不要なインスタンスを破棄する．
    // 利用可能になった時点で，状態を初期状態に戻す．
}

@end
