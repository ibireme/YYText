//
//  UIPasteboard+YYText.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/2.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIPasteboard+YYText.h"
#import "NSAttributedString+YYText.h"
#import <MobileCoreServices/MobileCoreServices.h>


#if __has_include("YYImage.h")
#import "YYImage.h"
#define YYTextAnimatedImageAvailable 1
#elif __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#define YYTextAnimatedImageAvailable 1
#else
#define YYTextAnimatedImageAvailable 0
#endif


// Dummy class for category
@interface UIPasteboard_YYText : NSObject @end
@implementation UIPasteboard_YYText @end


NSString *const YYTextPasteboardTypeAttributedString = @"com.ibireme.NSAttributedString";
NSString *const YYTextUTTypeWEBP = @"com.google.webp";

@implementation UIPasteboard (YYText)


- (void)setYy_PNGData:(NSData *)PNGData {
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}

- (NSData *)yy_PNGData {
    return [self dataForPasteboardType:(id)kUTTypePNG];
}

- (void)setYy_JPEGData:(NSData *)JPEGData {
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}

- (NSData *)yy_JPEGData {
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setYy_GIFData:(NSData *)GIFData {
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}

- (NSData *)yy_GIFData {
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}

- (void)setYy_WEBPData:(NSData *)WEBPData {
    [self setData:WEBPData forPasteboardType:YYTextUTTypeWEBP];
}

- (NSData *)yy_WEBPData {
    return [self dataForPasteboardType:YYTextUTTypeWEBP];
}

- (void)setYy_ImageData:(NSData *)imageData {
    [self setData:imageData forPasteboardType:(id)kUTTypeImage];
}

- (NSData *)yy_ImageData {
    return [self dataForPasteboardType:(id)kUTTypeImage];
}

- (void)setYy_AttributedString:(NSAttributedString *)attributedString {
    self.string = [attributedString yy_plainTextForRange:NSMakeRange(0, attributedString.length)];
    NSData *data = [attributedString yy_archiveToData];
    if (data) {
        NSDictionary *item = @{YYTextPasteboardTypeAttributedString : data};
        [self addItems:@[item]];
    }
    [attributedString enumerateAttribute:YYTextAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(YYTextAttachment *attachment, NSRange range, BOOL *stop) {
        UIImage *img = attachment.content;
        if ([img isKindOfClass:[UIImage class]]) {
            NSDictionary *item = @{@"com.apple.uikit.image" : img};
            [self addItems:@[item]];
            
#if YYTextAnimatedImageAvailable
            if ([img isKindOfClass:[YYImage class]] && ((YYImage *)img).animatedImageData) {
                if (((YYImage *)img).animatedImageType == YYImageTypeGIF) {
                    NSDictionary *item = @{(id)kUTTypeGIF : ((YYImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((YYImage *)img).animatedImageType == YYImageTypePNG) {
                    NSDictionary *item = @{(id)kUTTypePNG : ((YYImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((YYImage *)img).animatedImageType == YYImageTypeWebP) {
                    NSDictionary *item = @{(id)YYTextUTTypeWEBP : ((YYImage *)img).animatedImageData};
                    [self addItems:@[item]];
                }
            }
#endif
        }
    }];
}

- (NSAttributedString *)yy_AttributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[YYTextPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString yy_unarchiveFromData:data];
        }
    }
    return nil;
}

@end
