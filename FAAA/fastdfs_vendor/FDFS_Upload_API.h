//
//  FDFS_Upload_API.h
//  Fast_OC_Demo_1
//
//  Created by linxiang on 2018/8/16.
//  Copyright © 2018年 minxing. All rights reserved.
//

#ifndef FDFS_Upload_API_h
#define FDFS_Upload_API_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "fdfs_client.h"
#include "logger.h"


#ifdef __cplusplus
extern "C" {
#endif
    int fdfs_upload_by_filename(const char *filename,char *file_id, const char *clientName);
    int fdfs_getFileSize_filename(const char *filename, char *file_id, const char *clientName);
    int fdfs_append_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize, char *fileType);
    int fdfs_uploadAppend_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize);
    int file_size2(const char* filename);
    
#ifdef __cplusplus
}
#endif


#endif /* FDFS_Upload_API_h */
