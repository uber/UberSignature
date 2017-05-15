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
 A struct that defines a point that has an associated weight
 */
typedef struct
{
    CGPoint point;
    CGFloat weight;
} UBWeightedPoint;

/**
 Provides a set of class methods for generating @c UIBezierPaths between weighted points. It provides a dot for a single point, up to a full bezier curve for 4 points.
 
 The bezierPaths generated are actually a shape that needs to be filled. This is how the weight varies gradually between each point rather than using the @c UIBezierPath @c thickness property that sets the thickness of a whole path.
 */
@interface UIBezierPath (UBWeightedPoint)

/**
 Provides a dot with the given point.
 @param pointA The co-ordinate for the dot's center.
 @return A @c UIBezierPath for the dot.
 */
+ (UIBezierPath *)ub_dotWithWeightedPoint:(UBWeightedPoint)pointA;

/**
 Provides a straight line between the given points.
 @param pointA @c UBWeightedPoint for the start of the line.
 @param pointB The @c UBWeightedPoint for the end of the line.
 @return A \c UIBezierPath shape (that should be filled) for the line.
 */
+ (UIBezierPath *)ub_lineWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB;

/**
 Provides a quad curve between the given points.
 @param pointA @c UBWeightedPoint for the start of the curve.
 @param pointB The @c UBWeightedPoint for the middle of the curve.
 @param pointC The @c UBWeightedPoint for the end of the curve.
 @return A @c UIBezierPath shape (that should be filled) for the curve.
 */
+ (UIBezierPath *)ub_quadCurveWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB pointC:(UBWeightedPoint)pointC;

/**
 Provides a bezier curve between the given points.
 @param pointA The @c UBWeightedPoint for the start of the curve.
 @param pointB The @c UBWeightedPoint for the first control point of the curve.
 @param pointC The @c UBWeightedPoint for the second control point of the curve.
 @param pointD The @c UBWeightedPoint for the end of the curve.
 @return A @c UIBezierPath shape (that should be filled) for the curve.
 */
+ (UIBezierPath *)ub_bezierCurveWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB pointC:(UBWeightedPoint)pointC pointD:(UBWeightedPoint)pointD;

@end

NS_ASSUME_NONNULL_END
