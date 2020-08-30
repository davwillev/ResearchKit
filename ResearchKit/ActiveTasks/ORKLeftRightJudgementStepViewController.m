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

#import "ORKLeftRightJudgementStepViewController.h"
#import "ORKActiveStepView.h"
#import "ORKLeftRightJudgementContentView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKLeftRightJudgementResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKLeftRightJudgementStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKNavigationContainerView_Internal.h"


@interface ORKLeftRightJudgementStepViewController ()

@property (nonatomic, strong) ORKLeftRightJudgementContentView *leftRightJudgementContentView;
@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSDictionary *differentColorLabels;
@property (nonatomic) NSUInteger questionNumber;

@end


@implementation ORKLeftRightJudgementStepViewController {
    
    NSTimer *_nextQuestionTimer;
    NSMutableArray *_results;
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
    NSArray *_imageQueue;
    NSArray *_imagePaths;
    NSInteger _imageCount;
    NSString *_sideSelected;
    BOOL _stepMatch;
    
    // to be deleted once replaced
    UIColor *_red;
    UIColor *_green;
    UIColor *_blue;
    UIColor *_yellow;
    NSString *_redString;
    NSString *_greenString;
    NSString *_blueString;
    NSString *_yellowString;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKLeftRightJudgementStep *)leftRightJudgementStep {
    return (ORKLeftRightJudgementStep *)self.step;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // randomly present words with allocated colour
    _redString = ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_COLOR_RED", nil);
    _greenString = ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_COLOR_GREEN", nil);
    _blueString = ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_COLOR_BLUE", nil);
    _yellowString = ORKLocalizedString(@"LEFT_RIGHT_JUDGEMENT_COLOR_YELLOW", nil);
    _red = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    _green = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    _blue = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    _yellow = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    
    self.colors = @{
                    _redString: _red,
                    _blueString: _blue,
                    _yellowString: _yellow,
                    _greenString: _green,
                    };
    
    self.differentColorLabels = @{
                                  _redString: @[_blue, _green, _yellow],
                                  _blueString: @[_red, _green, _yellow,],
                                  _yellowString: @[_red, _blue, _green],
                                  _greenString: @[_red, _blue, _yellow],
                                  };
    
    // Assign question number
    self.questionNumber = 0;
    
    // Set up images
    _leftRightJudgementContentView = [ORKLeftRightJudgementContentView new];
    self.activeStepView.activeCustomView = _leftRightJudgementContentView;
    
    // Set up buttons
    [self.leftRightJudgementContentView.leftButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.leftRightJudgementContentView.rightButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
}
 
// Method to set action of buttons
- (void)buttonPressed:(id)sender {
    
    if (![self.leftRightJudgementContentView.imageLabelText isEqualToString:@" "]) {
        [self setButtonsDisabled];
        
        if (sender == self.leftRightJudgementContentView.leftButton) {
            _sideSelected = @"Left";
            NSString *sidePresented = [self sidePresented];
            if ([sidePresented isEqualToString:_sideSelected]) {
                _stepMatch = YES;
            } else {
                _stepMatch = NO;
            }
            [self createResult:[self nextFilenameInQueue] withSidePresented:sidePresented withSideSelected:_sideSelected toMatch:_stepMatch];
        }
        else if (sender == self.leftRightJudgementContentView.rightButton) {
            _sideSelected = @"Right";
            NSString *sidePresented = [self sidePresented];
            if ([sidePresented isEqualToString:_sideSelected]) {
                _stepMatch = YES;
            } else {
                _stepMatch = NO;
            }
            [self createResult:[self nextFilenameInQueue] withSidePresented:sidePresented withSideSelected:_sideSelected toMatch:_stepMatch];
        }
        self.leftRightJudgementContentView.imageLabelText = @" "; // delete this?
        
        _nextQuestionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector(startNextQuestionOrFinish)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    // _shouldIndicateFailure = YES; // based on reaction time
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //_shouldIndicateFailure = NO; // based on reaction time
}

- (void)stepDidFinish {
    [super stepDidFinish];
    [self.leftRightJudgementContentView finishStep:self];
    [self goForward];
}

- (void)start {
    [super start];
    [self startQuestion];
}
             
- (NSString *)sidePresented {
    NSString *fileName = [self nextFilenameInQueue];
    NSString *sidePresented;
    if ([fileName containsString:@"LH"]) {
        sidePresented = @"Left";
    } else if ([fileName containsString:@"RH"]) {
        sidePresented = @"Right";
    }
    return sidePresented;
}
             
- (UIImage *)nextImageInQueue {
    _imageQueue = [self arrayOfImagesForEachAttempt];
    UIImage *image = [_imageQueue objectAtIndex:_imageCount];
    _imageCount++; // increment after call
    return image;
}

- (NSString *)nextFilenameInQueue {
    NSString *path = [_imagePaths objectAtIndex:_imageCount];
    NSString *fileName = [[path lastPathComponent] stringByDeletingPathExtension];
    return fileName;
}

- (NSArray *)arrayOfImagesForEachAttempt {
    NSInteger imageQueueLength = ([self leftRightJudgementStep].numberOfAttempts);
    if (_imageCount == 0) { // build shuffled array only once
        _imagePaths = [self arrayOfShuffledPaths:@"png" fromDirectory:@"Images/Hands"];
    }
    NSMutableArray *imageQueueArray = [NSMutableArray arrayWithCapacity:imageQueueLength];
    // Allocate images
    for(NSUInteger i = 1; i <= imageQueueLength; i++) {
        UIImage *image = [UIImage imageWithContentsOfFile:[_imagePaths objectAtIndex:(i - 1)]];
        [imageQueueArray addObject:image];
    }
    return [imageQueueArray copy];
}

- (NSArray *)arrayOfShuffledPaths:(NSString*)type fromDirectory:(NSString*)directory {
    NSArray *pathArray = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:type inDirectory:directory];
    NSArray *shuffled;
    shuffled = [self shuffleArray:pathArray];
    return shuffled;
}

- (NSArray *)shuffleArray:(NSArray*)array {
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:array];
    for (NSUInteger i = 0; i < [shuffledArray count] - 1; ++i) {
        NSInteger remainingCount = [shuffledArray count] - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    return [shuffledArray copy];
}


#pragma mark - ORKResult

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    if (_results) {
         stepResult.results = [_results copy];
    }
    return stepResult;
}

- (void)createResult:(NSString *)imageName withSidePresented:(NSString *)sidePresented withSideSelected:(NSString *)sideSelected toMatch:(BOOL)stepMatch {
    ORKLeftRightJudgementResult *leftRightJudgementResult = [[ORKLeftRightJudgementResult alloc] initWithIdentifier:self.step.identifier];
    leftRightJudgementResult.startTime = _startTime;
    leftRightJudgementResult.endTime =  [NSProcessInfo processInfo].systemUptime;
    leftRightJudgementResult.stepTime = _endTime - _startTime;
    leftRightJudgementResult.imageName = imageName;
    leftRightJudgementResult.sidePresented = sidePresented;
    leftRightJudgementResult.sideSelected = sideSelected;
    leftRightJudgementResult.stepMatch = stepMatch;
    [_results addObject:leftRightJudgementResult];
}

- (void)startNextQuestionOrFinish {
    self.questionNumber = self.questionNumber + 1;
    if (self.questionNumber == ([self leftRightJudgementStep].numberOfAttempts)) {
        [self finish];
    } else {
        [self startQuestion];
    }
}

- (void)startQuestion {
    
    // display next image in queue
    UIImage *image = [self nextImageInQueue];
    self.leftRightJudgementContentView.imageToDisplay = image;

    // TODO: delete these
    int pattern = arc4random() % 2;
    if (pattern == 0) {
        int index = arc4random() % [self.colors.allKeys count];
        NSString *text = [self.colors.allKeys objectAtIndex:index];
        self.leftRightJudgementContentView.imageLabelText = text;
        UIColor *color = [self.colors valueForKey:text];
        self.leftRightJudgementContentView.imageLabelColor = color;
    }
    else {
        int index = arc4random() % [self.differentColorLabels.allKeys count];
        NSString *text = [self.differentColorLabels.allKeys objectAtIndex:index];
        self.leftRightJudgementContentView.imageLabelText = text;
        NSArray *colorArray = [self.differentColorLabels valueForKey:text];
        int randomColor = arc4random() % colorArray.count;
        UIColor *color = [colorArray objectAtIndex:randomColor];
        self.leftRightJudgementContentView.imageLabelColor = color;
    }
    
    // TODO: keep these
    [self setButtonsEnabled];
    _startTime = [NSProcessInfo processInfo].systemUptime;
}

- (void)setButtonsDisabled {
    [self.leftRightJudgementContentView.leftButton setEnabled: NO];
    [self.leftRightJudgementContentView.rightButton setEnabled: NO];
}

- (void)setButtonsEnabled {
    [self.leftRightJudgementContentView.leftButton setEnabled: YES];
    [self.leftRightJudgementContentView.rightButton setEnabled: YES];
}

@end
