/*
 Copyright (c) 2020, Dr David W. Evans. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKLeftRightJudgementContentView.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"


static const CGFloat minimumButtonHeight = 80;
static const CGFloat buttonStackViewSpacing = 100.0;

@implementation ORKLeftRightJudgementContentView {
    UIStackView *_buttonStackView;
    UIImageView *_imageView;
}
 
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setUpImageView];
        [self setUpButtons];
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpImageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        //_imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];
    }
}

- (void)setUpButtons {
    _leftButton = [[ORKBorderedButton alloc] init];
    _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_leftButton setTitle:ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_LEFT_BUTTON", nil) forState:UIControlStateNormal];
    
    _rightButton = [[ORKBorderedButton alloc] init];
    _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightButton setTitle:ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_RIGHT_BUTTON", nil) forState:UIControlStateNormal];
    
    if (!_buttonStackView) {
        _buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_leftButton, _rightButton]];

    }
    _buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonStackView.spacing = buttonStackViewSpacing;
    _buttonStackView.axis = UILayoutConstraintAxisHorizontal;

    [self addSubview:_buttonStackView];
}

- (void)setImageToDisplay:(UIImage *)imageToDisplay {
    [_imageView setImage: imageToDisplay];
    [self setNeedsDisplay];
}

- (UIImage *)imageToDisplay {
    return _imageView.image;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _buttonStackView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-(==30)-[_imageView]-(>=10)-[_buttonStackView]-(==30)-|"
                                      options:NSLayoutFormatAlignAllCenterX
                                      metrics:nil
                                      views:views]];
    
    [constraints addObjectsFromArray: [NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-(==30)-[_imageView]-(==30)-|"
                                       options:0
                                       metrics: nil
                                       views:views]];
    
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_buttonStackView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:_buttonStackView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0]
                                       ]];

    for (ORKBorderedButton *button in @[_leftButton, _rightButton]) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:button
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:button
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0.0]];
    }

    [self addConstraints:constraints];
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
