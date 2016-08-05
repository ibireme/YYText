//
//  YYFrameImage.m
//  YYImage <https://github.com/ibireme/YYImage>
//
//  Created by ibireme on 14/12/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYFrameImage.h"
#import "YYImageCoder.h"


/**
 Return the path scale.
 
 e.g.
 <table>
 <tr><th>Path            </th><th>Scale </th></tr>
 <tr><td>"icon.png"      </td><td>1     </td></tr>
 <tr><td>"icon@2x.png"   </td><td>2     </td></tr>
 <tr><td>"icon@2.5x.png" </td><td>2.5   </td></tr>
 <tr><td>"icon@2x"       </td><td>1     </td></tr>
 <tr><td>"icon@2x..png"  </td><td>1     </td></tr>
 <tr><td>"icon@2x.png/"  </td><td>1     </td></tr>
 </table>
 */
static CGFloat _NSStringPathScale(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location >= 3) {
            scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
        }
    }];
    
    return scale;
}



@implementation YYFrameImage {
    NSUInteger _loopCount;
    NSUInteger _oneFrameBytes;
    NSArray *_imagePaths;
    NSArray *_imageDatas;
    NSArray *_frameDurations;
}

- (instancetype)initWithImagePaths:(NSArray *)paths oneFrameDuration:(NSTimeInterval)oneFrameDuration loopCount:(NSUInteger)loopCount {
    NSMutableArray *durations = [NSMutableArray new];
    for (int i = 0, max = (int)paths.count; i < max; i++) {
        [durations addObject:@(oneFrameDuration)];
    }
    return [self initWithImagePaths:paths frameDurations:durations loopCount:loopCount];
}

- (instancetype)initWithImagePaths:(NSArray *)paths frameDurations:(NSArray *)frameDurations loopCount:(NSUInteger)loopCount {
    if (paths.count == 0) return nil;
    if (paths.count != frameDurations.count) return nil;
    
    NSString *firstPath = paths[0];
    NSData *firstData = [NSData dataWithContentsOfFile:firstPath];
    CGFloat scale = _NSStringPathScale(firstPath);
    UIImage *firstCG = [[[UIImage alloc] initWithData:firstData] yy_imageByDecoded];
    self = [self initWithCGImage:firstCG.CGImage scale:scale orientation:UIImageOrientationUp];
    if (!self) return nil;
    long frameByte = CGImageGetBytesPerRow(firstCG.CGImage) * CGImageGetHeight(firstCG.CGImage);
    _oneFrameBytes = (NSUInteger)frameByte;
    _imagePaths = paths.copy;
    _frameDurations = frameDurations.copy;
    _loopCount = loopCount;
    
    return self;
}

- (instancetype)initWithImageDataArray:(NSArray *)dataArray oneFrameDuration:(NSTimeInterval)oneFrameDuration loopCount:(NSUInteger)loopCount {
    NSMutableArray *durations = [NSMutableArray new];
    for (int i = 0, max = (int)dataArray.count; i < max; i++) {
        [durations addObject:@(oneFrameDuration)];
    }
    return [self initWithImageDataArray:dataArray frameDurations:durations loopCount:loopCount];
}

- (instancetype)initWithImageDataArray:(NSArray *)dataArray frameDurations:(NSArray *)frameDurations loopCount:(NSUInteger)loopCount {
    if (dataArray.count == 0) return nil;
    if (dataArray.count != frameDurations.count) return nil;
    
    NSData *firstData = dataArray[0];
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *firstCG = [[[UIImage alloc] initWithData:firstData] yy_imageByDecoded];
    self = [self initWithCGImage:firstCG.CGImage scale:scale orientation:UIImageOrientationUp];
    if (!self) return nil;
    long frameByte = CGImageGetBytesPerRow(firstCG.CGImage) * CGImageGetHeight(firstCG.CGImage);
    _oneFrameBytes = (NSUInteger)frameByte;
    _imageDatas = dataArray.copy;
    _frameDurations = frameDurations.copy;
    _loopCount = loopCount;
    
    return self;
}

#pragma mark - YYAnimtedImage

- (NSUInteger)animatedImageFrameCount {
    if (_imagePaths) {
        return _imagePaths.count;
    } else if (_imageDatas) {
        return _imageDatas.count;
    } else {
        return 1;
    }
}

- (NSUInteger)animatedImageLoopCount {
    return _loopCount;
}

- (NSUInteger)animatedImageBytesPerFrame {
    return _oneFrameBytes;
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    if (_imagePaths) {
        if (index >= _imagePaths.count) return nil;
        NSString *path = _imagePaths[index];
        CGFloat scale = _NSStringPathScale(path);
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [[UIImage imageWithData:data scale:scale] yy_imageByDecoded];
    } else if (_imageDatas) {
        if (index >= _imageDatas.count) return nil;
        NSData *data = _imageDatas[index];
        return [[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] yy_imageByDecoded];
    } else {
        return index == 0 ? self : nil;
    }
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= _frameDurations.count) return 0;
    NSNumber *num = _frameDurations[index];
    return [num doubleValue];
}

@end
