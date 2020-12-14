/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
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


#import "ORKRangeOfMotionStep.h"
#import "ORKRangeOfMotionStepViewController.h"
#import "ORKHelpers_Internal.h"


@implementation ORKRangeOfMotionStep

BOOL questionOptionNotValid;

+ (Class)stepViewControllerClass {
    return [ORKRangeOfMotionStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier limbOption:(ORKPredefinedTaskLimbOption)limbOption {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldVibrateOnStart = YES;
        self.shouldPlaySoundOnStart = YES;
        self.shouldVibrateOnFinish = YES;
        self.shouldPlaySoundOnFinish = YES;
        self.shouldContinueOnFinish = YES;
        self.shouldStartTimerAutomatically = YES;
        self.limbOption = limbOption;
        self.movementOption = _movementOption;
        self.questionOption = _questionOption;
        self.locationOption = _locationOption;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (!(self.limbOption & ORKPredefinedTaskLimbOptionLeft) &&
        !(self.limbOption & ORKPredefinedTaskLimbOptionRight)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:ORKLocalizedString(@"LIMB_OPTION_ERROR", nil)
                                     userInfo:nil];
    }
    if (!(self.questionOption & ORKPredefinedTaskQuestionOptionPainBefore) && !(self.questionOption & ORKPredefinedTaskQuestionOptionPainDuring) && !(self.questionOption & ORKPredefinedTaskQuestionOptionPainAfter) &&
        !(self.questionOption == ORKPredefinedTaskQuestionOptionUnspecified)) {
        questionOptionNotValid = YES;
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:ORKLocalizedString(@"QUESTION_OPTION_ERROR", nil)
                                     userInfo:nil];
    }
    if (!(self.questionOption == ORKPredefinedTaskQuestionOptionUnspecified) && (!(questionOptionNotValid) && (self.locationOption == ORKPredefinedTaskLocationOptionUnspecified))) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:ORKLocalizedString(@"QUESTION_LOCATION_OPTION_ERROR", nil)
                                     userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRangeOfMotionStep *step = [super copyWithZone:zone];
    step.limbOption = self.limbOption;
    step.movementOption = self.movementOption;
    step.questionOption = self.questionOption;
    step.locationOption = self.locationOption;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, limbOption);
        ORK_DECODE_ENUM(aDecoder, movementOption);
        ORK_DECODE_ENUM(aDecoder, questionOption);
        ORK_DECODE_ENUM(aDecoder, locationOption);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, limbOption);
    ORK_ENCODE_ENUM(aCoder, movementOption);
    ORK_ENCODE_ENUM(aCoder, questionOption);
    ORK_ENCODE_ENUM(aCoder, locationOption);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.limbOption == castObject.limbOption) &&
            (self.movementOption == castObject.movementOption) &&
            (self.questionOption == castObject.questionOption) &&
            (self.locationOption == castObject.locationOption));
}

@end
