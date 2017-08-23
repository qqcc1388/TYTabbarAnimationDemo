//
//  UIButton+FastKit.m
//  FastKitDemo
//
//  Created by 李新星 on 15/11/27.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "UIButton+FastKit.h"
#import <objc/runtime.h>

@implementation NSString (FastKit)

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end


@implementation UIButton (FastKit)

#pragma mark -
+(void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method ovr_method = class_getInstanceMethod([self class], @selector(layoutSubviews));
        Method swz_method = class_getInstanceMethod([self class], @selector(fastkit_CustomLayoutSubviews));
        method_exchangeImplementations(ovr_method, swz_method);
    });
}

- (void)fastkit_CustomLayoutSubviews {
    
    [self fastkit_CustomLayoutSubviews];
    //初始化初始值
    if (self.scale == 0) {
        self.scale = 1.0;
    }
    //将图片和文字综合放在视图最中央
    if (self.imageView.image && self.layoutType != LXButtonLayoutTypeNone) {
        switch (self.layoutType) {
            case LXButtonLayoutTypeImageLeft:
                [self layoutSubviewsByTypeLeft];
                break;
            case LXButtonLayoutTypeImageRight:
                [self layoutSubviewsByTypeRight];
                break;
            case LXButtonLayoutTypeImageBottom:
                [self layoutSubviewsByTypeBottom];
                break;
            case LXButtonLayoutTypeImageTop:
                [self layoutSubviewsByTypeTop];
                break;
            default:
                break;
        }
        
    }
    
}

#pragma mark - Public method
- (void) layoutWithType:(LXButtonLayoutType)layoutType subMargin:(CGFloat)subMargin {
    self.layoutType = layoutType;
    self.subMargin = subMargin;
}

#pragma mark - Runtime Setter and getter
- (void)setLayoutType:(LXButtonLayoutType)layoutType {
    if (self.layoutType == layoutType) {
        return;
    }
    objc_setAssociatedObject(self, @selector(layoutType),[NSNumber numberWithInteger:layoutType],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (LXButtonLayoutType)layoutType {
    NSNumber * result = objc_getAssociatedObject(self, @selector(layoutType));
    return [result integerValue];
}

- (void)setSubMargin:(CGFloat)subMargin {
    if (self.subMargin == subMargin) {
        return;
    }
    objc_setAssociatedObject(self, @selector(subMargin),[NSNumber numberWithFloat:subMargin],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)subMargin {
    NSNumber * result = objc_getAssociatedObject(self, @selector(subMargin));
    return [result floatValue];
}

-(void)setScale:(CGFloat)scale{
    if (self.scale == scale) {
        return;
    }
    objc_setAssociatedObject(self, @selector(scale),[NSNumber numberWithFloat:scale],OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(CGFloat)scale{
    NSNumber * result = objc_getAssociatedObject(self, @selector(scale));
    return [result floatValue];
}

#pragma mark - Layout Methods
- (void) layoutSubviewsByTypeLeft {
    
    CGFloat imageWidth = self.imageView.image.size.width*self.scale;
    CGFloat imageHeight = self.imageView.image.size.height*self.scale;
    
    CGFloat maxLabelWidth = CGRectGetWidth(self.frame) - imageWidth - self.subMargin;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = [self.titleLabel.text sizeForFont:self.titleLabel.font
                                                    size:maxSize
                                                    mode:NSLineBreakByWordWrapping];
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.subMargin) / 2.0;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame) + self.subMargin;
    CGFloat labelY = (CGRectGetHeight(self.frame) - labelSize.height) / 2.0;
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
}

- (void) layoutSubviewsByTypeRight {
    
    CGFloat imageHeight = self.imageView.image.size.height*self.scale;
    CGFloat imageWidth =self.imageView.image.size.width*self.scale;
    
    CGFloat maxLabelWidth = 999;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = [self.titleLabel.text sizeForFont:self.titleLabel.font
                                                    size:maxSize
                                                    mode:NSLineBreakByWordWrapping];
    
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.subMargin) / 2.0;
    CGFloat labelY = (CGRectGetHeight(self.frame) - labelSize.height) / 2.0;
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
    
    CGFloat imageViewX = CGRectGetMaxX(self.titleLabel.frame) + self.subMargin;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    
}

- (void)layoutSubviewsByTypeTop {
    CGFloat imageWidth = self.imageView.image.size.width*self.scale;
    CGFloat imageHeight = self.imageView.image.size.height*self.scale;
    
    CGSize labelSize = [self.titleLabel.text sizeForFont:self.titleLabel.font
                                                    size:CGSizeMake(CGRectGetWidth(self.frame), self.titleLabel.font.lineHeight)
                                                    mode:NSLineBreakByWordWrapping];
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - imageWidth) / 2.0;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.subMargin) / 2.0;
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width) / 2.0;
    CGFloat labelY = CGRectGetMaxY(self.imageView.frame) + self.subMargin;
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
}

- (void) layoutSubviewsByTypeBottom {
    CGFloat imageWidth = self.imageView.image.size.width*self.scale;
    CGFloat imageHeight = self.imageView.image.size.height*self.scale;
    
    CGSize labelSize = [self.titleLabel.text sizeForFont:self.titleLabel.font
                                                    size:CGSizeMake(CGRectGetWidth(self.frame), self.titleLabel.font.lineHeight)
                                                    mode:NSLineBreakByWordWrapping];
    
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width) / 2.0;
    CGFloat labelY =  (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.subMargin) / 2.0;
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - imageWidth) / 2.0;
    CGFloat imageViewY = CGRectGetMaxY(self.titleLabel.frame) + self.subMargin;
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
}




@end
