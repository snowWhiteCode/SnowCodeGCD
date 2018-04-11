//
//  NSThreadViewController.m
//  SnowCodeGCD
//
//  Created by xue bai on 2018/4/10.
//  Copyright © 2018年 com.bl.DaoJia. All rights reserved.
//

#import "NSThreadViewController.h"

@interface NSThreadViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSThread *oneThread;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSCondition *condition;
@end


/*
 NSThread属于轻量级多任务实现方式，可以更加直观的管理线程，需要手动管理线程的生命周期、同步、加锁问题，会导致一定的性能开销
 */
@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self performSelectorInBackground:@selector(doSomethingBackground:) withObject:@"Background"];/*在主线程指定在后台线程执行*/
    /*
     隐式创建
     用于线程之间通信，比如：指定任务在当前线程执行
     
     //在主线程中指定某个特定线程执行
     [self performSelector:@selector(doSomething:)  onThread:newThread withObject:tempStr waitUntilDone:YES];
     
     //不传递参数指定函数在当前线程执行
     [self performSelector:@selector(doSomething)];
     //传递参数指定函数在当前线程执行
     [self performSelector: @selector(doSomething:) withObject:tempStr];
     //传递参数指定函数2秒后在当前线程执行
     [self performSelector:@selector(doSomething:) withObject:tempStr afterDelay:2.0];
     
     */
}


-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.frame;
    
}



static int number = 0;
-(void)timeAction
{
    number ++;
    NSLog(@"%d",number);
}

#pragma mark -threadEvent
-(void)oneThreadDoSoming:(NSNumber*)num
{
    [self performSelectorOnMainThread:@selector(doSomethingMain) withObject:nil waitUntilDone:YES];//在其他线程中指定在主线程执行(在子线程中指定在主线程刷新UI)
}

-(void)doSomethingBackground:(NSString*)str
{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}
- (void)doSomethingMain
{
    self.dataSource = @[@"start",@"NSLock同步锁实现同步线程",@"synchronized关键字实现同步线程",@"NSCondition同步锁和线程检查器",@"back",@"数据刷新了"];
    [self.tableView reloadData];
}


-(void)NSLockDoSoming
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
   NSLock *threadLock = [[NSLock alloc]init];//首先创建一个NSLock同步锁对象,然后在需要加锁的代码块开始时调用 lock函数 在结束时调用unLock函数
    while (number>0) {
        [threadLock lock];
        [NSThread sleepForTimeInterval:1];//(此线程休眠是为了更直观的查看顺序)
        NSLog(@"threadName:%@ count:%d ",[NSThread currentThread].name, number);
        [arr addObject:[NSThread currentThread].name];
        if(arr.count/3 >= 3){
            break;
        }
    }
    [threadLock unlock];
}

-(void)synchronizedDoSoming
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    while (number>0) {
        @synchronized(self) { // 需要锁定的代码
            [NSThread sleepForTimeInterval:1];//(此线程休眠是为了更直观的查看顺序)
            NSLog(@"threadName:%@ count:%d ",[NSThread currentThread].name, number);
            [arr addObject:[NSThread currentThread].name];
            if(arr.count/3 >= 3){
                break;
            }
        }
    }
}

-(void)NSConditionDoSoming
{
   /* while (number > 0) {
        [self.condition lock];
        [NSThread sleepForTimeInterval:1];
        NSLog(@"threadName:%@ count:%d ",[NSThread currentThread].name, number);
        [self.condition unlock];
    }
    这个方式与NSLock相似
    */

    while (number>0) {
        [self.condition lock];
        [self.condition wait];
        [NSThread sleepForTimeInterval:1];//(此线程休眠是为了更直观的查看顺序)
        NSLog(@"threadName:%@ count:%d ",[NSThread currentThread].name, number);
        [self.condition unlock];
    }
    
}

-(void)NSConditionDoSomingTest
{
    while (YES) {
        [self.condition lock];
        [NSThread sleepForTimeInterval:3];
        [self.condition signal];
        [self.condition unlock];
    }
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
            [self.oneThread start];//线程开始
        }
            break;
            case 1:
        {
            /*NSLock同步锁 (同步线程)*/
            NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(NSLockDoSoming) object:nil];
            thread1.name=@"NSLock_thread-1";
            
            NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(NSLockDoSoming) object:nil];
            thread2.name=@"NSLock_thread-2";
            
            NSThread *thread3 = [[NSThread alloc]initWithTarget:self selector:@selector(NSLockDoSoming) object:nil];
            thread3.name=@"NSLock_thread-3";
            
            [thread1 start];
            [thread2 start];
            [thread3 start];
        }
            break;
            case 2:
        {
            /*@synchronized(对象)关键字  (同步线程)*/
            NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(synchronizedDoSoming) object:nil];
            thread1.name=@"synchronized_thread-1";
            
            NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(synchronizedDoSoming) object:nil];
            thread2.name=@"synchronized_thread-2";
            
            NSThread *thread3 = [[NSThread alloc]initWithTarget:self selector:@selector(synchronizedDoSoming) object:nil];
            thread3.name=@"synchronized_thread-3";
            
            [thread1 start];
            [thread2 start];
            [thread3 start];
            
        }
            break;
            case 3:
        {
         //NSCondition同步锁和线程检查器(  锁主要为了当检测条件时保护数据源，执行条件引发的任务；线程检查器主要是根据条件决定是否继续运行线程，即线程是否被阻塞。先创建一个NSCondition对象,NSCondition可以让线程进行等待，然后获取到CPU发信号告诉线程不用在等待，可以继续执行，上述的例子我们稍作修改，我们让线程三专门用于发送信号源,执行的结果会发现，只有在Thread-1、和Thread-2 收到信号源的时候才会执行，否则一直出于等待状态。)
            NSThread *thread1=[[NSThread alloc]initWithTarget:self selector:@selector(NSConditionDoSoming) object:nil];
            thread1.name=@"NSCondition_thread-1";
            
            NSThread *thread2=[[NSThread alloc]initWithTarget:self selector:@selector(NSConditionDoSoming) object:nil];
            thread2.name=@"NSCondition_thread-2";
            
            NSThread *thread3=[[NSThread alloc]initWithTarget:self selector:@selector(NSConditionDoSomingTest) object:nil];
            thread3.name=@"NSCondition_thread-3";
            
            [thread1 start];
            [thread2 start];
            [thread3 start];
        }
            break;
            case 4:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}



#pragma mark -getter/setter
/*
 //selector ：线程执行的方法，这个selector只能有一个参数，而且不能有返回值。
 //target  ：selector消息发送的对象
 //argument:传输给target的唯一参数，也可以是nil
 */
-(NSThread *)oneThread
{
    if(_oneThread == nil){
        _oneThread = [[NSThread alloc]initWithTarget:self selector:@selector(oneThreadDoSoming:) object:[NSNumber numberWithInt:number]];
        [_oneThread setName:@"oneThread"];//设置线程名字
        [_oneThread setQualityOfService:NSQualityOfServiceDefault];//设置线程优先级
        //[_oneThread setThreadPriority:0];
        //IOS 8 之后 推荐使用下面这种方式设置线程优先级
        //NSQualityOfServiceUserInteractive：最高优先级，用于用户交互事件
        //NSQualityOfServiceUserInitiated：次高优先级，用于用户需要马上执行的事件
        //NSQualityOfServiceDefault：默认优先级，主线程和没有设置优先级的线程都默认为这个优先级
        //NSQualityOfServiceUtility：普通优先级，用于普通任务
        //NSQualityOfServiceBackground：最低优先级，用于不重要的任务
    }
    return _oneThread;
}

-(NSCondition *)condition
{
    if(_condition == nil){
        _condition = [[NSCondition alloc]init];
    }
    return _condition;
}
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
        _dataSource = @[@"start",@"NSLock同步锁实现同步线程",@"synchronized关键字实现同步线程",@"NSCondition同步锁和线程检查器",@"back"];
    }
    return _dataSource;
}
@end
