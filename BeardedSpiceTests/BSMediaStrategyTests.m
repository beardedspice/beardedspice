//
//  BSMediaStrategyTests.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "Kiwi.h"
#import "BSMediaStrategy.h"

SPEC_BEGIN(BSMediaStrategyTests)

describe(@"Create an empty strategy", ^{
    let(path, ^{ return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"MediaStrategies"]; });

    it(@"will initialize defaults without template data", ^{
        NSString *fileName = @"random-file-name";
        NSURL *fileURL = [[NSURL alloc] initWithString:fileName relativeToURL:path];
        BSMediaStrategy *strategy = [[BSMediaStrategy alloc] initWithStrategyURL:fileURL];
        [[strategy should] beMemberOfClass:BSMediaStrategy.class];

        [[strategy.scripts should] beNil];
        [[theValue(strategy.strategyVersion) should] equal:theValue(0)];

        [[strategy.displayName should] equal:fileName];
        [[strategy.fileName should] equal:fileName];
    });
});

describe(@"Load the Youtube strategy", ^{
    let(path, ^{ return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"MediaStrategies"]; });

    it(@"will load the strategy properly", ^{
        NSString *youtubeName = @"Youtube";
        NSString *fileName = [NSString stringWithFormat:@"%@.js", youtubeName];
        NSURL *fileURL = [[NSURL alloc] initWithString:fileName relativeToURL:path];
        BSMediaStrategy *strategy = [[BSMediaStrategy alloc] initWithStrategyURL:fileURL];
        [[strategy should] beMemberOfClass:BSMediaStrategy.class];

        [[strategy.scripts shouldNot] beNil];
        [[theValue(strategy.strategyVersion) shouldNot] equal:theValue(0)];

        [[strategy.displayName should] equal:@"Youtube"]; // pasted from js
        [[strategy.fileName should] equal:@"Youtube.js"];
        [[strategy.displayName shouldNot] equal:strategy.fileName];

        [[strategy.toggle shouldNot] beNil];
        [[strategy.previous shouldNot] beNil];
        [[strategy.next shouldNot] beNil];
        [[strategy.pause shouldNot] beNil];
    });
});

SPEC_END
