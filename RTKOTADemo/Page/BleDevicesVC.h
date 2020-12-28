//
//  BleDevicesVC.h
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import <UIKit/UIKit.h>
#import <RTKOTASDK/RTKOTASDK.h>
#import "OTAVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface BleDevicesVC : UIViewController

@property(nonatomic, strong) id<OTAVCProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
