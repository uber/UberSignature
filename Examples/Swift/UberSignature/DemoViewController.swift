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
import UberSignature

class DemoViewController: UIViewController, SignatureDrawingViewControllerDelegate {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        signatureViewController.delegate = self
        addChildViewController(signatureViewController)
        view.addSubview(signatureViewController.view)
        signatureViewController.didMove(toParentViewController: self)
        
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // Constraints
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint.init(item: resetButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint.init(item: resetButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20),
            
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
        
        
    }
    
    // MARK: SignatureDrawingViewControllerDelegate
    
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        resetButton.isHidden = isEmpty
    }
    
    // MARK: Private
    
    private let signatureViewController = SignatureDrawingViewController()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        return button
    }()
    
    @objc private func resetTapped() {
        signatureViewController.reset()
    }
    
}

