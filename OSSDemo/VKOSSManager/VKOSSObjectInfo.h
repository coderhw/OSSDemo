//
//  VKOSSObjectInfo.h
//  ServiceEngineer
//
//  Created by Parity on 16/8/31.
//  Copyright © 2016年 Vanke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  oss对象的拥有者信息
 */
@interface VKOSSObjectOwner : NSObject

@property (nonatomic, copy) NSString *DisplayName;
@property (nonatomic, copy) NSString *ID;

@end

/**
 *  oss 下载的对象
 */
@interface VKOSSObjectInfo : NSObject

@property (nonatomic, copy) NSString *Etag;
@property (nonatomic, copy) NSString *Key;
@property (nonatomic, copy) NSString *LastModified;
@property (nonatomic, assign) CGFloat Size;
//@property (nonatomic, strong) VKOSSObjectOwner *Owner;

@end
