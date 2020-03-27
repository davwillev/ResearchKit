/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 Copyright (c) 2020, David W. Evans. All rights reserved.
 
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


#import <ResearchKit/ResearchKit.h>
#import <CoreMotion/CMDeviceMotion.h>


NS_ASSUME_NONNULL_BEGIN

/**
 This class is used by the `ORKRangeOfMotionStep.` Its result corresponds to the device's orientation
 as recorded by CoreMotion.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangeOfMotionStepViewController : ORKActiveStepViewController {
    UIDeviceOrientation _orientation;
    double _startAngle, _newAngle;
    double _minAngle, _maxAngle;
    double _maxAx, _maxAy, _maxAz;
    double _minAx, _minAy, _minAz;
    double _maxJx, _maxJy, _maxJz;
    double _minJx, _minJy, _minJz;
    double _maxAr, _meanAr, _varianceAr, _standardDevAr;
    double _maxJr, _meanJr, _varianceJr, _standardDevJr;
    double _totalTime;
    double _timeNormalizedIntegratedJerk;
}

@end

NS_ASSUME_NONNULL_END
