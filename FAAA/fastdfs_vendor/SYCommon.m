//
//  SYCommon.m
//  FAAA
//
//  Created by Li JinYou on 2018/9/21.
//  Copyright © 2018年 minxing. All rights reserved.
//

#import "SYCommon.h"

static const int DOWNLOAD_NUM = 256000;

@implementation SYCommon

// 下载文件
+ (void)FDFS_download:(char *)downloadFileId confPath:(NSString *)confPath filePath:(NSString *)filePath fileKey:(NSString *)myfileKey userId:(NSString *)myuserId timestamp:(NSString *)mytimestamp
{
    int retn = 0;
    int totalFilesize = 0;
    const char *clientname = [confPath UTF8String];
    
    const char *fileKey = [myfileKey UTF8String];
    const char *userId = [myuserId UTF8String];
    const char *timestamp = [mytimestamp UTF8String];
    
    // 要下载的文件
    char *file_id = downloadFileId;
    //totalFilesize = fdfs_getFileSize_filename([filePath UTF8String],file_id,clientname);
    totalFilesize = 0;
    
    int downfileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        downfileSize = file_size2([filePath UTF8String]);
        //NSLog(@"存在 == %d",downfileSize);
    }else{
        //NSLog(@"不存在");
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
            
            retn = fdfs_download_append_by_filename(file_id, clientname, [filePath UTF8String], totalFileSize, offset, fileKey, userId, timestamp);
            if(0 != retn)
            {
                printf("download_by_filename err,errno = %d\n",retn);
            }
            else{
                if (i == fileSize / DOWNLOAD_NUM - 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFinish" object:nil];
                }
            }
        }
    }
    else{
        retn = fdfs_download_append_by_filename(file_id, clientname, [filePath UTF8String], fileSize, downfileSize, fileKey, userId, timestamp);
        if(0 != retn)
        {
            printf("download_by_filename err,errno = %d\n",retn);
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFinish" object:nil];
        }
    }
    
    //    downfileSize = file_size2([filePath UTF8String]);
    //    NSLog(@"存在 == %d",downfileSize);
}

+ (void)FDFS_upload:(BOOL)isFirst file_id:(char *)uploadFileId confPath:(NSString *)confPath filePath:(NSString *)filePath fileType:(char *)fileType fileKey:(NSString *)myfileKey userId:(NSString *)myuserId timestamp:(NSString *)mytimestamp
{
    int retn = 0;
    
    const char *filename = [filePath UTF8String];
    const char *clientname = [confPath UTF8String];
    // char file_id[500] = {0};
    const char *fileKey = [myfileKey UTF8String];
    const char *userId = [myuserId UTF8String];
    const char *timestamp = [mytimestamp UTF8String];
    
    char file_id1[500] = {};
    char buff[100];
    
    ConnectionInfo pstorageServer;
    if (isFirst) {
        fdfs_append_by_filename(filename,file_id1,clientname,buff,0,fileType,fileKey,userId,timestamp,&pstorageServer);
    }
    else{
        const char *src = uploadFileId;
        strncpy(file_id1, src, strlen(uploadFileId));
    }
    printf("要上传的fileId == %s\n",file_id1);

    int fileSize = file_size2(filename);
    int downfileSize = 0;
    downfileSize = fdfs_getFileSize_filename(filename,file_id1,clientname,fileKey,userId,timestamp);
    
    printf("本地文件大小 == %d\n",fileSize);
    int totalFilesize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        totalFilesize = file_size2([filePath UTF8String]);
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
    
    if (fileSize / DOWNLOAD_NUM > 1) {
        for (int i = 0; i < fileSize / DOWNLOAD_NUM; i++) {
            int offset = 0;
            int totalFileSize = 0;
            
            if (i == fileSize / DOWNLOAD_NUM - 1) {
                
                offset = fdfs_getFileSize_filename(filename,file_id1,clientname,fileKey,userId,timestamp);
                
                
                totalFileSize = totalFilesize - offset;
                
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + offset,totalFileSize,fileKey,userId,timestamp);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                }else{
                    NSString *string_content = [[NSString alloc] initWithCString:file_id1 encoding:NSASCIIStringEncoding];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadFinish" object:string_content];
                }
                
            }else{
                retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + downfileSize + i * DOWNLOAD_NUM,DOWNLOAD_NUM,fileKey,userId,timestamp);
                if(0 != retn)
                {
                    printf("upload_by_filename err,errno = %d\n",retn);
                    
                }
                printf("file_id = %s\n",file_id1);
            }
        }
    }
    else{
        retn = fdfs_uploadAppend_by_filename(filename,file_id1,clientname,uploadBuff + downfileSize,fileSize,fileKey,userId,timestamp);
        if(0 != retn)
        {
            printf("upload_by_filename err,errno = %d\n",retn);
        }
        else{
            NSString *string_content = [[NSString alloc] initWithCString:file_id1 encoding:NSASCIIStringEncoding];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadFinish" object:string_content];
        }
        printf("file_id = %s\n",file_id1);
    }
    
    
}


@end
