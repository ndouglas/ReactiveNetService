//
//  RNSNetServiceDelegate.m
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSNetServiceDelegate.Private.h"
#import "ReactiveNetService.h"

@implementation RNSNetServiceDelegate
@synthesize resolutionSubject;
@synthesize resolved;
@synthesize referenced;
@synthesize lookupSubject;

- (RACSignal *)resolveNetService:(NSNetService *)netService timeout:(NSTimeInterval)timeout {
    RACSignal *result = nil;
    @synchronized (self) {
        if (self.resolved) {
            result = [RACSignal return:netService];
        } else if (self.resolutionSubject) {
            result = self.resolutionSubject;
        } else {
            self.resolutionSubject = [RACSubject subject];
            [netService resolveWithTimeout:timeout];
            result = self.resolutionSubject;
        }
    }
    return result;
}

- (RACSignal *)lookupTXTRecord:(NSNetService *)netService {
    RACSignal *result = nil;
    @synchronized (self) {
        if (self.referenced) {
            result = [RACSignal return:netService];
        } else if (self.lookupSubject) {
            result = self.lookupSubject;
        } else {
            self.lookupSubject = [RACSubject subject];
            [netService startMonitoring];
            result = self.lookupSubject;
        }
    }
    return result;
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    @synchronized (self) {
        self.resolved = YES;
        [self.resolutionSubject sendNext:netService];
        if ([self.class isValidTXTRecordData:netService.TXTRecordData]) {
            self.referenced = YES;
            [self.lookupSubject sendNext:netService];
        }
    }
}

- (void)netService:(NSNetService *)netService didUpdateTXTRecordData:(NSData *)data {
    @synchronized (self) {
        NSDictionary *dictionary = [NSNetService dictionaryFromTXTRecordData:data];
        if (dictionary && dictionary.count) {
            netService.rns_TXTRecordDictionary = [NSNetService dictionaryFromTXTRecordData:data];
            self.referenced = YES;
            [self.lookupSubject sendNext:netService];
            [netService stopMonitoring];
        }
    }
}

+ (BOOL)isValidTXTRecordData:(NSData *)data {
    NSDictionary *dictionary = [NSNetService dictionaryFromTXTRecordData:data];
    return dictionary && dictionary.count;
}

- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDictionary {
    @synchronized (self) {
        [self.resolutionSubject sendError:RNSErrorForErrorDictionary(errorDictionary)];
    }
}

@end
