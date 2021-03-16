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


#import "ORKStandingBendingRangeOfMotionStepViewController.h"
#import "ORKStandingBendingRangeOfMotionStep.h"
#import "ORKRangeOfMotionResult.h"

#import "ORKStepViewController_Internal.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"


NSString *const sagittal = @"sagittal";
NSString *const frontal = @"frontal";

#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))
#define allOrientationsForRoll(x, w, y, z) (atan2(2.0 * (y*w - x*z), 1.0 - 2.0 * (y*y + z*z)))
#define allOrientationsForYaw(x, w, y, z) (asin(2.0 * (x*y - w*z)))


@interface ORKRangeOfMotionContentView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property (nonatomic, strong, readonly) ORKProgressView *progressView;

@end


@interface ORKStandingBendingRangeOfMotionStepViewController () <ORKDeviceMotionRecorderDelegate> {
    ORKRangeOfMotionContentView *_contentView;
    UITapGestureRecognizer *_gestureRecognizer;
    CMAttitude *_referenceAttitude;
}

@end


@implementation ORKStandingBendingRangeOfMotionStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [ORKRangeOfMotionContentView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _contentView;
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.activeStepView addGestureRecognizer:_gestureRecognizer];
    
     // Initiate orientation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _orientation = [[UIDevice currentDevice] orientation]; // captures the initial device orientation
}

- (ORKStandingBendingRangeOfMotionStep *)standingBendingRangeOfMotionStep {
    return (ORKStandingBendingRangeOfMotionStep *)self.step;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
 
    // End orientation notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}
 
// Record the angle of the device when the screen is tapped
- (void)handleTap:(UIGestureRecognizer *)sender {
    [self calculateAndSetAngles];
    [self finish];
}

- (void)calculateAndSetAngles {
    _startAngle = ([self getDeviceAngleInDegreesFromAttitude:_referenceAttitude]);
    //Calculate maximum and minimum angles recorded by the device
    if (_newAngle > _maxAngle) {
        _maxAngle = _newAngle;
    }
    if (_newAngle < _minAngle) {
        _minAngle = _newAngle;
    }
}

#pragma mark - ORKDeviceMotionRecorderDelegate

- (NSString *)getCurrentPlaneOfRotation {
    NSString *plane;
    if (self.standingBendingRangeOfMotionStep.movementOption & ORKPredefinedTaskMovementOptionBendingForwards || self.standingBendingRangeOfMotionStep.movementOption & ORKPredefinedTaskMovementOptionBendingBackwards) {
        plane = sagittal;
    } else if (self.standingBendingRangeOfMotionStep.movementOption &
        ORKPredefinedTaskMovementOptionBendingRight ||
        self.standingBendingRangeOfMotionStep.movementOption &
        ORKPredefinedTaskMovementOptionBendingLeft) {
        plane = frontal;
    }
    return plane;
}

- (void)deviceMotionRecorderDidUpdateWithMotion:(CMDeviceMotion *)motion {
    if (!_referenceAttitude) {
        _referenceAttitude = motion.attitude;
    }
    CMAttitude *currentAttitude = [motion.attitude copy];
    [currentAttitude multiplyByInverseOfAttitude:_referenceAttitude]; // attitude relative to start
    double angle = [self getDeviceAngleInDegreesFromAttitude:currentAttitude];
    
    //During sagittal bending, we need to shift the range of angles reported by the device from +/-180 degrees to -90 to +270 degrees, in order to cover all achievable forward and backward bending ranges of motion
    if ([[self getCurrentPlaneOfRotation] isEqual:sagittal]) {
        if (UIDeviceOrientationLandscapeLeft == _orientation) {
            //BOOL shiftAngleRange = angle > 90 && angle <= 180;
            if (angle > 90 && angle <= 180) {
                _newAngle = fabs(angle) - 360;
            } else {
                _newAngle = angle;
            }
        } else if (UIDeviceOrientationPortrait == _orientation) {
            //BOOL shiftAngleRange = angle < -90 && angle >= -180;
            if (angle < -90 && angle >= -180) {
                _newAngle = 360 - fabs(angle);
            } else {
                _newAngle = angle;
            }
        } else if (UIDeviceOrientationLandscapeRight == _orientation) {
            //BOOL shiftAngleRange = angle < -90 && angle >= -180;
            if (angle < -90 && angle >= -180) {
                _newAngle = 360 - fabs(angle);
            } else {
                _newAngle = angle;
            }
        } else if (UIDeviceOrientationPortraitUpsideDown == _orientation) {
            //BOOL shiftAngleRange = angle > 90 && angle <= 180;
            if (angle > 90 && angle <= 180) {
                _newAngle = fabs(angle) - 360;
            } else {
                _newAngle = angle;
            }
        }
    }
    [self calculateAndSetAngles];
}
    
/*
 When the device is in Portrait mode, we need to get the attitude's pitch
 to determine the device's angle. attitude.pitch doesn't return all
 orientations, so we use the attitude's quaternion to calculate the
 angle.
 */
- (double)getDeviceAngleInDegreesFromAttitude:(CMAttitude *)attitude {
    double angle = 0.0;
    double x = attitude.quaternion.x;
    double w = attitude.quaternion.w;
    double y = attitude.quaternion.y;
    double z = attitude.quaternion.z;
    
    if ([[self getCurrentPlaneOfRotation] isEqual:sagittal]) {
        if (UIDeviceOrientationIsLandscape(_orientation)) {
            angle = radiansToDegrees(allOrientationsForRoll(x, w, y, z));
        } else if (UIDeviceOrientationIsPortrait(_orientation)) {
            angle = radiansToDegrees(allOrientationsForPitch(x, w, y, z));
        }
    } else if ([[self getCurrentPlaneOfRotation] isEqual:frontal]) {
            angle = radiansToDegrees(allOrientationsForYaw(x, w, y, z));
    }
    return angle;
}


#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    
    if ([[self getCurrentPlaneOfRotation] isEqual:sagittal]) {
        if (UIDeviceOrientationLandscapeLeft == _orientation) {
            result.orientation = ORIENTATION_LANDSCAPE_LEFT;
            result.start = -90.0 - _startAngle;
            result.finish = result.start + _newAngle;
        // In Landscape Left device orientation, the task uses roll in the direction opposite to the original CoreMotion device axes (i.e. right hand rule). Therefore, maximum and minimum angles are reported the 'wrong' way around for the forward bending tasks.
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
        }
    } else if ([[self getCurrentPlaneOfRotation] isEqual:frontal] &&
               (_orientation == UIDeviceOrientationLandscapeLeft ||
                _orientation == UIDeviceOrientationPortrait ||
                _orientation == UIDeviceOrientationLandscapeRight ||
                _orientation == UIDeviceOrientationPortraitUpsideDown)) {
        result.start = _startAngle;
        result.finish = result.start + _newAngle;
        result.minimum = result.start + _minAngle;
        result.maximum = result.start + _maxAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (!UIDeviceOrientationIsValidInterfaceOrientation(_orientation)) { // the phone should be upright at the outset of every standing bending task, or the data will be useless
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
