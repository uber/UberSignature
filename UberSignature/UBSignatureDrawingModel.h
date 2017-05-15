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
This model is updated with points (normally relating to a user's touch) and generates 2 view components a view can use to display the current signature:
 
 The @c temporarySignatureBezierPath is the path (up to one full bezier of 4 points) that is being updated every time @c updateWithPoint: is called.
 
 The @c signatureImage is a @c UIImage that the @c temporarySignatureBezierPath gets drawn into every time it becomes a full bezier and then resets.
 
 To get the current full signature image, @c fullSignatureImage can be called at any time to get both components in a single image.
 
 @note The reason this isn't just a single image that updates every time @c updateWithPoint: is called, is because the bezier changes as you draw (starts as a line and then becomes a quad and then bezier as more points are added), so the image would need to change some of the already drawn-in lines as they become curves. We could just return the composite image each update but it's too expensive to generate on every touch, even when the model is run in a background thread.
 
 @note The model is computationally expensive and running on the main thread should be avoided.
 */
@interface UBSignatureDrawingModel : NSObject

/**
 Initializes the model with an image size.
 @param imageSize The size (in points) for the backing image.
 @return An instance.
 */
- (instancetype)initWithImageSize:(CGSize)imageSize NS_DESIGNATED_INITIALIZER;

/**
 Updates the signature with a new point.
 @param point A @c CGPoint for a new point in the signature.
 */
- (void)updateWithPoint:(CGPoint)point;

/**
 Ends the current continuous signature line (equivilent to lifting your finger off the screen)
 */
- (void)endContinuousLine;

/// Resets the whole model, clears current signature.
- (void)reset;

/// Generates a @c UIImage of the @c signatureImage including the @c temporarySignatureBezierPath.
- (UIImage *)fullSignatureImage;

/**
 Add an image into the signature image.
 Useful for instantiating the model with a previous signature image.
 */
- (void)addImageToSignature:(UIImage *)image;

/**
 The color of the signature.
 @note Defaults to black
 */
@property (null_resettable, nonatomic) UIColor *signatureColor;

/**
 The size (in points) of the @c UIImage backing the signature.
 This should be set to match the size of the view a signature is being recorded in.
 */
@property (nonatomic) CGSize imageSize;

/**
 The @c UIImage of the immutable signature (doesn't include the @c temporarySignatureBezierPath)
 */
@property (nullable, nonatomic, readonly) UIImage *signatureImage;

/**
 The @c UIBezierPath for the mutable part of the signature. This is still being drawn and doesn't have enough points to make a full bezier and be drawn into @c signatureImage yet.
 */
@property (nullable, nonatomic, readonly) UIBezierPath *temporarySignatureBezierPath;

@end

NS_ASSUME_NONNULL_END
