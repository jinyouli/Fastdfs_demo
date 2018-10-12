//
//  FDFS_Upload_API.c
//  Fast_OC_Demo_1
//
//  Created by linxiang on 2018/8/16.
//  Copyright © 2018年 minxing. All rights reserved.
//

#include "FDFS_Upload_API.h"
#include "fdfs_global.h"
#include "sockopt.h"

int fdfs_download_by_filename(char *file_id, const char *clientName,const char *filepath,const char *fileKey,const char *userId,const char *timestamp)
{
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    //加载配置文件
    if ( (result=fdfs_client_init(clientName)) != 0 )
    {
        return result;
    }
    
    //获取tracker句柄
    pTrackerServer = tracker_get_connection();
    if (pTrackerServer == NULL)
    {
        fdfs_client_destroy();
        return errno != 0 ? errno : ECONNREFUSED;
    }
    
    *group_name = '\0';
    //获取storage句柄
    if ((result=tracker_query_storage_store(pTrackerServer, \
                                            &storageServer, group_name, &store_path_index)) != 0)
    {
        fdfs_client_destroy();
        fprintf(stderr, "tracker_query_storage fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
        return result;
    }
    
    char *file_buff;
    int64_t file_size;
    // 下载文件
    result = storage_download_file1(pTrackerServer, &storageServer, file_id, &file_buff, &file_size);
    
    printf("文件大小 == %lld \n",file_size);
    FILE *p = NULL;
    p = fopen(filepath, "w");
    if (p!=NULL) {
        fwrite(file_buff, (int)file_size, 1, p);
        fclose(p);
    }else{
        printf("写入错误");
    }
    
    if (result == 0)
    {
        printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "download file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
    tracker_disconnect_server_ex(pTrackerServer, true);
    fdfs_client_destroy();

    return result;
}


int fdfs_download_append_by_filename(char *file_id, const char *clientName,const char *filepath,int buff, int offset)
{
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    //加载配置文件
    if ( (result=fdfs_client_init(clientName)) != 0 )
    {
        return result;
    }
    
    //获取tracker句柄
    pTrackerServer = tracker_get_connection();
    if (pTrackerServer == NULL)
    {
        fdfs_client_destroy();
        return errno != 0 ? errno : ECONNREFUSED;
    }
    
    *group_name = '\0';
    
    //获取storage句柄
    if ((result=tracker_query_storage_store(pTrackerServer, \
                                            &storageServer, group_name, &store_path_index)) != 0)
    {
        fdfs_client_destroy();
        fprintf(stderr, "tracker_query_storage fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
        return result;
    }
    
    char *file_buff;
    int64_t file_size;
    // 下载文件
    //result = storage_download_file1(pTrackerServer, &storageServer, file_id, &file_buff, &file_size);
    
//    int retn = 0;
//    retn = fdfs_getFileSize_filename(filepath,file_id,clientName);
//    printf("服务器大小 == %d \n",retn);
    
    const int64_t total_buff = buff;
    const int64_t file_offset = offset;
    
    result = storage_do_download_file1_ex(pTrackerServer, &storageServer, FDFS_DOWNLOAD_TO_BUFF, file_id, file_offset, total_buff, &file_buff, NULL, &file_size);
    
    FILE *p = NULL;
    p = fopen(filepath, "ab+");
    if (p!=NULL) {
       // printf("写入成功 == %s\n",filepath);
        fwrite(file_buff, (int)file_size, 1, p);
        fclose(p);
    }else{
        printf("写入错误");
    }
    
    if (result == 0)
    {
       // printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "download file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
    tracker_disconnect_server_ex(pTrackerServer, true);
    fdfs_client_destroy();

    return result;
}




