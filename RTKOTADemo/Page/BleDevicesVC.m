//
//  BleDevicesVC.m
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import "BleDevicesVC.h"
#import "OTAVC.h"
#import "BleDeviceModel.h"
#import "SVProgressHUD.h"

static const Byte bytes[] = {0x57, 0x44, 0x4d};
#define WDMHeader [NSData dataWithBytes:bytes length:3]

@interface BleDevicesVC () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate>
@property (nonatomic, strong) UITableView *tableDevice;
@property (nonatomic, strong) NSMutableArray <BleDeviceModel *>*arrayDevice;
@property (nonatomic, strong) CBPeripheral *ble;

@property (nonatomic, strong) CBCentralManager *manager;
@end

@implementation BleDevicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Devices";

    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableDevice = [[UITableView alloc]initWithFrame: [UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableDevice.delegate = self;
    _tableDevice.dataSource = self;
    [_tableDevice registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.view addSubview:_tableDevice];
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    headerView.text = @"暂未过滤：请选择A2板子";
    headerView.textColor = [UIColor grayColor];
    _tableDevice.tableHeaderView = headerView;

    _arrayDevice = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScan];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayDevice.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    BleDeviceModel *deviceModel = _arrayDevice[indexPath.row];
    if (deviceModel.per.name != nil) {
        cell.textLabel.text = deviceModel.per.name;
    } else {
        cell.textLabel.text = @"null";
    }
    cell.detailTextLabel.text = deviceModel.per.identifier.UUIDString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BleDeviceModel *deviceModel = _arrayDevice[indexPath.row];
    [self.delegate haveSelectedPeripheral:deviceModel.per];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark BleManager

- (void)startScan {
    if (!_manager) {
        _manager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
        _manager.delegate = self;
    }
}

- (void)stopScan {
    [_manager stopScan];
}

#pragma mark ble delegate

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState = %ld", (long)central.state);
    if (central.state == 5) {
        [_manager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral %@", peripheral.identifier);
    
    NSData *any = advertisementData[CBAdvertisementDataManufacturerDataKey];
    if (!any || [any length] < 3) {
        return;
    }
    
    BOOL isWDM = [[any subdataWithRange:NSMakeRange(0, 3)] isEqualToData:WDMHeader];
    if (!isWDM) {
        return;;
    }
    
    for (BleDeviceModel *model in self.arrayDevice) {
        if (peripheral.identifier == model.per.identifier) {
            return;
        }
    }
    
    BleDeviceModel *model = [[BleDeviceModel alloc] init];
    model.per = peripheral;
    model.advertisementData = advertisementData;
    model.RSSI = RSSI;

    [self.arrayDevice addObject:model];
    [self.tableDevice reloadData];
}

@end
