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


#import "ORKRangeOfMotionStepViewController.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"
#import "ORKRangeOfMotionResult.h"
#import "ORKSkin.h"

#include <mach/mach_time.h>


#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))
#define allOrientationsForRoll(x, w, y, z) (atan2(2.0 * (y*w - x*z), 1.0 - 2.0 * (y*y + z*z)))
#define allOrientationsForYaw(x, w, y, z) (asin(2.0 * (x*y - w*z)))


@interface ORKRangeOfMotionContentView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property (nonatomic, strong, readonly) ORKProgressView *progressView;

@end


@implementation ORKRangeOfMotionContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progressView = [ORKProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_progressView];
        [self setUpConstraints];
        [self updateConstraintConstantsForWindow:self.window];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView);
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView]-(>=0)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    _topConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0]; // constant will be set in updateConstraintConstantsForWindow:
    [constraints addObject:_topConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    const CGFloat CaptionBaselineToProgressTop = 100;
    const CGFloat CaptionBaselineToStepViewTop = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTop, window);
    _topConstraint.constant = CaptionBaselineToProgressTop - CaptionBaselineToStepViewTop;
}

- (void)updateConstraints {
    [self updateConstraintConstantsForWindow:self.window];
    [super updateConstraints];
}

@end


@interface ORKRangeOfMotionStepViewController () <ORKDeviceMotionRecorderDelegate> {
    ORKRangeOfMotionContentView *_contentView;
    UITapGestureRecognizer *_gestureRecognizer;
    double sumDeltaTime;
    double _prevMa, _newMa, _prevSa, _newSa;
    double _prevMj, _newMj, _prevSj, _newSj;
    double _firstX, _prevX, _newX, _lastX;
    double _prevAccelX, _prevAccelY, _prevAccelZ;
    double _newAccelX, _newAccelY, _newAccelZ;
    double _deltaAccelX, _deltaAccelY, _deltaAccelZ;
    double _jerkX, _jerkY, _jerkZ;
    double _sumOdd, _sumEven, _h;
    double _integratedX;
    double _resultantJerk;
}

@end


@implementation ORKRangeOfMotionStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _contentView = [ORKRangeOfMotionContentView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _contentView;
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.activeStepView addGestureRecognizer:_gestureRecognizer];
    
     // Initiates orientation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _orientation = [[UIDevice currentDevice] orientation]; // captures the initial device orientation
}

   //When the screen is tapped, we need to stop recording
- (void)handleTap:(UIGestureRecognizer *)sender {
    [self calculateMaxAndMinAngles]; // not sure this is necessary here since value is already updated at every sensor pass through deviceMotionRecorderDidUpdateWithMotion
    
    // Ends orientation notifications
    //[[NSNotificationCenter defaultCenter] removeObserver:self]; // is this needed?
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [self finish];
}

/*
 Helper method to convert absolute time into seconds
 */
- (double)convertAbsoluteTimeIntoSeconds:(uint64_t) mach_time {
    mach_timebase_info_data_t _clock_timebase;
    mach_timebase_info(&_clock_timebase);
    double nanos = (mach_time * _clock_timebase.numer) / _clock_timebase.denom;
    return nanos / 10e8; // suprisingly, not correct when 10e9
}

/*
Helper methods to evaluate odd and even numbers
*/
- (BOOL)isOdd:(NSUInteger) n {
    return n % 2 != 0;
}

- (BOOL)isEven:(NSUInteger) n {
    return n % 2 == 0;
}

/* Method to calculate the numerical integral of a number (x) within a loop in which
 count and time duration are being measured (using extended Simpson's rule).
 For original formula, see: Press, Teukolsky, Vetterling, Flannery (2007) Numerical Recipes; p160.
*/
- (double)integrateSimpsons:(double)x usingCount:(int)count andDuration:(double)duration {
    if (count == 1) {
        _firstX = x;
    } else {
        _lastX = x; // updates to last iteration
    }
    if (count != 1) { // need to avoid a zero denominator at (n - 1)
        _h = duration / (count - 1);
    }
    // Sum of all odd (4/3) terms, excluding the first term (n == 1)
    if ([self isOdd: count] && (count != 1)) { // odds excluding '1'
        _sumOdd += 4.0 * x;
    }
    // Sum of all even (2/3) terms
    if ([self isEven: count]) { // even terms
        _sumEven += 2.0 * x;
    }
    if ([self isOdd: count]) { // odd terms
        _integratedX = _h * (_firstX + _sumOdd + _sumEven - (3.0 * _lastX)) / 3.0; // _lastX will have been added to sumEven 4 times, but we only want to retain one
    } else if ([self isEven: count]) { // even terms
        _integratedX = _h * (_firstX + _sumOdd + _sumEven - _lastX) / 3.0; // _lastX will have been added to sumEven 2 times, but we only want to retain one
    }
    return _integratedX;
}

/*
Calculate maximum and minimum angles recorded by the device
*/
- (void)calculateMaxAndMinAngles {
    //_startAngle = ([self getDeviceAngleInDegreesFromAttitude:_referenceAttitude]); // moved this
    if (_newAngle > _maxAngle) {
        _maxAngle = _newAngle;
    }
    if (_newAngle < _minAngle) {
        _minAngle = _newAngle;
    }
}

/*
Method that will cumulatively calculate userAcceleration statistics as it is called
within a loop with a count of each pass.
*/
- (void)calculateAccelerationResults:(CMDeviceMotion *)motion usingCount:(int)count {
    if (motion.userAcceleration.x > _maxAx) { // captures the greatest positive acceleration recorded along the x-axis (Ax)
        _maxAx = motion.userAcceleration.x;
    }
    if (motion.userAcceleration.x < _minAx) { // captures the greatest negative acceleration recorded along the x-axis (Ax)
        _minAx = motion.userAcceleration.x;
    }
    if (motion.userAcceleration.y > _maxAy) { // captures the greatest positive acceleration recorded along the y-axis (Ay)
        _maxAy = motion.userAcceleration.y;
    }
    if (motion.userAcceleration.y < _minAy) { // captures the greatest negative acceleration recorded along the y-axis (Ay)
        _minAy = motion.userAcceleration.y;
    }
    if (motion.userAcceleration.z > _maxAz) { // captures the greatest positive acceleration recorded along the z-axis (Az)
        _maxAz = motion.userAcceleration.z;
    }
    if (motion.userAcceleration.z < _minAz) { // captures the greatest negative acceleration recorded along the z-axis (Az)
        _minAz = motion.userAcceleration.z;
    }
    // calculate resultant acceleration (Ar)
    double resultant_accel = sqrt(
            (motion.userAcceleration.x * motion.userAcceleration.x) +
            (motion.userAcceleration.y * motion.userAcceleration.y) +
            (motion.userAcceleration.z * motion.userAcceleration.z));
    if (resultant_accel > _maxAr) { // captures the maximum recorded resultant acceleration
        _maxAr = resultant_accel;
    }
    // calculate mean and standard deviation of resultant acceleration (using Welford's algorithm)
    // see: Welford. (1962) Technometrics 4(3): 419-420.
    if (count == 1) {
        _prevMa = _newMa = resultant_accel;
        _prevSa = 0;
    } else {
        _newMa = _prevMa + (resultant_accel - _prevMa) / count;
        _newSa += _prevSa + (resultant_accel - _prevMa) * (resultant_accel - _newMa);
        _prevMa = _newMa;
    }
    _meanAr = (count > 0) ? _newMa : 0;
    _varianceAr = ((count > 1) ? _newSa / (count - 1) : 0);
    if (_varianceAr > 0) {
        _standardDevAr = sqrt(_varianceAr);
    }
}

/*
Method that will cumulatively calculate jerk statistics from userAcceleration data when
called within a loop with a counting variable
 */
- (void)calculateJerkResults:(CMDeviceMotion *)motion usingCount:(int)count {
    if (count == 1) {
        _first_time = _prev_time = _new_time = [self convertAbsoluteTimeIntoSeconds:mach_absolute_time()]; // captures first time value (in seconds)
        _prevAccelX = _newAccelX = motion.userAcceleration.x;
        _prevAccelY = _newAccelY = motion.userAcceleration.y;
        _prevAccelZ = _newAccelZ = motion.userAcceleration.x;
    } else {
        _prev_time = _new_time; // assigns previous time value
        _new_time = [self convertAbsoluteTimeIntoSeconds:mach_absolute_time()]; // immediately updates to the new time value (in seconds)
        double temp = sumDeltaTime + fabs(_new_time - _prev_time); // see: Press, Teukolsky, Vetterling, Flannery (2007) Numerical Recipes; p230.
        double delta_time = temp - sumDeltaTime;
        sumDeltaTime += delta_time; // sum of all deltas
        // assign previous accel values
        _prevAccelX = _newAccelX;
        _prevAccelY = _newAccelY;
        _prevAccelZ = _newAccelZ;
        // assign new accel values
        _newAccelX = motion.userAcceleration.x;
        _newAccelY = motion.userAcceleration.y;
        _newAccelZ = motion.userAcceleration.z;
        // calculate difference in acceleration between consecutive sensor measurements
        _deltaAccelX = _newAccelX - _prevAccelX;
        _deltaAccelY = _newAccelY - _prevAccelY;
        _deltaAccelZ = _newAccelZ - _prevAccelZ;
        // calculate jerk values
        _jerkX = _deltaAccelX / delta_time;
        _jerkY = _deltaAccelY / delta_time;
        _jerkZ = _deltaAccelZ / delta_time;
    }
    if (_jerkX > _maxJx) { // captures the greatest positive jerk recorded along the x-axis (Jx)
        _maxJx = _jerkX;
    }
    if (_jerkX < _minJx) { // captures the greatest negative jerk recorded along the x-axis (Jx)
        _minJx = _jerkX;
    }
    if (_jerkY > _maxJy) { // captures the greatest positive jerk recorded along the y-axis (Jy)
        _maxJy = _jerkY;
    }
    if (_jerkY < _minJy) { // captures the greatest negative jerk recorded along the y-axis (Jy)
        _minJy = _jerkY;
    }
    if (_jerkZ > _maxJz) { // captures the greatest positive jerk recorded along the z-axis (Jz)
        _maxJz = _jerkZ;
    }
    if (_jerkZ < _minJz) { // captures the greatest negative jerk recorded along the z-axis (Jz)
        _minJz = _jerkZ;
    }
    // calculate resultant jerk
    _resultantJerk = sqrt(
            (_jerkX * _jerkX) +
            (_jerkY * _jerkY) +
            (_jerkZ * _jerkZ));
     if (_resultantJerk > _maxJr) { // captures the maximum recorded resultant jerk
         _maxJr = _resultantJerk;
     }
    // Calculate mean and standard deviation of resultant jerk (using Welford's algorithm)
    if (count == 1) {
        _prevMj = _newMj = _resultantJerk;
        _prevSj = 0;
    } else {
        _newMj = _prevMj + (_resultantJerk - _prevMj) / count;
        _newSj = _prevSj += (_resultantJerk - _prevMj) * (_resultantJerk - _newMj);
        _prevMj = _newMj;
    }
    _meanJr = (count > 0) ? _newMj : 0; // mean
    _varianceJr = ((count > 1) ? _newSj / (count - 1) : 0); // variance
    if (_varianceJr > 0) {
        _standardDevJr = sqrt(_varianceJr); // standard deviation
    }
    _totalTime = fabs(_new_time - _first_time); // total time duration of entire recording (in seconds)
    // Calculate time integral of resultant jerk
    _integratedJerk = ([self integrateSimpsons:_resultantJerk usingCount:count andDuration:_totalTime]); // can use sumDeltaTime instead of _totalTime
}


#pragma mark - ORKDeviceMotionRecorderDelegate

- (void)deviceMotionRecorderDidUpdateWithMotion:(CMDeviceMotion *)motion {
    _count ++; // count each sensor pass
    
    /* Process device attitude data */
    //if (!_startAttitude) {
     if (_count == 1) {
        _startAttitude = motion.attitude; // captures start attitude (as quaternion)
        _startAngle = ([self getDeviceAngleInDegreesFromAttitude:_startAttitude]); // captures start angle
    }
    CMAttitude *currentAttitude = [motion.attitude copy];
    [currentAttitude multiplyByInverseOfAttitude:_startAttitude]; // calculates attitude rlative to start position
    double angle = [self getDeviceAngleInDegreesFromAttitude:currentAttitude]; // calculates angle (degrees) relative to start poistion
    [self shiftAngleRange:angle]; // shifts angle range as necessary
    [self calculateMaxAndMinAngles];
    
    /* Process device acclerometer data */
    [self calculateAccelerationResults:motion usingCount:_count];
    [self calculateJerkResults:motion usingCount:_count];
}

/* Method to shift the range of angles reported by the device from +/-180 degrees to -90
 to +270 degrees, which should be sufficient to cover all achievable forward bending
 ranges of motion
 */
-(double)shiftAngleRange:(double)angle {
    if (UIDeviceOrientationLandscapeLeft == _orientation) {
        BOOL shiftAngleRange = angle < -90 && angle >= -180;
        if (shiftAngleRange) {
            _newAngle = 360 - fabs(angle);
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationPortrait == _orientation) {
        BOOL shiftAngleRange = angle > 90 && angle <= 180;
        if (shiftAngleRange) {
            _newAngle = fabs(angle) - 360;
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationLandscapeRight == _orientation) {
        BOOL shiftAngleRange = angle > 90 && angle <= 180;
        if (shiftAngleRange) {
            _newAngle = fabs(angle) - 360;
        } else {
            _newAngle = angle;
        }
    } else if (UIDeviceOrientationPortraitUpsideDown == _orientation) {
       BOOL shiftAngleRange = angle < -90 && angle >= -180;
       if (shiftAngleRange) {
           _newAngle = 360 - fabs(angle);
       } else {
           _newAngle = angle;
       }
    }
    return _newAngle;
}

/*
When the device is in Portrait mode, we need to get the attitude's pitch to determine the
device's angle; whereas, when the device is in Landscape, we need the attitude's roll.
We can use the quaternion that represents the device's attitude to calculate the angle
in degrees around each axis.
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
    
    //int ORIENTATION_UNDETECTABLE = -2;
    int ORIENTATION_UNSPECIFIED = -1;
    int ORIENTATION_LANDSCAPE_LEFT = 0; // equivalent to LANDSCAPE in Android
    int ORIENTATION_PORTRAIT = 1;
    int ORIENTATION_LANDSCAPE_RIGHT = 2; // equivalent to REVERSE_LANDSCAPE in Android
    int ORIENTATION_PORTRAIT_UPSIDE_DOWN = 3;  // equivalent to REVERSE_PORTRAIT in Android
    
    // Duration of recording (seconds)
    result.duration = _totalTime; // or sumDeltaTime

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
    result.timeNormIntegratedJerk = _integratedJerk / result.duration;

    // Device orientation and angles
    if (UIDeviceOrientationLandscapeLeft == _orientation) {
        result.orientation = ORIENTATION_LANDSCAPE_LEFT;
        result.start = 90.0 + _startAngle;
        result.finish = result.start + _newAngle;
        result.minimum = result.start + _minAngle;
        result.maximum = result.start + _maxAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationPortrait == _orientation) {
        result.orientation = ORIENTATION_PORTRAIT;
        result.start = 90.0 - _startAngle;
        result.finish = result.start - _newAngle;
    // In Portrait device orientation, the task uses pitch in the direction opposite to the original CoreMotion device axes (i.e. right hand rule). Therefore, maximum and minimum angles are reported the 'wrong' way around for the knee and shoulder tasks.
        result.minimum = result.start - _maxAngle;
        result.maximum = result.start - _minAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationLandscapeRight == _orientation) {
        result.orientation = ORIENTATION_LANDSCAPE_RIGHT;
        result.start = 90.0 - _startAngle;
        result.finish = result.start - _newAngle;
    // In Landscape Right device orientation, the task uses roll in the direction opposite to the original CoreMotion device axes.
        result.minimum = result.start - _maxAngle;
        result.maximum = result.start - _minAngle;
        result.range = fabs(result.maximum - result.minimum);
    } else if (UIDeviceOrientationPortraitUpsideDown == _orientation) {
        result.orientation = ORIENTATION_PORTRAIT_UPSIDE_DOWN;
        result.start = -90 - _startAngle;
        result.finish = result.start + _newAngle;
        result.minimum = result.start + _minAngle;
        result.maximum = result.start + _maxAngle;
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
