//
//  EHCCache.m
//  ACommons
//
//  Created by Roman Sokolov on 14.03.14.
//  Copyright (c) 2014 Performix. All rights reserved.
//

#import "EHCCache.h"
#import "NSArray+Utils.h"


@implementation EHCCache

/////////////////////////////////////////////////////////////////////
#pragma mark -  Init and Class methods
/////////////////////////////////////////////////////////////////////

- (id)init{
    self = [super init];
    if (self) {

        mMaxItems = EHCC_DEFAULT_MAX_ITEMS;
        mItemsStore = [NSMutableDictionary dictionaryWithCapacity:mMaxItems];
        mArrivalOrder = [NSMutableArray arrayWithCapacity:mMaxItems];
    }
    
    return self;
}

/// Alternative constructor allowing maximum cache size to be specified
/// at construction time.
/// @param maxItems Maximum item of the cache.
- (id)initWithCapacity:(NSUInteger)maxItems
{
    self = [super init];
    if (self) {

        mMaxItems = maxItems;
        mItemsStore = [NSMutableDictionary dictionaryWithCapacity:mMaxItems];
        mArrivalOrder = [NSMutableArray arrayWithCapacity:mMaxItems];
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////
#pragma mark -  Properties and public methods
/////////////////////////////////////////////////////////////////////
@synthesize maxItems = mMaxItems;

/// Gets the keys.
- (NSArray *)keys
{
    @synchronized(mItemsStore){
        
        return [mArrivalOrder copy];
    }
}

- (NSDictionary *)cache{
    
    @synchronized(mItemsStore){
        
        return [mItemsStore copy];
    }
}

/// Add a new item into the cache.
/// @param key Identifier or key for the item.
/// @param value The actual item to store/cache.
- (void)addValue:(id)value forKey:(id<NSCopying>)key
{
    @synchronized(mItemsStore){
    
        if ([self containsKey:key])
            [mArrivalOrder removeObject:key];
        
        else if (mArrivalOrder.count >= mMaxItems)
            [self purgeSpace];
    
        [mArrivalOrder enqueue:key];
        [mItemsStore setObject:value forKey:key];
    }
}

/// Determines whether the cache contains the specific key.
/// @param kes Key to locate in the collection.
- (BOOL)containsKey:(id)key
{
    return [mArrivalOrder containsObject:key];
}

/// Indexer into the cache using the associated key to specify
/// the value to return.
/// Gets attribute value by it's name.
/// @return Returns value or nil if key/value does not exist.
- (id)objectForKeyedSubscript:(id <NSCopying, NSObject>)key
{
    return [self getValue:key];
}

/// Remove the specified item from the cache.
/// @param key Identifier for the item to remove.
- (void)removeByKey:(id)key
{
    @synchronized(mItemsStore){
        if ([self containsKey:key]){
            
            [mArrivalOrder removeObject:key];
            [mItemsStore removeObjectForKey:key];
        }
    }
}

/// Remove the specified items from the cache.
/// @param keys Array of the identifiers for the item to remove.
- (void)removeByKeys:(NSArray *)keys
{
    @synchronized(mItemsStore){
        
            [mArrivalOrder removeObjectsInArray:keys];
            [mItemsStore removeObjectsForKeys:keys];
    }
}

/// Clear
- (void)clear
{
    @synchronized(mItemsStore){
        
        [mArrivalOrder removeAllObjects];
        [mItemsStore removeAllObjects];
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark -  Private methods
/////////////////////////////////////////////////////////////////////

/// Returns the item associated with the supplied identifier.
/// @param key Identifier for the value to be returned.
/// @return Item value corresponding to Key supplied. Returns default value if not exist.
- (id)getValue:(id)key
{
    @synchronized(mItemsStore){
        [self touch:key];
        return mItemsStore[key];
    }
}

/// Touch or refresh a specified item.  This allows the specified
/// item to be moved to the end of the dispose queue.  E.g. when it
/// is known that this item would benifit from not being purged.
/// @param key Identifier of item to touch.
- (void)touch:(id)key
{
    [mArrivalOrder removeObject:key];
    [mArrivalOrder enqueue:key];
}

/// This function is used when it has been determined that the collection is
/// too full to fit the new item.
- (void)purgeSpace
{
    if (mArrivalOrder.count)
        [mItemsStore removeObjectForKey:[mArrivalOrder dequeue]];
}

@end
