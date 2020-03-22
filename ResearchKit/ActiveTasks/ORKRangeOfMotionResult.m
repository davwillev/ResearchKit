/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 
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


#import "ORKRangeOfMotionResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKRangeOfMotionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, duration);
    ORK_ENCODE_INTEGER(aCoder, orientation);
    ORK_ENCODE_DOUBLE(aCoder, maximumAx);
    ORK_ENCODE_DOUBLE(aCoder, maximumAy);
    ORK_ENCODE_DOUBLE(aCoder, maximumAz);
    ORK_ENCODE_DOUBLE(aCoder, maximumAr);
    ORK_ENCODE_DOUBLE(aCoder, meanAr);
    ORK_ENCODE_DOUBLE(aCoder, SDAr);
    ORK_ENCODE_DOUBLE(aCoder, maximumJx);
    ORK_ENCODE_DOUBLE(aCoder, maximumJy);
    ORK_ENCODE_DOUBLE(aCoder, maximumJz);
    ORK_ENCODE_DOUBLE(aCoder, maximumJr);
    ORK_ENCODE_DOUBLE(aCoder, meanJerk);
    ORK_ENCODE_DOUBLE(aCoder, SDJerk);
    ORK_ENCODE_DOUBLE(aCoder, timeNormIntegratedJerk);
    ORK_ENCODE_DOUBLE(aCoder, start);
    ORK_ENCODE_DOUBLE(aCoder, finish);
    ORK_ENCODE_DOUBLE(aCoder, minimum);
    ORK_ENCODE_DOUBLE(aCoder, maximum);
    ORK_ENCODE_DOUBLE(aCoder, range);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, duration);
        ORK_DECODE_INTEGER(aDecoder, orientation);
        ORK_DECODE_DOUBLE(aDecoder, maximumAx);
        ORK_DECODE_DOUBLE(aDecoder, maximumAy);
        ORK_DECODE_DOUBLE(aDecoder, maximumAz);
        ORK_DECODE_DOUBLE(aDecoder, maximumAr);
        ORK_DECODE_DOUBLE(aDecoder, meanAr);
        ORK_DECODE_DOUBLE(aDecoder, SDAr);
        ORK_DECODE_DOUBLE(aDecoder, maximumJx);
        ORK_DECODE_DOUBLE(aDecoder, maximumJy);
        ORK_DECODE_DOUBLE(aDecoder, maximumJz);
        ORK_DECODE_DOUBLE(aDecoder, maximumJr);
        ORK_DECODE_DOUBLE(aDecoder, meanJerk);
        ORK_DECODE_DOUBLE(aDecoder, SDJerk);
        ORK_DECODE_DOUBLE(aDecoder, timeNormIntegratedJerk);
        ORK_DECODE_DOUBLE(aDecoder, start);
        ORK_DECODE_DOUBLE(aDecoder, finish);
        ORK_DECODE_DOUBLE(aDecoder, minimum);
        ORK_DECODE_DOUBLE(aDecoder, maximum);
        ORK_DECODE_DOUBLE(aDecoder, range);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return isParentSame &&
    self.duration == castObject.duration &&
    self.orientation == castObject.orientation &&
    self.maximumAx == castObject.maximumAx &&
    self.maximumAy == castObject.maximumAy &&
    self.smaximumAz == castObject.maximumAz &&
    self.maximumAr == castObject.maximumAr &&
    self.meanAr == castObject.meanAr &&
    self.SDAr == castObject.SDAr &&
    self.maximumJx == castObject.maximumJx &&
    self.maximumJy == castObject.maximumJy &&
    self.maximumJz == castObject.maximumJz &&
    self.maximumJr == castObject.maximumJr &&
    self.meanJerk == castObject.meanJerk &&
    self.SDJerk == castObject.SDJerk &&
    self.timeNormIntegratedJerk == castObject.timeNormIntegratedJerk &&
    self.start == castObject.start &&
    self.finish == castObject.finish &&
    self.minimum == castObject.minimum &&
    self.maximum == castObject.maximum &&
    self.range == castObject.range;
}

- (NSUInteger)hash {
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRangeOfMotionResult *result = [super copyWithZone:zone];
    result.duration = self.duration;
    result.orientation = self.orientation;
    result.maximumAx = self.maximumAx;
    result.maximumAy = self.maximumAy;
    result.maximumAz = self.maximumAz;
    result.maximumAr = self.maximumAr;
    result.meanAr = self.meanAr;
    result.SDAr = self.SDAr;
    result.maximumJx = self.maximumJx;
    result.maximumJy = self.maximumJy;
    result.maximumJz = self.maximumJz;
    result.maximumJr = self.maximumJr;
    result.meanJerk = self.meanJerk;
    result.SDJerk = self.SDJerk;
    result.timeNormIntegratedJerk = self.timeNormIntegratedJerk;
    result.start = self.start;
    result.finish = self.finish;
    result.minimum = self.minimum;
    result.maximum = self.maximum;
    result.range = self.range;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"<%@: duration: %f; orientation: %li; maximumAx: %f; maximumAy: %f; maximumAz: %f; maximumAr: %f; meanAr: %f; SDAr: %f; maximumJx: %f; maximumJy: %f; maximumJz: %f; maximumJr: %f; meanJerk: %f; SDJerk: %f; timeNormIntegratedJerk: %f; start: %f; finish: %f; minimum: %f; maximum: %f; range: %f>", self.class.description, self.duration, self.orientation, self.maximumAx, self.maximumAy, self.maximumAz, self.maximumAr, self.meanAr, self.SDAr, self.maximumJx, self.maximumJy, self.maximumJz, self.maximumJr, self.meanJerk, self.SDJerk, self.timeNormIntegratedJerk, self.start, self.finish, self.minimum, self.maximum, self.range];
}

@end
