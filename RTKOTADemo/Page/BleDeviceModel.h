//
//  BleDeviceModel.h
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface BleDeviceModel : NSObject
@property (nonatomic, strong) CBPeripheral *per;
@property (nonatomic, strong) NSDictionary<NSString *, id> *advertisementData;
@property (nonatomic, strong) NSNumber *RSSI;
@end
