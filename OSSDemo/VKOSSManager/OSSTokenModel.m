//
//  OSSBaseInfoModel.m
//  OSSDemo
//
//  Created by Evan on 2016/11/29.
//  Copyright © 2016年 vanke. All rights reserved.
//

#import "OSSTokenModel.h"

#define kOSSBucketName @"kOSSBucketNameKey"
#define kOSSBucketURL @"kOSSBucketURLKey"
#define kBucketUrl @"kBucketUrlKey"
#define kAccessKeyId @"kAccessKeyIdKey"
#define kAccessKeySecret @"kAccessKeySecretKey"
#define kExpiration @"kExpirationKey"
#define kSecurityToken @"kSecurityTokenKey"

@implementation OSSTokenModel


- (void)setOSSBucketName:(NSString *)OSSBucketName {
    
    [[NSUserDefaults standardUserDefaults] setObject:OSSBucketName forKey:kOSSBucketName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOSSBucketURL:(NSString *)OSSBucketURL {
    [[NSUserDefaults standardUserDefaults] setObject:OSSBucketURL forKey:kOSSBucketURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBucketUrl:(NSString *)bucketUrl {
    [[NSUserDefaults standardUserDefaults] setObject:bucketUrl forKey:kBucketUrl];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAccessKeyId:(NSString *)accessKeyId {
    [[NSUserDefaults standardUserDefaults] setObject:accessKeyId forKey:kAccessKeyId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAccessKeySecret:(NSString *)accessKeySecret {
    [[NSUserDefaults standardUserDefaults] setObject:accessKeySecret forKey:kAccessKeySecret];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExpiration:(NSString *)expiration {
    [[NSUserDefaults standardUserDefaults] setObject:expiration forKey:kExpiration];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSecurityToken:(NSString *)securityToken {
    [[NSUserDefaults standardUserDefaults] setObject:securityToken forKey:kSecurityToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)OSSBucketName {
    NSString *OSSBucketStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kOSSBucketName];
    return OSSBucketStr;
}

- (NSString *)OSSBucketURL {
    NSString *OSSBucketURLStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kOSSBucketURL];
    return OSSBucketURLStr;
}

- (NSString *)bucketUrl {
    NSString *bucketUrlStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kBucketUrl];
    return bucketUrlStr;
}

- (NSString *)accessKeyId {
    NSString *accessKeyIdStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kAccessKeyId];
    return accessKeyIdStr;
}

- (NSString *)accessKeySecret {
    NSString *accessKeySecretStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kAccessKeySecret];
    return accessKeySecretStr;
}

- (NSString *)expiration {
    NSString *expirationStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kExpiration];
    return expirationStr;
}

- (NSString *)securityToken {
    NSString *securityTokenStr =  [[NSUserDefaults standardUserDefaults] objectForKey:kSecurityToken];
    return securityTokenStr;
}

+ (void)persistenceOSSToken:(OSSTokenModel *)tokenModel {
    OSSTokenModel *token = tokenModel;
    token.OSSBucketName = tokenModel.OSSBucketName;
    token.OSSBucketURL = tokenModel.OSSBucketURL;
    token.bucketUrl = tokenModel.bucketUrl;
    token.accessKeyId = tokenModel.accessKeyId;
    token.accessKeySecret = tokenModel.accessKeySecret;
    token.expiration = tokenModel.expiration;
    token.securityToken = tokenModel.securityToken;
}
+ (BOOL)isExist {
    OSSTokenModel *tokenModel =  [[OSSTokenModel alloc] init];
    if(tokenModel.accessKeyId || tokenModel.securityToken){
        return YES;
    }else{
        return NO;
    }
}

@end
