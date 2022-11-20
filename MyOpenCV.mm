//
//  MyOpenCV.m
//  PicToSketch
//
//  Created by 김효석 on 2022/11/11.
//

#import "MyOpenCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

using namespace std;
using namespace cv;

@implementation MyOpenCV

#pragma mark Public
+ (UIImage *)toSketch:(UIImage *)image {
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
   
    UIImageToMat(image, imageMat);
    
    if(imageMat.channels() == 1) {
        cv::cvtColor(imageMat, imageMat, COLOR_GRAY2BGR);
    }
   
    // If the image was alread grayscale, return it
//    if (imageMat.channels() == 1)
//        return image;
   

    // Cartoon Image
//    cv::Mat cartoonMat;
//    cv::Mat cartoonMat_gray;
//    cv::Mat cartoonMat_color;
//    cv::detailEnhance(imageMat, cartoonMat, 10, 0.8);
//    cv::pencilSketch(cartoonMat, cartoonMat_gray, cartoonMat_color, 10, 0.4, 0.02);
//
//    UIImage *resultImage = MatToUIImage(cartoonMat_color);
    
    // Sketch Image
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, COLOR_BGR2GRAY);
    
    cv::Mat invertMat;
    cv::bitwise_not(grayMat, invertMat);
    
    cv::Mat blurMat;
    cv::GaussianBlur(invertMat, blurMat, cv::Size(7, 7), 0);
    
    cv::Mat invblurMat;
    cv::bitwise_not(blurMat, invblurMat);
    
    cv::Mat sketchMat;
    cv::divide(256, grayMat, grayMat);
    cv::divide(256, invblurMat, invblurMat);
    cv::divide(grayMat, invblurMat, sketchMat);
    cv::divide(256, sketchMat, sketchMat);
    
    
    UIImage *resultImage = MatToUIImage(sketchMat);
    return resultImage;
}

@end
