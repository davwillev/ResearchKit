/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
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
#import "ORKLeftRightJudgementStep.h" // added
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"


static const CGFloat minimumButtonHeight = 80;
static const CGFloat buttonStackViewSpacing = 100.0;

@implementation ORKLeftRightJudgementContentView {
    UILabel *_imageLabel;
    UIStackView *_buttonStackView;
    UIImageView *_imageView; // added
    NSInteger _imageCount; //added
    UIImage *_image;
}
 
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setUpButtons];
        [self setUpImageView];
        [self setUpConstraints];
    }
    return self;
}

//- (ORKLeftRightJudgementStep *)leftRightJudgementStep {
//    return (ORKLeftRightJudgementStep *)self.step;
//}

- (void)setUpImageView {
    // compare these to original stroop task
    if (!_imageLabel) {
        [self displayImageLabel];
    }
    if (!_imageView) {
        [self displayNextImageInQueue]; // display first image
    }
}

- (void) displayImageLabel {
    _imageLabel = [UILabel new];
    _imageLabel.numberOfLines = 1;
    _imageLabel.textAlignment = NSTextAlignmentCenter;
    _imageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageLabel setFont:[UIFont systemFontOfSize:60]];
    [_imageLabel setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:_imageLabel];
}

- (void) displayNextImageInQueue {
    NSInteger imageQueueLength;
    imageQueueLength = 10; // ([self leftRightJudgementStep].numberOfAttempts); // TODO: need to insert number of attempts from step
    if (_imageCount <= (imageQueueLength - 1)) {
        NSArray *imageQueue;
        if (_imageCount == 0) { // allocate only once
            imageQueue = [self buildArrayOfRandomImagesOfLength:imageQueueLength];
        }
    _image = [imageQueue objectAtIndex:_imageCount];
    _imageView = [[UIImageView alloc] initWithImage:_image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit; // UIViewContentModeRedraw; 
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    }
    _imageCount++; // increment count every time method is called
}

- (NSArray *) buildArrayOfRandomImagesOfLength:(NSInteger)imageQueueLength {
    // Build array of pathnames to images in folder
    NSString *directory = @"Images/Hands";
    NSArray *pathArray = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"png" inDirectory:directory];
    //Create a shuffled copy of pathArray
    NSArray *shuffledPaths;
    shuffledPaths = [self shuffleArray:pathArray];
    // Create a mutable array to hold the images
    NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:imageQueueLength];
    // Fill the image queue array using pathnames
    for(NSUInteger i = 1; i <= imageQueueLength; i++) {
            UIImage *image = [UIImage imageWithContentsOfFile:[shuffledPaths objectAtIndex:(i - 1)]];
            [imageQueue addObject:image];
    }
    // Return the final array, by convention immutable (NSArray) so copy
    return [imageQueue copy];
}

- (NSArray *) shuffleArray:(NSArray*)array {
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:array];
    for (NSUInteger i = 0; i < [shuffledArray count] - 1; ++i) {
        NSInteger remainingCount = [shuffledArray count] - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    return [shuffledArray copy];
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

// added setter
- (void)setImageToDisplay:(UIImage *)imageToDisplay {
    [_imageView setImage:imageToDisplay];
    [self setNeedsDisplay];
}

- (void)setImageLabelText:(NSString *)imageLabelText {
    [_imageLabel setText:imageLabelText];
    [self setNeedsDisplay];
}

- (void)setImageLabelColor:(UIColor *)imageLabelColor {
    [_imageLabel setTextColor:imageLabelColor];
    [self setNeedsDisplay];
}

// added getters
- (UIImage *)imageToDisplay {
    return _imageView.image;
}

- (NSString *)imageLabelText {
    return _imageLabel.text;
}

- (UIColor *)imageLabelColor {
    return _imageLabel.textColor;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageLabel, _imageView, _buttonStackView);
    
    [constraints addObjectsFromArray: [NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|-[_imageView]-(==140)-|"
                                       options:(NSLayoutFormatOptions)0
                                       metrics: nil
                                       views:views]];
    
    [constraints addObjectsFromArray: [NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-(==30)-[_imageView]-(==30)-|"
                                       options:0
                                       metrics: nil
                                       views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==30)-[_imageLabel]-(>=10)-[_buttonStackView]-(==30)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
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

