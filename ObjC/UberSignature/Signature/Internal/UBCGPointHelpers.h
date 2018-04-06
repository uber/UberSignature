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

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/Foundation.h>

/*
 Generic helper methods for frequently needed calculations on CGPoint.
 */

/**
 Averages the x and y of 2 points.
 @param pointA the first @c CGPoint to average.
 @param pointB the second @c CGPoint to average with.
 @return A @c CGPoint with an x and y equal to the average of the two points' x and y.
 */
static inline CGPoint
UBCGPointAveragePoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = (pointA.x + pointB.x) * 0.5f;
    p.y = (pointA.y + pointB.y) * 0.5f;
    return p;
}

/**
 Calculates the difference in x and y of two points.
 @param pointA the first @c CGPoint.
 @param pointB the second @c CGPoint to calculate the difference from.
 @return A @c CGPoint with an x and y equal to the difference between the two points' x and y.
 */
static inline CGPoint
UBCGPointDifferentialPointOfPoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = pointB.x - pointA.x;
    p.y = pointB.y - pointA.y;
    return p;
}

/**
 Calculates the hypotenuse of the x and y component of a @c CGPoint.
 @param point A @c CGPoint.
 @return A @c CGFloat for the hypotenuse of @c point.
 */
static inline CGFloat
UBCGPointHypotenuseOfPoint(CGPoint point)
{
    return (CGFloat)sqrt(point.x * point.x + point.y * point.y);
}

/**
 Calculates the distance between two points.
 @param pointA the first @c CGPoint.
 @param pointB the second @c CGPoint to calculate the distance to.
 @return A @c CGFloat of the distance between the points.
 */
static inline CGFloat
UBCGPointDistanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
    return UBCGPointHypotenuseOfPoint(UBCGPointDifferentialPointOfPoints(pointA, pointB));
}
