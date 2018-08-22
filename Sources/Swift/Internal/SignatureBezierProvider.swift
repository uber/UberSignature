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

protocol SignatureBezierProviderDelegate: class {
    /**
     Provides the temporary signature bezier.
     This can be displayed to represent the most recent points of the signature,
     to give the feeling of real-time drawing but should not be permanently
     drawn, as it will change as more points are added.
     */
    func updatedTemporaryBezier(_ bezier: UIBezierPath?)
    
    /**
     Provides the finalized signature bezier.
     When enough points are added to form a full bezier curve, this will be
     returned as the finalized bezier and the temporary will reset.
     */
    func generatedFinalizedBezier(_ bezier: UIBezierPath)
}

/**
 Provides signature styled beziers using delegate callbacks as points are added.
 
 Temporary signature will change every time a point is added, occasionally a
 finalized bezier will be generated, which should be cached, as the temporary
 will then reset.
 
 Forms one continuous signature line. Call reset() to start generating a new line.
 */
class SignatureBezierProvider {
    
    /// The weight of a signature-styled dot.
    static let dotWeight: CGFloat = 3
    
    /// If a new point is added without being at least this distance from the previous point, it will be ignored.
    static let touchDistanceThreshold: CGFloat = 2
    
    /**
     Adds apoint to the signature line.
     The weight of the signature is based on the distance between these points,
     further apart making the line thinner.
     
     The delegate will receive callbacks when this function is used.
     */
    func addPointToSignature(_ point: CGPoint) {
        if isFirstPoint {
            startNewLine(from: WeightedPoint(point: point, weight: SignatureBezierProvider.dotWeight))
        } else {
            let previousPoint = points[nextPointIndex - 1].point
            guard previousPoint.distance(to: point) >= SignatureBezierProvider.touchDistanceThreshold else {
                return
            }
            if isStartOfNextLine {
                finalizeBezier(nextLineStartPoint: point)
                startNewLine(from: points[3])
            }
            
            let weightedPoint = WeightedPoint(point: point, weight: SignatureBezierProvider.signatureWeightForLine(between: previousPoint, and: point))
            addPoint(point: weightedPoint)
        }
        
        let newBezier = generateBezierPath(withPointIndex: nextPointIndex - 1)
        delegate?.updatedTemporaryBezier(newBezier)
    }
    
    /// Resets the provider - addPointToSignature() will start a new line after.
    func reset() {
        nextPointIndex = 0
        delegate?.updatedTemporaryBezier(nil)
    }
    
    /// Delegate for callbacks
    weak var delegate: SignatureBezierProviderDelegate?
    
    // MARK: Private
    
    private static let pointsPerLine: Int = 4
    private var nextPointIndex: Int = 0
    private var points = [WeightedPoint](repeating: WeightedPoint.zero, count: SignatureBezierProvider.pointsPerLine)
    
    private var isFirstPoint: Bool {
        return nextPointIndex == 0
    }
    
    private var isStartOfNextLine: Bool {
        return nextPointIndex >= SignatureBezierProvider.pointsPerLine
    }
    
    private func startNewLine(from weightedPoint: WeightedPoint) {
        points[0] = weightedPoint
        nextPointIndex = 1
    }
    
    private func addPoint(point: WeightedPoint) {
        points[nextPointIndex] = point
        nextPointIndex += 1
    }
    
    private func finalizeBezier(nextLineStartPoint: CGPoint) {
        /*
         Smooth the join between beziers by modifying the last point of the current bezier
         to equal the average of the points either side of it.
         */
        let touchPoint2 = points[2].point
        let newTouchPoint3 = touchPoint2.average(with: nextLineStartPoint)
        points[3] = WeightedPoint(point: newTouchPoint3, weight: SignatureBezierProvider.signatureWeightForLine(between: touchPoint2, and: newTouchPoint3))
        
        guard let bezier = generateBezierPath(withPointIndex: 3) else {
            return
        }
        
        delegate?.generatedFinalizedBezier(bezier)
    }
    
    private func generateBezierPath(withPointIndex index: Int) -> UIBezierPath? {
        switch index {
        case 0:
            return UIBezierPath.dot(with: points[0])
        case 1:
            return UIBezierPath.line(withWeightedPointA: points[0], pointB: points[1])
        case 2:
            return UIBezierPath.quadCurve(withWeightedPointA: points[0], pointB: points[1], pointC: points[2])
        case 3:
            return UIBezierPath.bezierCurve(withWeightedPointA: points[0], pointB: points[1], pointC: points[2], pointD: points[3])
        default:
            return nil
        }
    }
    
    // MARK: Helpers
        
    private class func signatureWeightForLine(between pointA: CGPoint, and pointB: CGPoint) -> CGFloat {
        let length = pointA.distance(to: pointB)
        
        /**
         The is the maximum length that will vary weight. Anything higher will return the same weight.
         */
        let maxLengthRange: CGFloat = 50
        
        /*
         These are based on having a minimum line thickness of 2.0 and maximum of 7, linearly over line lengths 0-maxLengthRange. They fit into a typical linear equation: y = mx + c
         
         Note: Only the points of the two parallel bezier curves will be at least as thick as the constant. The bezier curves themselves could still be drawn with sharp angles, meaning there is no true 'minimum thickness' of the signature.
         */
        let gradient: CGFloat = 0.1
        let constant: CGFloat = 2
        
        var inversedLength = maxLengthRange - length
        if inversedLength < 0 {
            inversedLength = 0
        }
        
        return (inversedLength * gradient) + constant
    }
}
