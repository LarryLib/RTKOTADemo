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



//  升级 回调 协议
@protocol OTAProtocol <NSObject>

- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didSend:(NSUInteger)length totalToSend:(NSUInteger)totalLength;
- (void)upgradeFinish:(NSString *)msg;
- (void)upgradeError:(UpgradeError)error;

@end

@interface RTKOTA: NSObject

@property (nonatomic, strong) id<OTAProtocol> delegate;

- (void)upgradePeripheral:(CBPeripheral *)peripheral file:(NSString *)filePath;

@end
