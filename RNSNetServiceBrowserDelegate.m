//
//  RNSNetServiceBrowserDelegate.m
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSNetServiceBrowserDelegate.Private.h"
#import "ReactiveNetService.h"
#import <objc/runtime.h>

static void *RNSNetServiceBrowserDelegateKey = &RNSNetServiceBrowserDelegateKey;

@implementation RNSNetServiceBrowserDelegate
@synthesize subject;
@synthesize services;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subject = [RACReplaySubject replaySubjectWithCapacity:1];
        self.services = [NSMutableArray array];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing {
    RNSNetServiceDelegate *delegate = [RNSNetServiceDelegate new];
    netService.delegate = delegate;
    objc_setAssociatedObject(netService, RNSNetServiceBrowserDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.services addObject:netService];
    if (!moreComing) {
        [self.subject sendNext:self.services.rac_sequence];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing {
    [self.services removeObject:netService];
    if (!moreComing) {
        [self.subject sendNext:self.services.rac_sequence];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDictionary {
    [self.subject sendError:RNSErrorForErrorDictionary(errorDictionary)];
}

@end
