//
//  OTAFilesVC.h
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import <UIKit/UIKit.h>
#import "OTAVC.h"

@interface OTAFilesVC : UIViewController

@property(nonatomic, strong) id<OTAVCProtocol> delegate;

@end
