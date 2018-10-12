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
#include "storage_client.h"

#ifdef __cplusplus
extern "C" {
#endif
    int fdfs_upload_by_filename(const char *filename,char *file_id, const char *clientName);
    int fdfs_getFileSize_filename(const char *filename, char *file_id, const char *clientName,const char *fileKey,const char *userId,const char *timestamp);
    int fdfs_append_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize, char *fileType, const char *fileKey,const char *userId,const char *timestamp,ConnectionInfo *pstorageServer);
    int fdfs_uploadAppend_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize,const char *fileKey,const char *userId,const char *timestamp);
    int file_size2(const char* filename);
    int fdfs_upload_by_filename2(const char *filename, char *file_id, const char *clientName, const char *fileKey,const char *userId,const char *timestamp);
    u_int32_t SendCheckToken( ConnectionInfo *pStorageServer,const char *fileKey,const char *userId,const char *timestamp);
    
#ifdef __cplusplus
}
#endif


#endif /* FDFS_Upload_API_h */
