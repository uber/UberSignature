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

public protocol SignatureDrawingViewControllerDelegate: class {
    /// Callback when isEmpty changes, due to user drawing or reset() being called.
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool)
}

/**
 A view controller that allows the user to draw a signature and provides additional functionality.
 */
public class SignatureDrawingViewController: UIViewController {
   
    /**
     Initializer
     - parameter image: An optional starting image for the signature.
     */
    public init(image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Use init(image:) instead.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Returns an image of the signature (with a transparent background).
    public var fullSignatureImage: UIImage? {
        return model.fullSignatureImage
    }
    
    /**
     The color of the signature.
     Defaults to black.
     */
    public var signatureColor: UIColor {
        get {
            return model.signatureColor
        }
        set(color) {
            model.signatureColor = color
            bezierPathLayer.strokeColor = color.cgColor
            bezierPathLayer.fillColor = color.cgColor
        }
    }
    
    /**
     Whether the signature drawing is empty or not.
     This changes when the user draws or the view is reset.
     - note: Defaults to false if there's a starting image.
     */
    private(set) var isEmpty = true {
        didSet {
            if isEmpty != oldValue {
                delegate?.signatureDrawingViewControllerIsEmptyDidChange(controller: self, isEmpty: isEmpty)
            }
        }
    }
    
    /// Delegate for callbacks.
    public weak var delegate: SignatureDrawingViewControllerDelegate?
    
    /// Resets the signature.
    public func reset() {
        model.reset()
        updateViewFromModel()
    }
    
    // MARK: UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.addSubview(imageView)
        
        view.layer.addSublayer(bezierPathLayer)
        
        // Constraints
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint.init(item: imageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = presetImage {
            view.layoutIfNeeded()
            model.addImageToSignature(image)
            updateViewFromModel()
            presetImage = nil
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        model.imageSize = view.bounds.size
        updateViewFromModel()
    }
    
    // MARK: UIResponder
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateModel(withTouches: touches, shouldEndContinousLine: true)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateModel(withTouches: touches, shouldEndContinousLine: false)
    }
    
    // MARK: Private
    
    private let model = SignatureDrawingModelAsync()
    
    private lazy var bezierPathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = signatureColor.cgColor
        layer.fillColor = signatureColor.cgColor
        
        return layer
    }()

    private var imageView = UIImageView()
    private var presetImage: UIImage?
    
    private func updateModel(withTouches touches: Set<UITouch>, shouldEndContinousLine: Bool) {
        guard let touchPoint = touches.touchPoint else {
            return
        }
        
        if shouldEndContinousLine {
            model.asyncEndContinuousLine()
        }
        model.asyncUpdate(withPoint: touchPoint)
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        model.asyncGetOutput { (output) in
            if self.imageView.image != output.signatureImage {
                self.imageView.image = output.signatureImage
            }
            if self.bezierPathLayer.path != output.temporarySignatureBezierPath?.cgPath {
                self.bezierPathLayer.path = output.temporarySignatureBezierPath?.cgPath
            }
            
            self.isEmpty = self.bezierPathLayer.path == nil && self.imageView.image == nil
        }
    }
}

extension Set where Element == UITouch {
    var touchPoint: CGPoint? {
        let touch = first
        
        return touch?.location(in: touch?.view)
    }
}
