//
//  OTAFilesVC.m
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import "OTAFilesVC.h"

@interface OTAFilesVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *fileTableView;
@property (nonatomic, strong) NSMutableArray <NSString *>*fileNameArry;

@end

@implementation OTAFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"OTAFilesVC";
    
    _fileTableView = [[UITableView alloc]initWithFrame: [UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _fileTableView.delegate = self;
    _fileTableView.dataSource = self;
    [_fileTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.view addSubview:_fileTableView];
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    headerView.text = @"文件路径：document/firmwares";
    headerView.textColor = [UIColor grayColor];
    _fileTableView.tableHeaderView = headerView;

    _fileNameArry = [[NSMutableArray alloc] init];

    NSError *err;
    [_fileNameArry addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self fileDirectoryPath] error:&err]];
}

- (NSString *)fileDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    return [NSString stringWithFormat:@"%@/firmwares", paths[0]];
}

#pragma mark -- UI
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileNameArry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor redColor];
    }
    cell.textLabel.text = _fileNameArry[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self fileDirectoryPath], _fileNameArry[indexPath.row]];
    [self.delegate haveSelectedFile:filePath];
    [self.navigationController popViewControllerAnimated:true];
}

@end
