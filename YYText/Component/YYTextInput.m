//
//  YYTextInput.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/17.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextInput.h"
#import "YYTextUtilities.h"


@interface YYTextPosition ()
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) YYTextAffinity affinity;
@end

@implementation YYTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset {
    return [self positionWithOffset:offset affinity:YYTextAffinityForward];
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(YYTextAffinity)affinity {
    YYTextPosition *p = [self new];
    p.offset = offset;
    p.affinity = affinity;
    return p;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class positionWithOffset:self.offset affinity:self.affinity];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@%@)", self.class, self, @(self.offset), self.affinity == YYTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash {
    return self.offset * 2 + (self.affinity == YYTextAffinityForward ? 1 : 0);
}

- (BOOL)isEqual:(YYTextPosition *)object {
    if (!object) return NO;
    return self.offset == object.offset && self.affinity == object.affinity;
}

- (NSComparisonResult)compare:(YYTextPosition *)otherPosition {
    if (!otherPosition) return NSOrderedAscending;
    if (self.offset < otherPosition.offset) return NSOrderedAscending;
    if (self.offset > otherPosition.offset) return NSOrderedDescending;
    if (self.affinity == YYTextAffinityBackward && otherPosition.affinity == YYTextAffinityForward) return NSOrderedAscending;
    if (self.affinity == YYTextAffinityForward && otherPosition.affinity == YYTextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;
}

@end


@interface YYTextRange ()
@property (nonatomic, strong) YYTextPosition *start;
@property (nonatomic, strong) YYTextPosition *end;
@end

@implementation YYTextRange

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.start = [YYTextPosition positionWithOffset:0];
    self.end = [YYTextPosition positionWithOffset:0];
    return self;
}

- (YYTextPosition *)start {
    return _start; // Keep direct ivar access for getter if desired, or change to self.start
}

- (YYTextPosition *)end {
    return _end; // Keep direct ivar access for getter if desired, or change to self.end
}

- (BOOL)isEmpty {
    return self.start.offset == self.end.offset;
}

- (NSRange)asRange {
    return NSMakeRange(self.start.offset, self.end.offset - self.start.offset);
}

+ (instancetype)rangeWithRange:(NSRange)range {
    return [self rangeWithRange:range affinity:YYTextAffinityForward];
}

+ (instancetype)rangeWithRange:(NSRange)range affinity:(YYTextAffinity)affinity {
    YYTextPosition *startPos = [YYTextPosition positionWithOffset:range.location affinity:affinity];
    YYTextPosition *endPos = [YYTextPosition positionWithOffset:range.location + range.length affinity:affinity];
    return [self rangeWithStart:startPos end:endPos];
}

+ (instancetype)rangeWithStart:(YYTextPosition *)startPos end:(YYTextPosition *)endPos {
    if (!startPos || !endPos) return nil;
    if ([startPos compare:endPos] == NSOrderedDescending) {
        YYTEXT_SWAP(startPos, endPos);
    }
    YYTextRange *range = [YYTextRange new];
    range.start = startPos;
    range.end = endPos;
    return range;
}

+ (instancetype)defaultRange {
    return [self new];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class rangeWithStart:self.start end:self.end];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)%@", self.class, self, @(self.start.offset), @(self.end.offset - self.start.offset), self.end.affinity == YYTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash {
    return (sizeof(NSUInteger) == 8 ? OSSwapInt64(self.start.hash) : OSSwapInt32(self.start.hash)) + self.end.hash;
}

- (BOOL)isEqual:(YYTextRange *)object {
    if (!object) return NO;
    return [self.start isEqual:object.start] && [self.end isEqual:object.end];
}

@end



@implementation YYTextSelectionRect

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

- (id)copyWithZone:(NSZone *)zone {
    YYTextSelectionRect *one = [self.class new];
    one.rect = _rect;
    one.writingDirection = _writingDirection;
    one.containsStart = _containsStart;
    one.containsEnd = _containsEnd;
    one.isVertical = _isVertical;
    return one;
}

@end
