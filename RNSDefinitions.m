//
//  RNSDefinitions.m
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSDefinitions.h"
#import "ReactiveNetService.h"

NSError *RNSErrorForErrorDictionary(NSDictionary *errorDictionary) {
    return [NSError errorWithDomain:NSURLErrorDomain code:[errorDictionary[NSNetServicesErrorCode] integerValue] userInfo:nil];
}

