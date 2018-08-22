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
 An async wrapper for the SignatureDrawingModel.
 Runs the model's complex and expensive operations on a background thread.
 Abstracts the asynchronous code around the model for ease of use.
 
 Simply use the async functions to update points and get the output UI elements.
 */
class SignatureDrawingModelAsync {
    
    /**
     Initializes the model with an image size.
     - parameter imageSize: The size (in points) for the backing image.
     */
    init(imageSize: CGSize = CGSize.zero) {
        model = SignatureDrawingModel(imageSize: imageSize)
    }
    
    // MARK: Async
    
    /**
     Updates the model with a new point in the signature.
     - parameter point: A new point in the signature.
     */
    func asyncUpdate(withPoint point: CGPoint) {
        operationQueue.addOperation {
            self.model.update(withPoint: point)
        }
    }
    
    /// Ends the current continuous signature line (equivilent to lifting your finger off the screen)
    func asyncEndContinuousLine() {
        operationQueue.addOperation {
            self.model.endContinuousLine()
        }
    }
    
    /**
     Gets the signature image and temporaryPath of the model.
     Call this after asyncUpdate(withPoint:) to asynchronously get the updated elements.
     - note: Closure will be executed on the thread this function was called on.
     */
    func asyncGetOutput(_ closure: @escaping ( (signatureImage: UIImage?, temporarySignatureBezierPath: UIBezierPath?) ) -> () ) {
        let currentQueue = OperationQueue.current
        
        operationQueue.addOperation {
            let image = self.model.signatureImage
            let path =  self.model.temporaryPath
            currentQueue?.addOperation({
                closure((signatureImage: image, temporarySignatureBezierPath: path))
            })
        }
    }
    
    // MARK: Sync
    // NOTE: The following computed properties/functions are synchronous and will block the thread they are called on until they can be completed.
    
    /// Generates an image of the signatureImage including the temporaryPath.
    var fullSignatureImage: UIImage? {
        return model.fullSignatureImage
    }
    
    /**
     The size (in points) of the image backing the signature.
     This should be set to match the size of the view the signature is being recorded in.
     */
    var imageSize: CGSize {
        get {
           return model.imageSize
        }
        set(size) {
            model.imageSize = size
        }
    }
    
    /// The color of the signature.
    var signatureColor: UIColor {
        get {
            return model.signatureColor
        }
        set(color) {
            model.signatureColor = color
        }
    }
    
    /// Resets the whole model, clears current signature.
    func reset() {
        operationQueue.cancelAllOperations()
        model.reset()
    }
    
    /**
     Add an image into the signature image.
     Useful for instantiating the model with a previous signature.
     */
    func addImageToSignature(_ image: UIImage) {
        model.addImageToSignature(image)
    }
    
    
    // MARK: Private
    
    private let model: SignatureDrawingModel
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
}
