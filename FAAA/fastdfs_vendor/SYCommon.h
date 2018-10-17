//
//  SYCommon.h
//  FAAA
//
//  Created by Li JinYou on 2018/9/21.
//  Copyright © 2018年 minxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDFS_Upload_API.h"
#import "FDFS_Download_API.h"

@interface SYCommon : NSObject

+ (void)FDFS_download:(char *)downloadFileId confPath:(NSString *)confPath filePath:(NSString *)filePath fileKey:(NSString *)myfileKey userId:(NSString *)myuserId timestamp:(NSString *)mytimestamp;

+ (void)FDFS_upload:(BOOL)isFirst file_id:(char *)uploadFileId confPath:(NSString *)confPath filePath:(NSString *)filePath fileType:(char *)fileType fileKey:(NSString *)myfileKey userId:(NSString *)myuserId timestamp:(NSString *)mytimestamp;

@end
