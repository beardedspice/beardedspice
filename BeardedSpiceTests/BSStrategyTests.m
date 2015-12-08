//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "BSStrategyMockObject.h"
#import "BSMediaStrategy.h"

SPEC_BEGIN(BSStrategyTests)

describe(@"Test Strategy Mocks", ^{

    let (strategyName, ^{ return @"Youtube"; });
    let (strategy, ^{ return [[BSMediaStrategy alloc] initWithStrategyName:strategyName]; });
    let (mock, ^{ return [[BSStrategyMockObject alloc] initWithStrategyName:strategyName]; });

    context(@"startup the mock and test scripts", ^{

        beforeAll(^{
            /*[mock start];
            while (!mock.finishedLoading) {
                sleep(1);
                NSLog(@"sleeping... %@", [[mock.webView mainFrame] DOMDocument]);
            }*/
        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid accept script", ^{
            NSDictionary *acceptScript = strategy.strategyData[kBSMediaStrategyKeyAccepts];
            [[acceptScript shouldNot] beNil];
            [[acceptScript shouldNot] beEmpty];
            //kBSMediaStrategyKeyPredicate
            //kBSMediaStrategyKeyScript
            //kBSMediaStrategyKeyTabValue
            //kBSMediaStrategyKeyTabValueURL
            //kBSMediaStrategyKeyTabValueTitle
            //NSString *result = [mock evaluateScript:script];
            //[[result shouldNot] beNil];
            //[[result shouldNot] beEmpty];
        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid isPlaying script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyIsPlaying];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/

        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid toggle script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyToggle];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/
        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid previous script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyPrevious];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/
        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid next script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyNext];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/
        });

        /*it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid favorite script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyFavorite];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];
        });*/

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid pause script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyPause];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/
        });

        it(@"should be a valid object", ^{ [[mock should] beKindOfClass:BSStrategyMockObject.class]; });
        it(@"should have a valid trackInfo script", ^{
            NSString *script = strategy.strategyData[kBSMediaStrategyKeyTrackInfo];
            [[script shouldNot] beNil];
            [[script shouldNot] beEmpty];

            /*NSString *result = [mock evaluateScript:script];
            [[result shouldNot] beNil];
            [[result shouldNot] beEmpty];*/
        });
    });
});

SPEC_END
