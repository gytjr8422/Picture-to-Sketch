//
//  MyOpenCV.h
//  PicToSketch
//
//  Created by 김효석 on 2022/11/11.
//

#import <Foundation/Foundation.h>
#import "MyOpenCV.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyOpenCV : NSObject

+ (UIImage *)toSketch:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
