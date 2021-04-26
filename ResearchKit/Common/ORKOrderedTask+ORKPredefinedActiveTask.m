/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2016, Sage Bionetworks
 
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


#import "ORKOrderedTask+ORKPredefinedActiveTask.h"
#import "ORKOrderedTask_Private.h"

#import "ORKAudioStepViewController.h"
#import "ORKAmslerGridStepViewController.h"
#import "ORKCountdownStepViewController.h"
#import "ORKTouchAnywhereStepViewController.h"
#import "ORKFitnessStepViewController.h"
#import "ORKToneAudiometryStepViewController.h"
#import "ORKSpatialSpanMemoryStepViewController.h"
#import "ORKSpeechRecognitionStepViewController.h"
#import "ORKStroopStepViewController.h"
#import "ORKWalkingTaskStepViewController.h"

#import "ORKAccelerometerRecorder.h"
#import "ORKActiveStep_Internal.h"
#import "ORKAmslerGridStep.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAudioLevelNavigationRule.h"
#import "ORKAudioRecorder.h"
#import "ORKAudioStep.h"
#import "ORKCompletionStep.h"
#import "ORKCountdownStep.h"
#import "ORKEnvironmentSPLMeterStep.h"
#import "ORKHolePegTestPlaceStep.h"
#import "ORKHolePegTestRemoveStep.h"
#import "ORKTouchAnywhereStep.h"
#import "ORKFitnessStep.h"
#import "ORKFormStep.h"
#import "ORKStandingBendingRangeOfMotionStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKPSATStep.h"
#import "ORKQuestionStep.h"
#import "ORKReactionTimeStep.h"
#import "ORKNormalizedReactionTimeStep.h"
#import "ORKSpatialSpanMemoryStep.h"
#import "ORKSpeechRecognitionStep.h"
#import "ORKStep_Private.h"
#import "ORKStroopStep.h"
#import "ORKTappingIntervalStep.h"
#import "ORKTimedWalkStep.h"
#import "ORKToneAudiometryStep.h"
#import "ORKTowerOfHanoiStep.h"
#import "ORKTrailmakingStep.h"
#import "ORKVisualConsentStep.h"
#import "ORKRangeOfMotionStep.h"
#import "ORKShoulderRangeOfMotionStep.h"
#import "ORKWaitStep.h"
#import "ORKWalkingTaskStep.h"
#import "ORKResultPredicate.h"
#import "ORKSpeechInNoiseStep.h"
#import "ORKdBHLToneAudiometryStep.h"
#import "ORKdBHLToneAudiometryOnboardingStep.h"
#import "ORKSkin.h"

#import "ORKHelpers_Internal.h"
#import "UIImage+ResearchKit.h"
#import <limits.h>


ORKTaskProgress ORKTaskProgressMake(NSUInteger current, NSUInteger total) {
    return (ORKTaskProgress){.current=current, .total=total};
}

#pragma mark - Predefined

NSString *const ORKInstruction0StepIdentifier = @"instruction";
NSString *const ORKInstruction1StepIdentifier = @"instruction1";
NSString *const ORKInstruction2StepIdentifier = @"instruction2";
NSString *const ORKInstruction3StepIdentifier = @"instruction3";
NSString *const ORKInstruction4StepIdentifier = @"instruction4";
NSString *const ORKInstruction5StepIdentifier = @"instruction5";
NSString *const ORKInstruction6StepIdentifier = @"instruction6";
NSString *const ORKInstruction7StepIdentifier = @"instruction7";

NSString *const ORKCountdownStepIdentifier = @"countdown";
NSString *const ORKCountdown1StepIdentifier = @"countdown1";
NSString *const ORKCountdown2StepIdentifier = @"countdown2";
NSString *const ORKCountdown3StepIdentifier = @"countdown3";
NSString *const ORKCountdown4StepIdentifier = @"countdown4";
NSString *const ORKCountdown5StepIdentifier = @"countdown5";

NSString *const ORKEditSpeechTranscript0StepIdentifier = @"editSpeechTranscript0";

NSString *const ORKConclusionStepIdentifier = @"conclusion";

NSString *const ORKActiveTaskLeftLimbIdentifier = @"left";
NSString *const ORKActiveTaskRightLimbIdentifier = @"right";

NSString *const ORKActiveTaskForwardBendingIdentifier = @"forward";
NSString *const ORKActiveTaskBackwardBendingIdentifier = @"backward";
NSString *const ORKActiveTaskRightBendingIdentifier = @"right";
NSString *const ORKActiveTaskLeftBendingIdentifier = @"left";

NSString *const ORKActiveTaskLeftHandIdentifier = @"left";
NSString *const ORKActiveTaskMostAffectedHandIdentifier = @"mostAffected";
NSString *const ORKActiveTaskRightHandIdentifier = @"right";
NSString *const ORKActiveTaskSkipHandStepIdentifier = @"skipHand";

NSString *const ORKTouchAnywhereStepIdentifier = @"touch.anywhere";

NSString *const ORKAudioRecorderIdentifier = @"audio";
NSString *const ORKAccelerometerRecorderIdentifier = @"accelerometer";
NSString *const ORKStreamingAudioRecorderIdentifier = @"streamingAudio";
NSString *const ORKPedometerRecorderIdentifier = @"pedometer";
NSString *const ORKDeviceMotionRecorderIdentifier = @"deviceMotion";
NSString *const ORKLocationRecorderIdentifier = @"location";
NSString *const ORKHeartRateRecorderIdentifier = @"heartRate";

void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

@implementation ORKOrderedTask (ORKMakeTaskUtilities)

+ (ORKCompletionStep *)makeCompletionStep {
    ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKConclusionStepIdentifier];
    step.title = ORKLocalizedString(@"TASK_COMPLETE_TITLE", nil);
    step.text = ORKLocalizedString(@"TASK_COMPLETE_TEXT", nil);
    step.shouldTintImages = YES;
    return step;
}

+ (NSDateComponentsFormatter *)textTimeFormatter {
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
    
    // Exception list: Korean, Chinese (all), Thai, and Vietnamese.
    NSArray *nonSpelledOutLanguages = @[@"ko", @"zh", @"th", @"vi", @"ja"];
    NSString *currentLanguage = [[NSBundle mainBundle] preferredLocalizations].firstObject;
    NSString *currentLanguageCode = [NSLocale componentsFromLocaleIdentifier:currentLanguage][NSLocaleLanguageCode];
    if ((currentLanguageCode != nil) && [nonSpelledOutLanguages containsObject:currentLanguageCode]) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    }
    
    formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    return formatter;
}

@end


@implementation ORKOrderedTask (ORKPredefinedActiveTask)

#pragma mark - AmslerGridTask

NSString *const ORKAmslerGridStepLeftIdentifier = @"amsler.grid.left";
NSString *const ORKAmslerGridStepRightIdentifier = @"amsler.grid.right";
NSString *const ORKAmslerGridCalibrationLeftIdentifier = @"amsler.grid.calibration.left";
NSString *const ORKAmslerGridCalibrationRightIdentifier = @"amsler.grid.calibration.Right";

+ (ORKOrderedTask *)amslerGridTaskWithIdentifier:(NSString *)identifier
                                   intendedUseDescription:(NSString *)intendedUseDescription
                                                  options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    UIColor *tintColor = [[[UIApplication sharedApplication] delegate] window].tintColor ? : ORKColor(ORKBlueHighlightColorKey);

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"AMSLER_GRID_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"AMSLER_GRID_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"amslerGrid" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            
            
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"AMSLER_GRID_TITLE", nil);
            step.text = ORKLocalizedString(@"AMSLER_GRID_INSTRUCTION_TEXT", nil);

            NSString *leftEye = ORKLocalizedString(@"AMSLER_GRID_LEFT_EYE", nil);
            NSString *detailText = [@"\n" stringByAppendingString:[NSString stringWithFormat:ORKLocalizedString(@"AMSLER_GRID_INSTRUCTION_DETAIL_TEXT", nil), leftEye]];

            NSMutableAttributedString *attributedDetailText = [[NSMutableAttributedString alloc] initWithString:detailText];
            [attributedDetailText addAttribute:NSForegroundColorAttributeName
                                         value:tintColor
                                         range:[detailText rangeOfString:leftEye]];
            step.attributedDetailText = attributedDetailText;
            
            step.image = [UIImage imageNamed:@"amslerGrid" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    {
        ORKAmslerGridStep *step = [[ORKAmslerGridStep alloc] initWithIdentifier:ORKAmslerGridStepLeftIdentifier];
        step.eyeSide = ORKAmslerGridEyeSideLeft;
        ORKStepArrayAddStep(steps, step);
    }
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
            step.title = ORKLocalizedString(@"AMSLER_GRID_TITLE", nil);
            step.text = ORKLocalizedString(@"AMSLER_GRID_INSTRUCTION_TEXT", nil);
            NSString *rightEye = ORKLocalizedString(@"AMSLER_GRID_RIGHT_EYE", nil);
            NSString *detailText = [@"\n" stringByAppendingString:[NSString stringWithFormat:ORKLocalizedString(@"AMSLER_GRID_INSTRUCTION_DETAIL_TEXT", nil), rightEye]];
            
            NSMutableAttributedString *attributedDetailText = [[NSMutableAttributedString alloc] initWithString:detailText];
            [attributedDetailText addAttribute:NSForegroundColorAttributeName
                                         value:tintColor
                                         range:[detailText rangeOfString:rightEye]];
            step.attributedDetailText = attributedDetailText;
            step.image = [UIImage imageNamed:@"amslerGrid" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    {
        ORKAmslerGridStep *step = [[ORKAmslerGridStep alloc] initWithIdentifier:ORKAmslerGridStepRightIdentifier];
        step.eyeSide = ORKAmslerGridEyeSideRight;
        ORKStepArrayAddStep(steps, step);
    }
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *completionStep = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, completionStep);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

#pragma mark - holePegTestTask

NSString *const ORKHolePegTestDominantPlaceStepIdentifier = @"hole.peg.test.dominant.place";
NSString *const ORKHolePegTestDominantRemoveStepIdentifier = @"hole.peg.test.dominant.remove";
NSString *const ORKHolePegTestNonDominantPlaceStepIdentifier = @"hole.peg.test.non.dominant.place";
NSString *const ORKHolePegTestNonDominantRemoveStepIdentifier = @"hole.peg.test.non.dominant.remove";

+ (ORKNavigableOrderedTask *)holePegTestTaskWithIdentifier:(NSString *)identifier
                                    intendedUseDescription:(nullable NSString *)intendedUseDescription
                                              dominantHand:(ORKBodySagittal)dominantHand
                                              numberOfPegs:(int)numberOfPegs
                                                 threshold:(double)threshold
                                                   rotated:(BOOL)rotated
                                                 timeLimit:(NSTimeInterval)timeLimit
                                                   options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    BOOL dominantHandLeft = (dominantHand == ORKBodySagittalLeft);
    NSTimeInterval stepDuration = (timeLimit == 0) ? CGFLOAT_MAX : timeLimit;
    NSString *pegs = [NSNumberFormatter localizedStringFromNumber:@(numberOfPegs) numberStyle:NSNumberFormatterNoStyle];

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = intendedUseDescription;
            step.detailText = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_INTRO_TEXT_%@", nil), pegs];
            step.image = [UIImage imageNamed:@"phoneholepeg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = dominantHandLeft ? [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_INTRO_TEXT_2_LEFT_HAND_FIRST_%@", nil), pegs, pegs] : [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_INTRO_TEXT_2_RIGHT_HAND_FIRST_%@", nil), pegs, pegs];
            step.detailText = ORKLocalizedString(@"HOLE_PEG_TEST_CALL_TO_ACTION", nil);
            UIImage *image1 = [UIImage imageNamed:@"holepegtest1" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *image2 = [UIImage imageNamed:@"holepegtest2" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *image3 = [UIImage imageNamed:@"holepegtest3" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *image4 = [UIImage imageNamed:@"holepegtest4" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *image5 = [UIImage imageNamed:@"holepegtest5" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *image6 = [UIImage imageNamed:@"holepegtest6" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.image = [UIImage animatedImageWithImages:@[image1, image2, image3, image4, image5, image6] duration:4];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        {
            ORKHolePegTestPlaceStep *step = [[ORKHolePegTestPlaceStep alloc] initWithIdentifier:ORKHolePegTestDominantPlaceStepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = [dominantHandLeft ? ORKLocalizedString(@"HOLE_PEG_TEST_PLACE_INSTRUCTION_LEFT_HAND", nil) : ORKLocalizedString(@"HOLE_PEG_TEST_PLACE_INSTRUCTION_RIGHT_HAND", nil) stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.movingDirection = dominantHand;
            step.dominantHandTested = YES;
            step.numberOfPegs = numberOfPegs;
            step.threshold = threshold;
            step.rotated = rotated;
            step.shouldTintImages = YES;
            step.stepDuration = stepDuration;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKHolePegTestRemoveStep *step = [[ORKHolePegTestRemoveStep alloc] initWithIdentifier:ORKHolePegTestDominantRemoveStepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = [dominantHandLeft ? ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_LEFT_HAND", nil) : ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_RIGHT_HAND", nil) stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.movingDirection = (dominantHand == ORKBodySagittalLeft) ? ORKBodySagittalRight : ORKBodySagittalLeft;
            step.dominantHandTested = YES;
            step.numberOfPegs = numberOfPegs;
            step.threshold = threshold;
            step.shouldTintImages = YES;
            step.stepDuration = stepDuration;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKHolePegTestPlaceStep *step = [[ORKHolePegTestPlaceStep alloc] initWithIdentifier:ORKHolePegTestNonDominantPlaceStepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = [dominantHandLeft ? ORKLocalizedString(@"HOLE_PEG_TEST_PLACE_INSTRUCTION_RIGHT_HAND", nil) : ORKLocalizedString(@"HOLE_PEG_TEST_PLACE_INSTRUCTION_LEFT_HAND", nil) stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.movingDirection = (dominantHand == ORKBodySagittalLeft) ? ORKBodySagittalRight : ORKBodySagittalLeft;
            step.dominantHandTested = NO;
            step.numberOfPegs = numberOfPegs;
            step.threshold = threshold;
            step.rotated = rotated;
            step.shouldTintImages = YES;
            step.stepDuration = stepDuration;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKHolePegTestRemoveStep *step = [[ORKHolePegTestRemoveStep alloc] initWithIdentifier:ORKHolePegTestNonDominantRemoveStepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"HOLE_PEG_TEST_TITLE_%@", nil), pegs];
            step.text = [dominantHandLeft ? ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_RIGHT_HAND", nil) : ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_LEFT_HAND", nil) stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.movingDirection = dominantHand;
            step.dominantHandTested = NO;
            step.numberOfPegs = numberOfPegs;
            step.threshold = threshold;
            step.shouldTintImages = YES;
            step.stepDuration = stepDuration;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    
    // The task is actually dynamic. The direct navigation rules are used for skipping the peg
    // removal steps if the user doesn't succeed in placing all the pegs in the allotted time
    // (the rules are removed from `ORKHolePegTestPlaceStepViewController` if she succeeds).
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    ORKStepNavigationRule *navigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKHolePegTestNonDominantPlaceStepIdentifier];
    [task setNavigationRule:navigationRule forTriggerStepIdentifier:ORKHolePegTestDominantPlaceStepIdentifier];
    navigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKConclusionStepIdentifier];
    [task setNavigationRule:navigationRule forTriggerStepIdentifier:ORKHolePegTestNonDominantPlaceStepIdentifier];
    
    return task;
}


#pragma mark - twoFingerTappingInterval

NSString *const ORKTappingStepIdentifier = @"tapping";

+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                        intendedUseDescription:(NSString *)intendedUseDescription
                                                      duration:(NSTimeInterval)duration
                                                   handOptions:(ORKPredefinedTaskHandOption)handOptions
                                                       options:(ORKPredefinedTaskOption)options {
    
    NSString *durationString = [ORKDurationStringFormatter() stringFromTimeInterval:duration];
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TAPPING_INTRO_TEXT", nil);
            
            NSString *imageName = @"phonetapping";
            if (![[NSLocale preferredLanguages].firstObject hasPrefix:@"en"]) {
                imageName = [imageName stringByAppendingString:@"_notap"];
            }
            step.image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // Setup which hand to start with and how many hands to add based on the handOptions parameter
    // Hand order is randomly determined.
    NSUInteger handCount = ((handOptions & ORKPredefinedTaskHandOptionBoth) == ORKPredefinedTaskHandOptionBoth) ? 2 : 1;
    BOOL undefinedHand = (handOptions == 0);
    BOOL rightHand;
    switch (handOptions) {
        case ORKPredefinedTaskHandOptionLeft:
            rightHand = NO; break;
        case ORKPredefinedTaskHandOptionRight:
        case ORKPredefinedTaskHandOptionUnspecified:
            rightHand = YES; break;
        default:
            rightHand = (arc4random()%2 == 0); break;
        }
        
    for (NSUInteger hand = 1; hand <= handCount; hand++) {
        
        NSString * (^appendIdentifier) (NSString *) = ^ (NSString * identifier) {
            if (undefinedHand) {
                return identifier;
            } else {
                NSString *handIdentifier = rightHand ? ORKActiveTaskRightHandIdentifier : ORKActiveTaskLeftHandIdentifier;
                return [NSString stringWithFormat:@"%@.%@", identifier, handIdentifier];
            }
        };
        
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction1StepIdentifier)];
            
            // Set the title based on the hand
            if (undefinedHand) {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE_RIGHT", nil);
            } else {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE_LEFT", nil);
            }
            
            // Set the instructions for the tapping test screen that is displayed prior to each hand test
            NSString *restText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_REST_PHONE", nil);
            NSString *tappingTextFormat = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_FORMAT", nil);
            NSString *tappingText = [NSString localizedStringWithFormat:tappingTextFormat, durationString];
            NSString *handText = nil;
            
            if (hand == 1) {
                if (undefinedHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_MOST_AFFECTED", nil);
                } else if (rightHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_RIGHT_FIRST", nil);
                } else {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_LEFT_FIRST", nil);
                }
            } else {
                if (rightHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_RIGHT_SECOND", nil);
                } else {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_LEFT_SECOND", nil);
                }
            }
            
            step.text = [NSString localizedStringWithFormat:@"%@ %@ %@", restText, handText, tappingText];
            
            // Continue button will be different from first hand and second hand
            if (hand == 1) {
                step.detailText = ORKLocalizedString(@"TAPPING_CALL_TO_ACTION", nil);
            } else {
                step.detailText = ORKLocalizedString(@"TAPPING_CALL_TO_ACTION_NEXT", nil);
            }
            
            // Set the image
            UIImage *im1 = [UIImage imageNamed:@"handtapping01" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *im2 = [UIImage imageNamed:@"handtapping02" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *imageAnimation = [UIImage animatedImageWithImages:@[im1, im2] duration:1];
            
            if (rightHand || undefinedHand) {
                step.image = imageAnimation;
            } else {
                step.image = [imageAnimation ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    
        // TAPPING STEP
    {
        NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
        if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                      frequency:100]];
        }
        
            ORKTappingIntervalStep *step = [[ORKTappingIntervalStep alloc] initWithIdentifier:appendIdentifier(ORKTappingStepIdentifier)];
            step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);

            if (undefinedHand) {
                step.text = ORKLocalizedString(@"TAPPING_INSTRUCTION", nil);
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TAPPING_INSTRUCTION_RIGHT", nil);
            } else {
                step.text = ORKLocalizedString(@"TAPPING_INSTRUCTION_LEFT", nil);
            }
            if (UIAccessibilityIsVoiceOverRunning()) {
                step.text = [NSString stringWithFormat:ORKLocalizedString(@"AX_TAPPING_INSTRUCTION_VOICEOVER", nil), step.text];
            }
            step.stepDuration = duration;
            step.shouldContinueOnFinish = YES;
            step.recorderConfigurations = recorderConfigurations;
            step.optional = (handCount == 2);
            
            ORKStepArrayAddStep(steps, step);
        }
        
        // Flip to the other hand (ignored if handCount == 1)
        rightHand = !rightHand;
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:[steps copy]];
    
    return task;
}


#pragma mark - audioTask

NSString *const ORKAudioStepIdentifier = @"audio";
NSString *const ORKAudioTooLoudStepIdentifier = @"audio.tooloud";

+ (ORKNavigableOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                   speechInstruction:(nullable NSString *)speechInstruction
                              shortSpeechInstruction:(nullable NSString *)shortSpeechInstruction
                                            duration:(NSTimeInterval)duration
                                   recordingSettings:(nullable NSDictionary *)recordingSettings
                                     checkAudioLevel:(BOOL)checkAudioLevel
                                             options:(ORKPredefinedTaskOption)options {

    recordingSettings = recordingSettings ? : @{ AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                 AVNumberOfChannelsKey : @(2),
                                                AVSampleRateKey: @(44100.0) };
    
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"AUDIO_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phonewaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
            step.text = speechInstruction ? : ORKLocalizedString(@"AUDIO_INTRO_TEXT",nil);
            step.detailText = ORKLocalizedString(@"AUDIO_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonesoundwaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);

        // Collect audio during the countdown step too, to provide a baseline.
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:ORKAudioRecorderIdentifier
                                                                                 recorderSettings:recordingSettings]];
        
        // If checking the sound level then add text indicating that's what is happening
        if (checkAudioLevel) {
            step.text = ORKLocalizedString(@"AUDIO_LEVEL_CHECK_LABEL", nil);
        }
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (checkAudioLevel) {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKAudioTooLoudStepIdentifier];
        step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
        step.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_MESSAGE", nil);
        step.detailText = ORKLocalizedString(@"AUDIO_TOO_LOUD_ACTION_NEXT", nil);
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:ORKAudioStepIdentifier];
        step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
        step.text = shortSpeechInstruction ? : ORKLocalizedString(@"AUDIO_INSTRUCTION", nil);
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:ORKAudioRecorderIdentifier
                                                                                 recorderSettings:recordingSettings]];
        step.stepDuration = duration;
        step.shouldContinueOnFinish = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    if (checkAudioLevel) {
    
        // Add rules to check for audio and fail, looping back to the countdown step if required
        ORKAudioLevelNavigationRule *audioRule = [[ORKAudioLevelNavigationRule alloc] initWithAudioLevelStepIdentifier:ORKCountdownStepIdentifier destinationStepIdentifier:ORKAudioStepIdentifier recordingSettings:recordingSettings];
        ORKDirectStepNavigationRule *loopRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKCountdownStepIdentifier];
    
        [task setNavigationRule:audioRule forTriggerStepIdentifier:ORKCountdownStepIdentifier];
        [task setNavigationRule:loopRule forTriggerStepIdentifier:ORKAudioTooLoudStepIdentifier];
    }
    
    return task;
}


#pragma mark - fitnessCheckTask

NSString *const ORKFitnessWalkStepIdentifier = @"fitness.walk";
NSString *const ORKFitnessRestStepIdentifier = @"fitness.rest";

+ (ORKOrderedTask *)fitnessCheckTaskWithIdentifier:(NSString *)identifier
                           intendedUseDescription:(NSString *)intendedUseDescription
                                     walkDuration:(NSTimeInterval)walkDuration
                                     restDuration:(NSTimeInterval)restDuration
                                          options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = intendedUseDescription ? : [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            step.image = [UIImage imageNamed:@"heartbeat" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_2_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration], [formatter stringFromTimeInterval:restDuration]];
            step.image = [UIImage imageNamed:@"walkingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    {
        if (walkDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeLocation & options)) {
                [recorderConfigurations addObject:[[ORKLocationRecorderConfiguration alloc] initWithIdentifier:ORKLocationRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:ORKHeartRateRecorderIdentifier
                                                                                                      healthQuantityType:heartRateType unit:bpmUnit]];
            }
            ORKFitnessStep *fitnessStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessWalkStepIdentifier];
            fitnessStep.stepDuration = walkDuration;
            fitnessStep.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            fitnessStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_WALK_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            fitnessStep.spokenInstruction = fitnessStep.text;
            fitnessStep.recorderConfigurations = recorderConfigurations;
            fitnessStep.shouldContinueOnFinish = YES;
            fitnessStep.optional = NO;
            fitnessStep.shouldStartTimerAutomatically = YES;
            fitnessStep.shouldTintImages = YES;
            fitnessStep.image = [UIImage imageNamed:@"walkingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            fitnessStep.shouldVibrateOnStart = YES;
            fitnessStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, fitnessStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:ORKHeartRateRecorderIdentifier
                                                                                                      healthQuantityType:heartRateType unit:bpmUnit]];
            }
            
            ORKFitnessStep *stillStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessRestStepIdentifier];
            stillStep.stepDuration = restDuration;
            stillStep.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            stillStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_SIT_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:restDuration]];
            stillStep.spokenInstruction = stillStep.text;
            stillStep.recorderConfigurations = recorderConfigurations;
            stillStep.shouldContinueOnFinish = YES;
            stillStep.optional = NO;
            stillStep.shouldStartTimerAutomatically = YES;
            stillStep.shouldTintImages = YES;
            stillStep.image = [UIImage imageNamed:@"sittingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            stillStep.shouldVibrateOnStart = YES;
            stillStep.shouldPlaySoundOnStart = YES;
            stillStep.shouldPlaySoundOnFinish = YES;
            stillStep.shouldVibrateOnFinish = YES;
            
            ORKStepArrayAddStep(steps, stillStep);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}


#pragma mark - shortWalkTask

NSString *const ORKShortWalkOutboundStepIdentifier = @"walking.outbound";
NSString *const ORKShortWalkReturnStepIdentifier = @"walking.return";
NSString *const ORKShortWalkRestStepIdentifier = @"walking.rest";

+ (ORKOrderedTask *)shortWalkTaskWithIdentifier:(NSString *)identifier
                         intendedUseDescription:(NSString *)intendedUseDescription
                            numberOfStepsPerLeg:(NSInteger)numberOfStepsPerLeg
                                   restDuration:(NSTimeInterval)restDuration
                                        options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"WALK_INTRO_TEXT", nil);
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_INTRO_2_TEXT_%ld", nil),numberOfStepsPerLeg];
            step.detailText = ORKLocalizedString(@"WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"pocket" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkOutboundStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            walkingStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_OUTBOUND_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.text;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.optional = NO;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkReturnStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            walkingStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_RETURN_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.text;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.optional = NO;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKFitnessStep *activeStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKShortWalkRestStepIdentifier];
            activeStep.recorderConfigurations = recorderConfigurations;
            NSString *durationString = [formatter stringFromTimeInterval:restDuration];
            activeStep.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            activeStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_STAND_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.spokenInstruction = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_STAND_VOICE_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.shouldStartTimerAutomatically = YES;
            activeStep.stepDuration = restDuration;
            activeStep.shouldContinueOnFinish = YES;
            activeStep.optional = NO;
            activeStep.shouldVibrateOnStart = YES;
            activeStep.shouldPlaySoundOnStart = YES;
            activeStep.shouldVibrateOnFinish = YES;
            activeStep.shouldPlaySoundOnFinish = YES;
            
            ORKStepArrayAddStep(steps, activeStep);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


#pragma mark - walkBackAndForthTask

+ (ORKOrderedTask *)walkBackAndForthTaskWithIdentifier:(NSString *)identifier
                                intendedUseDescription:(NSString *)intendedUseDescription
                                          walkDuration:(NSTimeInterval)walkDuration
                                          restDuration:(NSTimeInterval)restDuration
                                               options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"WALK_INTRO_TEXT", nil);
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = ORKLocalizedString(@"WALK_INTRO_2_TEXT_BACK_AND_FORTH_INSTRUCTION", nil);
            step.detailText = ORKLocalizedString(@"WALK_INTRO_2_DETAIL_BACK_AND_FORTH_INSTRUCTION", nil);
            step.image = [UIImage imageNamed:@"pocket" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            
            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkOutboundStepIdentifier];
            walkingStep.numberOfStepsPerLeg = 1000; // Set the number of steps very high so it is ignored
            NSString *walkingDurationString = [formatter stringFromTimeInterval:walkDuration];
            walkingStep.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);

            walkingStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_BACK_AND_FORTH_INSTRUCTION_FORMAT", nil), walkingDurationString];
            walkingStep.spokenInstruction = walkingStep.text;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.optional = NO;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.stepDuration = walkDuration; // Set the walking duration to the step duration
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            walkingStep.shouldSpeakRemainingTimeAtHalfway = (walkDuration > 20);
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            
            ORKFitnessStep *activeStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKShortWalkRestStepIdentifier];
            activeStep.recorderConfigurations = recorderConfigurations;
            NSString *durationString = [formatter stringFromTimeInterval:restDuration];
            activeStep.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            activeStep.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_BACK_AND_FORTH_STAND_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.spokenInstruction = activeStep.text;
            activeStep.shouldStartTimerAutomatically = YES;
            activeStep.stepDuration = restDuration;
            activeStep.shouldContinueOnFinish = YES;
            activeStep.optional = NO;
            activeStep.shouldVibrateOnStart = YES;
            activeStep.shouldPlaySoundOnStart = YES;
            activeStep.shouldVibrateOnFinish = YES;
            activeStep.shouldPlaySoundOnFinish = YES;
            activeStep.finishedSpokenInstruction = ORKLocalizedString(@"WALK_BACK_AND_FORTH_FINISHED_VOICE", nil);
            activeStep.shouldSpeakRemainingTimeAtHalfway = (restDuration > 20);
            
            ORKStepArrayAddStep(steps, activeStep);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


#pragma mark - kneeRangeOfMotionTask

NSString *const ORKKneeRangeOfMotionStepIdentifier = @"knee.range.of.motion";

+ (ORKOrderedTask *)kneeRangeOfMotionTaskWithIdentifier:(NSString *)identifier
                                             limbOption:(ORKPredefinedTaskLimbOption)limbOption
                                 intendedUseDescription:(NSString *)intendedUseDescription
                                                options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Setup which limb (left or right) to start with and how many limbs (1 or both) to add, based on the limbOption parameter. If both limbs are selected, the order is randomly allocated
    NSUInteger limbCount = ((limbOption & ORKPredefinedTaskLimbOptionBoth) == ORKPredefinedTaskLimbOptionBoth) ? 2 : 1;
    BOOL doingBoth = (limbCount == 2);
    BOOL rightLimb;
    
    switch (limbOption) {
        case ORKPredefinedTaskLimbOptionLeft:
            rightLimb = NO; break;
        case ORKPredefinedTaskLimbOptionRight:
        case ORKPredefinedTaskLimbOptionUnspecified:
            rightLimb = YES; break;
        default:
            rightLimb = (arc4random()%2 == 0); break;
        }
    
    for (NSUInteger limb = 1; limb <= limbCount; limb++) {
        
        // Create unique identifiers when both limbs are selected
        NSString * (^appendIdentifier) (NSString *) = ^ (NSString * stepIdentifier) {
            if (!doingBoth) {
                return stepIdentifier;
            } else {
                NSString *limbIdentifier = rightLimb ? ORKActiveTaskRightLimbIdentifier : ORKActiveTaskLeftLimbIdentifier;
                return [NSString stringWithFormat:@"%@.%@", stepIdentifier, limbIdentifier];
            }
        };
        
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        
            {   /* Instruction step 0 */
            
                ORKInstructionStep *instructionStep0 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction0StepIdentifier)];
            
                if (doingBoth) {
                    // Set the title and instructions based on the limb(s) selected
                    if (limb == 1) {
                        if (rightLimb) {
                            instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                            instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT_FIRST", nil); // different instructions for right being first
                            instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    } else {
                            instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                            instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT_FIRST", nil); // different instructions for left being first
                            instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                        }
                
                    } else { // limb == 2
                        if (rightLimb) {
                            instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                            instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT_SECOND", nil); // different instructions for right being second
                            //instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                        } else {
                            instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                            instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT_SECOND", nil); // different instructions for left being second
                            //instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                        }
                    }
                } else { // not doing both
                    if (rightLimb) {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT", nil);
                        instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    } else {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT", nil);
                        instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    }
                }
                instructionStep0.shouldTintImages = YES;
                //instructionStep0.imageContentMode = UIViewContentModeCenter;
                ORKStepArrayAddStep(steps, instructionStep0);
            }
            
            {   /* Instruction step 1 */
    
                ORKInstructionStep *instructionStep1 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction1StepIdentifier)];
    
                if (limb == 1) {
                    if (rightLimb) {
                        instructionStep1.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT", nil);
                    } else {
                        instructionStep1.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT", nil);
                    }
                } else { // limb == 2
                    if (rightLimb) {
                        instructionStep1.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT_SECOND", nil); // different instruction for right being second
                    } else {
                        instructionStep1.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT_SECOND", nil); // different instruction for left being second
                    }
                }
                instructionStep1.shouldTintImages = YES;
                //instructionStep1.imageContentMode = UIViewContentModeCenter;
                ORKStepArrayAddStep(steps, instructionStep1);
            }
            
            {   /* Instruction step 2 */
            
                UIImage *kneeStartImage;
            
                ORKInstructionStep *instructionStep2 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction2StepIdentifier)];

                if (limb == 1) {
                    if (rightLimb) {
                        instructionStep2.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep2.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_RIGHT", nil);
                        kneeStartImage = [UIImage imageNamed:@"knee_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    } else {
                        instructionStep2.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep2.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_LEFT", nil);
                        kneeStartImage = [UIImage imageNamed:@"knee_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    }
                } else {
                    if (rightLimb) {
                        instructionStep2.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep2.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_RIGHT", nil);
                        kneeStartImage = [UIImage imageNamed:@"knee_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    } else {
                        instructionStep2.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep2.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_LEFT", nil);
                        kneeStartImage = [UIImage imageNamed:@"knee_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    }
                }
                instructionStep2.image = kneeStartImage;
                //instructionStep2.imageContentMode = UIViewContentModeCenter;
                instructionStep2.shouldTintImages = YES;
                ORKStepArrayAddStep(steps, instructionStep2);
            }
            
            {   /* Instruction step 3 */
            
                UIImage *kneeMaximumImage;
            
                ORKInstructionStep *instructionStep3 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction3StepIdentifier)];

                if (limb == 1) {
                    if (rightLimb) {
                        instructionStep3.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep3.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_RIGHT", nil);
                        kneeMaximumImage = [UIImage imageNamed:@"knee_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    } else {
                        instructionStep3.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep3.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_LEFT", nil);
                        kneeMaximumImage = [UIImage imageNamed:@"knee_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    }
                } else {
                    if (rightLimb) {
                        instructionStep3.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep3.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_RIGHT", nil);
                        kneeMaximumImage = [UIImage imageNamed:@"knee_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    } else {
                        instructionStep3.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep3.detailText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_LEFT", nil);
                        kneeMaximumImage = [UIImage imageNamed:@"knee_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    }
                }
                instructionStep3.image = kneeMaximumImage;
                //instructionStep3.imageContentMode = UIViewContentModeCenter;
                instructionStep3.shouldTintImages = YES;
                ORKStepArrayAddStep(steps, instructionStep3);
            }
        }
            
        {   /* Touch anywhere step */
            
            NSString *touchAnywhereStepText;
            // Set the instructions to be displayed and spoken
            if (rightLimb) {
                touchAnywhereStepText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_RIGHT", nil);
            } else {
                    touchAnywhereStepText = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_LEFT", nil);
            }
            ORKTouchAnywhereStep *touchAnywhereStep = [[ORKTouchAnywhereStep alloc] initWithIdentifier:appendIdentifier(ORKTouchAnywhereStepIdentifier) instructionText:touchAnywhereStepText];
            
            touchAnywhereStep.spokenInstruction = touchAnywhereStepText;
            
            // Set title based on the selected limb(s)
            if (rightLimb) {
                touchAnywhereStep.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
            } else {
            touchAnywhereStep.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
            }
            ORKStepArrayAddStep(steps, touchAnywhereStep);
        }
            
        {   /* Range of motion step */
            
            ORKDeviceMotionRecorderConfiguration *deviceMotionRecorderConfig = [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency:100];
    
            ORKRangeOfMotionStep *kneeRangeOfMotionStep = [[ORKRangeOfMotionStep alloc] initWithIdentifier:appendIdentifier(ORKKneeRangeOfMotionStepIdentifier) limbOption:limbOption];
            
            // Set title and instructions based on the selected limb(s)
            if (rightLimb) {
            kneeRangeOfMotionStep.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_RIGHT", nil);
            kneeRangeOfMotionStep.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_RIGHT", nil);
            } else {
            kneeRangeOfMotionStep.title = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_LEFT", nil);
            kneeRangeOfMotionStep.text = ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_LEFT", nil);
            }
            kneeRangeOfMotionStep.spokenInstruction = kneeRangeOfMotionStep.text;
            kneeRangeOfMotionStep.recorderConfigurations = @[deviceMotionRecorderConfig];
            kneeRangeOfMotionStep.optional = NO;
            ORKStepArrayAddStep(steps, kneeRangeOfMotionStep);
        }
        // Flip to the other limb if doing both (ignored if limbCount == 1)
        rightLimb = !rightLimb;
    }
                            
    /* Conclusion step */
                                    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *completionStep = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, completionStep);
    }
                        
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
        return task;
}


#pragma mark - shoulderRangeOfMotionTask

NSString *const ORKShoulderRangeOfMotionStepIdentifier = @"shoulder.range.of.motion";

+ (ORKOrderedTask *)shoulderRangeOfMotionTaskWithIdentifier:(NSString *)identifier
                                             limbOption:(ORKPredefinedTaskLimbOption)limbOption
                                 intendedUseDescription:(NSString *)intendedUseDescription
                                                options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Setup which limb (left or right) to start with and how many limbs (1 or both) to add, based on the limbOption parameter. If both limbs are selected, the order is randomly allocated
    NSUInteger limbCount = ((limbOption & ORKPredefinedTaskLimbOptionBoth) == ORKPredefinedTaskLimbOptionBoth) ? 2 : 1;
    BOOL doingBoth = (limbCount == 2);
    BOOL rightLimb;
    
    switch (limbOption) {
        case ORKPredefinedTaskLimbOptionLeft:
            rightLimb = NO; break;
        case ORKPredefinedTaskLimbOptionRight:
        case ORKPredefinedTaskLimbOptionUnspecified:
            rightLimb = YES; break;
        default:
            rightLimb = (arc4random()%2 == 0); break;
        }
    
    for (NSUInteger limb = 1; limb <= limbCount; limb++) {
        
        // Create unique identifiers when both limbs are selected
        NSString * (^appendIdentifier) (NSString *) = ^ (NSString * stepIdentifier) {
            if (!doingBoth) {
                return stepIdentifier;
            } else {
                NSString *limbIdentifier = rightLimb ? ORKActiveTaskRightLimbIdentifier : ORKActiveTaskLeftLimbIdentifier;
                return [NSString stringWithFormat:@"%@.%@", stepIdentifier, limbIdentifier];
            }
        };
        
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        
        {   /* Instruction step 0 */
            
            ORKInstructionStep *instructionStep0 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction0StepIdentifier)];
            
            if (doingBoth) {
                // Set the title and instructions based on the limb(s) selected
                if (limb == 1) {
                    if (rightLimb) {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT_FIRST", nil); // different instructions for right being first
                        instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    } else {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT_FIRST", nil); // different instructions for left being first
                        instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    }
                
                } else { // limb == 2
                    if (rightLimb) {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT_SECOND", nil); // different instructions for right being second
                        //instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    } else {
                        instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT_SECOND", nil); // different instructions for left being second
                        //instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    }
                }
            } else { // not doing both
                if (rightLimb) {
                    instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_RIGHT", nil);
                    instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                } else {
                    instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep0.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_LEFT", nil);
                    instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                }
            }
            instructionStep0.shouldTintImages = YES;
            //instructionStep0.imageContentMode = UIViewContentModeCenter;
            ORKStepArrayAddStep(steps, instructionStep0);
        }
            
        {   /* Instruction step 1 */
    
            ORKInstructionStep *instructionStep1 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction1StepIdentifier)];
    
            if (limb == 1) {
                if (rightLimb) {
                    instructionStep1.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT", nil);
                } else {
                    instructionStep1.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT", nil);
                }
            } else { // limb == 2
                if (rightLimb) {
                    instructionStep1.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT_SECOND", nil); // different instruction for right being second
                } else {
                    instructionStep1.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep1.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT_SECOND", nil); // different instruction for left being second
                }
            }
            instructionStep1.shouldTintImages = YES;
            //instructionStep1.imageContentMode = UIViewContentModeCenter;
            ORKStepArrayAddStep(steps, instructionStep1);
        }
            
        {   /* Instruction step 2 */
            
            UIImage *shoulderStartImage;
            
            ORKInstructionStep *instructionStep2 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction2StepIdentifier)];

            if (limb == 1) {
                if (rightLimb) {
                    instructionStep2.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep2.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_RIGHT", nil);
                    shoulderStartImage = [UIImage imageNamed:@"shoulder_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else {
                    instructionStep2.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep2.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_LEFT", nil);
                    shoulderStartImage = [UIImage imageNamed:@"shoulder_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            } else {
                if (rightLimb) {
                    instructionStep2.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep2.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_RIGHT", nil);
                    shoulderStartImage = [UIImage imageNamed:@"shoulder_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else {
                    instructionStep2.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep2.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_LEFT", nil);
                    shoulderStartImage = [UIImage imageNamed:@"shoulder_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            }
            instructionStep2.image = shoulderStartImage;
            //instructionStep2.imageContentMode = UIViewContentModeCenter;
            instructionStep2.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, instructionStep2);
        }
            
        {   /* Instruction step 3 */
            
            UIImage *shoulderMaximumImage;
            
            ORKInstructionStep *instructionStep3 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction3StepIdentifier)];

            if (limb == 1) {
                if (rightLimb) {
                    instructionStep3.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_RIGHT", nil);
                    shoulderMaximumImage = [UIImage imageNamed:@"shoulder_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else {
                    instructionStep3.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_LEFT", nil);
                    shoulderMaximumImage = [UIImage imageNamed:@"shoulder_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            } else {
                if (rightLimb) {
                    instructionStep3.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                    instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_RIGHT", nil);
                    shoulderMaximumImage = [UIImage imageNamed:@"shoulder_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else {
                    instructionStep3.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                    instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_LEFT", nil);
                    shoulderMaximumImage = [UIImage imageNamed:@"shoulder_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            }
            instructionStep3.image = shoulderMaximumImage;
            //instructionStep3.imageContentMode = UIViewContentModeCenter;
            instructionStep3.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, instructionStep3);
            }
        }
                            
        {   /* Touch anywhere step */
                            
            NSString *touchAnywhereStepText;
            // Set the instructions to be displayed and spoken
            if (rightLimb) {
                touchAnywhereStepText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_RIGHT", nil);
            } else {
                touchAnywhereStepText = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_LEFT", nil);
            }
            ORKTouchAnywhereStep *touchAnywhereStep = [[ORKTouchAnywhereStep alloc] initWithIdentifier:appendIdentifier(ORKTouchAnywhereStepIdentifier) instructionText:touchAnywhereStepText];
            
            touchAnywhereStep.spokenInstruction = touchAnywhereStepText;
                            
            // Set title based on the selected limb(s)
            if (rightLimb) {
                touchAnywhereStep.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
            } else {
                touchAnywhereStep.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
            }
            ORKStepArrayAddStep(steps, touchAnywhereStep);
        }
                            
        {   /* Range of motion step */
                            
            ORKDeviceMotionRecorderConfiguration *deviceMotionRecorderConfig = [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency:100];
                
            ORKShoulderRangeOfMotionStep *shoulderRangeOfMotionStep = [[ORKShoulderRangeOfMotionStep alloc] initWithIdentifier:appendIdentifier(ORKShoulderRangeOfMotionStepIdentifier) limbOption:limbOption];
                            
            // Set title and instructions based on the selected limb(s)
            if (rightLimb) {
                shoulderRangeOfMotionStep.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                shoulderRangeOfMotionStep.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_RIGHT", nil);
            } else {
                shoulderRangeOfMotionStep.title = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_LEFT", nil);
                shoulderRangeOfMotionStep.text = ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_LEFT", nil);
                }
            shoulderRangeOfMotionStep.spokenInstruction = shoulderRangeOfMotionStep.text;
            shoulderRangeOfMotionStep.recorderConfigurations = @[deviceMotionRecorderConfig];
            shoulderRangeOfMotionStep.optional = NO;
                        ORKStepArrayAddStep(steps, shoulderRangeOfMotionStep);
            }
            // Flip to the other limb if doing both (ignored if limbCount == 1)
            rightLimb = !rightLimb;
        }
                    
        /* Conclusion step */
                            
        if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
            ORKCompletionStep *completionStep = [self makeCompletionStep];
            ORKStepArrayAddStep(steps, completionStep);
    }
                
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
                    return task;
}


#pragma mark - standingBendingRangeOfMotionTask

NSString *const ORKStandingBendingRangeOfMotionStepIdentifier = @"standing.bending.range.of.motion";

+ (ORKOrderedTask *)standingBendingRangeOfMotionTaskWithIdentifier:(NSString *)identifier
                                            limbOption:(ORKPredefinedTaskLimbOption)limbOption
                                            movementOption:(ORKPredefinedTaskMovementOption)movementOption
                                            questionOption:(ORKPredefinedTaskQuestionOption)questionOption
                                            locationOption:(ORKPredefinedTaskLocationOption)locationOption
                                            intendedUseDescription:(NSString *)intendedUseDescription
                                            options:(ORKPredefinedTaskOption)options {
    
    NSInteger const scaleMax = 10;
    NSInteger const scaleMin = 0;
    NSInteger const scaleDefault = -1; // no scale number to be displayed on initiation
    NSInteger const scaleStep = 1;
    NSMutableArray *steps = [NSMutableArray array];
    NSString *location;
    NSInteger movement;
    
    // Build list of movements from predefined enums, and setup which movement to start with and how many movements (1-4) there will be, based on the movementOption parameter. If more than one movements are selected, the order in which they are presented will be randomized.
    NSMutableArray *movementList = [[NSMutableArray alloc] init];
    if (movementOption & ORKPredefinedTaskMovementOptionBendingForwards) {
        [movementList addObject:[NSNumber numberWithInteger:ORKPredefinedTaskMovementOptionBendingForwards]];
    }
    if (movementOption & ORKPredefinedTaskMovementOptionBendingBackwards) {
        [movementList addObject:[NSNumber numberWithInteger:ORKPredefinedTaskMovementOptionBendingBackwards]];
    }
    if (movementOption & ORKPredefinedTaskMovementOptionBendingLeft) {
        [movementList addObject:[NSNumber numberWithInteger:ORKPredefinedTaskMovementOptionBendingLeft]];
    }
    if (movementOption & ORKPredefinedTaskMovementOptionBendingRight) {
        [movementList addObject:[NSNumber numberWithInteger:ORKPredefinedTaskMovementOptionBendingRight]];
    }
    NSUInteger movementCount = [movementList count];
    
    // Shuffle the list of movements
    NSMutableArray *shuffledMovements = [NSMutableArray arrayWithArray:movementList];
    for (NSUInteger i = 0; i < ([shuffledMovements count]) - 1; ++i) {
        NSInteger remainingCount = [shuffledMovements count] - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [shuffledMovements exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    for (movement = 1; movement <= movementCount; movement++) {
        
        // Allocate next movement and convert back to enum
        ORKPredefinedTaskMovementOption nextMovement = [shuffledMovements[movement - 1] integerValue];
        
        // Create unique identifiers for each movement (and add the order in which they are presented if doing more than 1 movement)
        NSString * (^appendIdentifier) (NSString *) = ^ (NSString * stepIdentifier) {
            NSString *movementIdentifier;
            switch (nextMovement) {
            case ORKPredefinedTaskMovementOptionBendingForwards:
                    movementIdentifier = ORKActiveTaskForwardBendingIdentifier; break;
            case ORKPredefinedTaskMovementOptionBendingBackwards:
                    movementIdentifier = ORKActiveTaskBackwardBendingIdentifier; break;
            case ORKPredefinedTaskMovementOptionBendingRight:
                    movementIdentifier = ORKActiveTaskRightBendingIdentifier; break;
            case ORKPredefinedTaskMovementOptionBendingLeft:
                    movementIdentifier = ORKActiveTaskLeftBendingIdentifier; break;
            }
            if (movementCount == 1) {
                return [NSString stringWithFormat:@"%@.%@", stepIdentifier, movementIdentifier];
            } else {
                return [NSString stringWithFormat:@"%@.%ld.%@", stepIdentifier, (long)movement, movementIdentifier];
            }
        };
        
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        
        {   /* Instruction step 0 */
            
            ORKInstructionStep *instructionStep0 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction0StepIdentifier)];
            if (movement == 1) {
                if (movementCount == 1) { // single movement
                    instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                    // Set the instruction text based on the single movement selected
                    if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                        instructionStep0.text = [NSString localizedStringWithFormat:
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_SINGLE", nil),
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil)];
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                        instructionStep0.text = [NSString localizedStringWithFormat:
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_SINGLE", nil),
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil)];
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                        instructionStep0.text = [NSString localizedStringWithFormat:
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_SINGLE", nil),
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil)];
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                        instructionStep0.text = [NSString localizedStringWithFormat:
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_SINGLE", nil),
                                                 ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil)];
                    }
                } else { // multiple movements
                    instructionStep0.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep0.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_MULTIPLE", nil), @(movementCount)];
                    instructionStep0.detailText = ORKLocalizedString(@"RANGE_OF_MOTION_SOUND", nil);
                }
                //instructionStep0.shouldTintImages = YES;
                //instructionStep1.imageContentMode = UIViewContentModeScaleAspectFit;
                ORKStepArrayAddStep(steps, instructionStep0);
            }
        }
            
        {   /* Instruction step 1 */
            
            ORKInstructionStep *instructionStep1 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction1StepIdentifier)];
            
            if (movementCount > 1) {
                if (movement == 1) { // different instructions for first movement
                    if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_FORWARD_FIRST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_BACKWARD_FIRST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT_FIRST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT_FIRST", nil);
                    }
                } else if (movement == movementCount) { // different instructions for last movement
                    if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_FORWARD_LAST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_BACKWARD_LAST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT_LAST", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT_LAST", nil);
                    }
                } else { // movement >= 2 but < movementCount
                    if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                        instructionStep1.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_FORWARD_NEXT", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                        instructionStep1.detailText =  ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_BACKWARD_NEXT", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                        instructionStep1.detailText =  ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT_NEXT", nil);
                    } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                        instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                        instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                        instructionStep1.detailText =  ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT_NEXT", nil);
                    }
                }
            } else { // single movement task
                if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                    instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_FORWARD", nil);
                } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                    instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_BACKWARD", nil);
                } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                    instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_RIGHT", nil);
                } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                    instructionStep1.title = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep1.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_LEFT", nil);
                }
            }
            // Setup animation
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"forward_bending_1_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im3 = [UIImage imageNamed:@"forward_bending_2_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im4 = [UIImage imageNamed:@"forward_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep1.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im3, im4, im4, im3, im2, im1, im1] duration:6];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"forward_bending_1_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im3 = [UIImage imageNamed:@"forward_bending_2_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im4 = [UIImage imageNamed:@"forward_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep1.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im3, im4, im4, im3, im2, im1, im1] duration:6];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"backward_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep1.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im2, im1, im1] duration:5];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"backward_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep1.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im2, im1, im1] duration:5];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                // TODO: Create right side bending animation
                instructionStep1.image = [UIImage imageNamed:@"side_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                // TODO: Create left side bending animation
                instructionStep1.image = [UIImage imageNamed:@"side_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            }
            
            instructionStep1.shouldTintImages = YES;
            //instructionStep1.imageContentMode = UIViewContentModeScaleAspectFit;
            ORKStepArrayAddStep(steps, instructionStep1);
        }
            
        {   // Optional assessment of pain before the motion task
        
            if (questionOption & ORKPredefinedTaskQuestionOptionPainBefore) {
            
                // Set the title and instructions based on the location(s) selected
                if (locationOption == ORKPredefinedTaskLocationOptionBack) {
                    location = [ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_LOCATION_BACK", nil) lowercaseString];
                } else if (locationOption == ORKPredefinedTaskLocationOptionLegs) {
                    location = [ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_LOCATION_LEGS", nil) lowercaseString];
                } else if (locationOption == ORKPredefinedTaskLocationOptionBackAndLegs) {
                    location = [ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_LOCATION_BACK_LEGS", nil) lowercaseString];
                }
                
                ORKScaleAnswerFormat *beforeScaleFormat = [[ORKScaleAnswerFormat alloc]
                                                           initWithMaximumValue:scaleMax
                                                           minimumValue:scaleMin
                                                           defaultValue:scaleDefault
                                                           step:scaleStep
                                                           vertical:NO
                                                           maximumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MAX", nil)
                                                           minimumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MIN", nil)];

                ORKQuestionStep *scaleBeforeStep = [ORKQuestionStep
                                                    questionStepWithIdentifier:appendIdentifier(@"pain.scale.before")
                                                    title:ORKLocalizedString(@"RANGE_OF_MOTION_QUESTION_TITLE_BEFORE", nil)
                                                    //title:[NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_TITLE_NOW", nil), location]
                                                    question:[NSString localizedStringWithFormat: ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_NOW", nil), location]
                                                    answer:beforeScaleFormat];
                scaleBeforeStep.optional = NO;
                ORKStepArrayAddStep(steps, scaleBeforeStep);
            }
        }
            
        {   /* Instruction step 2 */
            
            UIImage *standingBendingStartImage;
    
            ORKInstructionStep *instructionStep2 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction2StepIdentifier)];
    
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                instructionStep2.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                instructionStep2.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_STANDING_APART", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                instructionStep2.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                instructionStep2.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_STANDING_APART", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                instructionStep2.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                instructionStep2.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_STANDING_TOGETHER", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                instructionStep2.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                instructionStep2.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_STANDING_TOGETHER", nil);
            }
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) { // phone must be held in opposite hand during side bending
                standingBendingStartImage = [UIImage imageNamed:@"side_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) { // phone must be held in opposite hand during side bending
                standingBendingStartImage = [UIImage imageNamed:@"side_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (limbOption == ORKPredefinedTaskLimbOptionRight) {
               standingBendingStartImage = [UIImage imageNamed:@"sagittal_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                standingBendingStartImage = [UIImage imageNamed:@"sagittal_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            }
            instructionStep2.image = standingBendingStartImage;
            instructionStep2.shouldTintImages = YES;
            //instructionStep2.imageContentMode = UIViewContentModeScaleAspectFit;
            ORKStepArrayAddStep(steps, instructionStep2);
        }
            
        {   /* Instruction step 3 */
            
            ORKInstructionStep *instructionStep3 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction3StepIdentifier)];

            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                instructionStep3.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                    //instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_FORWARD_MOVEMENT_RIGHT_LIMB", nil);
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_FORWARD_MOVEMENT_LEFT_LIMB", nil);
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                    instructionStep3.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                    //instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_BACKWARD_MOVEMENT_RIGHT_LIMB", nil);
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_BACKWARD_MOVEMENT_LEFT_LIMB", nil);
                    }
                } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                    instructionStep3.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                                   //instructionStep2.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_RIGHT_MOVEMENT_LEFT_LIMB", nil); // phone must be held in opposite hand during side bending
                } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                    instructionStep3.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                            //instructionStep3.text = ORKLocalizedString(@"RANGE_OF_MOTION_TITLE", nil);
                    instructionStep3.detailText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_LEFT_MOVEMENT_RIGHT_LIMB", nil); // phone must be held in opposite hand during side bending
                }
            // Setup animation
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"forward_bending_1_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im3 = [UIImage imageNamed:@"forward_bending_2_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im4 = [UIImage imageNamed:@"forward_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep3.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im3, im4, im4, im3, im2, im1, im1] duration:6];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"forward_bending_1_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im3 = [UIImage imageNamed:@"forward_bending_2_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im4 = [UIImage imageNamed:@"forward_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep3.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im3, im4, im4, im3, im2, im1, im1] duration:6];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"backward_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep3.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im2, im1, im1] duration:5];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    UIImage *im1 = [UIImage imageNamed:@"sagittal_bending_start_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    UIImage *im2 = [UIImage imageNamed:@"backward_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                    instructionStep3.image = [UIImage animatedImageWithImages:@[im1, im1, im2, im2, im1, im1] duration:5];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                // TODO: Create right side bending animation
                instructionStep3.image = [UIImage imageNamed:@"side_bending_maximum_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                // TODO: Create left side bending animation
                instructionStep3.image = [UIImage imageNamed:@"side_bending_maximum_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            }
            //instructionStep3.imageContentMode = UIViewContentModeScaleAspectFit;
            instructionStep3.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, instructionStep3);
        }
            
        {   /* Instruction step 4 */
            UIImage *phoneAgainstChestImage;
            
            ORKInstructionStep *instructionStep4 = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction4StepIdentifier)];

            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                instructionStep4.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_RIGHT_LIMB", nil);
                    phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                    instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_LEFT_LIMB", nil);
                    phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                instructionStep4.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                    instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_RIGHT_LIMB", nil);
                    phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                        instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_LEFT_LIMB", nil);
                    phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                }
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                instructionStep4.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_RIGHT", nil);
                instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_LEFT_LIMB", nil); // phone must be held in opposite hand during side bending
                phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                instructionStep4.title = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_LEFT", nil);
                instructionStep4.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TEXT_INSTRUCTION_4_RIGHT_LIMB", nil); // phone must be held in opposite hand during side bending
                phoneAgainstChestImage = [UIImage imageNamed:@"phone_against_chest_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            }
            instructionStep4.image = phoneAgainstChestImage;
            //instructionStep4.imageContentMode = UIViewContentModeScaleAspectFit;
            instructionStep4.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, instructionStep4);
            }
        }
                            
        {   /* Touch anywhere step */
                            
            NSString *touchAnywhereStepText;
            // Build the instructions to be displayed and spoken
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) { // phone must be held in opposite hand during side bending
                touchAnywhereStepText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_RIGHT_LIMB", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) { // phone must be held in opposite hand during side bending
                touchAnywhereStepText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_LEFT_LIMB", nil);
            } else if (limbOption == ORKPredefinedTaskLimbOptionRight) {
                touchAnywhereStepText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_RIGHT_LIMB", nil);
            } else if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
                touchAnywhereStepText = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_LEFT_LIMB", nil);
            }
            ORKTouchAnywhereStep *touchAnywhereStep = [[ORKTouchAnywhereStep alloc] initWithIdentifier:appendIdentifier(ORKTouchAnywhereStepIdentifier)];
            
            touchAnywhereStep.spokenInstruction = touchAnywhereStepText;
                            
            // Set title and instructions based on the selected movement(s)
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                touchAnywhereStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //touchAnywhereStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                touchAnywhereStep.text = touchAnywhereStepText;
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                touchAnywhereStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //touchAnywhereStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                touchAnywhereStep.text = touchAnywhereStepText;
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                touchAnywhereStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //touchAnywhereStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                touchAnywhereStep.text = touchAnywhereStepText;
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                touchAnywhereStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //touchAnywhereStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_BACKWARD", nil);
                touchAnywhereStep.text = touchAnywhereStepText;
            }
            ORKStepArrayAddStep(steps, touchAnywhereStep);
        }
                            
        {   /* Range of motion step */
                            
            ORKDeviceMotionRecorderConfiguration *deviceMotionRecorderConfig = [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency:100];
                
            ORKStandingBendingRangeOfMotionStep *standingBendingRangeOfMotionStep = [[ORKStandingBendingRangeOfMotionStep alloc] initWithIdentifier:appendIdentifier(ORKStandingBendingRangeOfMotionStepIdentifier) limbOption:limbOption];
                            
            // Set title and instructions based on the selected movement(s)
            if (nextMovement == ORKPredefinedTaskMovementOptionBendingForwards) {
                standingBendingRangeOfMotionStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                standingBendingRangeOfMotionStep.text =ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_FORWARD", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingBackwards) {
                standingBendingRangeOfMotionStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_BACKWARD", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingRight) {
                standingBendingRangeOfMotionStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_RIGHT", nil);
            } else if (nextMovement == ORKPredefinedTaskMovementOptionBendingLeft) {
                standingBendingRangeOfMotionStep.title = ORKLocalizedString(@"RANGE_OF_MOTION_TEST_TITLE", nil);
                //standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_TITLE_FORWARD", nil);
                standingBendingRangeOfMotionStep.text = ORKLocalizedString(@"STANDING_BENDING_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_LEFT", nil);
            }
            //standingBendingRangeOfMotionStep.spokenInstruction = standingBendingRangeOfMotionStep.detailText;
            standingBendingRangeOfMotionStep.spokenInstruction = standingBendingRangeOfMotionStep.text;
            standingBendingRangeOfMotionStep.recorderConfigurations = @[deviceMotionRecorderConfig];
            standingBendingRangeOfMotionStep.movementOption = nextMovement;
            standingBendingRangeOfMotionStep.questionOption = questionOption;
            standingBendingRangeOfMotionStep.locationOption = locationOption;
            standingBendingRangeOfMotionStep.optional = NO;
                        ORKStepArrayAddStep(steps, standingBendingRangeOfMotionStep);
            }
        
        {   // Optional assessment of pain during the motion task
            
            if (questionOption & ORKPredefinedTaskQuestionOptionPainDuring) {
                
                ORKScaleAnswerFormat *scaleFormat = [[ORKScaleAnswerFormat alloc]
                                                        initWithMaximumValue:scaleMax
                                                        minimumValue:scaleMin
                                                        defaultValue:scaleDefault
                                                        step:scaleStep
                                                        vertical:NO
                                                        maximumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MAX", nil)
                                                        minimumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MIN", nil)];
            
                ORKQuestionStep *scaleDuringStep = [ORKQuestionStep
                                                    questionStepWithIdentifier:appendIdentifier(@"pain.scale.during")
                                                    //title:[NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_TITLE_DURING", nil), location]
                                                    title:ORKLocalizedString(@"RANGE_OF_MOTION_QUESTION_TITLE_DURING", nil)
                                                    question:[NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_DURING", nil), location]
                                                    answer:scaleFormat];
            scaleDuringStep.optional = NO;
            ORKStepArrayAddStep(steps, scaleDuringStep);
            }
        }
                
        {   // Optional assessment of pain after the motion task
                
            if (questionOption & ORKPredefinedTaskQuestionOptionPainAfter) {
                
            ORKScaleAnswerFormat *afterScaleFormat = [[ORKScaleAnswerFormat alloc]
                                                    initWithMaximumValue:scaleMax
                                                    minimumValue:scaleMin
                                                    defaultValue:scaleDefault
                                                    step:scaleStep
                                                    vertical:NO
                                                    maximumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MAX", nil)
                                                    minimumValueDescription:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_MIN", nil)];
                
            ORKQuestionStep *scaleAfterStep = [ORKQuestionStep
                                                questionStepWithIdentifier:appendIdentifier(@"pain.scale.after")
                                               //title:[NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_TITLE_NOW", nil), location]
                                               title:ORKLocalizedString(@"RANGE_OF_MOTION_QUESTION_TITLE_AFTER", nil)
                                                question:[NSString localizedStringWithFormat: ORKLocalizedString(@"RANGE_OF_MOTION_PAIN_SCALE_QUESTION_NOW", nil), location]
                                                answer:afterScaleFormat];
            scaleAfterStep.optional = NO;
            ORKStepArrayAddStep(steps, scaleAfterStep);
            }
        }
    }
                    
    /* Conclusion step */
                            
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *completionStep = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, completionStep);
    }
                
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
                    return task;
}


#pragma mark - spatialSpanMemoryTask

NSString *const ORKSpatialSpanMemoryStepIdentifier = @"cognitive.memory.spatialspan";

+ (ORKOrderedTask *)spatialSpanMemoryTaskWithIdentifier:(NSString *)identifier
                                 intendedUseDescription:(NSString *)intendedUseDescription
                                            initialSpan:(NSInteger)initialSpan
                                            minimumSpan:(NSInteger)minimumSpan
                                            maximumSpan:(NSInteger)maximumSpan
                                              playSpeed:(NSTimeInterval)playSpeed
                                               maximumTests:(NSInteger)maximumTests
                                 maximumConsecutiveFailures:(NSInteger)maximumConsecutiveFailures
                                      customTargetImage:(UIImage *)customTargetImage
                                 customTargetPluralName:(NSString *)customTargetPluralName
                                        requireReversal:(BOOL)requireReversal
                                                options:(ORKPredefinedTaskOption)options {
    
    NSString *targetPluralName = customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_PLURAL", nil);
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_TEXT_%@", nil),targetPluralName];
            
            step.image = [UIImage imageNamed:@"phone-memory" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:requireReversal ? ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_REVERSE_%@", nil) : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_%@", nil), targetPluralName, targetPluralName];
            step.detailText = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_CALL_TO_ACTION", nil);
            
            if (!customTargetImage) {
                step.image = [UIImage imageNamed:@"memory-second-screen" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else {
                step.image = customTargetImage;
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKSpatialSpanMemoryStep *step = [[ORKSpatialSpanMemoryStep alloc] initWithIdentifier:ORKSpatialSpanMemoryStepIdentifier];
        step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
        step.text = nil;
        
        step.initialSpan = initialSpan;
        step.minimumSpan = minimumSpan;
        step.maximumSpan = maximumSpan;
        step.playSpeed = playSpeed;
        step.maximumTests = maximumTests;
        step.maximumConsecutiveFailures = maximumConsecutiveFailures;
        step.customTargetImage = customTargetImage;
        step.customTargetPluralName = customTargetPluralName;
        step.requireReversal = requireReversal;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


#pragma mark - speechRecognitionTask

NSString *const ORKSpeechRecognitionStepIdentifier = @"speech.recognition";

+ (ORKOrderedTask *)speechRecognitionTaskWithIdentifier:(NSString *)identifier
                                 intendedUseDescription:(nullable NSString *)intendedUseDescription
                                 speechRecognizerLocale:(ORKSpeechRecognizerLocale)speechRecognizerLocale
                                 speechRecognitionImage:(nullable UIImage *)speechRecognitionImage
                                  speechRecognitionText:(nullable NSString *)speechRecognitionText
                                   shouldHideTranscript:(BOOL)shouldHideTranscript
                               allowsEdittingTranscript:(BOOL)allowsEdittingTranscript
                                                options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"SPEECH_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"SPEECH_RECOGNITION_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"phonewaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"SPEECH_TASK_TITLE", nil);
            step.text = ORKLocalizedString(@"SPEECH_RECOGNITION_INTRO_2_TEXT", nil);
            step.detailText = ORKLocalizedString(@"SPEECH_RECOGNITION_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonewavesspeech" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    ORKSpeechRecognitionStep *step = [[ORKSpeechRecognitionStep alloc] initWithIdentifier: ORKSpeechRecognitionStepIdentifier image:speechRecognitionImage text:speechRecognitionText];
    ORKStreamingAudioRecorderConfiguration *config = [[ORKStreamingAudioRecorderConfiguration alloc] initWithIdentifier: ORKStreamingAudioRecorderIdentifier];
    step.title = ORKLocalizedString(@"SPEECH_TASK_TITLE", nil);
    step.shouldHideTranscript = shouldHideTranscript;
    step.recorderConfigurations = @[config];
    step.speechRecognizerLocale = speechRecognizerLocale;
    step.shouldContinueOnFinish = NO;
    
    ORKStepArrayAddStep(steps, step);
    
    if (allowsEdittingTranscript) {
        ORKQuestionStep *editTranscriptStep = [ORKQuestionStep questionStepWithIdentifier:ORKEditSpeechTranscript0StepIdentifier
                                                                                    title:ORKLocalizedString(@"SPEECH_RECOGNITION_QUESTION_TITLE", nil)
                                                                                 question:nil
                                                                                   answer:[ORKTextAnswerFormat new]];
        editTranscriptStep.text = ORKLocalizedString(@"SPEECH_RECOGNITION_QUESTION_TEXT", nil);
        ORKStepArrayAddStep(steps, editTranscriptStep);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

#pragma mark - speechInNoiseTask

NSString *const ORKSpeechInNoiseStep0Identifier = @"speech.in.noise0";
NSString *const ORKSpeechInNoiseStep1Identifier = @"speech.in.noise1";
NSString *const ORKSpeechInNoiseStep2Identifier = @"speech.in.noise2";

+ (ORKOrderedTask *)speechInNoiseTaskWithIdentifier:(NSString *)identifier
                             intendedUseDescription:(nullable NSString *)intendedUseDescription
                                            options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_TITLE", nil);
        step.detailText = intendedUseDescription;
        step.text = intendedUseDescription ? : ORKLocalizedString(@"SPEECH_IN_NOISE_INTRO_TEXT", nil);
        step.image = [UIImage imageNamed:@"speechInNoise" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        step.shouldTintImages = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_TITLE", nil);
        step.detailText = ORKLocalizedString(@"SPEECH_IN_NOISE_DETAIL_TEXT", nil);
        step.image = [UIImage imageNamed:@"speechInNoise" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        step.shouldTintImages = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    // SNR ranging from 18 dB to 0 dB with a 3 dB step
    NSMutableArray *gainValues = [NSMutableArray new];
    [gainValues addObject:[NSNumber numberWithDouble:0.18]];
    [gainValues addObject:[NSNumber numberWithDouble:0.25]];
    [gainValues addObject:[NSNumber numberWithDouble:0.36]];
    [gainValues addObject:[NSNumber numberWithDouble:0.51]];
    [gainValues addObject:[NSNumber numberWithDouble:0.73]];
    [gainValues addObject:[NSNumber numberWithDouble:1.03]];
    [gainValues addObject:[NSNumber numberWithDouble:1.46]];
    
    
    {
        ORKSpeechInNoiseStep *step = [[ORKSpeechInNoiseStep alloc] initWithIdentifier:ORKSpeechInNoiseStep1Identifier];
        step.speechFileNameWithExtension = @"Sentence1.wav";
        step.gainAppliedToNoise = [gainValues[0] doubleValue];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_STEP_TITLE", nil);
        step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_STEP_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKSpeechRecognitionStep *step = [[ORKSpeechRecognitionStep alloc] initWithIdentifier: ORKSpeechInNoiseStep2Identifier image:nil text:nil];
        ORKStreamingAudioRecorderConfiguration *config = [[ORKStreamingAudioRecorderConfiguration alloc] initWithIdentifier: ORKStreamingAudioRecorderIdentifier];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_SPEAK_TITLE", nil);
        step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_SPEAK_TEXT", nil);
        step.shouldHideTranscript = YES;
        step.recorderConfigurations = @[config];
        step.speechRecognizerLocale = ORKSpeechRecognizerLocaleEnglishUS;
        step.shouldContinueOnFinish = NO;
        step.optional = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    {
        ORKTextAnswerFormat *answerFormat = [ORKTextAnswerFormat new];
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        ORKQuestionStep *editTranscriptStep = [ORKQuestionStep questionStepWithIdentifier:ORKEditSpeechTranscript0StepIdentifier
                                                                                    title:ORKLocalizedString(@"SPEECH_RECOGNITION_QUESTION_TITLE", nil)
                                                                                 question:nil
                                                                                   answer:answerFormat];
        editTranscriptStep.text = ORKLocalizedString(@"SPEECH_RECOGNITION_QUESTION_TEXT", nil);
        ORKStepArrayAddStep(steps, editTranscriptStep);
    }
    
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
    
}

#pragma mark - stroopTask

NSString *const ORKStroopStepIdentifier = @"stroop";

+ (ORKOrderedTask *)stroopTaskWithIdentifier:(NSString *)identifier
                      intendedUseDescription:(nullable NSString *)intendedUseDescription
                            numberOfAttempts:(NSInteger)numberOfAttempts
                                     options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"STROOP_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"STROOP_TASK_INTRO1_DETAIL_TEXT", nil);
            step.image = [UIImage imageNamed:@"phonestrooplabel" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"STROOP_TASK_TITLE", nil);
            step.detailText = ORKLocalizedString(@"STROOP_TASK_INTRO2_DETAIL_TEXT", nil);
            step.image = [UIImage imageNamed:@"phonestroopbutton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"STROOP_TASK_TITLE", nil);
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    {
        ORKStroopStep *step = [[ORKStroopStep alloc] initWithIdentifier:ORKStroopStepIdentifier];
        step.title = ORKLocalizedString(@"STROOP_TASK_TITLE", nil);
        step.text = ORKLocalizedString(@"STROOP_TASK_STEP_TEXT", nil);
        step.spokenInstruction = step.text;
        step.numberOfAttempts = numberOfAttempts;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


#pragma mark - toneAudiometryTask

NSString *const ORKToneAudiometryPracticeStepIdentifier = @"tone.audiometry.practice";
NSString *const ORKToneAudiometryStepIdentifier = @"tone.audiometry";

+ (ORKOrderedTask *)toneAudiometryTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                   speechInstruction:(nullable NSString *)speechInstruction
                              shortSpeechInstruction:(nullable NSString *)shortSpeechInstruction
                                        toneDuration:(NSTimeInterval)toneDuration
                                             options:(ORKPredefinedTaskOption)options {

    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }

    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TONE_AUDIOMETRY_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phonewaves_inverted" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = speechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_INTRO_TEXT", nil);
            step.detailText = ORKLocalizedString(@"TONE_AUDIOMETRY_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonefrequencywaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }
    
    NSString *instructionText = shortSpeechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_INSTRUCTION", nil);
    {
        ORKToneAudiometryStep *step = [[ORKToneAudiometryStep alloc] initWithIdentifier:ORKToneAudiometryPracticeStepIdentifier];
        step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
        NSString *prepText = speechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_PREP_TEXT", nil);
        if (UIAccessibilityIsVoiceOverRunning()) {
            prepText = [NSString stringWithFormat:ORKLocalizedString(@"AX_TONE_AUDIOMETRY_PREP_TEXT_VOICEOVER", nil), prepText, instructionText];
        }
        step.text = prepText;
        step.toneDuration = CGFLOAT_MAX;
        step.practiceStep = YES;
        ORKStepArrayAddStep(steps, step);
        
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.stepDuration = 5.0;

        ORKStepArrayAddStep(steps, step);
    }

    {
        ORKToneAudiometryStep *step = [[ORKToneAudiometryStep alloc] initWithIdentifier:ORKToneAudiometryStepIdentifier];
        step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.text = instructionText;
        step.toneDuration = toneDuration;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];

        ORKStepArrayAddStep(steps, step);
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];

    return task;
}

#pragma mark - dBHLToneAudiometryTask

NSString *const ORKdBHLToneAudiometryStepIdentifier = @"dBHL.tone.audiometry";
NSString *const ORKdBHLToneAudiometryStep0Identifier = @"dBHL0.tone.audiometry";
NSString *const ORKdBHLToneAudiometryStep1Identifier = @"dBHL1.tone.audiometry";
NSString *const ORKdBHLToneAudiometryStep2Identifier = @"dBHL2.tone.audiometry";
NSString *const ORKdBHLToneAudiometryStep3Identifier = @"dBHL3.tone.audiometry";

+ (ORKOrderedTask *)dBHLToneAudiometryTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                             options:(ORKPredefinedTaskOption)options {
    
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }

    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"audiometry" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
    }

    {
        ORKdBHLToneAudiometryOnboardingStep *step = [[ORKdBHLToneAudiometryOnboardingStep alloc] initWithIdentifier:ORKdBHLToneAudiometryStepIdentifier];
        step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.text = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_ONBOARDING", nil);
        
        step.optional = NO;
        
        ORKTextChoice *left = [ORKTextChoice choiceWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_OPTION_LEFT", nil)
                                                      value:@"LEFT"];
        ORKTextChoice *right = [ORKTextChoice choiceWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_OPTION_RIGHT", nil)
                                                       value:@"RIGHT"];
        ORKTextChoice *neither = [ORKTextChoice choiceWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_OPTION_NO_PREFERENCE", nil)
                                                         value:@"NEITHER"];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[right, left, neither]];
        
        ORKFormItem *formItem = [[ORKFormItem alloc] initWithIdentifier:ORKdBHLToneAudiometryStep0Identifier
                                                                   text:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_ONBOARDING_QUESTION", nil)
                                                           answerFormat:answerFormat];
        
        ORKTextChoice *airpods = [ORKTextChoice choiceWithText:@"AirPods"
                                                      value:@"AIRPODS"];
        ORKTextChoice *earpods = [ORKTextChoice choiceWithText:@"EarPods"
                                                         value:@"EARPODS"];
        
        ORKAnswerFormat *answerFormat1 = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[airpods, earpods]];
        ORKFormItem *formItem1 = [[ORKFormItem alloc] initWithIdentifier:ORKdBHLToneAudiometryStep3Identifier
                                                                   text:@"Select the headphones that you will be using"
                                                           answerFormat:answerFormat1];

        
        formItem.optional = NO;
        formItem1.optional = NO;
        
        step.formItems = @[formItem, formItem1];
    
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_INTRO_TEXT", nil);
            if (UIAccessibilityIsVoiceOverRunning()) {
                step.text = [NSString stringWithFormat:ORKLocalizedString(@"AX_dBHL_TONE_AUDIOMETRY_INTRO_TEXT", nil), step.text];
            }
            step.image = [UIImage imageNamed:@"audiometry" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKdBHLToneAudiometryStep *step = [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:ORKdBHLToneAudiometryStep1Identifier];
        step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.stepDuration = CGFLOAT_MAX;
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdown1StepIdentifier];
        step.stepDuration = 5.0;
        step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKdBHLToneAudiometryStep *step = [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:ORKdBHLToneAudiometryStep2Identifier];
        step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.stepDuration = CGFLOAT_MAX;
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}



#pragma mark - towerOfHanoiTask

NSString *const ORKTowerOfHanoiStepIdentifier = @"towerOfHanoi";

+ (ORKOrderedTask *)towerOfHanoiTaskWithIdentifier:(NSString *)identifier
                            intendedUseDescription:(nullable NSString *)intendedUseDescription
                                     numberOfDisks:(NSUInteger)numberOfDisks
                                           options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phone-tower-of-hanoi" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TITLE", nil);
            step.text = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_INTRO_TEXT", nil);
            step.detailText = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TASK_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"tower-of-hanoi-second-screen" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    ORKTowerOfHanoiStep *towerOfHanoiStep = [[ORKTowerOfHanoiStep alloc]initWithIdentifier:ORKTowerOfHanoiStepIdentifier];
    towerOfHanoiStep.title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TITLE", nil);
    towerOfHanoiStep.numberOfDisks = numberOfDisks;
    ORKStepArrayAddStep(steps, towerOfHanoiStep);
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc]initWithIdentifier:identifier steps:steps];
    
    return task;
}


#pragma mark - reactionTimeTask

NSString *const ORKReactionTimeStepIdentifier = @"reactionTime";

+ (ORKOrderedTask *)reactionTimeTaskWithIdentifier:(NSString *)identifier
                            intendedUseDescription:(nullable NSString *)intendedUseDescription
                           maximumStimulusInterval:(NSTimeInterval)maximumStimulusInterval
                           minimumStimulusInterval:(NSTimeInterval)minimumStimulusInterval
                             thresholdAcceleration:(double)thresholdAcceleration
                                  numberOfAttempts:(int)numberOfAttempts
                                           timeout:(NSTimeInterval)timeout
                                      successSound:(UInt32)successSoundID
                                      timeoutSound:(UInt32)timeoutSoundID
                                      failureSound:(UInt32)failureSoundID
                                           options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"REACTION_TIME_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"REACTION_TIME_TASK_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phoneshake" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"REACTION_TIME_TASK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat: ORKLocalizedString(@"REACTION_TIME_TASK_INTRO_TEXT_FORMAT", nil), numberOfAttempts];
            step.detailText = ORKLocalizedString(@"REACTION_TIME_TASK_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phoneshakecircle" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    ORKReactionTimeStep *step = [[ORKReactionTimeStep alloc] initWithIdentifier:ORKReactionTimeStepIdentifier];
    step.title = ORKLocalizedString(@"REACTION_TIME_TASK_TITLE", nil);
    step.maximumStimulusInterval = maximumStimulusInterval;
    step.minimumStimulusInterval = minimumStimulusInterval;
    step.thresholdAcceleration = thresholdAcceleration;
    step.numberOfAttempts = numberOfAttempts;
    step.timeout = timeout;
    step.successSound = successSoundID;
    step.timeoutSound = timeoutSoundID;
    step.failureSound = failureSoundID;
    step.recorderConfigurations = @[ [[ORKDeviceMotionRecorderConfiguration  alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency: 100]];

    ORKStepArrayAddStep(steps, step);
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

#pragma mark - timedWalkTask

NSString *const ORKTimedWalkFormStepIdentifier = @"timed.walk.form";
NSString *const ORKTimedWalkFormAFOStepIdentifier = @"timed.walk.form.afo";
NSString *const ORKTimedWalkFormAssistanceStepIdentifier = @"timed.walk.form.assistance";
NSString *const ORKTimedWalkTrial1StepIdentifier = @"timed.walk.trial1";
NSString *const ORKTimedWalkTurnAroundStepIdentifier = @"timed.walk.turn.around";
NSString *const ORKTimedWalkTrial2StepIdentifier = @"timed.walk.trial2";

+ (ORKOrderedTask *)timedWalkTaskWithIdentifier:(NSString *)identifier
                         intendedUseDescription:(nullable NSString *)intendedUseDescription
                               distanceInMeters:(double)distanceInMeters
                                      timeLimit:(NSTimeInterval)timeLimit
                            turnAroundTimeLimit:(NSTimeInterval)turnAroundTimeLimit
                     includeAssistiveDeviceForm:(BOOL)includeAssistiveDeviceForm
                                        options:(ORKPredefinedTaskOption)options {

    NSMutableArray *steps = [NSMutableArray array];

    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    lengthFormatter.numberFormatter.maximumFractionDigits = 1;
    lengthFormatter.numberFormatter.maximumSignificantDigits = 3;
    NSString *formattedLength = [lengthFormatter stringFromMeters:distanceInMeters];

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_DETAIL", nil);
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (includeAssistiveDeviceForm) {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:ORKTimedWalkFormStepIdentifier
                                                              title:ORKLocalizedString(@"TIMED_WALK_FORM_TITLE", nil)
                                                               text:ORKLocalizedString(@"TIMED_WALK_FORM_TEXT", nil)];

        ORKAnswerFormat *answerFormat1 = [ORKAnswerFormat booleanAnswerFormat];
        ORKFormItem *formItem1 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAFOStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_TEXT", nil)
                                                            answerFormat:answerFormat1];
        formItem1.optional = NO;

        NSArray *textChoices = @[ [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE"],
                                  [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_2", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE_2"],
                                  [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_3", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE_3"],
                                  [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_4", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE_4"],
                                  [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_5", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE_5"],
                                  [ORKTextChoice choiceWithText:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_6", nil) value:@"TIMED_WALK_QUESTION_2_CHOICE_6"] ];
        ORKAnswerFormat *answerFormat2 = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *formItem2 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAssistanceStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TITLE", nil)
                                                            answerFormat:answerFormat2];
        formItem2.placeholder = ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TEXT", nil);
        formItem2.optional = NO;

        step.formItems = @[formItem1, formItem2];
        step.optional = NO;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TIMED_WALK_INTRO_2_TEXT_%@", nil), formattedLength];
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"timer" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
        step.stepDuration = 5.0;

        ORKStepArrayAddStep(steps, step);
    }

    {
        NSMutableArray *recorderConfigurations = [NSMutableArray array];
        if (!(options & ORKPredefinedTaskOptionExcludePedometer)) {
            [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeAccelerometer)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                      frequency:100]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeDeviceMotion)) {
            [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                     frequency:100]];
        }
        if (! (options & ORKPredefinedTaskOptionExcludeLocation)) {
            [recorderConfigurations addObject:[[ORKLocationRecorderConfiguration alloc] initWithIdentifier:ORKLocationRecorderIdentifier]];
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial1StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = [[[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_%@", nil), formattedLength] stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-outbound" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }

        {
            if (turnAroundTimeLimit > 0) {
                ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTurnAroundStepIdentifier];
                step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
                step.text = [ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TURN", nil) stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil)]];
                step.spokenInstruction = step.text;
                step.recorderConfigurations = recorderConfigurations;
                step.distanceInMeters = 1;
                step.shouldTintImages = YES;
                step.image = [UIImage imageNamed:@"turnaround" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
                step.stepDuration = turnAroundTimeLimit == 0 ? CGFLOAT_MAX : turnAroundTimeLimit;

                ORKStepArrayAddStep(steps, step);
            }
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial2StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = [[[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_2", nil), formattedLength] stringByAppendingString:[@"\n" stringByAppendingString:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil)]];
            step.spokenInstruction = step.text;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-return" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];

        ORKStepArrayAddStep(steps, step);
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


#pragma mark - PSATTask

NSString *const ORKPSATStepIdentifier = @"psat";

+ (ORKOrderedTask *)PSATTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(nullable NSString *)intendedUseDescription
                          presentationMode:(ORKPSATPresentationMode)presentationMode
                     interStimulusInterval:(NSTimeInterval)interStimulusInterval
                          stimulusDuration:(NSTimeInterval)stimulusDuration
                              seriesLength:(NSInteger)seriesLength
                                   options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    NSString *versionTitle = @"";
    NSString *versionDetailText = @"";
    
    if (presentationMode == ORKPSATPresentationModeAuditory) {
        versionTitle = ORKLocalizedString(@"PASAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PASAT_INTRO_TEXT", nil);
    } else if (presentationMode == ORKPSATPresentationModeVisual) {
        versionTitle = ORKLocalizedString(@"PVSAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PVSAT_INTRO_TEXT", nil);
    } else {
        versionTitle = ORKLocalizedString(@"PAVSAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PAVSAT_INTRO_TEXT", nil);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = versionTitle;
            step.detailText = versionDetailText;
            step.text = intendedUseDescription;
            step.image = [UIImage imageNamed:@"phonepsat" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = versionTitle;
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"PSAT_INTRO_TEXT_2_%@", nil), [NSNumberFormatter localizedStringFromNumber:@(interStimulusInterval) numberStyle:NSNumberFormatterDecimalStyle]];
            step.detailText = ORKLocalizedString(@"PSAT_CALL_TO_ACTION", nil);
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        step.title = versionTitle;

        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKPSATStep *step = [[ORKPSATStep alloc] initWithIdentifier:ORKPSATStepIdentifier];
        step.title = versionTitle;
        step.text = ORKLocalizedString(@"PSAT_INITIAL_INSTRUCTION", nil);
        step.stepDuration = (seriesLength + 1) * interStimulusInterval;
        step.presentationMode = presentationMode;
        step.interStimulusInterval = interStimulusInterval;
        step.stimulusDuration = stimulusDuration;
        step.seriesLength = seriesLength;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:[steps copy]];
    
    return task;
}


#pragma mark - tremorTestTask

NSString *const ORKTremorTestInLapStepIdentifier = @"tremor.handInLap";
NSString *const ORKTremorTestExtendArmStepIdentifier = @"tremor.handAtShoulderLength";
NSString *const ORKTremorTestBendArmStepIdentifier = @"tremor.handAtShoulderLengthWithElbowBent";
NSString *const ORKTremorTestTouchNoseStepIdentifier = @"tremor.handToNose";
NSString *const ORKTremorTestTurnWristStepIdentifier = @"tremor.handQueenWave";

+ (NSString *)stepIdentifier:(NSString *)stepIdentifier withHandIdentifier:(NSString *)handIdentifier {
    return [NSString stringWithFormat:@"%@.%@", stepIdentifier, handIdentifier];
}

+ (NSMutableArray *)stepsForOneHandTremorTestTaskWithIdentifier:(NSString *)identifier
                                             activeStepDuration:(NSTimeInterval)activeStepDuration
                                              activeTaskOptions:(ORKTremorActiveTaskOption)activeTaskOptions
                                                       lastHand:(BOOL)lastHand
                                                       leftHand:(BOOL)leftHand
                                                 handIdentifier:(NSString *)handIdentifier
                                                introDetailText:(NSString *)detailText
                                                        options:(ORKPredefinedTaskOption)options {
    NSMutableArray<ORKActiveStep *> *steps = [NSMutableArray array];
    NSString *stepFinishedInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_FINISHED_INSTRUCTION", nil);
    BOOL rightHand = !leftHand && ![handIdentifier isEqualToString:ORKActiveTaskMostAffectedHandIdentifier];
    
    {
        NSString *stepIdentifier = [self stepIdentifier:ORKInstruction1StepIdentifier withHandIdentifier:handIdentifier];
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
        step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
        
        if ([identifier isEqualToString:ORKActiveTaskMostAffectedHandIdentifier]) {
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DEFAULT_TEXT", nil);
            step.text = detailText;
        } else {
            if (leftHand) {
                step.detailText = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_LEFT_HAND_TEXT", nil);
            } else {
                step.detailText = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_RIGHT_HAND_TEXT", nil);
            }
        }
        
        NSString *imageName = leftHand ? @"tremortestLeft" : @"tremortestRight";
        step.image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        step.shouldTintImages = YES;
        
        ORKStepArrayAddStep(steps, step);
    }

    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandInLap)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction2StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO", nil);
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest3a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest3b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown1StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestInLapStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac1_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac1_motion" frequency:100.0]];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.text;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction4StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO", nil);
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest4a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest4b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown2StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestExtendArmStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac2_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac2_motion" frequency:100.0]];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.text;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.image = [UIImage imageNamed:@"tremortest4a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction5StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO", nil);
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest5a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest5b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown3StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestBendArmStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac3_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac3_motion" frequency:100.0]];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.text;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandToNose)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction6StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO", nil);
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest6a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest6b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown4StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestTouchNoseStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac4_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac4_motion" frequency:100.0]];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.text;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeQueenWave)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction7StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO", nil);
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest7" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown5StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestTurnWristStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac5_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac5_motion" frequency:100.0]];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.text;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // fix the spoken instruction on the last included step, depending on which hand we're on
    ORKActiveStep *lastStep = (ORKActiveStep *)[steps lastObject];
    if (lastHand) {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_COMPLETED_INSTRUCTION", nil);
    } else if (leftHand) {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_SWITCH_HANDS_RIGHT_INSTRUCTION", nil);
    } else {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_SWITCH_HANDS_LEFT_INSTRUCTION", nil);
    }
    
    return steps;
}

+ (ORKNavigableOrderedTask *)tremorTestTaskWithIdentifier:(NSString *)identifier
                                   intendedUseDescription:(nullable NSString *)intendedUseDescription
                                       activeStepDuration:(NSTimeInterval)activeStepDuration
                                        activeTaskOptions:(ORKTremorActiveTaskOption)activeTaskOptions
                                              handOptions:(ORKPredefinedTaskHandOption)handOptions
                                                  options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray<__kindof ORKStep *> *steps = [NSMutableArray array];
    // coin toss for which hand first (in case we're doing both)
    BOOL leftFirstIfDoingBoth = arc4random_uniform(2) == 1;
    BOOL doingBoth = ((handOptions & ORKPredefinedTaskHandOptionLeft) && (handOptions & ORKPredefinedTaskHandOptionRight));
    BOOL firstIsLeft = (leftFirstIfDoingBoth && doingBoth) || (!doingBoth && (handOptions & ORKPredefinedTaskHandOptionLeft));
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.detailText = intendedUseDescription;
            step.text = ORKLocalizedString(@"TREMOR_TEST_INTRO_1_DETAIL", nil);
            step.image = [UIImage imageNamed:@"tremortest1" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (firstIsLeft) {
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // Build the string for the detail texts
    NSArray<NSString *>*detailStringForNumberOfTasks = @[
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_1_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_2_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_3_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_4_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_5_TASK", nil)
                                                         ];
    
    // start with the count for all the tasks, then subtract one for each excluded task flag
    static const NSInteger allTasks = 5; // hold in lap, outstretched arm, elbow bent, repeatedly touching nose, queen wave
    NSInteger actualTasksIndex = allTasks - 1;
    for (NSInteger i = 0; i < allTasks; ++i) {
        if (activeTaskOptions & (1 << i)) {
            actualTasksIndex--;
        }
    }
    
    NSString *detailFormat = doingBoth ? ORKLocalizedString(@"TREMOR_TEST_SKIP_QUESTION_BOTH_HANDS_%@", nil) : ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_DEFAULT_%@", nil);
    NSString *detailText = [NSString localizedStringWithFormat:detailFormat, detailStringForNumberOfTasks[actualTasksIndex]];
    
    if (doingBoth) {
        // If doing both hands then ask the user if they need to skip one of the hands
        ORKTextChoice *skipRight = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_RIGHT_HAND", nil)
                                                          value:ORKActiveTaskRightHandIdentifier];
        ORKTextChoice *skipLeft = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_LEFT_HAND", nil)
                                                          value:ORKActiveTaskLeftHandIdentifier];
        ORKTextChoice *skipNeither = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_NEITHER", nil)
                                                             value:@""];

        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[skipRight, skipLeft, skipNeither]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:ORKActiveTaskSkipHandStepIdentifier
                                                                      title:ORKLocalizedString(@"TREMOR_TEST_TITLE", nil)
                                                                   question:detailText
                                                                     answer:answerFormat];
        step.optional = NO;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    // right or most-affected hand
    NSArray<__kindof ORKStep *> *rightSteps = nil;
    if (handOptions == ORKPredefinedTaskHandOptionUnspecified) {
        rightSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                    activeStepDuration:activeStepDuration
                                                     activeTaskOptions:activeTaskOptions
                                                              lastHand:YES
                                                              leftHand:NO
                                                        handIdentifier:ORKActiveTaskMostAffectedHandIdentifier
                                                       introDetailText:detailText
                                                               options:options];
    } else if (handOptions & ORKPredefinedTaskHandOptionRight) {
        rightSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                    activeStepDuration:activeStepDuration
                                                     activeTaskOptions:activeTaskOptions
                                                              lastHand:firstIsLeft
                                                              leftHand:NO
                                                        handIdentifier:ORKActiveTaskRightHandIdentifier
                                                       introDetailText:nil
                                                               options:options];
    }
    
    // left hand
    NSArray<__kindof ORKStep *> *leftSteps = nil;
    if (handOptions & ORKPredefinedTaskHandOptionLeft) {
        leftSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                   activeStepDuration:activeStepDuration
                                                    activeTaskOptions:activeTaskOptions
                                                             lastHand:!firstIsLeft || !(handOptions & ORKPredefinedTaskHandOptionRight)
                                                             leftHand:YES
                                                       handIdentifier:ORKActiveTaskLeftHandIdentifier
                                                      introDetailText:nil
                                                              options:options];
    }
    
    if (firstIsLeft && leftSteps != nil) {
        [steps addObjectsFromArray:leftSteps];
    }
    
    if (rightSteps != nil) {
        [steps addObjectsFromArray:rightSteps];
    }
    
    if (!firstIsLeft && leftSteps != nil) {
        [steps addObjectsFromArray:leftSteps];
    }
    
    BOOL hasCompletionStep = NO;
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        hasCompletionStep = YES;
        ORKCompletionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    if (doingBoth) {
        // Setup rules for skipping all the steps in either the left or right hand if called upon to do so.
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithStepIdentifier:ORKActiveTaskSkipHandStepIdentifier
                                                                         resultIdentifier:ORKActiveTaskSkipHandStepIdentifier];
        NSPredicate *predicateRight = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:ORKActiveTaskRightHandIdentifier];
        NSPredicate *predicateLeft = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:ORKActiveTaskLeftHandIdentifier];
        
        // Setup rule for skipping first hand
        NSString *secondHandIdentifier = firstIsLeft ? [[rightSteps firstObject] identifier] : [[leftSteps firstObject] identifier];
        NSPredicate *firstPredicate = firstIsLeft ? predicateLeft : predicateRight;
        ORKStepNavigationRule *skipFirst = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[firstPredicate]
                                                                                 destinationStepIdentifiers:@[secondHandIdentifier]];
        [task setNavigationRule:skipFirst forTriggerStepIdentifier:ORKActiveTaskSkipHandStepIdentifier];
        
        // Setup rule for skipping the second hand
        NSString *triggerIdentifier = firstIsLeft ? [[leftSteps lastObject] identifier] : [[rightSteps lastObject] identifier];
        NSString *conclusionIdentifier = hasCompletionStep ? [[steps lastObject] identifier] : ORKNullStepIdentifier;
        NSPredicate *secondPredicate = firstIsLeft ? predicateRight : predicateLeft;
        ORKStepNavigationRule *skipSecond = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[secondPredicate]
                                                                                  destinationStepIdentifiers:@[conclusionIdentifier]];
        [task setNavigationRule:skipSecond forTriggerStepIdentifier:triggerIdentifier];
        
        // Setup step modifier to change the finished spoken step if skipping the second hand
        NSString *key = NSStringFromSelector(@selector(finishedSpokenInstruction));
        NSString *value = ORKLocalizedString(@"TREMOR_TEST_COMPLETED_INSTRUCTION", nil);
        ORKStepModifier *stepModifier = [[ORKKeyValueStepModifier alloc] initWithResultPredicate:secondPredicate
                                                                                     keyValueMap:@{key: value}];
        [task setStepModifier:stepModifier forStepIdentifier:triggerIdentifier];
    }
    
    return task;
}


#pragma mark - trailmakingTask

NSString *const ORKTrailmakingStepIdentifier = @"trailmaking";

+ (ORKOrderedTask *)trailmakingTaskWithIdentifier:(NSString *)identifier
                           intendedUseDescription:(nullable NSString *)intendedUseDescription
                           trailmakingInstruction:(nullable NSString *)trailmakingInstruction
                                        trailType:(ORKTrailMakingTypeIdentifier)trailType
                                          options:(ORKPredefinedTaskOption)options {
    
    NSArray *supportedTypes = @[ORKTrailMakingTypeIdentifierA, ORKTrailMakingTypeIdentifierB];
    NSAssert1([supportedTypes containsObject:trailType], @"Trail type %@ is not supported.", trailType);
    
    NSMutableArray<__kindof ORKStep *> *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            if ([trailType isEqualToString:ORKTrailMakingTypeIdentifierA]) {
                step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE2_A", nil);
            } else {
                step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE2_B", nil);
            }
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            step.text = trailmakingInstruction ? : ORKLocalizedString(@"TRAILMAKING_INTRO_TEXT",nil);
            step.detailText = ORKLocalizedString(@"TRAILMAKING_CALL_TO_ACTION", nil);
            if (UIAccessibilityIsVoiceOverRunning()) {
                step.detailText = [NSString stringWithFormat:ORKLocalizedString(@"AX_TRAILMAKING_CALL_TO_ACTION_VOICEOVER", nil), step.detailText];
            }
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
        step.stepDuration = 3.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKTrailmakingStep *step = [[ORKTrailmakingStep alloc] initWithIdentifier:ORKTrailmakingStepIdentifier];
        step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
        step.trailType = trailType;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

@end
