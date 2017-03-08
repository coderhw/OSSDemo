//
//  OSSManager.h
//  OSSDemo
//
//  Created by Evan on 2016/11/29.
//  Copyright © 2016年 vanke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AliyunOSSiOS/OSSService.h>
#import "OSSTokenModel.h"

typedef NS_ENUM(NSInteger, UploadImageState) {
    UploadImageFailed   = 0,
    UploadImageSuccess  = 1
};

typedef NS_ENUM(NSInteger, DeleteImageState) {
    DeleteImageFailed   = 0,
    DeleteImageSuccess  = 1
};

typedef void(^VKOSSBucketResult)(NSArray *results, NSError *error);
typedef void(^VKOSSPutObjectResult)(UploadImageState state, NSError *error);
typedef void(^VKOSSGetObjectResult)(NSData *data, NSError *error);
typedef void(^VKOSSDeleteObjectResult)(DeleteImageState state, NSError *error);


@interface VKOSSManager : NSObject


/**
 * 用来筛选目录需要下载的object。
 */
@property (nonatomic, copy) NSString *prefix;

/**
 *  过滤list，默认过滤size＝0的文件。
 */
@property (nonatomic, strong) NSPredicate *predicate;



+ (instancetype)sharedOSSManagerWith:(OSSTokenModel *)OSSInfoModel;

/**
 检查缓存的token
 
 @param expiration 过期时间, 不传则去默认的token进行判断
 @return 是否有效
 */
- (BOOL)checkTokenIsValidwithExpiration:(NSString *)expiration;

/**
 *  获取bucket的obj列表
 *
 *  @param resultBlock 列表的回调，注意，此处不在main线程中。
 */
- (void)getObjectsWithPrifix:(NSString *)prifix result:(VKOSSBucketResult)resultBlock;


/**
 * 获取prefix 对应objects的key

 @param prifix prefix
 @param resultBlock 返回需要的keys
 */
- (void)getObjectKeysWithPrifix:(NSString *)prifix result:(VKOSSBucketResult)resultBlock;


/**
 *  获取bucket的obj列表  分页
 *  @param marker   设定结果从Marker之后按字母排序的第一个开始返回。
 *  @param resultBlock 列表的回调，注意，此处不在main线程中。
 */
- (void)getListWithMaxPage:(NSString *)marker withPrefix:(NSString *)prefix results:(VKOSSBucketResult)resultBlock;

/**
 获取bucket的object映射url列表。

 @param resuleBlock 对应的Images 的url回调。
 */
- (void)getImageUrlwithPrifix:(NSString *)prfix results:(VKOSSBucketResult)resuleBlock;


/**
 单张图片上传
 
 @param image 要上传的图片
 @param path  从外部传进来的绝对路径
 @param results 返回错误信息
 */
- (void)asyncUploadImage:(UIImage *)image
            withFullPath:(NSString *)path
                complete:(VKOSSPutObjectResult)results;

/**
 多张图片上传
 
 @param images 要上传的图片容器
 @param path  从外部传进来的绝对路径
 @param results 返回错误信息
 */
- (void)asyncUploadImages:(NSArray<UIImage *> *)images
             withFullPath:(NSString *)path
                 complete:(VKOSSPutObjectResult)results;



/**
 异步获取object

 @param Key object对应的Key
 @param resultBlock 返回的数据
 */
- (void)asyncGetObjectWithKey:(NSString *)Key
                     complete:(VKOSSGetObjectResult)resultBlock;

/**
 异步获取objects
 @param Keys object对应的Key
 @param resultsBlock 返回的objects数组
 */
- (void)asyncGetObjectsWithKey:(NSArray *)Keys
                      complete:(VKOSSBucketResult)resultsBlock;


/**
 * 删除Objects
 *
 @param key Object KeyPath
 */
- (void)deleteObjectWithKey:(NSString *)key complete:(VKOSSDeleteObjectResult)resultsBlock;


- (void)deleteObjectWithKeys:(NSArray *)keys complete:(VKOSSDeleteObjectResult)resultsBlock;

@end
