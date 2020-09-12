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

@property (nonatomic) NSUInteger questionNumber;

@end


@implementation ORKLeftRightJudgementStepViewController {
    
    NSTimer *_nextQuestionTimer;
    NSMutableArray *_results;
    NSTimeInterval _startTime;
    NSArray *_imageQueue;
    NSArray *_imagePaths;
    NSInteger _imageCount;
    NSInteger _leftCount;
    NSInteger _rightCount;
    NSInteger _leftSumCorrect;
    NSInteger _rightSumCorrect;
    double _leftPercentCorrect;
    double _rightPercentCorrect;
    double _meanLeftDuration;
    double _varianceLeftDuration;
    double _stdLeftDuration;
    double _prevMl;
    double _newMl;
    double _prevSl;
    double _newSl;
    double _meanRightDuration;
    double _varianceRightDuration;
    double _stdRightDuration;
    double _prevMr;
    double _newMr;
    double _prevSr;
    double _newSr;
    BOOL _match;
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
    _results = [NSMutableArray new];
    self.questionNumber = 0;
    
    _leftRightJudgementContentView = [ORKLeftRightJudgementContentView new];
    self.activeStepView.activeCustomView = _leftRightJudgementContentView;
    
    [self.leftRightJudgementContentView.leftButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.leftRightJudgementContentView.rightButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
}
 
- (void)buttonPressed:(id)sender {
    if (!(self.leftRightJudgementContentView.imageToDisplay == [UIImage imageNamed:@" "])) {
        [self setButtonsDisabled];
        NSString *sidePresented = [self sidePresented];
        NSTimeInterval endTime = [NSProcessInfo processInfo].systemUptime;
        double duration = (endTime - _startTime);
        
        // analyse durations for each side presented separately
        if ([sidePresented isEqualToString: @"Left"]) {
            // calculate mean and standard deviation of duration (using Welford's algorithm: Welford. (1962) Technometrics 4(3), 419-420)
            if (_leftCount == 1) {
                _prevMl = _newMl = duration;
                _prevSl = 0;
            } else {
                _newMl = _prevMl + (duration - _prevMl) / _leftCount;
                _newSl += _prevSl + (duration - _prevMl) * (duration - _newMl);
                _prevMl = _newMl;
            }
            _meanLeftDuration = (_leftCount > 0) ? _newMl : 0;
            _varianceLeftDuration = ((_leftCount > 1) ? _newSl / (_leftCount - 1) : 0);
            if (_varianceLeftDuration > 0) {
                _stdLeftDuration = sqrt(_varianceLeftDuration);
            }
        } else if ([sidePresented isEqualToString: @"Right"]) {
            // use Welford's algorithm
            if (_rightCount == 1) {
                _prevMr = _newMr = duration;
                _prevSr = 0;
            } else {
                _newMr = _prevMr + (duration - _prevMr) / _rightCount;
                _newSr += _prevSr + (duration - _prevMr) * (duration - _newMr);
                _prevMr = _newMr;
            }
            _meanRightDuration = (_rightCount > 0) ? _newMr : 0;
            _varianceRightDuration = ((_rightCount > 1) ? _newSr / (_rightCount - 1) : 0);
            if (_varianceRightDuration > 0) {
                _stdRightDuration = sqrt(_varianceRightDuration);
            }
        }
        // evaluate matches according to the button pressed
        NSString *sideSelected;
        NSString *orientation = [self orientationPresented];
        if (sender == self.leftRightJudgementContentView.leftButton) {
            sideSelected = @"Left";
            _match = ([sidePresented isEqualToString:sideSelected]) ? YES : NO;
            _leftSumCorrect = (_match) ? _leftSumCorrect + 1 : _leftSumCorrect;
            if (_leftCount > 0) { // prevent zero denominator
                _leftPercentCorrect = (100 * _leftSumCorrect) / _leftCount;
            }
            [self createResultfromImage:[self nextFileNameInQueue] inOrientation:orientation matching:_match sidePresented:sidePresented withSideSelected:sideSelected inDuration:duration];
        }
        else if (sender == self.leftRightJudgementContentView.rightButton) {
            sideSelected = @"Right";
            _match = ([sidePresented isEqualToString:sideSelected]) ? YES : NO;
            _rightSumCorrect = (_match) ? _rightSumCorrect + 1 : _rightSumCorrect;
            if (_rightCount > 0) { // prevent zero denominator
                _rightPercentCorrect = (100 * _rightSumCorrect) / _rightCount;
            }
            [self createResultfromImage:[self nextFileNameInQueue] inOrientation:orientation matching:_match sidePresented:sidePresented withSideSelected:sideSelected inDuration:duration];
        }
    self.leftRightJudgementContentView.imageToDisplay = [UIImage imageNamed:@" "];
        
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
    // _shouldIndicateFailure = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //_shouldIndicateFailure = NO;
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
    NSString *fileName = [self nextFileNameInQueue];
    NSString *sidePresented;
    if ([fileName containsString:@"LH"]) {
        sidePresented = @"Left";
        _leftCount ++;
    } else if ([fileName containsString:@"RH"]) {
        sidePresented = @"Right";
        _rightCount ++;
    }
    return sidePresented;
}

- (NSString *)orientationPresented {
    NSString *fileName = [self nextFileNameInQueue];
    NSString *anglePresented;
    if ([fileName containsString:@"330y"] ||
        [fileName containsString:@"000y"] ||
        [fileName containsString:@"030y"]) {
        anglePresented = @"Anterior";
    } else if ([fileName containsString:@"060y"] ||
               [fileName containsString:@"090y"] ||
               [fileName containsString:@"120y"]) {
        anglePresented = @"Medial";
    } else if ([fileName containsString:@"150y"] ||
               [fileName containsString:@"180y"] ||
               [fileName containsString:@"210y"]) {
        anglePresented = @"Posterior";
    } else if ([fileName containsString:@"240y"] ||
               [fileName containsString:@"270y"] ||
               [fileName containsString:@"300y"]) {
        anglePresented = @"Lateral";
    }
    return anglePresented;
}
             
- (UIImage *)nextImageInQueue {
    _imageQueue = [self arrayOfImagesForEachAttempt];
    UIImage *image = [_imageQueue objectAtIndex:_imageCount];
    _imageCount++; // increment when called
    return image;
}

- (NSString *)nextFileNameInQueue {
    NSString *path = [_imagePaths objectAtIndex:_imageCount];
    NSString *fileName = [[path lastPathComponent] stringByDeletingPathExtension];
    return fileName;
}

- (NSString *)getDirectoryForImages {
    NSString *directory;
    if ([self leftRightJudgementStep].imageOption == ORKPredefinedTaskImageOptionHands) {
        directory = @"Images/Hands";
    } else if ([self leftRightJudgementStep].imageOption == ORKPredefinedTaskImageOptionFeet) {
        directory = @"Images/Feet";
    }
    return directory;
}

- (NSArray *)arrayOfImagesForEachAttempt {
    NSInteger imageQueueLength = ([self leftRightJudgementStep].numberOfAttempts);
    NSString *directory = [self getDirectoryForImages];
    if (_imageCount == 0) { // build shuffled array only once
        _imagePaths = [self arrayOfShuffledPaths:@"png" fromDirectory:directory];
    }
    NSMutableArray *imageQueueArray = [NSMutableArray arrayWithCapacity:imageQueueLength];
    // Allocate images
    for(NSUInteger i = 1; i <= imageQueueLength; i++) {
        UIImage *image = [UIImage imageWithContentsOfFile:[_imagePaths objectAtIndex:(i)]];
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
    for (NSUInteger i = 0; i < ([shuffledArray count]) - 1; ++i) {
        NSInteger remainingCount = [shuffledArray count] - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
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

- (void)createResultfromImage:(NSString *)imageName inOrientation:(NSString *)orientation matching:(BOOL)match sidePresented:(NSString *)sidePresented withSideSelected:(NSString *)sideSelected inDuration:(double)duration {
    ORKLeftRightJudgementResult *leftRightJudgementResult = [[ORKLeftRightJudgementResult alloc] initWithIdentifier:self.step.identifier];
    // image results
    leftRightJudgementResult.imageNumber = _imageCount;
    leftRightJudgementResult.imageName = imageName;
    leftRightJudgementResult.orientationPresented = orientation;
    leftRightJudgementResult.imageDuration = duration;
    leftRightJudgementResult.sidePresented = sidePresented;
    leftRightJudgementResult.sideSelected = sideSelected;
    leftRightJudgementResult.sideMatch = match;
    // task results
    leftRightJudgementResult.leftImages = _leftCount;
    leftRightJudgementResult.rightImages = _rightCount;
    leftRightJudgementResult.leftPercentCorrect = _leftPercentCorrect;
    leftRightJudgementResult.rightPercentCorrect = _rightPercentCorrect;
    leftRightJudgementResult.leftMeanDuration = _meanLeftDuration;
    leftRightJudgementResult.rightMeanDuration = _meanRightDuration;
    leftRightJudgementResult.leftSDDuration = _stdLeftDuration;;
    leftRightJudgementResult.rightSDDuration = _stdRightDuration;;
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
    UIImage *image = [self nextImageInQueue];
    self.leftRightJudgementContentView.imageToDisplay = image;
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
