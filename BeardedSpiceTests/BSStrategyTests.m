//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Kiwi/Kiwi.h>

#import "BSStrategyMockObject.h"
#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"

SHARED_EXAMPLES_BEGIN(BSMediaStrategyTestHelper)

sharedExamplesFor(@"MediaStrategy", ^(NSDictionary *data) {

    __block NSString *strategyFileName = nil;
    __block BSMediaStrategy *strategy = nil;
    //__block BSStrategyMockObject *mock = nil;

    beforeAll(^{
         strategyFileName = data[@"strategyName"];
         strategy = data[@"strategy"];
         //mock = [[BSStrategyMockObject alloc] initWithStrategyName:strategyFileName];
    });

    context(@"Tests for Media Strategy", ^{
        it(@"should be properly loaded", ^{
            [[theValue(strategy) shouldNot] beNil];
        });

        /* Excluding keys:
            kBSMediaStrategyKeyIsPlaying
            kBSMediaStrategyKeyFavorite
            kBSMediaStrategyKeyPrevious
            kBSMediaStrategyKeyNext
            kBSMediaStrategyKeyPause
            kBSMediaStrategyKeyTrackInfo
        */

        /* Bare minimum components a strategy should have */

        it(@"should have a valid accept script", ^{
            NSDictionary *acceptParams = strategy.acceptParams;
            [[acceptParams shouldNot] beNil];
            [[acceptParams shouldNot] beEmpty];

            NSString *acceptScript = acceptParams[kBSMediaStrategyAcceptMethod];
            [[acceptScript shouldNot] beNil];
            [[acceptScript shouldNot] beEmpty];
        });

        it(@"should have a valid toggle script", ^{
            NSString *script = strategy.scripts[kBSMediaStrategyKeyToggle];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];
        });
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(BSMediaStrategyTest)

__block BSStrategyCache *cache = nil;

describe(@"BSStrategyCache properly loads all strategies.", ^{
    cache = [BSStrategyCache new];
    [cache updateStrategiesFromSourceURL: [NSURL URLForBundleStrategies]];

    [[theValue([cache allKeys].count) should] beGreaterThan:theValue(0)];
});

for (NSString *strategyName in [cache allKeys])
{
    describe([NSString stringWithFormat:@"Test %@ for valid javascript", strategyName], ^{
        itBehavesLike(@"MediaStrategy", @{ @"strategyName": strategyName, @"strategy": [cache strategyForFileName:strategyName] });
    });
    //break;
}

SPEC_END
