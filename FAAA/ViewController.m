//
//  ViewController.m
//  FAAA
//
//  Created by Created by Momo on 2018/8/23.
//  Copyright © 2018年 Momo. All rights reserved.
//

#import "ViewController.h"
#import "SYCommon.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kAppleUrlToCheckNetStatus @"http://captive.apple.com/"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic, copy) NSString *filePath;
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 检测网络
    if (![self checkNetCanUse]) {
        NSLog(@"网络错误");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish) name:@"downloadFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:@"uploadFinish" object:nil];
    [self request];
}

- (void)request
{
    NSString *urlStr = @"http://192.168.0.1:6001/gateway/user/login";
    //如果字符串里面含有中文要进行转码
    //urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //2.设置请求路径
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //3.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; // 默认就是GET请求
    request.timeoutInterval = 5; // 设置请求超时
    request.HTTPMethod = @"POST"; // 设置为POST请求
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //4.设置请求体
    NSString *param = [NSString stringWithFormat:@"\{\"username\"\:\"admin\"\,\"password\"\:\"654321\"\}"];
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    
    //5.发送请求
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {  // 当请求结束的时候调用
        
        NSDictionary *dict = [self dictionaryWithJsonString:[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
        
        char file_id[500] = {};
        NSDictionary *dataDict = dict[@"data"];
        //NSLog(@"返回数据 == %@",dataDict);
        
        //fdfs_upload_by_filename2(filename, file_id, clientname, fileKey, userId, timestamp);
        
        [self upLoad:[NSString stringWithFormat:@"%@",dataDict[@"fileKey"]] userId:[NSString stringWithFormat:@"%@",dataDict[@"userId"]] timestamp:[NSString stringWithFormat:@"%@",dataDict[@"expired"]]];
    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)downloadFinish
{
    NSLog(@"下载完成");
    self.image.image = [UIImage imageWithContentsOfFile:self.filePath];
    [self showAlert:@"下载完成"];
}

- (void)uploadFinish:(NSNotification *)notif
{
    NSLog(@"消息 == %@",notif.object);
    self.textfield.text = notif.object;
    [self showAlert:@"上传完成"];
}

- (IBAction)downloadFile:(UIButton *)sender {
    
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    // 设置下载路径
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",@"Hello2.png"]];
    self.filePath = filePath;
    NSFileManager *defauleManager = [NSFileManager defaultManager];
    
    BOOL isDir;
    if ([defauleManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [defauleManager removeItemAtPath:filePath error:nil];
    }
    
    if (self.textfield.text.length > 0) {
        [SYCommon FDFS_download:[self.textfield.text UTF8String] confPath:confPath filePath:filePath];
    }
    else{
        [self showAlert:@"请输入文件id"];
    }
}

- (void)showAlert:(NSString *)meg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:meg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)uploadFile:(UIButton *)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        //设置当前控制器为picker对象的代理
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// 获取图片后操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"图片2 == %@",info);
    
    //从info取出此时摄像头的媒体类型
   // NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
//    int downfileSize = file_size2([[info[@"UIImagePickerControllerImageURL"] absoluteString] UTF8String]);
//    NSLog(@"图片 == %d",downfileSize);
    
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *data1;
    if (UIImagePNGRepresentation(image) == nil) {
        data1 = UIImageJPEGRepresentation(image, 1);
    } else {
        data1 = UIImagePNGRepresentation(image);
    }
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //文件管理器
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
//    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
//    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image"] contents:data1 attributes:nil];
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath, @"/image"];
    self.filePath = filePath;
    self.image.image = image;
    
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    // 配置文件路径
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    //[SYCommon FDFS_upload:YES file_id:"" confPath:confPath filePath:self.filePath fileType:"jpg"];

    int size = file_size2([filePath UTF8String]);
    NSLog(@"测试文件大小 == %d",size);
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)downLoad
{
    // 配置文件路径
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    // 设置下载路径
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",@"Hello.png"]];
    [SYCommon FDFS_download:"group1/M00/00/92/wKh-oVukrWqERu0jAAAAAAAAAAA931.jpg" confPath:confPath filePath:filePath];
}

- (void)upLoad:(NSString *)myfileKey userId:(NSString *)myuserId timestamp:(NSString *)mytimestamp
{
    // 配置文件路径
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    //要上传的文件路径
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"icon_demo" ofType:@"jpg"];
    //[SYCommon FDFS_upload:NO file_id:"group1/M00/00/92/wKh-oVujXGqEGhoTAAAAAAAAAAA826.jpg" confPath:confPath filePath:imgPath fileType:"jpg"];
    
    const char *filename = [imgPath UTF8String];
    const char *clientname = [confPath UTF8String];
    const char *fileKey = [myfileKey UTF8String];
    const char *userId = [myuserId UTF8String];
    const char *timestamp = [mytimestamp UTF8String];

    int downfileSize = 0;
    char file_id1[500] = {};
    downfileSize = fdfs_getFileSize_filename(filename,"group1/M00/00/02/wKh-g1vAa-GEEJyyAAAAAAAAAAA905.jpg",clientname,fileKey,userId,timestamp);

    printf("服务文件大小 == %d\n",downfileSize);
    
   // [SYCommon FDFS_upload:YES file_id:"" confPath:confPath filePath:imgPath fileType:"jpg" fileKey:myfileKey userId:myuserId timestamp:mytimestamp];
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
