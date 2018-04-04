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
@class UBSignatureDrawingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol UBSignatureDrawingViewControllerDelegate <NSObject>
@optional
/// Callback when @c isEmpty changes, due to user drawing or reset being called.
- (void)signatureDrawingViewController:(UBSignatureDrawingViewController *)signatureDrawingViewController isEmptyDidChange:(BOOL)isEmpty;

@end

/**
 A view controller that allows the user to draw a signature and provides additional functionality.
 */
@interface UBSignatureDrawingViewController : UIViewController

/**
 Init
 @param image An optional starting image for the signature.
 @return An instance
 */
- (instancetype)initWithImage:(nullable UIImage *)image NS_DESIGNATED_INITIALIZER;

/// Resets the signature
- (void)reset;

/// Returns a @c UIImage of the signature (with a transparent background).
- (UIImage *)fullSignatureImage;

/**
 Whether the signature drawing is empty or not.
 This changes when the user draws or the view is reset.
 @note Defaults to @c NO if there's a starting image.
 */
@property (nonatomic, readonly) BOOL isEmpty;

/**
 The color of the signature.
 Defaults to black.
 */
@property (nonatomic) UIColor *signatureColor;

/**
 Delegate to receive view controller callbacks.
 */
@property (nullable, nonatomic, weak) id<UBSignatureDrawingViewControllerDelegate> delegate;

#pragma mark - Unavailable
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
