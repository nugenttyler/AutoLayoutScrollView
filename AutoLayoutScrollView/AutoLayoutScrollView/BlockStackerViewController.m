//
//  BlockStackerViewController.m
//  AutoLayoutScrollView
//
//  Created by Tyler Nugent on 3/28/15.
//  Copyright (c) 2015 Hoyt Street Software. All rights reserved.
//

#import "BlockStackerViewController.h"
#import "UIColor+Hex.h"

@interface BlockStackerViewController ()

@property (nonatomic, strong) NSArray *blockViewColors;
@property (nonatomic, assign) NSInteger currentBlockViewColorIdx;

@property (nonatomic, strong) UIScrollView *scrollView;

// book keeping
@property (nonatomic, weak) UIView *lastBlockView;
@property (nonatomic, weak) NSLayoutConstraint *bottomPinConstraint;

@end

@implementation BlockStackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // colors for our views, let's make this look nice
    _blockViewColors = @[
             [UIColor colorWithHexRGB:0x2196F3],
             [UIColor colorWithHexRGB:0xBF0C43],
             [UIColor colorWithHexRGB:0xF9BA15],
             [UIColor colorWithHexRGB:0x8EAC00],
             [UIColor colorWithHexRGB:0x127A97],
             [UIColor colorWithHexRGB:0x452B72],
             ];
    
    // scrollview init and layout
    _scrollView = [UIScrollView new];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    // auto-layout fill
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];
    
    // tap to add blocks
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addAnotherBlockViewToScrollView:)];
    [_scrollView addGestureRecognizer:tapGest];
    
    // add hint below the scroll view...
    UILabel *tapMeHint = [UILabel new];
    tapMeHint.text = @"Tap me!";
    tapMeHint.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:70];
    tapMeHint.textColor = _blockViewColors[3];
    tapMeHint.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:tapMeHint belowSubview:_scrollView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tapMeHint
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tapMeHint
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0 constant:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addAnotherBlockViewToScrollView:(UIGestureRecognizer *)recognizer
{
    NSInteger randColorIndex = ++_currentBlockViewColorIdx % _blockViewColors.count;
    UIView *blockView = [UIView new];
    blockView.backgroundColor = _blockViewColors[randColorIndex];
    blockView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:blockView];
    
    // we want the blocks to span the block - it's important to remember to pin to the scrollview's
    //  superview in this case.  Think of the scrollview's content as an infinite plane - it's ambiguous
    //  to pin to this planes edges...
    [_scrollView.superview addConstraint:[NSLayoutConstraint constraintWithItem:blockView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_scrollView.superview
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0 constant:0]];
    [_scrollView.superview addConstraint:[NSLayoutConstraint constraintWithItem:blockView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_scrollView.superview
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];

    
    // height will be arbitrary, we'll use a percentage of screen height
    [_scrollView.superview addConstraint:[NSLayoutConstraint constraintWithItem:blockView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_scrollView.superview
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:.3 constant:0]];
    
    if (_lastBlockView)
    {
        // pin under the last block
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_lastBlockView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:blockView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0]];
    }
    else
    {
        // pin to the top - might be able to pin to the top of the scroll view...
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:blockView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_scrollView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    }
    
    // remove the previous pin to the bottom of the scroll view's content area
    if (_bottomPinConstraint)
        [_scrollView removeConstraint:_bottomPinConstraint];
    
    _bottomPinConstraint = [NSLayoutConstraint constraintWithItem:blockView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_scrollView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0 constant:0];
    [_scrollView addConstraint:_bottomPinConstraint];
    
    // so we can pin the next block
    _lastBlockView = blockView;
    
    // unfortunate, we need to force a layout pass so we can measure correctly for scroll-to-bottom
    [_scrollView layoutIfNeeded];
    
    // scroll to bottom
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    if (0 < bottomOffset.y)
        [_scrollView setContentOffset:bottomOffset animated:YES];
}


@end
