//
//  OTAVC.h
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//


#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol OTAVCProtocol <NSObject>

- (void)haveSelectedPeripheral:(CBPeripheral *)peripheral;
- (void)haveSelectedFile:(NSString *)filePath;

@end

@interface OTAVC: UIViewController <OTAVCProtocol>

@end
