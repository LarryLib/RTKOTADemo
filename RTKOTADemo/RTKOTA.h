//
//  RTKOTA.h
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <RTKOTASDK/RTKOTASDK.h>

typedef NSString *UpgradeError NS_STRING_ENUM;

static UpgradeError const UE_reconnect = @"请重新搜索连接外设";
static UpgradeError const UE_connectFail = @"连接外设失败";
static UpgradeError const UE_peripheralInvalid = @"选择的蓝牙无效或不匹配";
static UpgradeError const UE_fileInvalid = @"选择的文件无效或不匹配";
static UpgradeError const UE_unknown = @"升级失败";

typedef void(^RTKUpgradeFinish)(NSString *);
typedef void(^RTKUpgradeFail)(UpgradeError);
typedef void(^RTKUpgradeProgress)(RTKDFUPeripheral *,NSUInteger, NSUInteger);

@interface RTKOTA: NSObject

- (void)upgradePeripheral:(CBPeripheral *)peripheral file:(NSString *)filePath progress:(RTKUpgradeProgress)progress finish:(RTKUpgradeFinish)finish fail:(RTKUpgradeFail)error;

@end
