//
//  BSPredicateToJS.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 20.08.17.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
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
    @"function bsJsFunctions(){"
    
    @"this.bsMatchesPredicate = function (str, pattern, flags) {"
    @"    var expr = new RegExp('^' + pattern + '$' , flags);"
    @"    return (str.search(expr) != -1);"
    @"};"

    @"this.bsLikePredicate = function (str, pattern, flags) {"
    
    @"    var replaced = pattern.replace(/\\./g, '\\\\.');"
    @"    replaced = replaced.replace(/([^\\\\])\\?/g, '$1.?');"
    @"    replaced = replaced.replace(/([^\\\\])\\*/g, '$1.*');"
    @"    replaced = replaced.replace(/^\\?/g, '.?');"
    @"    replaced = replaced.replace(/^\\*/g, '.*');"
    @"    var expr = new RegExp('^' + replaced + '$' , flags);"
    @"    return (str.search(expr) != -1);"
    @"};"

    
    @"this.bsBeginsWithPredicate = function (str, pattern, flags) {"
    @"    var val = str;"
    @"    var pat = pattern;"
    
    @"    if (flags && flags.indexOf('i') != -1) {"
    @"    "
    @"        val = val.toLowerCase();"
    @"        pat = pat.toLowerCase();"
    @"    }"
    @"    "
    @"    return (val.indexOf(pat) == 0);"
    @"};"
    
    @"this.bsEndsWithPredicate = function (str, pattern, flags) {"
    @"    var val = str;"
    @"    var pat = pattern;"
    
    @"    if (flags && flags.indexOf('i') != -1) {"
    @"    "
    @"        val = val.toLowerCase();"
    @"        pat = pat.toLowerCase();"
    @"    }"
    @"    var index = val.indexOf(pat);"
    @"    return (index != -1 && pat.length == (val.length - index));"
    @"};"

    
    @"this.bsContainsPredicate = function (str, pattern, flags) {"
    @"    var val = str;"
    @"    var pat = pattern;"
    
    @"    if (flags && flags.indexOf('i') != -1) {"
    @"    "
    @"        val = val.toLowerCase();"
    @"        pat = pat.toLowerCase();"
    @"    }"
    @"    return (val.indexOf(pat) != -1);"
    @"};"
    
    @"this.bsInPredicate = function (val, arr, flags) {"
    
    @"    if (arr && arr.length){"
    @"        return ! arr.every(function(currentValue, index, array){"
    
    @"            if (val == currentValue) {"
    @"                return false;"
    @"            }"
    @"            return true;"
    @"        });"
    @"    }"
    @"    return false;"
    @"};"

    @"this.bsBetweenPredicate = function (val, arr, flags) {"
    
    @"    if (arr && arr.length == 2){"
    @"        return ! (val > arr[1] || val < arr[0]);"
    @"    }"
    @"    return false;"
    @"};"
    
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
                operation = @"bsMatchesPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSLikePredicateOperatorType:
                operation = @"bsLikePredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSBeginsWithPredicateOperatorType:
                operation = @"bsBeginsWithPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSEndsWithPredicateOperatorType:
                operation = @"bsEndsWithPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSInPredicateOperatorType:
                operation = @"bsInPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSCustomSelectorPredicateOperatorType: // Not supported
                return @"false";
                
            case NSContainsPredicateOperatorType:
                operation = @"bsContainsPredicate(%@, %@, %@)";
                asFunction = YES;
                break;
            case NSBetweenPredicateOperatorType:
                operation = @"bsBetweenPredicate(%@, %@, %@)";
                asFunction = YES;
                break;

            default:
                return @"false";
                break;
        }
        
//        NSMutableString *options = [NSMutableString string];
        NSString *options = [NSString new];
        if (predicate.options & NSCaseInsensitivePredicateOption) {
//            [options appendString:@"\"i"];
            options = @"\"i\"";
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
        
        NSData *data;
        switch (expression.expressionType) {
                // Expression that always returns the same value
            case NSConstantValueExpressionType:
//                if ([expression.constantValue isKindOfClass:[NSString class]]) {
//                    NSString *value = [expression.constantValue stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
//                    return [NSString stringWithFormat:@"\"%@\"", value];
//                }
                data = [NSJSONSerialization dataWithJSONObject:@[expression.constantValue] options:0 error:nil];
                if (data.length > 2) {
                    return [[NSString alloc] initWithBytes:(data.bytes + 1) length:(data.length - 2) encoding:NSUTF8StringEncoding];
                }
                return nil;
            case NSEvaluatedObjectExpressionType: // Expression that always returns the parameter object itself
                return @"bsParameters";
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
        
        return [NSString stringWithFormat:@"bsParameters.%@", [keyPath substringFromIndex:5]];
    }
    
    return [NSString stringWithFormat:@"bsParameters.%@", keyPath];
}

@end
