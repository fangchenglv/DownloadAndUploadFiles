//
//  UploadFile.m
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import "UploadFile.h"
#define kBOUNDARY @"abc"
@implementation UploadFile

//上传单个文件
+ (void) uploadFile:(NSString *)urlString andFieldName:(NSString *)fieldName andFieldPath:(NSString *)fieldPath
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置post
    request.HTTPMethod = @"POST";
    //设置请求头
    //Content-Type: multipart/form-data; boundary=----WebKitFormBoundarybk9buOJnGRqbucOp
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBOUNDARY] forHTTPHeaderField:@"Content-Type"];
    //设置请求体
    request.HTTPBody = [self makeBody:fieldName andFieldPath:fieldPath];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError)
        {
            NSLog(@"连接错误 %@",connectionError);
            return ;
        }
        
        //
        NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200 || httpResponse.statusCode ==304 )
        {
            //解析数据
            id josn = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"%@",josn);
        }
        else
        {
            NSLog(@"服务器内部错误");
        }
    }];
}

//请求体 body

+ (NSData *)makeBody:(NSString *)fieldName andFieldPath:(NSString *)fieldPath
{
    //
    NSMutableData *mData = [NSMutableData data];
    NSMutableString *mString = [NSMutableString string];
    [mString appendFormat:@"--%@\r\n",kBOUNDARY];
    [mString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,[fieldPath lastPathComponent]];
    
    [mString appendString:@"Content-Type: application/octet-stream\r\n"];
    [mString appendString:@"\r\n"];
    
    [mData appendData:[mString dataUsingEncoding:NSUTF8StringEncoding]];
    //加载要上传的文件
   // NSString *path = [[NSBundle mainBundle] pathForResource:@"02.jpg" ofType:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:fieldPath];
    [mData appendData:data];
    //
    NSString *end = [NSString stringWithFormat:@"\r\n--%@--",kBOUNDARY];
    [mData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    return mData.copy;
}


@end
