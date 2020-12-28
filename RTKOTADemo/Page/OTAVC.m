//
//  OTAVC.m
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import "OTAVC.h"
#import "RTKOTA.h"

#import "SVProgressHUD.h"

#import "BleDevicesVC.h"
#import "OTAFilesVC.h"

@interface OTAVC () <UITableViewDelegate, UITableViewDataSource, OTAProtocol>
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RTKOTA *rtkOTA;
@end


@implementation OTAVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"OTA";
    
    _rtkOTA = [RTKOTA new];
    _rtkOTA.delegate = self;
    
    self.tableView = [[UITableView alloc]initWithFrame: [UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.view addSubview:self.tableView];
    
    [SVProgressHUD showSuccessWithStatus:@"请先阅读《README.md》"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [NSString stringWithFormat:@"OTACELL%ld", (long)indexPath.section] ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSArray *arrStr = @[@[@"Select Device", @"Select File", @"Upgrade"]];
    
    cell.textLabel.text = arrStr[indexPath.section][indexPath.row];
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = self.peripheral.name ?  self.peripheral.name : @"";
    } else if (indexPath.row == 1) {
        cell.detailTextLabel.text = _filePath ? _filePath : @"";
        [cell.detailTextLabel sizeToFit];
    } else{
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BleDevicesVC *vc = [[BleDevicesVC alloc]init];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 1) {
            OTAFilesVC *vc = [[OTAFilesVC alloc]init];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 2) {
            [SVProgressHUD showWithStatus:@"请稍后"];
            [_rtkOTA upgradePeripheral:_peripheral file:_filePath];
        }
    }
}

- (void)haveSelectedPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    [self.tableView reloadData];
}

- (void)haveSelectedFile:(NSString *)filePath {
    _filePath = filePath;
    [self.tableView reloadData];
}

#pragma mark  升级回调
- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didSend:(NSUInteger)length totalToSend:(NSUInteger)totalLength {
    [SVProgressHUD showProgress:((float)length)/totalLength status:[NSString stringWithFormat:@"Updating...\n %lu/%lu", (unsigned long)length, (unsigned long)totalLength]];
}

- (void)upgradeFinish:(NSString *)msg {
    NSLog(msg);
    [SVProgressHUD showSuccessWithStatus:msg];
    [SVProgressHUD dismissWithDelay:2];
    
    _peripheral = nil;
    _filePath = nil;
    [self.tableView reloadData];
}

- (void)upgradeError:(UpgradeError)error {
    NSString *errorStr = [NSString stringWithFormat:@"%@", error];
    NSLog(errorStr);
    NSLog(error);
    [SVProgressHUD showErrorWithStatus:errorStr];
    [SVProgressHUD dismissWithDelay:2];
    
    _peripheral = nil;
    _filePath = nil;
    [self.tableView reloadData];
}

@end
