//
//  FDFS_Upload_API.h
//  Fast_OC_Demo_1
//
//  Created by linxiang on 2018/8/16.
//  Copyright © 2018年 minxing. All rights reserved.
//

#ifndef FDFS_Download_API_h
#define FDFS_Download_API_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "fdfs_client.h"
#include "logger.h"
#include "FDFS_Upload_API.h"

#ifdef __cplusplus
extern "C" {
#endif
    int fdfs_download_by_filename(char *file_id, const char *clientName,const char *filepath);
    int fdfs_download_append_by_filename(char *file_id, const char *clientName,const char *filepath,int buff, int offset, const char *fileKey,const char *userId,const char *timestamp);
#ifdef __cplusplus
}
#endif


#endif /* FDFS_Download_API_h */
