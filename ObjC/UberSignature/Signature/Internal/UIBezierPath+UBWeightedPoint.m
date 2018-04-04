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

#import "UIBezierPath+UBWeightedPoint.h"
#import "UBCGPointHelpers.h"


/**
 A struct to represent a line between a start and end point
 */
typedef struct
{
    CGPoint startPoint;
    CGPoint endPoint;
} UBLine;

/**
 A struct to represent a pair of UBLines
 */
typedef struct
{
    UBLine firstLine;
    UBLine secondLine;
} UBLinePair;


@implementation UIBezierPath (UBWeightedPoint)

#pragma mark - Public

+ (UIBezierPath *)ub_dotWithWeightedPoint:(UBWeightedPoint)pointA
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:pointA.point radius:pointA.weight startAngle:0 endAngle:(CGFloat)M_PI * 2.0 clockwise:YES];

    return bezierPath;
}

+ (UIBezierPath *)ub_lineWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB
{
    UBLinePair linePair = [UIBezierPath _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:linePair.firstLine.startPoint];
    [bezierPath addLineToPoint:linePair.secondLine.startPoint];
    [bezierPath addLineToPoint:linePair.secondLine.endPoint];
    [bezierPath addLineToPoint:linePair.firstLine.endPoint];
    [bezierPath closePath];

    return bezierPath;
}

+ (UIBezierPath *)ub_quadCurveWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB pointC:(UBWeightedPoint)pointC
{
    UBLinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    UBLinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];

    UBLine lineA = linePairAB.firstLine;
    UBLine lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    UBLine lineC = linePairBC.secondLine;

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:lineA.startPoint];
    [bezierPath addQuadCurveToPoint:lineC.startPoint controlPoint:lineB.startPoint];
    [bezierPath addLineToPoint:lineC.endPoint];
    [bezierPath addQuadCurveToPoint:lineA.endPoint controlPoint:lineB.endPoint];
    [bezierPath closePath];

    return bezierPath;
}

+ (UIBezierPath *)ub_bezierCurveWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB pointC:(UBWeightedPoint)pointC pointD:(UBWeightedPoint)pointD
{
    UBLinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    UBLinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];
    UBLinePair linePairCD = [self.class _linesPerpendicularToLineWithWeightedPointA:pointC pointB:pointD];

    UBLine lineA = linePairAB.firstLine;
    UBLine lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    UBLine lineC = [self.class _averageLine:linePairBC.secondLine andLine:linePairCD.firstLine];
    UBLine lineD = linePairCD.secondLine;

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:lineA.startPoint];
    [bezierPath addCurveToPoint:lineD.startPoint controlPoint1:lineB.startPoint controlPoint2:lineC.startPoint];
    [bezierPath addLineToPoint:lineD.endPoint];
    [bezierPath addCurveToPoint:lineA.endPoint controlPoint1:lineC.endPoint controlPoint2:lineB.endPoint];
    [bezierPath closePath];

    return bezierPath;
}

#pragma mark - Private

+ (UBLinePair)_linesPerpendicularToLineWithWeightedPointA:(UBWeightedPoint)pointA pointB:(UBWeightedPoint)pointB
{
    UBLine line = (UBLine){pointA.point, pointB.point};

    UBLine linePerpendicularToPointA = [self.class _linePerpendicularToLine:line withMiddlePoint:pointA.point length:pointA.weight];
    UBLine linePerpendicularToPointB = [self.class _linePerpendicularToLine:line withMiddlePoint:pointB.point length:pointB.weight];

    return (UBLinePair){linePerpendicularToPointA, linePerpendicularToPointB};
}

+ (UBLine)_linePerpendicularToLine:(UBLine)line withMiddlePoint:(CGPoint)middlePoint length:(CGFloat)newLength
{
    // Calculate end point if line started at 0,0
    CGPoint relativeEndPoint = UBCGPointDifferentialPointOfPoints(line.startPoint, line.endPoint);
    
    if (newLength == 0 || CGPointEqualToPoint(relativeEndPoint, CGPointZero)) {
        return (UBLine){middlePoint, middlePoint};
    }
    
    // Modify line's length to be the length needed either side of the middle point
    CGFloat lengthEitherSideOfMiddlePoint = newLength / 2.0f;
    CGFloat originalLineLength = [self.class _lengthOfLine:line];
    CGFloat lengthModifier = lengthEitherSideOfMiddlePoint / originalLineLength;
    relativeEndPoint.x *= lengthModifier;
    relativeEndPoint.y *= lengthModifier;
    
    // Swap X/Y and invert one axis to get perpendicular line
    CGPoint perpendicularLineStartPoint = CGPointMake(relativeEndPoint.y, -relativeEndPoint.x);
    // Make other axis negative for perpendicular line in the opposite direction
    CGPoint perpendicularLineEndPoint = CGPointMake(-relativeEndPoint.y, relativeEndPoint.x);
    
    // Move perpendicular line to middle point
    perpendicularLineStartPoint.x += middlePoint.x;
    perpendicularLineStartPoint.y += middlePoint.y;
    
    perpendicularLineEndPoint.x += middlePoint.x;
    perpendicularLineEndPoint.y += middlePoint.y;
    
    return (UBLine){perpendicularLineStartPoint, perpendicularLineEndPoint};
}

#pragma mark - Helpers

+ (UBLine)_averageLine:(UBLine)lineA andLine:(UBLine)lineB
{
    return (UBLine){UBCGPointAveragePoints(lineA.startPoint, lineB.startPoint), UBCGPointAveragePoints(lineA.endPoint, lineB.endPoint)};
}

+ (CGFloat)_lengthOfLine:(UBLine)line
{
    return UBCGPointDistanceBetweenPoints(line.startPoint, line.endPoint);
}

@end
