//
//  OSSBaseInfoModel.h
//  OSSDemo
//
//  Created by Evan on 2016/11/29.
//  Copyright © 2016年 vanke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSTokenModel : NSObject

@property (nonatomic, copy) NSString *OSSBucketName;
@property (nonatomic, copy) NSString *OSSBucketURL;
@property (nonatomic, copy) NSString *bucketUrl;
@property (nonatomic, copy) NSString *accessKeyId;
@property (nonatomic, copy) NSString *accessKeySecret;
@property (nonatomic, copy) NSString *expiration;
@property (nonatomic, copy) NSString *securityToken;

+ (void)persistenceOSSToken:(OSSTokenModel *)tokenModel;

+ (BOOL)isExist;
@end
