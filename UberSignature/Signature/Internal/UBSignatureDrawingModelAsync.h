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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An async wrapper for @c UBSignatureDrawingModel.
 Runs the models complex and expensive operations on a background thread.
 Abstracts the asynchronous code around the model for ease of use.
 
 Simply use the async methods to update points and get the output UI elements.
 */
@interface UBSignatureDrawingModelAsync : NSObject

/**
 Initializes the model with an image size.
 @param imageSize The size (in points) for the backing image.
 @return An instance.
 */
- (instancetype)initWithImageSize:(CGSize)imageSize NS_DESIGNATED_INITIALIZER;


#pragma mark - Async

/**
 Updates the object with a new point in the signature.
 @param point A @c CGPoint for a new point in the signature.
 */
- (void)asyncUpdateWithPoint:(CGPoint)point;

/**
 Ends the current continuous signature line (equivilent to lifting your finger off the screen)
 */
- (void)asyncEndContinuousLine;

/**
 Gets the signature image and temporarySignatureBezierPath of the model.
 Call this after @c asyncUpdateWithPoint: to asynchronously get the updated elements.
 @note block will be executed on the thread this method was called on.
 */
- (void)asyncGetOutputWithBlock:(void (^)( UIImage  * _Nullable signatureImage, UIBezierPath * _Nullable temporarySignatureBezierPath))block;


#pragma mark - Sync
// NOTE: The following methods are synchronous and will block the thread they are called on until they can be completed.

/// Resets the whole model, clears current signature.
- (void)reset;

/**
 Add an image into the signature image.
 Useful for instantiating the model with a previous signature.
 */
- (void)addImageToSignature:(UIImage *)image;

/// Generates a @c UIImage of the @c signatureImage including the @c temporarySignatureBezierPath.
- (UIImage *)fullSignatureImage;

/**
 The color of the signature.
 @note Defaults to black.
 */
@property (nonatomic) UIColor *signatureColor;

/**
 The size (in points) of the @c UIImage backing the signature.
 This should be set to match the size of the view a signature is being recorded in.
 */
@property (nonatomic) CGSize imageSize;

@end

NS_ASSUME_NONNULL_END
