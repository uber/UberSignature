/**
 Copyright (c) 2017 Uber Technologies, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "UBSignatureDrawingModel.h"
#import "UBSignatureBezierProvider.h"

@interface UBSignatureDrawingModel () <UBSignatureBezierProviderDelegate>

@property (nonatomic) UIImage *signatureImage;
@property (nonatomic) UIBezierPath *temporarySignatureBezierPath;

@property (nonatomic, readonly) UBSignatureBezierProvider *bezierProvider;

@end


@implementation UBSignatureDrawingModel

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithImageSize:CGSizeZero];
}

- (instancetype)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        _imageSize = imageSize;
        
        _bezierProvider = [[UBSignatureBezierProvider alloc] init];
        _bezierProvider.delegate = self;
    }

    return self;
}

#pragma mark - Public

- (void)setImageSize:(CGSize)imageSize
{
    if (CGSizeEqualToSize(imageSize, self.imageSize)) {
        return;
    }
    
    // Add the temporary bezier into the current signature image, so the image can be resized
    [self endContinuousLine];
    
    _imageSize = imageSize;
    
    // Resize signature image
    self.signatureImage = [self.class _imageWithImage:self.signatureImage size:self.imageSize];
}

- (void)updateWithPoint:(CGPoint)point
{
    [self.bezierProvider addPointToSignatureBezier:point];
}

- (void)endContinuousLine
{
    self.signatureImage = [self fullSignatureImage];
    self.temporarySignatureBezierPath = nil;
    [self.bezierProvider reset];
}

- (void)reset
{
    self.signatureImage = nil;
    self.temporarySignatureBezierPath = nil;
    [self.bezierProvider reset];
}

- (UIImage *)fullSignatureImage
{
    return [self _signatureImageAddingBezierPath:self.temporarySignatureBezierPath];
}

- (void)addImageToSignature:(UIImage *)image
{
    self.signatureImage = [self.class _imageWithImageA:self.signatureImage imageB:image size:self.imageSize];
}

- (UIColor *)signatureColor
{
    if (!_signatureColor) {
        return [UIColor blackColor];
    }
    
    return _signatureColor;
}

#pragma mark - Private

- (UIImage *)_signatureImageAddingBezierPath:(UIBezierPath *)bezierPath
{
    return [self.class _imageWithImage:self.signatureImage bezierPath:bezierPath color:self.signatureColor size:self.imageSize];
}

#pragma mark - <UBSignatureBezierProviderDelegate>

- (void)signatureBezierProvider:(UBSignatureBezierProvider *)provider updatedTemporarySignatureBezier:(UIBezierPath *)temporarySignatureBezier
{
    self.temporarySignatureBezierPath = temporarySignatureBezier;
}

- (void)signatureBezierProvider:(UBSignatureBezierProvider *)provider generatedFinalizedSignatureBezier:(UIBezierPath *)finalizedSignatureBezier
{
    self.signatureImage = [self _signatureImageAddingBezierPath:finalizedSignatureBezier];
}

#pragma mark - Helpers

+ (UIImage *)_imageWithImage:(UIImage *)image size:(CGSize)size
{
    return [self.class _imageWithImageA:image imageB:nil bezierPath:nil color:nil size:size];
}

+ (UIImage *)_imageWithImageA:(UIImage *)imageA imageB:(UIImage *)imageB size:(CGSize)size
{
    return [self.class _imageWithImageA:imageA imageB:imageB bezierPath:nil color:nil size:size];
}

+ (UIImage *)_imageWithImage:(UIImage *)image bezierPath:(UIBezierPath *)bezierPath color:(UIColor *)color size:(CGSize)size
{
    return [self.class _imageWithImageA:image imageB:nil bezierPath:bezierPath color:color size:size];
}

+ (UIImage *)_imageWithImageA:(UIImage *)imageA imageB:(UIImage *)imageB bezierPath:(UIBezierPath *)bezierPath color:(UIColor *)color size:(CGSize)size
{
    if (![self.class _isPositiveSize:size]) {
        return nil;
    }
    
    if (!imageA && !imageB && !bezierPath) {
        return nil;
    }
    
    CGRect imageFrame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, 0);
    
    [imageA drawInRect:imageFrame];
    [imageB drawInRect:imageFrame];
    
    if (bezierPath) {
        [color setStroke];
        [color setFill];
        
        [bezierPath stroke];
        [bezierPath fill];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (BOOL)_isPositiveSize:(CGSize)size
{
    return (size.width > 0 && size.height > 0);
}

@end
