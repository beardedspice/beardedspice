//
//  EHCCache.h
//  ACommons
//
//  Created by Roman Sokolov on 14.03.14.
//  Copyright (c) 2014 Performix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EHCC_DEFAULT_MAX_ITEMS 30

/// Cache of named objects with determinate maximum length
@interface EHCCache : NSObject{
    
/// The private container representing the cache.
    NSMutableDictionary *mItemsStore;
    
/// The private queue maintaining a basic order of items
/// for purging when space necessitates.
    NSMutableArray *mArrivalOrder;

/// The max item variable stores the maximum size of cache
    NSUInteger mMaxItems;

}

/////////////////////////////////////////////////////////////////////
#pragma mark -  Init and Class methods
/////////////////////////////////////////////////////////////////////

/// Alternative constructor allowing maximum cache size to be specified
/// at construction time.
/// @param maxItems Maximum item of the cache.
- (id)initWithCapacity:(NSUInteger)maxItems;

/////////////////////////////////////////////////////////////////////
#pragma mark -  Properties and public methods
/////////////////////////////////////////////////////////////////////

@property NSUInteger maxItems;
/// Gets the keys.
@property (readonly) NSArray *keys;
/// Get full cache
@property (readonly) NSDictionary *cache;

/// Add a new item into the cache.
/// @param key Identifier or key for the item.
/// @param value The actual item to store/cache.
- (void)addValue:(id)value forKey:(id<NSCopying>)key;

/// Determines whether the cache contains the specific key.
/// @param kes Key to locate in the collection.
- (BOOL)containsKey:(id)key;

/// Indexer into the cache using the associated key to specify
/// the value to return.
/// Gets attribute value by it's name.
/// @return Returns value or nil if key/value does not exist.
- (id)objectForKeyedSubscript:(id <NSCopying, NSObject>)key;

/// Remove the specified item from the cache.
/// @param key Identifier for the item to remove.
- (void)removeByKey:(id)key;

/// Remove the specified items from the cache.
/// @param keys Array of the identifiers for the item to remove.
- (void)removeByKeys:(NSArray *)keys;

/// Remove ALL 
- (void)clear;

@end
