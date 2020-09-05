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

#import "ORKLeftRightJudgementResult.h"
#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@implementation ORKLeftRightJudgementResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, imageDuration);
    ORK_ENCODE_DOUBLE(aCoder, leftPercentCorrect);
    ORK_ENCODE_DOUBLE(aCoder, rightPercentCorrect);
    ORK_ENCODE_DOUBLE(aCoder, leftMeanDuration);
    ORK_ENCODE_DOUBLE(aCoder, rightMeanDuration);
    ORK_ENCODE_DOUBLE(aCoder, leftSDDuration);
    ORK_ENCODE_DOUBLE(aCoder, rightSDDuration);
    ORK_ENCODE_BOOL(aCoder, sideMatch);
    ORK_ENCODE_INTEGER(aCoder, imageNumber);
    ORK_ENCODE_OBJ(aCoder, imageName);
    ORK_ENCODE_OBJ(aCoder, orientationPresented);
    ORK_ENCODE_OBJ(aCoder, sidePresented);
    ORK_ENCODE_OBJ(aCoder, sideSelected);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, imageDuration);
        ORK_DECODE_DOUBLE(aDecoder, leftPercentCorrect);
        ORK_DECODE_DOUBLE(aDecoder, rightPercentCorrect);
        ORK_DECODE_DOUBLE(aDecoder, leftMeanDuration);
        ORK_DECODE_DOUBLE(aDecoder, rightMeanDuration);
        ORK_DECODE_DOUBLE(aDecoder, leftSDDuration);
        ORK_DECODE_DOUBLE(aDecoder, rightSDDuration);
        ORK_DECODE_BOOL(aDecoder, sideMatch);
        ORK_DECODE_INTEGER(aDecoder, imageNumber);
        ORK_DECODE_OBJ_CLASS(aDecoder, imageName, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, orientationPresented, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, sidePresented, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, sideSelected, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.imageDuration == castObject.imageDuration) &&
            (self.leftPercentCorrect == castObject.leftPercentCorrect) &&
            (self.rightPercentCorrect == castObject.rightPercentCorrect) &&
            (self.leftMeanDuration == castObject.leftMeanDuration) &&
            (self.rightMeanDuration == castObject.rightMeanDuration) &&
            (self.leftSDDuration == castObject.leftSDDuration) &&
            (self.rightSDDuration == castObject.rightSDDuration) &&
            (self.sideMatch == castObject.sideMatch) &&
            (self.imageNumber == castObject.imageNumber) &&
            ORKEqualObjects(self.imageName, castObject.imageName) &&
            ORKEqualObjects(self.orientationPresented, castObject.orientationPresented) &&
            ORKEqualObjects(self.sidePresented, castObject.sidePresented) &&
            ORKEqualObjects(self.sideSelected, castObject.sideSelected));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKLeftRightJudgementResult *result = [super copyWithZone:zone];
    result.imageDuration = self.imageDuration;
    result.leftPercentCorrect = self.leftPercentCorrect;
    result.rightPercentCorrect = self.rightPercentCorrect;
    result.leftMeanDuration = self.leftMeanDuration;
    result.rightMeanDuration = self.rightMeanDuration;
    result.leftSDDuration = self.leftSDDuration;
    result.rightSDDuration = self.rightSDDuration;
    result.sideMatch = self.sideMatch;
    result.imageNumber = self.imageNumber;
    result -> _imageName = [self.imageName copy];
    result -> _orientationPresented = [self.orientationPresented copy];
    result -> _sidePresented = [self.sidePresented copy];
    result -> _sideSelected = [self.sideSelected copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; imageDuration: %f; leftPercentCorrect: %f; rightPercentCorrect: %f; leftMeanDuration: %f; rightMeanDuration: %f; leftSDDuration: %f; rightSDDuration: %f; sideMatch: %d; imageName: %@; orientationPresented: %@; sidePresented: %@; sideSelected: %@ %@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.imageDuration, self.leftPercentCorrect, self.rightPercentCorrect, self.leftMeanDuration, self.rightMeanDuration, self.leftSDDuration, self.rightSDDuration, self.sideMatch, self.imageName, self.orientationPresented, self.sidePresented, self.sideSelected, self.descriptionSuffix];
}


@end
