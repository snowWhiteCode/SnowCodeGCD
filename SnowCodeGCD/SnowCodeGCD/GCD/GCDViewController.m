//
//  GCDViewController.m
//  SnowCodeGCD
//
//  Created by xue bai on 2018/4/10.
//  Copyright © 2018年 com.bl.DaoJia. All rights reserved.
//
/*
 Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并发任务。
 
 GCD 可用于多核的并行运算
 GCD 会自动利用更多的 CPU 内核（比如双核、四核）
 GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
 程序员只需要告诉 GCD 想要执行什么任务，不需要编写任何线程管理代码
 
 同步执行（sync）：
 
 同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行。
 只能在当前线程中执行任务，不具备开启新线程的能力。
 
 异步执行（async）：
 
 异步添加任务到指定的队列中，它不会做任何等待，可以继续执行任务。
 可以在新的线程中执行任务，具备开启新线程的能力。
 
 
 
 
 并发队列（Concurrent Dispatch Queue）：
 
 可以让多个任务并发（同时）执行。（可以开启多个线程，并且同时执行任务）
 
 
 创建一个队列（串行队列或并发队列）
 将任务追加到任务的等待队列中，然后系统就会根据任务类型执行任务（同步执行或异步执行）
 
 
 */
#import "GCDViewController.h"

@interface GCDViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation GCDViewController

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

#pragma mark - UITableViewDelegate
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
#pragma mark - UITableViewDataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0://同步执行-->串行队列（没有开启新线程在主线程中执行）
        {
            /*1.创建队列 （串行队列或并发队列） 2.将任务追加在队列中等待执行任务，然后系统就会根据任务类型执行任务（同步执行或异步执行）
             串行队列（Serial Dispatch Queue）：
             每次只有一个任务被执行。让任务一个接着一个地执行。（只开启一个线程，一个任务执行完毕后，再执行下一个任务）
             */
            dispatch_queue_t queue =  dispatch_queue_create("串行队列+同步执行", DISPATCH_QUEUE_SERIAL);//创建一个串行队列  第一个参数：表示队列的唯一标识符；第二个参数：来识别是并行队列还是串行队列 serial是串行对列的意思
            //同步执行任务创建的方法
            dispatch_sync(queue, ^{
                //任务1
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"串行队列+同步执行:1---%@",[NSThread currentThread]);
                    
                }
            });
            dispatch_sync(queue, ^{
                //任务2
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"串行队列+同步执行:2---%@",[NSThread currentThread]);
                    
                }
            });
            dispatch_sync(queue, ^{
                //任务3
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"串行队列+同步执行:3---%@",[NSThread currentThread]);
                    
                }
            });
            
            
        }
            break;
        case 1://异步执行-->串行队列(开启新线程(1条))
        {
            dispatch_queue_t queue = dispatch_queue_create("异步执行-->串行队列", DISPATCH_QUEUE_SERIAL);
            //异步执行任务创建方法
            dispatch_async(queue, ^{
                //任务1
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->串行队列:1---%@",[NSThread currentThread]);
                    
                }
            });
            
            dispatch_async(queue, ^{
                //任务2
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->串行队列:2---%@",[NSThread currentThread]);
                    
                }
            });
            
            dispatch_async(queue, ^{
                //任务3
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->串行队列:3---%@",[NSThread currentThread]);
                    
                }
            });
            
        }
            break;
        case 2://同步执行-->并行队列（没有开启新线程在主线程中执行）
        {
            //创建一个并行队列
            dispatch_queue_t queue = dispatch_queue_create("同步执行-->并行队列", DISPATCH_QUEUE_CONCURRENT);
            dispatch_sync(queue, ^{
                //任务1
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"同步执行-->并行队列:1---%@",[NSThread currentThread]);
                    
                }
            });
            dispatch_sync(queue, ^{
                //任务2
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"同步执行-->并行队列:2---%@",[NSThread currentThread]);
                    
                }
            });
            dispatch_sync(queue, ^{
                //任务3
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"同步执行-->并行队列:3---%@",[NSThread currentThread]);
                    
                }
            });
            
        }
            break;
        case 3://异步执行-->并行队列(有开启新线程，并发执行任务)
        {
            dispatch_queue_t queue = dispatch_queue_create("同步执行-->并行队列", DISPATCH_QUEUE_CONCURRENT);
            
            dispatch_async(queue, ^{
                //任务1
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->并行队列:1---%@",[NSThread currentThread]);
                    
                }
            });
            
            dispatch_async(queue, ^{
                //任务2
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->并行队列:2---%@",[NSThread currentThread]);
                    
                }
            });
            
            dispatch_async(queue, ^{
                //任务3
                for (int a = 0; a < 2; a++) {
                    [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                    NSLog(@"异步执行-->并行队列:3---%@",[NSThread currentThread]);
                    
                }
            }) ;
        }
            break;
        case 4:
        {
            
            
        }
            break;
            
        case 5:{//同步执行 + 主队列
            //直接在主线程调用会直接卡死   在子线程中调用同步执行（不会开启新线程，执行完一个任务，再执行下一个任务。）
            [NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
            
        }
            break;
            
        case 6://异步执行 + 主队列
        {
            //只能在主线程中执行，执行完一个任务，再执行下一个任务。
            [self asyncMain];
            
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark - syncMain
/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡主不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
-(void)syncMain
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        //任务1
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:1---%@",[NSThread currentThread]);
            
        }
    });
    dispatch_sync(queue, ^{
        //任务2
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:2---%@",[NSThread currentThread]);
            
        }
    });
    dispatch_sync(queue, ^{
        //任务3
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:3---%@",[NSThread currentThread]);
            self.dataSource = @[@"同步执行-->串行队列",@"异步执行-->串行队列",@"同步执行-->并行队列",@"异步执行-->并行队列",@"全局并发队列",@"同步执行 + 主队列",@"异步执行 + 主队列",@"列表刷新啦"];
            [self.tableView reloadData];//主线程刷新UI
        }
    });
}
/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)asyncMain {
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        //任务1
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:1---%@",[NSThread currentThread]);
            
        }
    });
    dispatch_async(queue, ^{
        //任务2
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:2---%@",[NSThread currentThread]);
            self.dataSource = @[@"同步执行-->串行队列",@"异步执行-->串行队列",@"同步执行-->并行队列",@"异步执行-->并行队列",@"全局并发队列",@"同步执行 + 主队列",@"异步执行 + 主队列"];
            [self.tableView reloadData];//主线程刷新UI
        }
    });
    dispatch_async(queue, ^{
        //任务3
        for (int a = 0; a < 2; a++) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"同步执行 + 主队列:3---%@",[NSThread currentThread]);
           
        }
    });
}
#pragma mark - getter/setter

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
        _dataSource = @[@"同步执行-->串行队列",@"异步执行-->串行队列",@"同步执行-->并行队列",@"异步执行-->并行队列",@"全局并发队列",@"同步执行 + 主队列",@"异步执行 + 主队列"];
    }
    return _dataSource;
}
@end
