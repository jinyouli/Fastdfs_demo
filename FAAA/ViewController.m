//
//  ViewController.m
//  FAAA
//
//  Created by Created by Momo on 2018/8/23.
//  Copyright © 2018年 Momo. All rights reserved.
//

#import "ViewController.h"
#import "SYCommon.h"

#define kAppleUrlToCheckNetStatus @"http://captive.apple.com/"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 检测网络
    if (![self checkNetCanUse]) {
        NSLog(@"网络错误");
    }
}

- (void)downLoad
{
    // 配置文件路径
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    // 设置下载路径
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",@"Hell1115.png"]];
    [SYCommon FDFS_download:"group1/M00/00/92/wKh-oVujXGqEGhoTAAAAAAAAAAA826.jpg" confPath:confPath filePath:filePath];
}

- (void)upLoad
{
    // 配置文件路径
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    //要上传的文件路径
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"icon_demo" ofType:@"abc"];
    [SYCommon FDFS_upload:NO file_id:"group1/M00/00/92/wKh-oVujXGqEGhoTAAAAAAAAAAA826.jpg" confPath:confPath filePath:imgPath];
    [SYCommon FDFS_upload:YES file_id:"" confPath:confPath filePath:imgPath];
}

// 检测网络
- (BOOL)checkNetCanUse {
    
    __block BOOL canUse = NO;
    
    NSString *urlString = kAppleUrlToCheckNetStatus;
    
    // 使用信号量实现NSURLSession同步请求**
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"error == %@",error);
        
        NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //解析html页面
        NSString *htmlString = [self filterHTML:result];
        //除掉换行符
        NSString *resultString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([resultString isEqualToString:@"SuccessSuccess"]) {
            canUse = YES;
            NSLog(@"手机所连接的网络是可以访问互联网的: %d",canUse);
            
        }else {
            canUse = NO;
            NSLog(@"手机无法访问互联网: %d",canUse);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return canUse;
}

- (NSString *)filterHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
