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

// Generic helper methods for frequently needed calculations on CGPoint.
extension CGPoint {
    
    /**
     Averages the point with another.
     - parameter point: The point to average with.
     - returns: A point with an x and y equal to the average of this and the given point's x and y.
     */
    func average(with point: CGPoint) -> CGPoint {
        return CGPoint(x: (x + point.x) * 0.5, y: (y + point.y) * 0.5)
    }
    
    /**
     Calculates the difference in x and y between 2 points.
     - parameter point: The point to calculate the difference to.
     - returns: A point with an x and y equal to the difference between this and the given point's x and y.
     */
    func differential(to point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - x, y: point.y - y)
    }
    
    /**
     Calculates the distance between two points.
     - parameter point: the point to calculate the distance to.
     - returns: A CGFloat of the distance between the points.
     */
    func distance(to point: CGPoint) -> CGFloat {
        return differential(to: point).hypotenuse
    }
    
    /**
     Calculates the hypotenuse of the x and y component of a point.
     - returns: A CGFloat for the hypotenuse of the point.
     */
    var hypotenuse: CGFloat {
        return sqrt(x * x + y * y)
    }
}
