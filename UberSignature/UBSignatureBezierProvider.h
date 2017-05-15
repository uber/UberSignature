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

#import <Foundation/Foundation.h>
#import "UIBezierPath+UBWeightedPoint.h"
@class UBSignatureBezierProvider;

NS_ASSUME_NONNULL_BEGIN

@protocol UBSignatureBezierProviderDelegate <NSObject>

/**
 Provides the temporary signature bezier.
 This can be displayed to represent the most recent points of the signature,
 to give the feeling of real-time drawing but should not be permanently
 drawn, as it will change as more points are added.
 */
- (void)signatureBezierProvider:(UBSignatureBezierProvider *)provider updatedTemporarySignatureBezier:(nullable UIBezierPath *)temporarySignatureBezier;

/**
 Provides the finalized signature bezier.
 When enough points are added to form a full bezier curve, this will be 
 returned as the finalized bezier and the temporary will reset.
 */
- (void)signatureBezierProvider:(UBSignatureBezierProvider *)provider generatedFinalizedSignatureBezier:(UIBezierPath *)finalizedSignatureBezier;

@end

/**
 Provides signature styled beziers using delegate callbacks as points are added.
 
 Temporary signature will change every time a point is added, occasionally a
 finalized bezier will be generated, which should be cached, as the temporary 
 will then reset.
 
 Forms one continuous signature line. Call @c reset to start generating a new line.
 */
@interface UBSignatureBezierProvider : NSObject

/**
 Adds points to the signature line.
 The weight of the signature is based on the distance apart these points are,
 further apart making the line thinner.
 
 The delegate will receive callbacks when this method is used.
 */
- (void)addPointToSignatureBezier:(CGPoint)point;

/// Resets the provider. addPointToSignatureBezier: will start a new line
- (void)reset;

@property (nullable, nonatomic, weak) id<UBSignatureBezierProviderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
