//
//  RNSNetServiceDelegate.Private.h
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSNetServiceDelegate.h"

@class RACSubject;

@interface RNSNetServiceDelegate () {
    RACSubject *resolutionSubject;
    BOOL resolved;
    BOOL referenced;
    RACSubject *lookupSubject;
}
@property (strong, nonatomic, readwrite) RACSubject *resolutionSubject;
@property (assign, nonatomic, readwrite) BOOL resolved;
@property (assign, nonatomic, readwrite) BOOL referenced;
@property (strong, nonatomic, readwrite) RACSubject *lookupSubject;
- (RACSignal *)resolveNetService:(NSNetService *)netService timeout:(NSTimeInterval)timeout;
- (RACSignal *)lookupTXTRecord:(NSNetService *)netService;
@end
