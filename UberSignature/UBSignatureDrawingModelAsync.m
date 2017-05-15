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

#import "UBSignatureDrawingModelAsync.h"
#import "UBSignatureDrawingModel.h"

@interface UBSignatureDrawingModelAsync ()

/// self.model is atomic, to prevent access by multiple threads at same time
@property (atomic, readonly) UBSignatureDrawingModel *model;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation UBSignatureDrawingModelAsync

- (instancetype)init
{
    return [self initWithImageSize:CGSizeZero];
}

- (instancetype)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        _model = [[UBSignatureDrawingModel alloc] initWithImageSize:imageSize];
        
        _operationQueue = ({
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            queue;
        });
    }
    
    return self;
}

#pragma mark - Async

- (void)asyncUpdateWithPoint:(CGPoint)point
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model updateWithPoint:point];
    }];
}

- (void)asyncEndContinuousLine
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model endContinuousLine];
    }];
}

- (void)asyncGetOutputWithBlock:(void (^)(UIImage *signatureImage, UIBezierPath *temporarySignatureBezierPath))block
{
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    
    [self.operationQueue addOperationWithBlock:^{
        UIImage *signatureImage = self.model.signatureImage;
        UIBezierPath *temporaryBezierPath = self.model.temporarySignatureBezierPath;
            [currentQueue addOperationWithBlock:^{
                block(signatureImage, temporaryBezierPath);
            }];
    }];
}

#pragma mark - Sync

- (void)reset
{
    [self.operationQueue cancelAllOperations];
    [self.model reset];
}

- (void)addImageToSignature:(UIImage *)image
{
    [self.model addImageToSignature:image];
}

- (UIImage *)fullSignatureImage
{
    return [self.model fullSignatureImage];
}

- (CGSize)imageSize
{
    return self.model.imageSize;
}

- (void)setImageSize:(CGSize)imageSize
{
    self.model.imageSize = imageSize;
}

- (UIColor *)signatureColor
{
    return self.model.signatureColor;
}

- (void)setSignatureColor:(UIColor *)signatureColor
{
    self.model.signatureColor = signatureColor;
}

@end
