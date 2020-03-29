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


#import "ORKForwardBendingRangeOfMotionStepViewController.h"

#import "ORKRangeOfMotionResult.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"


#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))
#define allOrientationsForRoll(x, w, y, z) (atan2(2.0 * (y*w - x*z), 1.0 - 2.0 * (y*y + z*z)))
#define allOrientationsForYaw(x, w, y, z) (asin(2.0 * (x*y - w*z)))


@implementation ORKForwardBendingRangeOfMotionStepViewController


#pragma mark - ORKDeviceMotionRecorderDelegate
    
//Method to shift the range of angles reported by the device from +/-180 degrees to -90 to +270 degrees, which should be sufficient to cover all achievable forward bending ranges of motion
-(double)shiftAngleRange:(double)angle {
    if (UIDeviceOrientationLandscapeLeft == _orientation) {
        BOOL angleRange = angle > 90 && angle <= 180;
        if (angleRange) {
            _newAngle = fabs(angle) - 360;
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationPortrait == _orientation) {
        BOOL angleRange = angle < -90 && angle >= -180;
        if (angleRange) {
            _newAngle = 360 - fabs(angle);
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationLandscapeRight == _orientation) {
        BOOL angleRange = angle < -90 && angle >= -180;
        if (angleRange) {
            _newAngle = 360 - fabs(angle);
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationPortraitUpsideDown == _orientation) {
        BOOL shiftAngleRange = angle > 90 && angle <= 180;
        if (shiftAngleRange) {
            _newAngle = fabs(angle) - 360;
        } else {
            _newAngle = angle;
        }
    }
    return _newAngle;
}

/*
 When the device is in Portrait mode, we need to get the attitude's pitch
 to determine the device's angle. attitude.pitch doesn't return all
 orientations, so we use the attitude's quaternion to calculate the
 angle.
 */
- (double)getDeviceAngleInDegreesFromAttitude:(CMAttitude *)attitude {
    double angle = 0.0;
    if (UIDeviceOrientationIsLandscape(_orientation)) {
        double x = attitude.quaternion.x;
        double w = attitude.quaternion.w;
        double y = attitude.quaternion.y;
        double z = attitude.quaternion.z;
        angle = radiansToDegrees(allOrientationsForRoll(x, w, y, z));
    } else if (UIDeviceOrientationIsPortrait(_orientation)) {
        double x = attitude.quaternion.x;
        double w = attitude.quaternion.w;
        double y = attitude.quaternion.y;
        double z = attitude.quaternion.z;
        angle = radiansToDegrees(allOrientationsForPitch(x, w, y, z));
    }
    return angle;
}


#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    
    int ORIENTATION_UNSPECIFIED = -1;
    int ORIENTATION_LANDSCAPE_LEFT = 0; // equivalent to LANDSCAPE in Android
    int ORIENTATION_PORTRAIT = 1;
    int ORIENTATION_LANDSCAPE_RIGHT = 2; // equivalent to REVERSE_LANDSCAPE in Android
    int ORIENTATION_PORTRAIT_UPSIDE_DOWN = 3;  // equivalent to REVERSE_PORTRAIT in Android
    
    // Duration of recording (seconds)
    result.duration = _totalTime; // sumDeltaTime or total_time

    // Greatest positive acceleration along x-axis
    result.maximumAx = _maxAx;

    // Greatest negative acceleration along x-axis
    result.minimumAx = _minAx;
    
    // Greatest positive acceleration along y-axis
    result.maximumAy = _maxAy;
    
    // Greatest negative acceleration along y-axis
    result.minimumAy = _minAy;

    // Greatest positive acceleration along z-axis
    result.maximumAz = _maxAz;
    
    // Greatest negative acceleration along z-axis
    result.minimumAz = _minAz;

    // Maximum resultant acceleration
    result.maximumAr = _maxAr;

    // Mean resultant acceleration
    result.meanAr = _meanAr;

    // Standard deviation of resultant acceleration
    result.SDAr = _standardDevAr;

    // Greatest positive jerk along x-axis
    result.maximumJx = _maxJx;

    // Greatest negative jerk along x-axis
    result.minimumJx = _minJx;
    
    // Greatest positive jerk along y-axis
    result.maximumJy = _maxJy;
    
    // Greatest negative jerk along y-axis
    result.minimumJy = _minJy;
    
    // Greatest positive jerk along z-axis
    result.maximumJz = _maxJz;
    
    // Greatest negative jerk along z-axis
    result.minimumJz = _minJz;

    // Maximum resultant jerk
    result.maximumJr = _maxJr;

    // Mean resultant jerk
    result.meanJerk = _meanJr;

    // Standard deviation of resultant jerk
    result.SDJerk = _standardDevJr;

    // Time-normalized integrated resultant jerk (smoothness)
    result.timeNormIntegratedJerk = _integratedJerk / _totalTime;

    // Device orientation and angles
    if (UIDeviceOrientationLandscapeLeft == _orientation) {
        result.orientation = ORIENTATION_LANDSCAPE_LEFT;
        result.start = -90.0 - _startAngle;
        result.finish = result.start + _newAngle;
    // In Lanscape Left device orientation, the task uses roll in the direction opposite to the original CoreMotion device axes (i.e. right hand rule). Therefore, maximum and minimum angles are reported the 'wrong' way around for the forward bending tasks.
        result.minimum = result.start - _maxAngle;
        result.maximum = result.start - _minAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationPortrait == _orientation) {
        result.orientation = ORIENTATION_PORTRAIT;
        result.start = _startAngle - 90.0;
        result.finish = result.start + _newAngle;
        result.minimum = result.start + _minAngle;
        result.maximum = result.start + _maxAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationLandscapeRight == _orientation) {
        result.orientation = ORIENTATION_LANDSCAPE_RIGHT;
        result.start = _startAngle - 90.0;
        result.finish = result.start + _newAngle;
        result.minimum = result.start + _minAngle;
        result.maximum = result.start + _maxAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationPortraitUpsideDown == _orientation) {
        result.orientation = ORIENTATION_PORTRAIT_UPSIDE_DOWN;
        result.start = 90.0 + _startAngle;
        result.finish = result.start + _newAngle;
    // In Portrait Upside Down device orientation, the task uses pitch in the direction opposite to the original CoreMotion device axes.
        result.minimum = result.start - _maxAngle;
        result.maximum = result.start - _minAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (!UIDeviceOrientationIsValidInterfaceOrientation(_orientation)) {
        result.orientation = ORIENTATION_UNSPECIFIED;
        result.start = NAN;
        result.finish = NAN;
        result.minimum = NAN;
        result.maximum = NAN;
        result.range = NAN;
    }
               
    stepResult.results = [self.addedResults arrayByAddingObject:result] ? : @[result];
    
    return stepResult;
}

@end
