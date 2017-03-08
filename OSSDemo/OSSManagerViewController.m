

//
//  OSSImageManagerViewController.m
//  OSSDemo
//
//  Created by Evan on 2016/11/29.
//  Copyright © 2016年 vanke. All rights reserved.
//

#import "OSSManagerViewController.h"

#import <AliyunOSSiOS/OSSService.h>
#import "VKOSSManager.h"
#import <MJExtension/MJExtension.h>

@interface OSSManagerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (nonatomic, copy) NSString *marker;



@end

@implementation OSSManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
}

- (IBAction)uploadImage:(id)sender {
    [self uploadImages];
}

//上传单张 或者多张
- (void)uploadImages {
    
    UIImage *image1 = [UIImage imageNamed:@"Image_0.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"Image_1.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"Image_3.jpg"];
    UIImage *image4 = [UIImage imageNamed:@"Image_4.jpg"];

//    UIImage *image4 = [UIImage imageNamed:@"Image_4.jpg"];
//    UIImage *image5 = [UIImage imageNamed:@"Image_5.jpg"];
    
    NSString *prefix1 = @"bhouse/user/info_img";
    NSString *userId = @"13928460216";
    NSString *prefix = [prefix1 stringByAppendingPathComponent:userId];
    
    NSArray *images = @[image1,image4];
//    [[VKOSSManager sharedOSSManagerWith:nil] asyncUploadImage:image1 withFullPath:nil complete:^(UploadImageState state, NSError *error) {
//        
//    }];
    
    //多张图片
    [[VKOSSManager sharedOSSManagerWith:nil] asyncUploadImages:images withFullPath:prefix complete:^(UploadImageState state, NSError *error) {
        
    }];
    
}

- (IBAction)queryImage:(id)sender {
    
    NSString *prefix = @"vankesalesbucket/bhouse/user/";
    //返回object 数组
    [[VKOSSManager sharedOSSManagerWith:nil] getObjectsWithPrifix:prefix result:^(NSArray *results, NSError *error) {
        NSLog(@"results(objects):%lu", (unsigned long)results.count);
        
        
    }];
//    //返回 image url
//    [[VKOSSManager sharedOSSManagerWith:nil] getImageUrlwithPrifix:prefix results:^(NSArray *results, NSError *error) {
//        NSLog(@"results(imageURL):%lu", (unsigned long)results.count);
//
//    }];
}

// 分页查询
- (IBAction)queryPartImage:(id)sender {

    NSString *key = @"vankesalesbucket/bhouse/user";
    [[VKOSSManager sharedOSSManagerWith:nil] getListWithMaxPage:self.marker
                                                     withPrefix:key
                                                        results:^(NSArray *results, NSError *error) {
                                                      
         self.marker = [results.lastObject objectForKey:@"Key"];
         if(results.count < 5) {
            self.marker = nil;
         }
         NSLog(@"分页results:%lu", (unsigned long) results.count);
    }];
}


- (IBAction)quertSingleImage:(id)sender {
    
    NSString *key = @"vankesalesbucket/bhouse/user/info_img/13928460216/ef3889c3-c65a-4700-942d-e4bfdab2c1c1.jpg";
    [[VKOSSManager sharedOSSManagerWith:nil] asyncGetObjectWithKey:key
                                                          complete:^(NSData *data, NSError *error) {
                                                              NSLog(@"data:%@", data);
    }];
}

- (IBAction)quertMutiImages:(id)sender {
    
    NSString *key2 = @"vankesalesbucket/bhouse/user/info_img/13928460216/683e80a2-7b85-4f72-96f4-b020045a7317.jpg";
    NSString *key1 = @"vankesalesbucket/bhouse/user/info_img/13928460216/ef3889c3-c65a-4700-942d-e4bfdab2c1c1.jpg";
    [[VKOSSManager sharedOSSManagerWith:nil] asyncGetObjectsWithKey:@[key1, key2]
                                                           complete:^(NSArray *results, NSError *error) {
                                                               NSLog(@"results:%@", results);
                                                           }];
}

- (IBAction)quertObjectsKeys:(id)sender {
    NSString *prefix = @"vankesalesbucket/bhouse/user/";
    [[VKOSSManager sharedOSSManagerWith:nil] getObjectKeysWithPrifix:prefix result:^(NSArray *results, NSError *error) {
        NSLog(@"results:%@", results);
    }];
}

@end
