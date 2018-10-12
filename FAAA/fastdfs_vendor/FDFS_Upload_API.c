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
#include "storage_client.h"

#define STORAGE_PROTO_CMD_CHECK_TOKEN         38

u_int32_t SendCheckToken( ConnectionInfo *pStorageServer,const char *fileKey,const char *userId,const char *timestamp)
{
    u_int32_t nRet;
    u_int32_t nMasterFileNameLen, nPrefixNameLen;
    byte byOutBuff[512] = {0};
    byte *p;
    
    int appender_filename_len;
    if (pStorageServer == NULL)
    {
        return 0;
    }
    //    char *fileKey;
    //    char *userId;
    //    char *timestamp;
    
    int key_len = 200, userid_len = 64, timestamp_len = 16;
    int body_len = key_len + userid_len + timestamp_len;
    
    TrackerHeader *pHeader = (TrackerHeader*)byOutBuff;
    p = byOutBuff + sizeof(TrackerHeader);
    
    memcpy(p, fileKey, strlen(fileKey));
    p += key_len;
    
    memcpy(p, userId, strlen(userId));
    p += userid_len;
    
    memcpy(p, timestamp, strlen(timestamp));
    p += timestamp_len;
    
    long2buff(body_len,pHeader->pkg_len);
    pHeader->cmd = STORAGE_PROTO_CMD_CHECK_TOKEN;
    pHeader->status = 0;
    
    
    
    int result;
    if ((result=tcpsenddata_nb(pStorageServer->sock, byOutBuff, p - byOutBuff, g_fdfs_network_timeout)) != 0)
    {
        logError("file: "__FILE__", line: %d, " \
                 "send data to storage server %s:%d fail, " \
                 "errno: %d, error info: %s", __LINE__, \
                 pStorageServer->ip_addr, pStorageServer->port, \
                 result, STRERROR(result));
    }
    
    TrackerHeader resp;
    int nCount = 0;
    
    if ((nRet = tcprecvdata_nb_ex(pStorageServer->sock, &resp, sizeof(resp), DEFAULT_NETWORK_TIMEOUT, &nCount)) != 0)
    {
        printf("失败1");
        return 0;
    }
    
    if (resp.status != 0)
    {
        printf("失败2");
        return 0;
    }
    
    return 1;
}

int fdfs_upload_by_filename(const char *filename, char *file_id, const char *clientName)
{
    const char *local_filename;
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    
    log_init();
    g_log_context.log_level = LOG_ERR;
    
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
    
    local_filename = filename;
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
    
    //    char file_buff[500] = {0};
    //    result = storage_upload_appender_by_filebuff1(pTrackerServer, &storageServer, store_path_index, file_buff, 0, NULL, NULL, 0, group_name, file_id);
    
    
    result = storage_upload_appender_by_filename1(pTrackerServer, \
                                                  
                                                  &storageServer, store_path_index, \
                                                  local_filename, NULL, \
                                                  NULL, 0, group_name, file_id);
    if (result == 0)
    {
        printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "upload file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
    tracker_disconnect_server_ex(pTrackerServer, true);
    fdfs_client_destroy();
    
    return result;
}

int fdfs_uploadAppend_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize,const char *fileKey,const char *userId,const char *timestamp)
{
    const char *local_filename;
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    
    log_init();
    g_log_context.log_level = LOG_ERR;
    
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
    
    local_filename = filename;
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
    
    ConnectionInfo mystorageServer;
    bool new_connection;
    ConnectionInfo *pStorageServer = &storageServer;
    storage_get_connection(pTrackerServer, &pStorageServer, TRACKER_PROTO_CMD_SERVICE_QUERY_UPDATE, group_name, filename, &mystorageServer, &new_connection);
    int checkResult = SendCheckToken(&storageServer, fileKey, userId, timestamp);

    if (checkResult != 1) {
        printf("上传错误==2\n");
        return 0;
    }
    
    printf("id == %s\n", file_id);
    result = storage_append_by_filebuff1(pTrackerServer, &storageServer, fileBuff, fileSize, file_id);

    if (result == 0)
    {
        printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "upload file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
    tracker_disconnect_server_ex(pTrackerServer, true);
    fdfs_client_destroy();
    
    return result;
}


// 断点续传
int fdfs_append_by_filename(const char *filename, char *file_id, const char *clientName,char *fileBuff,int fileSize, char *fileType, const char *fileKey,const char *userId,const char *timestamp,ConnectionInfo *pstorageServer)
{
    const char *local_filename;
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    log_init();
    g_log_context.log_level = LOG_ERR;
    
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
    
    local_filename = filename;
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
    
    ConnectionInfo mystorageServer;
    bool new_connection;
    ConnectionInfo *pStorageServer = &storageServer;
    storage_get_connection(pTrackerServer, &pStorageServer, TRACKER_PROTO_CMD_SERVICE_QUERY_UPDATE, group_name, filename, &mystorageServer, &new_connection);
    int checkResult = SendCheckToken(&storageServer, fileKey, userId, timestamp);
    
    if (checkResult != 1) {
        printf("check token错误\n");
        return 0;
    }
    
    pstorageServer = &storageServer;
    //上传文件,得到file_id
    result = storage_upload_appender_by_filebuff1(pTrackerServer, &storageServer, store_path_index, fileBuff, fileSize, fileType, NULL, 0, group_name, file_id);

    if (result == 0)
    {
        printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "upload file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
//    tracker_disconnect_server_ex(pTrackerServer, true);
//    fdfs_client_destroy();
    
    return result;
}


int fdfs_getFileSize_filename(const char *filename, char *file_id, const char *clientName,const char *fileKey,const char *userId,const char *timestamp)
{
    char *conf_filename;
    int result;
    FDFSFileInfo file_info;
    
    conf_filename = clientName;
    if ((result=fdfs_client_init(conf_filename)) != 0)
    {
        return result;
    }
    
    memset(&file_info, 0, sizeof(file_info));
    result = fdfs_get_file_info_ex1(file_id, true, &file_info,filename,fileKey,userId,timestamp);
    if (result != 0)
    {
        printf("query file info fail, " \
               "error no: %d, error info: %s\n", \
               result, STRERROR(result));
    }
    else
    {
        char szDatetime[32];
        
        printf("source storage id: %d\n", file_info.source_id);
        printf("source ip address: %s\n", file_info.source_ip_addr);
        printf("file create timestamp: %s\n", formatDatetime(
                                                             file_info.create_timestamp, "%Y-%m-%d %H:%M:%S", \
                                                             szDatetime, sizeof(szDatetime)));
        printf("file size: %ld\n", \
               file_info.file_size);
        printf("file crc32: %u (0x%08X)\n", \
               file_info.crc32, file_info.crc32);
    }
    
    tracker_close_all_connections();
    fdfs_client_destroy();
    
    printf("服务器文件大小 == %d",file_info.file_size);
    return file_info.file_size;
}

int file_size2(const char* filename)
{
    struct stat statbuf;
    stat(filename,&statbuf);
    long size = (int)statbuf.st_size;
    return (int)size;
}

int fdfs_upload_by_filename2(const char *filename, char *file_id, const char *clientName, const char *fileKey,const char *userId,const char *timestamp)
{
    const char *local_filename;
    char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
    ConnectionInfo *pTrackerServer;
    int result;
    int store_path_index;
    ConnectionInfo storageServer;
    
    
    log_init();
    g_log_context.log_level = LOG_ERR;
    
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
    
    local_filename = filename;
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
    
    ConnectionInfo mystorageServer;
    bool new_connection;
    ConnectionInfo *pStorageServer = &storageServer;
    storage_get_connection(pTrackerServer, &pStorageServer, TRACKER_PROTO_CMD_SERVICE_QUERY_UPDATE, group_name, filename, &mystorageServer, &new_connection);
    SendCheckToken(&storageServer, fileKey, userId, timestamp);
    
//    result = storage_upload_appender_by_filename1(pTrackerServer, \
//
//                                                  &storageServer, store_path_index, \
//                                                  local_filename, NULL, \
//                                                  NULL, 0, group_name, file_id);
    
    result = storage_upload_by_filename_ex(pTrackerServer, &storageServer, store_path_index, STORAGE_PROTO_CMD_UPLOAD_APPENDER_FILE, local_filename, NULL, NULL, 0, group_name, file_id);
    
    if (result == 0)
    {
        printf("%s\n", file_id);
    }
    else
    {
        fprintf(stderr, "upload file fail, " \
                "error no: %d, error info: %s\n", \
                result, STRERROR(result));
    }
    
    tracker_disconnect_server_ex(pTrackerServer, true);
    fdfs_client_destroy();
    
    return result;
}

