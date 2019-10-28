//
//  Downloader.m
//  DownloadFile
//
//  Created by lfc on 2019/10/21.
//  Copyright © 2019 lfc. All rights reserved.
//


//断点续传思路
/**
 1、判断是否存在文件，如果文件不存在 从0开始下载
 2、如果文件u存在
    判断文件大小 == 服务器文件大小  不需要下载 返回-1
    判断文件大小 <  服务器文件大小  从当前位置开始下载 返回fileSize
    判断文件大小 >  服务器文件大小  删除文件 从0开始下载  删除文件 返回0
 */

#import "Downloader.h"

@interface Downloader () <NSURLConnectionDataDelegate>
//文件总大小
@property (nonatomic,assign) long long exepectedContentLength;
//文件已下载大小
@property (nonatomic,assign) long long receivedContentLength;

//
@property (nonatomic,strong) NSOutputStream * outputstream;

//要保存文件的路径
@property (nonatomic,copy) NSString * filePath;

//
@property (nonatomic,strong) NSURLConnection * conn;

//回调的block
@property (nonatomic,copy) void (^successBlock)(NSString *path);

@property (nonatomic,copy) void (^processBlock)(float process);

@property (nonatomic,copy) void (^errorBlock)(NSError *error);



@end

@implementation Downloader


//暂停下载
- (void)pause
{
    [self.conn cancel];
}

//开始下载
- (void)download:(NSString *)urlString andSuccessBlock:(void(^)(NSString *path))successBlock andProcessBlock:(void(^)(float process))processBlock andErrorBlock:(void(^)(NSError *error))errorBlock
{
    self.successBlock = successBlock;
    self.processBlock = processBlock;
    self.errorBlock = errorBlock;
    
    NSURL *url = [NSURL URLWithString:urlString];
   // NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //下载之前，获取服务器文件的大小和名称  在主线程执行
    [self getServerInfo:url];
    
    
    //获取并判断本地文件大小
    self.receivedContentLength = [self checkLocalFileInfo];
    
    //判断是否要下载
    if(self.receivedContentLength == -1)
    {
        NSLog(@"已下载完成，最好不要重复下载");
        
        //block
           if(self.successBlock)
           {
               //回到主线程
               dispatch_async(dispatch_get_main_queue(), ^{
                   self.successBlock(self.filePath);
               });
               
           }
        
        return;
    }
    
    NSLog(@"%lld---%lld",self.receivedContentLength,self.exepectedContentLength);
   
    //从指定位置处下载文件
    [self downloadFile:url];
    
}

- (void)downloadFile:(NSURL *)url
{
    //子线程中下载
    [[NSOperationQueue new] addOperationWithBlock:^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-",self.receivedContentLength] forHTTPHeaderField:@"Range"];
        
        //下载过程是在当前线程的消息循环中下载的
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        self.conn = conn;
        
        [[NSRunLoop currentRunLoop] run];
        
    }];
    
    
}

//获取服务器文件大小和名称  get请求 可以下载文件
- (void) getServerInfo:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"head";
    
    
    NSURLResponse *response = nil;
    //同步请求
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    self.exepectedContentLength = response.expectedContentLength;
    
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    
}

//获取本地文件大小并和服务器文件大小比较
- (long long)checkLocalFileInfo
{
    long long fileSize = 0;
    //判断文件是否存在 返回0
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:self.filePath])
    {
        //本地文件存在，比较服务器文件大小
        //本地文件大小
      NSDictionary *attrs =  [fileManager attributesOfItemAtPath:self.filePath error:NULL];
        fileSize = attrs.fileSize;
        
        
        if(fileSize ==self.exepectedContentLength)
        {
            fileSize = -1;
        }
        if(fileSize >self.exepectedContentLength)
        {
            //删除文件
            [fileManager removeItemAtPath:self.filePath error:NULL];
        }
    }
    return fileSize;
}

//代理方法
//接收到响应头
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //文件总大小
   // self.exepectedContentLength = response.expectedContentLength;
    
    //文件存放路径
    self.outputstream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    //打开流
    [self.outputstream open];
}

//一点点接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    //当前下载大小
    self.receivedContentLength += data.length;
    
    //下载进度
    float process = self.receivedContentLength * 1.0 /self.exepectedContentLength;
  //  NSLog(@"%.2f%%===%@",process * 100,[NSThread currentThread]);
    
    
    //写数据   data.length
    [self.outputstream write:data.bytes maxLength:data.length];
    
    //block
    if(self.processBlock)
    {
        self.processBlock(process);
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"下载完成");
    
    //关闭流
    [self.outputstream close];
    
    //block
    if(self.successBlock)
    {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            self.successBlock(self.filePath);
        });
        
    }
}

//错误处理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   // NSLog(@"下载出错 %@",error);
    
    //block
      if(self.errorBlock)
      {
          self.errorBlock(error);
      }
}

@end
