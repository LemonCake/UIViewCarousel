//
//  NSDictionary+Convenience.m
//  Miso
//
//  Copyright 2010 Bazaar Labs, Inc. All rights reserved.
//

#import "NSDictionary+Convenience.h"
#import "NSString+Convenience.h"

@implementation NSDictionary (Convenience) 


+ (NSDictionary *)dictionaryWithParameterString:(NSString *)parameterString {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
	
	NSArray *queryElements = [parameterString componentsSeparatedByString:@"&"];
	
	for (NSString *element in queryElements) {
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		if ([keyVal count] <= 1) {
			continue;
		}
		NSString *key = [keyVal objectAtIndex:0];
		NSString *value = [[keyVal lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[dictionary setObject:value forKey:key];
	}
	
	return [dictionary autorelease];
}

+ (NSDictionary *)queryParamsWithUrl:(NSString *)url {
    NSArray *components = [url componentsSeparatedByString:@"?"];
    if ([components count] == 2) {
        return [NSDictionary dictionaryWithParameterString:[components objectAtIndex:1]];
    }
    
    return nil;
}

- (id)objectOrNilForKey:(id)key {
	id object = [self objectForKey:key];
	
	if ((NSNull *) object == [NSNull null]) {
		return nil;
	}
	
	return object;
}

- (id)valueOrNilForKeyPath:(id)keyPath {
    id object = [self valueForKeyPath:keyPath];
    if ((NSNull *)object == [NSNull null]) {
        return nil;
    }
    return object;
}

- (id)stringForKey:(id)key {
    id object = [self objectOrNilForKey:key];
    if ([object isKindOfClass:[NSString class]])
        return object;
    else if ([object isKindOfClass:[NSNumber class]])
        return [object stringValue];

    return object;
}

- (NSNumber *)numberForKey:(id)key {
    id object = [self objectOrNilForKey:key];
    if ([object isKindOfClass:[NSString class]])
        return [NSNumber numberWithInt:[object intValue]];
    else if ([object isKindOfClass:[NSNumber class]])
        return object;
    
    return object;
}

- (NSString *)queryString {
    NSString *queryString = @"";
    
    NSArray *keys = [self allKeys];
    for (int i=0; i < [self count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        id value = [self objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]]) {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [[self objectForKey:key] stringWithPercentEscape]];
            queryString = [queryString stringByAppendingString:param];
        } else if ([value isKindOfClass:[NSArray class]] && ([value count] > 0)) {
            for (int j = 0; j < [value count]; j++) {
                NSString *param = [NSString stringWithFormat:@"%@[]=%@", key, [value objectAtIndex:j]];
                queryString = [queryString stringByAppendingString:param];
                
                if (j < [value count] - 1)
                    queryString = [queryString stringByAppendingString:@"&"];
            }
        } else if ([value isKindOfClass:[NSArray class]] && ([value count] == 0)) {
            queryString = [queryString stringByAppendingFormat:@"%@[]=", key];
        }
        
        if (i < [self count] - 1)
            queryString = [queryString stringByAppendingString:@"&"];
    }
    
    return queryString;
}
@end
