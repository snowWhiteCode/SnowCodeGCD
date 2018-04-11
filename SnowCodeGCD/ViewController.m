//
//  ViewController.m
//  SnowCodeGCD
//
//  Created by xue bai on 2018/4/10.
//  Copyright © 2018年 com.bl.DaoJia. All rights reserved.
//

#import "ViewController.h"
#import "PthreadsViewController.h"
#import "NSThreadViewController.h"
#import "GCDViewController.h"
#import "NSOperationViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}


-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.frame;

}

#pragma mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}
#pragma mark -UITableViewDataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
            case 0:
        {
            PthreadsViewController *vc = [[PthreadsViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            case 1:
        {
            NSThreadViewController *vc = [[NSThreadViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            case 2:
        {
            GCDViewController *vc = [[GCDViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            case 3:
        {
            NSOperationViewController *vc = [[NSOperationViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -getter/setter
-(UITableView *)tableView
{
    if(_tableView == nil){
        _tableView = [[UITableView alloc]initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellId"];
    }
    return _tableView;
}


-(NSArray *)dataSource
{
    if(_dataSource == nil){
        _dataSource = @[@"Pthreads",@"NSThread",@"GCD",@"NSOperation & NSOperationQueue"];
    }
    return _dataSource;
}
@end
