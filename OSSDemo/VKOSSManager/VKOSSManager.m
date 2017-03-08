//
//  OSSManager.m
//  OSSDemo
//
//  Created by Evan on 2016/11/29.
//  Copyright © 2016年 vanke. All rights reserved.
//

#import "VKOSSManager.h"
/***************仅用来做为测试使用************************/
#define kOSSBucketName      @"vankesalesbucket"
#define kOSSBucketURL       @"http://oss-cn-shenzhen.aliyuncs.com"
#define kBucketUrl          @"oss-cn-shenzhen.aliyuncs.com"
#define kAccessKeyId        @"LTAIHGhV7Uix7S8Q"
#define kAccessKeySecret    @"wKlKVFb09YCnOYZPcJPot2RUvgtB7a"
#define kExpiration         @"2016-11-30T10:56:47Z"

#define kSecurityToken   @"CAES+QIIARKAAVly+yGhZtjfHtYjCF5vamC+WpatpPdDCY27hqJYhIj12voEt6JrjNxZMxwR2GzxYOB0qCpJ00aSNZsErojoGGGjID6kB3ZQCxEq/SpRMq/Ll8F54pYzWBJrySQLgS5D2ffIJpnXzvAq5M8W3BJsjVdzE5/xlM61vOgwaQS3q4p/Gh1TVFMuSGtZd2ZBNWJ5WGlHUUttRVc2TVlUekYxRyISMzkwNjkxNDgwMzkxNTQ1MDQ1KgtjbGllbnRfbmFtZTDM5oSniys6BlJzYU1ENUJOCgExGkkKBUFsbG93Eh8KDEFjdGlvbkVxdWFscxIGQWN0aW9uGgcKBW9zczoqEh8KDlJlc291cmNlRXF1YWxzEghSZXNvdXJjZRoDCgEqShAxMzgzODk5MTg3Mjc3OTA5UgUyNjg0MloPQXNzdW1lZFJvbGVVc2VyYABqEjM5MDY5MTQ4MDM5MTU0NTA0NXIKdGVzdC1yb2xlMnjV4Nmb4tS6Ag=="

NSString *const VKAccessKey = @"LTAIHGhV7Uix7S8Q";
NSString *const VKSecretKey = @"wKlKVFb09YCnOYZPcJPot2RUvgtB7a";
/*****************************************************/



#define global_queue   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define main_queue     dispatch_get_main_queue()

static id _instance;

@interface VKOSSManager ()

@property (nonatomic, strong) OSSGetObjectRequest *getRequest;  //获取object请求
@property (nonatomic, strong) OSSGetBucketRequest *getButketRequest; //获取butket 请求
@property (nonatomic, strong) OSSPutObjectRequest *putRequest;  //上传object请求
@property (nonatomic, strong) OSSTask *task; //

@property (nonatomic, strong) NSMutableArray *imageUrls; //用于缓存图片的url
@property (nonatomic, strong) NSArray *objects;         //下载object的容器
@property (nonatomic, strong) OSSClient *client;
@property (nonatomic, copy) NSString *bucketName;       //桶名
@property (nonatomic, copy) NSString *endPoint;         //域名
@property (nonatomic, copy) NSString *accessKeyId;
@property (nonatomic, copy) NSString *assessSecret;
@property (nonatomic, copy) NSString *expiration;
@property (nonatomic, copy) NSString *securityToken;
@property (nonatomic, copy) NSString *objectPath;       //object path  

@property (nonatomic, assign) NSUInteger uploadCount;   //需要上传的object数量
@property (nonatomic, assign) NSUInteger downloadCount; //需要下载的object数量

@property (nonatomic, assign) NSUInteger deleteCount; //需要下载的object数量

@property (nonatomic, copy) NSString *userId;           //用来配置用户图片存储途径
@property (nonatomic, strong) OSSTokenModel *tokenModel;


@end

@implementation VKOSSManager

+ (id)allocWithZone:(struct _NSZone *)zone{
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [super allocWithZone:zone];
            }
        }
    }
    return _instance;
}

+ (instancetype)sharedOSSManagerWith:(OSSTokenModel *)OSSInfoModel {
    
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [[self alloc] init];
            }
        }
    }
    [_instance setupClient:OSSInfoModel];
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}
- (NSMutableArray *)imageUrls {
    if(!_imageUrls) {
        _imageUrls = [[NSMutableArray alloc] init];
    }

    return _imageUrls;
}

#pragma mark - Client

//初始化获取OSSClient
- (void)setupClient:(OSSTokenModel *)OSSInfoModel {
    //如果token获取不到, 用本地持久化上次的token
    OSSTokenModel *localToken = [OSSTokenModel new];
    if(OSSInfoModel) {
        self.tokenModel = OSSInfoModel;
    }else {
        self.tokenModel = localToken;
    }
    
    if(!self.tokenModel) return;
    
    BOOL isVaild = [self checkTokenIsValidwithExpiration:self.tokenModel.expiration];
    if(!isVaild) {
        [[MFAppStartManager instance] getSTSTokenWith:nil password:nil];
    }
    
    //STS 鉴权
    id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc]
                                            initWithFederationTokenGetter:^OSSFederationToken * {
        return [self getFederationToken];
    }];
    _client = [[OSSClient alloc] initWithEndpoint:_tokenModel.OSSBucketURL credentialProvider:credential];
    
}

- (OSSFederationToken *)getFederationToken {
    
    OSSFederationToken *token = [OSSFederationToken new];
    token.tAccessKey = _tokenModel.accessKeyId;
    token.tSecretKey = _tokenModel.accessKeySecret;
    token.tToken = _tokenModel.securityToken;
    token.expirationTimeInGMTFormat = _tokenModel.expiration;
    
    //test
//    token.tAccessKey = kAccessKeyId;
//    token.tSecretKey = kAccessKeySecret;
//    token.tToken = kSecurityToken;
//    token.expirationTimeInGMTFormat = kExpiration;
    
//    NSLog(@"AccessKey: %@ \n SecretKey: %@ \n Token:%@ expirationTime: %@ \n",
//          token.tAccessKey, token.tSecretKey, token.tToken, token.expirationTimeInGMTFormat);
    return token;
}


#pragma mark - Get Services
- (void)asyncGetObjectWithKey:(NSString *)Key complete:(VKOSSGetObjectResult)resultBlock {
    
    if (Key == nil || [Key length] == 0) {
        return;
    }
    _getRequest = [OSSGetObjectRequest new];
    _getRequest.bucketName = self.tokenModel.OSSBucketName;
    //test
//    _getRequest.bucketName = kOSSBucketName;
    _getRequest.objectKey = Key;
    OSSTask * getImagetask = [_client getObject:_getRequest];
    
    [getImagetask continueWithBlock:^id(OSSTask *tempTask) {
        OSSGetObjectResult *result = tempTask.result;
        if (!tempTask.error) {
            NSLog(@"Get image success!");
            NSLog(@"resultImage%@", result.downloadedData);
            resultBlock(result.downloadedData, nil);
            
        } else {
            NSLog(@"Get image failed, %@", tempTask.error);
            if (tempTask.error.code == OSSClientErrorCodeTaskCancelled) {
                    resultBlock(nil, tempTask.error);
            } else {
                    resultBlock(nil, tempTask.error);
            }
        }
        self.getRequest = nil;
        return nil;
    }];
}


- (void)asyncGetObjectsWithKey:(NSArray *)Keys
                      complete:(VKOSSBucketResult)resultsBlock {
    if(!Keys.count) return;
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    __block NSInteger imageKeyCount = Keys.count;
    __block NSInteger downloadCount = 0;
    for(int i = 0; i < Keys.count; i++) {
        
        [self asyncGetObjectWithKey:[Keys objectAtIndex:i]
                           complete:^(NSData *data, NSError *error) {
            
            if(error) {
                resultsBlock(nil, error);
            }
            downloadCount++;
            UIImage *image = [UIImage imageWithData:data];
            [resultsArray addObject:image];
            
            if(downloadCount == imageKeyCount) {
                resultsBlock(resultsArray, nil);
            }
        }];
    }
}

- (void)getObjectWithKey:(NSString *)bucketName {
    
    OSSGetBucketRequest * getBucket = [OSSGetBucketRequest new];
    getBucket.bucketName = _tokenModel.OSSBucketName;
//     getBucket.bucketName = kOSSBucketName; //test
    // getBucket.marker = @"";
    // getBucket.prefix = @"";
    // getBucket.delimiter = @"";
    _task = [self.client getBucket:getBucket];
    [_task continueWithBlock:^id(OSSTask *tempTask) {
        if (!tempTask.error) {
            OSSGetBucketResult * result = tempTask.result;
            NSLog(@"get bucket success!");
            for (NSDictionary * objectInfo in result.contents) {
                NSLog(@"list object: %@", objectInfo);
            }        } else {
            NSLog(@"get bucket failed, error: %@", tempTask.error);
        }
        return nil;
    }];
}


- (void)getObjectsWithPrifix:(NSString *)prifix result:(VKOSSBucketResult)resultBlock {
    
    _getButketRequest = [OSSGetBucketRequest new];
    //test kOSSBucketName
//    _getButketRequest.bucketName = kOSSBucketName;
    _getButketRequest.bucketName = _tokenModel.OSSBucketName;
    _getButketRequest.prefix = prifix;//筛选图片
    _task = [_client getBucket:_getButketRequest];
    
    [_task continueWithBlock:^id _Nullable(OSSTask *tempTask) {
        if (!tempTask.error) {
            
            OSSGetBucketResult *result = tempTask.result;
            NSArray *list = nil;
            if(_predicate != nil) {
                list = [result.contents filteredArrayUsingPredicate:_predicate];
            }else{
                list = result.contents;
            }
            
            self.objects = list;
            if (resultBlock) {
                resultBlock(list,nil);
            }
        }else {
            if (resultBlock) {
                resultBlock(nil,_task.error);
            }
        }
        return nil;
    }];
}


- (void)getObjectKeysWithPrifix:(NSString *)prifix result:(VKOSSBucketResult)resultBlock {
    
    [self getObjectsWithPrifix:prifix result:^(NSArray *results, NSError *error) {
        NSMutableArray *keys = [NSMutableArray array];
        for (id obj in results) {
            if([obj isKindOfClass:[NSDictionary class]]) {
                NSString *key = [obj objectForKey:@"Key"];
                [keys addObject:key];
            }
        }
        resultBlock(keys, nil);
    }];
}

- (void)getListWithMaxPage:(NSString *)marker
                withPrefix:(NSString *)prefix
                   results:(VKOSSBucketResult)resultBlock {

    _getButketRequest = [OSSGetBucketRequest new];
    _getButketRequest.bucketName = _tokenModel.OSSBucketName;
    //test
//    _getButketRequest.bucketName = kOSSBucketName;
    _getButketRequest.prefix = prefix; //筛选图片
    _getButketRequest.maxKeys = 5;
    _getButketRequest.marker = marker;

    
    _task = [_client getBucket:_getButketRequest];
    
    [_task continueWithBlock:^id _Nullable(OSSTask *tempTask) {
        if (!tempTask.error) {
            OSSGetBucketResult *result = tempTask.result;
            NSArray *list = nil;
            if(_predicate != nil) {
                list = [result.contents filteredArrayUsingPredicate:_predicate];
            }else{
                list = result.contents;
            }
            self.objects = list;
            if (resultBlock) {
                resultBlock(list,nil);
            }
        }else {
            if (resultBlock) {
                resultBlock(nil,_task.error);
            }
        }
        return nil;
    }];
}


- (void)getImageUrlwithPrifix:(NSString *)prfix results:(VKOSSBucketResult)resuleBlock {

    __block NSString * constrainURL = nil;
    __block NSUInteger imageCount = 0;

    [self getObjectsWithPrifix:prfix result:^(NSArray *results, NSError *error) {
        
        for(id obj in results) {
            
            if([obj isKindOfClass:[NSDictionary class]]){
                
                if([obj objectForKey:@"Key"]) {
                    NSString *objKey = [obj objectForKey:@"Key"];
                    //kOSSBucketName test  _tokenModel.OSSBucketName
                    _task = [_client presignConstrainURLWithBucketName:_tokenModel.OSSBucketName
                                                         withObjectKey:objKey
                                                withExpirationInterval:30*60];
                    if (!_task.error) {
                        constrainURL = _task.result;
                        [self.imageUrls addObject:constrainURL];
                        imageCount++;
                        if(imageCount == results.count) {
                            resuleBlock(self.imageUrls, nil);
                            [self.imageUrls removeAllObjects];
                        }
                        
                    } else {
                        imageCount++;
                        NSLog(@"error: %@", _task.error);
                    }
                }
            }
        }
    }];
    
}


#pragma mark - Put Services
- (void)asyncUploadImage:(UIImage *)image
            withFullPath:(NSString *)path
                complete:(VKOSSPutObjectResult)results {
    [self uploadImages:@[image] withPath:path isAsync:NO complete:results];

}

- (void)asyncUploadImages:(NSArray<UIImage *> *)images
              withFullPath:(NSString *)path
                  complete:(VKOSSPutObjectResult)results {
    
    [self uploadImages:images withPath:path isAsync:YES complete:results];
}

- (void)uploadImages:(NSArray<UIImage *> *)images
            withPath:path
             isAsync:(BOOL)isAsync
            complete:(VKOSSPutObjectResult)results {
    

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = images.count;
    int i = 0;
    for (UIImage *image in images) {
        if (image) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                //任务执行
                _putRequest = [OSSPutObjectRequest new];
                _putRequest.bucketName = _tokenModel.OSSBucketName;
                //test
//                _putRequest.bucketName = kOSSBucketName;
                NSString *objectPath = [[self objectNameWithPath:path] stringByAppendingString:@".png"];
                _putRequest.objectKey = objectPath;
                
                NSData *data = UIImageJPEGRepresentation(image, 0.2);
                _putRequest.uploadingData = data;
                
                OSSTask * putTask = [_client putObject:_putRequest];
                // 阻塞直到上传完成
                [putTask waitUntilFinished];
                if (!putTask.error) {
                    NSLog(@"upload object success!");
                    results(UploadImageSuccess, nil);
                } else {
                    results(UploadImageFailed, putTask.error);
                }
                if (isAsync) {
                    if (image == images.lastObject) {
                        NSLog(@"upload object finished!");
                        if (results) {
                            results(UploadImageSuccess, nil);
                        }
                    }
                }
            }];
            if (queue.operations.count != 0) {
                [operation addDependency:queue.operations.lastObject];
            }
            [queue addOperation:operation];
        }
        i++;
    }
    
    if (!isAsync) {
        [queue waitUntilAllOperationsAreFinished];
        NSLog(@"haha");
        if (results) {
            if (results) {
                results(UploadImageSuccess, nil);
            }
        }
    }
}


- (void)deleteObjectWithKey:(NSString *)key complete:(VKOSSDeleteObjectResult)resultsBlock{
    OSSDeleteObjectRequest * delete = [OSSDeleteObjectRequest new];
    delete.bucketName = _tokenModel.OSSBucketName;
    //test
//    delete.bucketName = kOSSBucketName;
    delete.objectKey = key;
    OSSTask *deleteTask = [_client deleteObject:delete];
    [deleteTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            resultsBlock(DeleteImageSuccess, nil);
        }else {
            resultsBlock(DeleteImageFailed, nil);
        }
        return nil;
    }];
}

- (void)deleteObjectWithKeys:(NSArray *)keys complete:(VKOSSDeleteObjectResult)resultsBlock{
    
    __block NSUInteger deleteCount = 0;
    for(int i = 0; i < keys.count; i++) {
        [self deleteObjectWithKey:keys[i] complete:^(DeleteImageState state, NSError *error) {
            if(state == DeleteImageSuccess) {
                deleteCount++;
            }
            if(deleteCount == keys.count) {
                resultsBlock(DeleteImageSuccess, nil);
            }
        }];
        
    }
}

- (NSString *)objectNameWithPath:(NSString *)path {
    NSString *uuid = [[NSUUID UUID].UUIDString lowercaseString];
    NSString *objectNameStr = [path stringByAppendingPathComponent:uuid];
    return objectNameStr;
}


#pragma mark - Other Method
//检查token是否失效 如果失效则下载更新 传空默认检查本地Token
- (BOOL)checkTokenIsValidwithExpiration:(NSString *)expiration {
    
    if(!expiration) {
        //如果token获取不到, 用本地持久化上次的token
        OSSTokenModel *localToken = [OSSTokenModel new];
        if(self.tokenModel) {
            expiration = self.tokenModel.expiration;
        }else {
            expiration = localToken.expiration;
        }
    }
    if(!expiration) return NO;
    
    int64_t expirationTimeInMilliSecond = 0;
    
    if (expiration) {
        NSDateFormatter * fm = [NSDateFormatter new];
        [fm setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        expirationTimeInMilliSecond = [[fm dateFromString:expiration] timeIntervalSince1970] * 1000;
        OSSLogVerbose(@"Transform GMT date to expirationTimeInMilliSecond: %lld", expirationTimeInMilliSecond);
    }
    NSDate * expirationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(expirationTimeInMilliSecond / 1000)];
    NSTimeInterval interval = [expirationDate timeIntervalSinceDate:[NSDate oss_clockSkewFixedDate]];
    NSLog(@"-----interval:%f", interval);
    if (interval < 15 * 60) {
        OSSLogDebug(@"get federation token, but after %lf second it would be expired", interval);
        NSLog(@"token即将过期，更新本地token");
        //需要更新本地缓存Token
        [[MFAppStartManager instance] getSTSTokenWith:nil password:nil];
        return NO;
    }else{
        return YES;
    }
    
}


@end



