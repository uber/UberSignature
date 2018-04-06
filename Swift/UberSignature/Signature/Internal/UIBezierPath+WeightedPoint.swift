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

import UIKit

/// Represents a point and associated weight
struct WeightedPoint {
    let point: CGPoint
    let weight: CGFloat
    
    static let zero = WeightedPoint(point: CGPoint.zero, weight: 0)
}

/**
 Provides a set of class methods for generating UIBezierPaths between weighted points. It provides a dot for a single point, up to a full bezier curve for 4 points.
 
 The bezierPaths generated are actually a shape that needs to be filled. This is how the weight varies gradually between each point rather than using the UIBezierPath thickness property that sets the thickness of a whole path.
 */
extension UIBezierPath {
    
    /**
     Provides a dot with the given point.
     - parameter weightedPoint: The co-ordinate for the dot's center and the radius of the dot.
     - returns: A UIBezierPath for the dot.
     */
    class func dot(with weightedPoint: WeightedPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: weightedPoint.point, radius: weightedPoint.weight, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        return path
    }
    
    /**
     Provides a straight line between the given points.
     - parameter pointA: The WeightedPoint for the start of the line.
     - parameter pointB: The  WeightedPoint for the end of the line.
     - returns: A UIBezierPath shape (that should be filled) representing the line.
     */
    class func line(withWeightedPointA pointA: WeightedPoint, pointB: WeightedPoint) -> UIBezierPath {
        let lines = linesPerpendicularToLine(from: pointA, to: pointB)
        
        let path = UIBezierPath()
        path.move(to: lines.0.start)
        path.addLine(to: lines.1.start)
        path.addLine(to: lines.1.end)
        path.addLine(to: lines.0.start)
        path.close()
        
        return path
    }
    
    /**
     Provides a quad curve between the given points.
     - parameter pointA: The WeightedPoint for the start of the curve.
     - parameter pointB: The WeightedPoint for the middle of the curve.
     - parameter pointC: The WeightedPoint for the end of the curve.
     - returns: A UIBezierPath shape (that should be filled) representing the curve.
     */
    class func quadCurve(withWeightedPointA pointA: WeightedPoint, pointB: WeightedPoint, pointC: WeightedPoint) -> UIBezierPath {
        let linesAB = linesPerpendicularToLine(from: pointA, to: pointB)
        let linesBC = linesPerpendicularToLine(from: pointB, to: pointC)
        
        let lineA = linesAB.0
        let lineB = linesAB.1.average(with: linesBC.0)
        let lineC = linesBC.1
        
        let path = UIBezierPath()
        path.move(to: lineA.start)
        path.addQuadCurve(to: lineC.start, controlPoint: lineB.start)
        path.addLine(to: lineC.end)
        path.addQuadCurve(to: lineA.end, controlPoint: lineB.end)
        path.close()
        
        return path
    }
    
    /**
     Provides a bezier curve between the given points.
     - parameter pointA: The WeightedPoint for the start of the curve.
     - parameter pointB: The WeightedPoint for the first control point of the curve.
     - parameter pointC: The WeightedPoint for the second control point of the curve.
     - parameter pointD: The WeightedPoint for the end of the curve.
     - returns: A UIBezierPath shape (that should be filled) representing the curve.
     */
    class func bezierCurve(withWeightedPointA pointA: WeightedPoint, pointB: WeightedPoint, pointC: WeightedPoint, pointD: WeightedPoint) -> UIBezierPath {
        let linesAB = linesPerpendicularToLine(from: pointA, to: pointB)
        let linesBC = linesPerpendicularToLine(from: pointB, to: pointC)
        let linesCD = linesPerpendicularToLine(from: pointC, to: pointD)
        
        let lineA = linesAB.0
        let lineB = linesAB.1.average(with: linesBC.0)
        let lineC = linesBC.1.average(with: linesCD.0)
        let lineD = linesCD.1
        
        let path = UIBezierPath()
        path.move(to: lineA.start)
        path.addCurve(to: lineD.start, controlPoint1: lineB.start, controlPoint2: lineC.start)
        path.addLine(to: lineD.end)
        path.addCurve(to: lineA.end, controlPoint1: lineC.end, controlPoint2: lineB.end)
        path.close()
        
        return path
    }
    
    // MARK: Private
    
    private struct Line {
        let start: CGPoint
        let end: CGPoint
        
        var length: CGFloat {
            return start.distance(to: end)
        }
        
        func average(with line: Line) -> Line {
            return Line(start: start.average(with: line.start), end: end.average(with: line.end))
        }
        
        func perpendicularLine(from weightedPoint: WeightedPoint) -> Line {
            return perpendicularLine(withMiddle: weightedPoint.point, weight: weightedPoint.weight)
        }
        
        func perpendicularLine(withMiddle middle: CGPoint, weight: CGFloat) -> Line {
            // Calculate end point if line started at 0,0
            let relativeEnd = start.differential(to: end)
            
            guard weight != 0 && relativeEnd != CGPoint.zero else {
                return Line(start: middle, end: middle)
            }
            
            // Modify line's length to be the length needed either side of the middle point
            
            let lengthEitherSideOfMiddle = weight / 2
            let lengthModifier = lengthEitherSideOfMiddle / length
            
            let modifiedRelativeEnd = CGPoint(x: relativeEnd.x * lengthModifier, y: relativeEnd.y * lengthModifier)
            
            
            
            // Swap X/Y and invert one axis to get perpendicular line
            var perpendicularLineStart = CGPoint(x: modifiedRelativeEnd.y, y: -modifiedRelativeEnd.x)
            // Make other axis negative for perpendicular line in the opposite direction
            var perpendicularLineEnd = CGPoint(x: -modifiedRelativeEnd.y, y: modifiedRelativeEnd.x)
            
            // Move perpendicular line to middle point
            perpendicularLineStart.x += middle.x;
            perpendicularLineStart.y += middle.y;
            
            perpendicularLineEnd.x += middle.x;
            perpendicularLineEnd.y += middle.y;
            
            return Line(start: perpendicularLineStart, end: perpendicularLineEnd)
        }
    }
    
    private class func linesPerpendicularToLine(from pointA: WeightedPoint, to pointB: WeightedPoint) -> (Line, Line) {
        let line = Line(start: pointA.point, end: pointB.point)
        
        return (line.perpendicularLine(from: pointA), line.perpendicularLine(from: pointB))
    }
}
