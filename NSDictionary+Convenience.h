//
//  NSDictionary+Convenience.h
//  Miso
//
//  Copyright 2010 Bazaar Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Convenience)

+ (NSDictionary *)dictionaryWithParameterString:(NSString *)parameterString;
+ (NSDictionary *)queryParamsWithUrl:(NSString *)url;

- (id)objectOrNilForKey:(id)key;
- (id)valueOrNilForKeyPath:(id)keyPath; 
- (NSString *)stringForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
- (NSString *)queryString;

@end
