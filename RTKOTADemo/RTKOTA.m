//
//  RTKOTA.m
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import "RTKOTA.h"

@interface RTKOTA () <RTKLEProfileDelegate, RTKMultiDFUPeripheralDelegate>
@property RTKOTAProfile *OTAProfile;

@property RTKOTAPeripheral *OTAPeripheral;
@property (nonatomic) RTKMultiDFUPeripheral *DFUPeripheral;

@property (nonatomic, nullable, readonly) NSArray <RTKOTAUpgradeBin*> *toUpgradeImages;

@end


@implementation RTKOTA {
    NSDate *_timeUpgradeBegin;
    
    NSArray <RTKOTAUpgradeBin*> *_images;
}

- (NSArray <RTKOTAUpgradeBin*> *)toUpgradeImages {
    return self.OTAPeripheral ? _images : nil;
}

/*---------------------------------------------------------------
 *  升级过程
 *--------------------------------------------------------------*/

#pragma Public

#pragma mark - 1、init OTAPeripheral
- (void)upgradePeripheral:(CBPeripheral *)peripheral file:(NSString *)filePath {
    if (peripheral == nil) {
        [self.delegate upgradeError:UE_reconnect];
        return;
    }
    if (filePath == nil) {
        [self.delegate upgradeError:UE_fileInvalid];
        return;
    }
    
    NSInteger interval = 0;
    if (self.OTAProfile == nil) {
        self.OTAProfile = [[RTKOTAProfile alloc] init];
        self.OTAProfile.delegate = self;
        interval = 3;
    }
    if (self.OTAPeripheral) {
        [self.OTAProfile cancelConnectionWith: self.OTAPeripheral];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.OTAPeripheral = [self.OTAProfile OTAPeripheralFromCBPeripheral:peripheral];

        if (self.OTAPeripheral != nil) {
            [self.OTAProfile connectTo:self.OTAPeripheral];
            
            NSLog(@"verifyPeripheral suceess");
            
            [self verifyFile:filePath];
        } else {
            [self.delegate upgradeError:UE_peripheralInvalid];
        }
    });
}

#pragma mark - 2、select file/files
- (void)verifyFile:(NSString *)filePath {
    if (self.OTAPeripheral == nil) {
        [self.delegate upgradeError:UE_reconnect];
        return;
    }
    
    _images = nil;
    
    NSError *error;
    _images = [RTKOTAUpgradeBin imagesExtractedFromMPPackFilePath:filePath error:&error];
    if (error || _images.count == 0) {
        [self.delegate upgradeError:UE_reconnect];
        return;
    }
    NSLog(@"verifyFile suceess");
    
    [self startUpgrade];
}

#pragma mark - 3、静默升级：需要1、2完成，且2之后3s后再执行3
- (void)startUpgrade {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.toUpgradeImages.count > 0) {
           if (self.OTAPeripheral.canEnterOTAMode && self.OTAPeripheral.canUpgradeSliently) {
                RTKDFUPeripheral *DFUPeripheral = [self.OTAProfile DFUPeripheralOfOTAPeripheral:self.OTAPeripheral];
                if (!DFUPeripheral) {
                    [self.delegate upgradeError:UE_reconnect];
                    return ;
                }
               
                DFUPeripheral.delegate = self;
                [self.OTAProfile connectTo:DFUPeripheral];
                self.DFUPeripheral = (RTKMultiDFUPeripheral*)DFUPeripheral;
           } else {
               [self.delegate upgradeError:UE_reconnect];
           }
        } else {
            [self.delegate upgradeError:UE_reconnect];
        }
    });
}

/*---------------------------------------------------------------
 *  蓝牙代理
 ---------------------------------------------------------------*/

#pragma mark - RTKLEProfileDelegate
- (void)profileManagerDidUpdateState:(RTKLEProfile *)profile {

}

- (void)profile:(RTKLEProfile *)profile didConnectPeripheral:(nonnull RTKLEPeripheral *)peripheral {
    if (peripheral == self.DFUPeripheral) {
        [self.DFUPeripheral upgradeImages:self.toUpgradeImages inOTAMode:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_timeUpgradeBegin = [NSDate date];
        });
    }
}

- (void)profile:(RTKLEProfile *)profile didDisconnectPeripheral:(nonnull RTKLEPeripheral *)peripheral error:(nullable NSError *)error {
    if (peripheral == self.OTAPeripheral) {
        if (!error) {
            self.OTAPeripheral = nil;
        }
    }
}

- (void)profile:(RTKLEProfile *)profile didFailToConnectPeripheral:(RTKLEPeripheral *)peripheral error:(nullable NSError *)error {
    [self.delegate upgradeError:UE_connectFail];
}

#pragma mark - RTKMultiDFUPeripheralDelegate

- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didSend:(NSUInteger)length totalToSend:(NSUInteger)totalLength {
    [self.delegate DFUPeripheral:peripheral didSend:length totalToSend:totalLength];
}

- (void)presentTransmissionSpeed {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger lengthTotalImages = 0;
        for (RTKOTAUpgradeBin *bin in self.toUpgradeImages) {
            lengthTotalImages += bin.data.length;
        }
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self->_timeUpgradeBegin];
        
        NSString *msg = [@"升级完成。\n" stringByAppendingFormat:@"平均速率：%.2f KB/s", (lengthTotalImages/1000.)/interval];
        [self.delegate upgradeFinish:msg];
    });
}

- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didFinishWithError:(nullable NSError *)err {
    if (err) {
        [self.delegate upgradeError: UE_unknown];
    } else {
        // 计算总传输速率
        [self presentTransmissionSpeed];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.OTAProfile cancelConnectionWith:peripheral];
        [self.OTAProfile cancelConnectionWith:self.OTAPeripheral];
        
        self.DFUPeripheral = nil;
        self.OTAPeripheral = nil;
    });
}

@end
