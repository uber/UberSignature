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

#import "UBDemoViewController.h"
#import <UberSignature/UBSignatureDrawingViewController.h>

@interface UBDemoViewController () <UBSignatureDrawingViewControllerDelegate>

@property (nonatomic) UBSignatureDrawingViewController *signatureViewController;
@property (nonatomic) UIButton *resetButton;

@end

@implementation UBDemoViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.signatureViewController = [[UBSignatureDrawingViewController alloc] initWithImage:nil];
    self.signatureViewController.delegate = self;
    [self addChildViewController:self.signatureViewController];
    [self.view addSubview:self.self.signatureViewController.view];
    [self.signatureViewController didMoveToParentViewController:self];
    
    self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(_resetTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.resetButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20],
                                [NSLayoutConstraint constraintWithItem:self.resetButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:20],
                                
                                [NSLayoutConstraint constraintWithItem:self.signatureViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.signatureViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.signatureViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.signatureViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                ]];
    
}

#pragma mark - Private

- (void)_resetTapped
{
    [self.signatureViewController reset];
}

#pragma mark - <UBSignatureDrawingViewControllerDelegate>

- (void)signatureDrawingViewController:(UBSignatureDrawingViewController *)signatureDrawingViewController isEmptyDidChange:(BOOL)isEmpty
{
    self.resetButton.hidden = isEmpty;
}

@end
