//
//  BSPredicateToJS.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 20.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSPredicateToJS.h"

@implementation BSPredicateToJS

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (NSString *)jsFromPredicate:(NSPredicate *)predicate {

    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        
        return [self jsForComparisionPredicate:(NSComparisonPredicate *)predicate];
    }
    else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        return [self jsForCompoundPredicate:(NSCompoundPredicate *)predicate];
    }
    
    return @"false";
}

+ (NSString *)jsFunctions {
    
    return
    @"var matchesPredicate = function (str, pattern, flags) {"
    @"    var expr = new RegExp(pattern , flags);"
    @"    return (str.search(expr) != -1);"
    @"}"
    ;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

+ (NSString *)jsForComparisionPredicate:(NSComparisonPredicate *)predicate {
    
    @autoreleasepool {
        
        NSString *operation = @" ";
        BOOL asFunction = NO;
        switch (predicate.predicateOperatorType) {
                
            case NSLessThanPredicateOperatorType:
                operation = @" < ";
                break;
            case NSLessThanOrEqualToPredicateOperatorType:
                operation = @" <= ";
                break;
            case NSGreaterThanPredicateOperatorType:
                operation = @" > ";
                break;
            case NSGreaterThanOrEqualToPredicateOperatorType:
                operation = @" >= ";
                break;
            case NSEqualToPredicateOperatorType:
                operation = @" == ";
                break;
            case NSNotEqualToPredicateOperatorType:
                operation = @" != ";
                break;
            case NSMatchesPredicateOperatorType:
                operation = @"matchesPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSLikePredicateOperatorType:
                operation = @"likePredicate(%@, %@, %@)";
                break;
            case NSBeginsWithPredicateOperatorType:
                operation = @"beginWithPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSEndsWithPredicateOperatorType:
                operation = @"endWithPredicate(%@, %@, @)";
                break;
            case NSInPredicateOperatorType:
                operation = @"inPredicate(%@, %@, %@)";
                break;
            case NSCustomSelectorPredicateOperatorType: // Not supported
                return @"false";
                
            case NSContainsPredicateOperatorType:
                operation = @"containsPredicate(%@, %@, %@)";
                break;
            case NSBetweenPredicateOperatorType:
                operation = @"betweenPredicate(%@, %@, %@)";
                break;

            default:
                return @"false";
                break;
        }
        
        NSMutableString *options = [NSMutableString string];
        if (predicate.options & NSCaseInsensitivePredicateOption) {
            [options appendString:@"i"];
        }
//not supported
//        if (predicate.options & NSDiacriticInsensitivePredicateOption) {
//            [options appendString:@"i"];
//        }
//        if (predicate.options & NSNormalizedPredicateOption) {
//            [options appendString:@"i"];
//        }
//---------------
        NSString *leftOp = [self jsFromExpression:predicate.leftExpression];
        NSString *rightOp = [self jsFromExpression:predicate.rightExpression];
        
        
        
        if (asFunction) {
            
            return [NSString stringWithFormat:operation, leftOp, rightOp, options];
        }
        else {
            
            return [NSString stringWithFormat:@"%@%@%@", leftOp, operation, rightOp];
        }
    }
    return @"false";
}

+ (NSString *)jsForCompoundPredicate:(NSCompoundPredicate *)predicate {

    @autoreleasepool {
        
        NSMutableString *result = [NSMutableString new];
        NSString *operation = @" ";
        BOOL thisIsNot = NO;
        switch (predicate.compoundPredicateType) {
            case NSNotPredicateType:
                
                operation = @" !";
                thisIsNot = YES;
                break;
                
            case NSOrPredicateType:
                
                operation = @" || ";
                break;
                
            case NSAndPredicateType:
                
                operation = @" && ";
                break;
                
            default:
                break;
        }
        
        [predicate.subpredicates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx || thisIsNot) {
                
                [result appendString:operation];
            }
            [result appendFormat:@"( %@ )", [self jsFromPredicate:obj]];
        }];
        return result;
    }
}

+ (NSString *)jsFromExpression:(NSExpression *)expression {
    
    @try {
        
        switch (expression.expressionType) {
                // Expression that always returns the same value
            case NSConstantValueExpressionType:
                return [expression.constantValue description];
            case NSEvaluatedObjectExpressionType: // Expression that always returns the parameter object itself
                return @"false"; //not supported
            case NSVariableExpressionType: // Expression that always returns whatever is stored at 'variable' in the bindings dictionary
                return expression.variable;
            case NSKeyPathExpressionType: // Expression that returns something that can be used as a key path
                return [self jsConvertSelfInKeyPath:expression.keyPath];
            case NSFunctionExpressionType: // Expression that returns the result of evaluating a symbol
                return @"false"; //not supported
            case NSUnionSetExpressionType: // Expression that returns the result of doing a unionSet: on two expressions that evaluate to flat collections (arrays or sets)
                return @"false"; //not supported
            case NSIntersectSetExpressionType: // Expression that returns the result of doing an intersectSet: on two expressions that evaluate to flat collections (arrays or sets)
                return @"false"; //not supported
            case NSMinusSetExpressionType: // Expression that returns the result of doing a minusSet: on two expressions that evaluate to flat collections (arrays or sets)
                return @"false"; //not supported
            case NSSubqueryExpressionType:
                return @"false"; //not supported
            case NSAggregateExpressionType:
                return @"false"; //not supported
            case NSAnyKeyExpressionType:
                return @"false"; //not supported
            case NSBlockExpressionType:
                return @"false"; //not supported
            case NSConditionalExpressionType:
                return @"false"; //not supported
            default:
                break;
        }
    } @catch (NSException *exception) {
    }
    return @"false";
}

+ (NSString *)jsConvertSelfInKeyPath:(NSString *)keyPath {
    
    if ([keyPath hasPrefix:@"self."]) {
        
        return [NSString stringWithFormat:@"this.%@", [keyPath substringFromIndex:5]];
    }
    
    return [NSString stringWithFormat:@"this.%@", keyPath];
}

@end
