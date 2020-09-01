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

#import <ResearchKit/ORKResult.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKLeftRightJudgementResult` class represents the result of a single successful attempt within an ORKLeftRightJudgementStep.
 
 A left/right judgement result is typically generated by the framework as the task proceeds. When the task completes, it may be appropriate to serialize the sample for transmission to a server or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKLeftRightJudgementResult: ORKResult


/**
 The `duration` property is the time taken for each step, equal to the difference between the timestamp from when the image is displayed to the timestamp when the button is pressed.
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 A Boolean value indicating whether the side of the body selected matches that which is presented.
 The value of this property is `YES` when the result is correct, and `NO` otherwise.
 */
@property (nonatomic, assign) BOOL correct;

/**
 The `imageName` property is the name of the image presented during the step.
 */
@property (nonatomic, copy) NSString *imageName;

/**
 The `sidePresented` property is the side of the body presented in the image.
 */
@property (nonatomic, copy) NSString *sidePresented;

/**
 The `sideSelected` property corresponds to the button tapped by the user as an answer.
 */
@property (nonatomic, copy, nullable) NSString *sideSelected;


@end

NS_ASSUME_NONNULL_END

