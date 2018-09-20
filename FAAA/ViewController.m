//
//  ViewController.m
//  FAAA
//
//  Created by Created by Momo on 2018/8/23.
//  Copyright © 2018年 Momo. All rights reserved.
//

#import "ViewController.h"
#import "FDFS_Upload_API.h"
#import "FDFS_Download_API.h"

#define kAppleUrlToCheckNetStatus @"http://captive.apple.com/"
static const int DOWNLOAD_NUM = 256000;

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
    
    [self download:@"Hell1115.png" file_id:"group1/M00/00/92/wKh-oVujXGqEGhoTAAAAAAAAAAA826.jpg"];
   //[self myUpload:YES file_id:""];
    //[self myUpload:NO file_id:"group1/M00/00/92/wKh-oVujXGqEGhoTAAAAAAAAAAA826.jpg"];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //[self download:@"Hello1.png"];
    [self upload:YES file_id:"group1/M00/00/91/wKh-oVuiCMiEYaHnAAAAAAAAAAA4119880"];
}

// 下载文件
- (void)download:(NSString *)myFile file_id:(char *)uploadFileId
{
    // 配置路径
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    // 设置下载路径
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",myFile]];
    int retn = 0;
    int totalFilesize = 0;
    const char *clientname = [imagePath UTF8String];
    
    // 要下载的文件
    char *file_id = uploadFileId;
    totalFilesize = fdfs_getFileSize_filename([filePath UTF8String],file_id,clientname);
    
    int downfileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        downfileSize = file_size2([filePath UTF8String]);
        NSLog(@"存在 == %d",downfileSize);
    }else{
        NSLog(@"不存在");
    }
    
    int fileSize = 0;
    fileSize = totalFilesize - downfileSize;
    
    if (fileSize / DOWNLOAD_NUM > 1) {
        for (int i = 0; i < fileSize / DOWNLOAD_NUM; i++) {
            int offset = 0;
            int totalFileSize = 0;

            if (i == fileSize / DOWNLOAD_NUM - 1) {
                
                offset = file_size2([filePath UTF8String]);
                totalFileSize = totalFilesize - offset;

            }else{
                offset = downfileSize + i * DOWNLOAD_NUM;
                totalFileSize = DOWNLOAD_NUM;
            }

            retn = fdfs_download_append_by_filename(file_id,clientname,[filePath UTF8String],totalFileSize, offset);
            if(0 != retn)
            {
                printf("download_by_filename err,errno = %d\n",retn);
            }
        }
    }
    else{
        retn = fdfs_download_append_by_filename(file_id, clientname, [filePath UTF8String], fileSize, downfileSize);
        if(0 != retn)
        {
            printf("download_by_filename err,errno = %d\n",retn);
        }
    }
    
//    downfileSize = file_size2([filePath UTF8String]);
//    NSLog(@"存在 == %d",downfileSize);
}

// 上传文件
- (void)upload:(BOOL)isFirst file_id:(char *)uploadFileId
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    //要上传的文件路径
    NSString *imagePath2 = [[NSBundle mainBundle] pathForResource:@"icon_demo" ofType:@"abc"];
    int retn = 0;
    
    const char *filename = [imagePath2 UTF8String];
    const char *clientname = [imagePath UTF8String];
   // char file_id[500] = {0};
    
    char file_id1[500] = {};
    char buff[100];
    
    if (isFirst) {
        fdfs_append_by_filename(filename,file_id1,clientname,buff,0);
    }
    else{
        const char *src = uploadFileId;
        strncpy(file_id1, src, strlen(uploadFileId));
    }
    
    printf("要上传的fileId == %s\n",file_id1);
    
    //char file_id[500] = "group1/M00/00/91/wKh-oVubU2WEdpfwAAAAAMLma8U8573072";
    int fileSize = file_size2(filename);

    int downfileSize = 0;
    //char *file_id = "group1/M00/00/91/wKh-oVubU2WEdpfwAAAAAMLma8U8573072";
    downfileSize = fdfs_getFileSize_filename(filename,file_id1,clientname);
    NSLog(@"已上传 == %d",downfileSize);
    
    int totalFilesize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath2] == YES) {
        totalFilesize = file_size2([imagePath2 UTF8String]);
    }
    fileSize = totalFilesize - downfileSize;
    
    FILE * pFile;
    char *uploadBuff = (char *)malloc(totalFilesize);
    pFile = fopen (filename , "r");
    if (pFile == NULL)
        perror ("Error opening file");
    else {
        if ( fgets (uploadBuff , totalFilesize , pFile) != NULL )
            puts (uploadBuff);
        fclose (pFile);
    }
    
    if (fileSize / DOWNLOAD_NUM > 1) {
        for (int i = 0; i < fileSize / DOWNLOAD_NUM; i++) {
            int offset = 0;
            int totalFileSize = 0;
            
            if (i == fileSize / DOWNLOAD_NUM - 1) {
                
                offset = fdfs_getFileSize_filename(filename,file_id1,clientname);
                totalFileSize = totalFilesize - offset;
                
                char *destBuff = (char *)malloc(totalFileSize);
                strncpy(destBuff, uploadBuff + offset, totalFileSize);
                
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,destBuff,totalFileSize);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                }
                printf("file_id = %s\n",file_id1);
                
            }else{
                char *destBuff = (char *)malloc(DOWNLOAD_NUM);
                strncpy(destBuff, uploadBuff + downfileSize + i * DOWNLOAD_NUM, DOWNLOAD_NUM);
                
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,destBuff,DOWNLOAD_NUM);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                }
                printf("file_id = %s\n",file_id1);
            }
        }
    }
    else{
        
        char *destBuff = (char *)malloc(fileSize);
        strncpy(destBuff, uploadBuff + downfileSize, fileSize);
        
        retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,destBuff,fileSize);
        if(0 != retn)
        {
            printf("upload_by_filename err,errno = %d\n",retn);
        }
        printf("file_id = %s\n",file_id1);
    }
}

- (void)myUpload:(BOOL)isFirst file_id:(char *)uploadFileId
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"conf"];
    //要上传的文件路径
    NSString *imagePath2 = [[NSBundle mainBundle] pathForResource:@"icon_demo" ofType:@"abc"];
    int retn = 0;
    
    const char *filename = [imagePath2 UTF8String];
    const char *clientname = [imagePath UTF8String];
    // char file_id[500] = {0};
    
    char file_id1[500] = {};
    char buff[100];
    
    if (isFirst) {
        fdfs_append_by_filename(filename,file_id1,clientname,buff,0);
    }
    else{
        const char *src = uploadFileId;
        strncpy(file_id1, src, strlen(uploadFileId));
    }
    
    printf("要上传的fileId == %s\n",file_id1);
    
    //char file_id[500] = "group1/M00/00/91/wKh-oVubU2WEdpfwAAAAAMLma8U8573072";
    int fileSize = file_size2(filename);
    
    int downfileSize = 0;
    //char *file_id = "group1/M00/00/91/wKh-oVubU2WEdpfwAAAAAMLma8U8573072";
    downfileSize = fdfs_getFileSize_filename(filename,file_id1,clientname);
    //NSLog(@"已上传 == %d",downfileSize);
    
    int totalFilesize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath2] == YES) {
        
        //NSLog(@"长度 == %d",(int)file_getsize([imagePath2 UTF8String]));
        totalFilesize = file_size2([imagePath2 UTF8String]);
    }
    fileSize = totalFilesize - downfileSize;

    
    FILE * pFile;
    int c;
    int n = 0;
    
    char *uploadBuff = (char *)malloc(totalFilesize);
    pFile = fopen (filename , "r");
    if(pFile == NULL)
    {
        perror("打开文件时发生错误");
    }
    do
    {
        c = fgetc(pFile);
        if( feof(pFile) )
        {
            break ;
        }
        *(uploadBuff + n++) = c;
    }while(1);
    
    fclose(pFile);
    //printf("预测长度 == %d\n",n);
    
    
//    retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff,totalFilesize);
//    if(0 != retn)
//    {
//        printf("upload_by_filename err,errno = %d\n",retn);
//    }
//    printf("file_id = %s\n",file_id1);
    
//    NSString *myPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/document.jpg"]];
//    FILE *p = NULL;
//    p = fopen([myPath UTF8String], "wb");
//    if (p!=NULL) {
//        fwrite(uploadBuff, n, 1, p);
//        fclose(p);
//    }else{
//        printf("写入错误 errno = %d reason = %s \n", errno, strerror(errno));
//    }
    
    if (fileSize / DOWNLOAD_NUM > 1) {
        for (int i = 0; i < fileSize / DOWNLOAD_NUM; i++) {
            int offset = 0;
            int totalFileSize = 0;
            
            if (i == fileSize / DOWNLOAD_NUM - 1) {
                
                offset = fdfs_getFileSize_filename(filename,file_id1,clientname);
                totalFileSize = totalFilesize - offset;

                printf("上传数目2 == %d\n",totalFileSize);
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + offset,totalFileSize);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                }
                printf("file_id = %s\n",file_id1);
                
            }else{
                printf("上传数目1 == %d\n",DOWNLOAD_NUM);
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + downfileSize + i * DOWNLOAD_NUM,DOWNLOAD_NUM);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                }
                printf("file_id = %s\n",file_id1);
            }
        }
    }
    else{
        retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + downfileSize,fileSize);
        if(0 != retn)
        {
            printf("upload_by_filename err,errno = %d\n",retn);
        }
        printf("file_id = %s\n",file_id1);
    }
}

//函数返回fname指定文件的全部内容，如果打不开文件，则返回NULL，并显示打开文件错误
char *getfileall(const char *fname)
{
    FILE *fp;
    char *str;
    char txt[1000];
    int filesize;
    if ((fp=fopen(fname,"r"))==NULL){
        printf("打开文件%s错误\n",fname);
        return NULL;
    }
    
    fseek(fp,0,SEEK_END);
    
    filesize = ftell(fp);
    str=(char *)malloc(filesize);
    str[0]=0;
    
    rewind(fp);
    while((fgets(txt,1000,fp))!=NULL){
        strcat(str,txt);
    }
    fclose(fp);
    return str;
}

long file_getsize(const char * path) {
    FILE * txt;
    long rt;
    
    if ((!path) || !(txt = fopen(path, "rb")))
        return 0;
    
    fseek(txt, 0, SEEK_END);
    rt = ftell(txt);
    
    fclose(txt);
    return rt;
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
