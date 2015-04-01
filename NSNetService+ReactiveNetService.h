//
//  NSNetService+ReactiveNetService.h
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSDefinitions.h"

@class RACSignal;

/**
 Additions to NSNetService.
 */

@interface NSNetService (ReactiveNetService)

/**
 A URL resolving the resource.
 */

@property (copy, nonatomic, readonly) NSURL *rns_URL;

/**
 This net service's TXT record dictionary.
 */

@property (copy, nonatomic, readwrite, setter=rns_setTXTRecordDictionary:) NSDictionary *rns_TXTRecordDictionary;

/**
 Returns a signal encompassing the desired resolved services with updated TXT records.
 
 @param type The type of the services to search for.
 @param domain The domain of the services to search for.
 @return A signal of RACSequence objects containing discovered services.
 */

+ (RACSignal *)rns_resolvedServicesWithTXTRecordsOfType:(NSString *)type inDomain:(NSString *)domain;

/**
 Returns a signal encompassing the desired resolved services.
 
 @param type The type of the services to search for.
 @param domain The domain of the services to search for.
 @return A signal of RACSequence objects containing discovered services.
 */

+ (RACSignal *)rns_resolvedServicesOfType:(NSString *)type inDomain:(NSString *)domain;

/**
 Returns a signal encompassing the desired services.
 
 @param type The type of the services to search for.
 @param domain The domain of the services to search for.
 @return A signal of RACSequence objects containing discovered services.
 */

+ (RACSignal *)rns_servicesOfType:(NSString *)type inDomain:(NSString *)domain;

@end
