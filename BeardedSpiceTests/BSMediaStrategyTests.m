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
    it(@"will initialize defaults without template data", ^{
        NSString *fileName = @"random-file-name";
        BSMediaStrategy *strategy = [[BSMediaStrategy alloc] initWithStrategyName:fileName];
        [[strategy should] beMemberOfClass:BSMediaStrategy.class];

        [[strategy.strategyData should] beNil];
        [[theValue(strategy.strategyVersion) should] equal:theValue(0)];

        [[strategy.displayName should] equal:fileName];
        [[strategy.fileName should] equal:fileName];
    });
});

describe(@"Load the Youtube strategy", ^{
    it(@"will load the strategy properly", ^{
        NSString *youtubeName = @"Youtube";
        BSMediaStrategy *strategy = [[BSMediaStrategy alloc] initWithStrategyName:youtubeName]; // case sensitive
        [[strategy should] beMemberOfClass:BSMediaStrategy.class];

        [[strategy.strategyData shouldNot] beNil];
        [[theValue(strategy.strategyVersion) shouldNot] equal:theValue(0)];

        [[strategy.displayName should] equal:@"YouTube"]; // pasted from Youtube.plist
        [[strategy.fileName should] equal:youtubeName];
        [[strategy.displayName shouldNot] equal:strategy.fileName];

        [[strategy.toggle shouldNot] beNil];
        [[strategy.previous shouldNot] beNil];
        [[strategy.next shouldNot] beNil];
        [[strategy.pause shouldNot] beNil];
    });
});

SPEC_END
