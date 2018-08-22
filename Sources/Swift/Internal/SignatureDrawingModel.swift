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

/**
 This model is updated with points (normally relating to a user's touch) and generates 2 view components a view can use to display the current signature:
 
 The temporaryPath is the path (up to one full bezier of 4 points) that is being updated every time update(withPoint:) is called.
 
 The signatureImage is an image that the temporaryPath gets drawn into every time it becomes a full bezier and then resets.
 
 To get the current full signature image, fullSignatureImage can be called at any time to get both components in a single image.
 
 - note: The reason this isn't just a single image that updates every time update(withPoint:) is called, is because the bezier changes as you draw (starts as a line and then becomes a quad and then bezier as more points are added), so the image would need to change some of the already drawn-in lines as they become curves. We could just return the composite image each update but it's too expensive to generate on every touch, even when the model is run in a background thread.
 
     The model is computationally expensive and running on the main thread should be avoided.
 */
class SignatureDrawingModel: SignatureBezierProviderDelegate {
    
    /// The color of the signature line.
    var signatureColor = UIColor.black
    
    /// The image of the immutable signature (doesn't include the temporaryPath)
    var signatureImage: UIImage?
    
    /**
     The bezier path for the mutable part of the signature.
     This is still being drawn and doesn't have enough points to make a full bezier and be drawn into the signatureImage yet.
     */
    var temporaryPath: UIBezierPath?
    
    /// Generates an image of the signatureImage including the temporaryPath.
    var fullSignatureImage: UIImage? {
        return signatureImage(adding: temporaryPath)
    }
    
    /**
     The size (in points) of the image backing the signature.
     This should be set to match the size of the view a signature is being recorded in.
     */
    var imageSize = CGSize.zero {
        didSet {
            guard imageSize != oldValue else {
                return
            }
            
            // Add the temporary bezier into the current signature image, so the image can be resized
            endContinuousLine()
            
            // Resize signature image
            signatureImage = SignatureDrawingModel.generateImage(withImageA: signatureImage, imageB: nil, bezierPath: nil, color: signatureColor, size: imageSize)
        }
    }
    
    /**
     Initializes the model with an image size.
     - parameter imageSize: The size (in points) for the backing image.
     */
    init(imageSize: CGSize = CGSize.zero) {
        self.imageSize = imageSize
        bezierProvider.delegate = self
    }
    
    /// Updates the signature with a new point.
    func update(withPoint point: CGPoint) {
        bezierProvider.addPointToSignature(point)
    }
    
    /// Ends the current continuous signature line (equivilent to lifting your finger off the screen)
    func endContinuousLine() {
        signatureImage = fullSignatureImage
        temporaryPath = nil
        bezierProvider.reset()
    }
    
    /// Resets the whole model, clears current signature.
    func reset() {
        signatureImage = nil
        temporaryPath = nil
        bezierProvider.reset()
    }
    
    /**
     Add an image into the signature image.
     Useful for instantiating the model with a previous signature image.
     */
    func addImageToSignature(_ image: UIImage) {
        signatureImage = SignatureDrawingModel.generateImage(withImageA: signatureImage, imageB: image, bezierPath: nil, color: signatureColor, size: imageSize)
    }
    
    // MARK: SignatureBezierProviderDelegate
    
    func updatedTemporaryBezier(_ bezier: UIBezierPath?) {
        temporaryPath = bezier
    }
    
    func generatedFinalizedBezier(_ bezier: UIBezierPath) {
        signatureImage = signatureImage(adding: bezier)
    }
    
    // MARK: Private

    private let bezierProvider = SignatureBezierProvider()
    
    private func signatureImage(adding path: UIBezierPath?) -> UIImage? {
        return SignatureDrawingModel.generateImage(withImageA: signatureImage, imageB: nil, bezierPath: path, color: signatureColor, size: imageSize)
    }
    
    // MARK: Helpers
    
    private class func generateImage(withImageA imageA: UIImage?, imageB: UIImage?, bezierPath: UIBezierPath?, color: UIColor, size: CGSize) -> UIImage? {
        guard size.isPositive && (imageA != nil || imageB != nil || bezierPath != nil) else {
            return nil
        }
        
        let imageFrame = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, 0)
        imageA?.draw(in: imageFrame)
        imageB?.draw(in: imageFrame)
        
        if let path = bezierPath {
            color.setStroke()
            color.setFill()
            path.stroke()
            path.fill()
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }

}

extension CGSize {
    var isPositive: Bool {
        return width > 0 && height > 0
    }
}
