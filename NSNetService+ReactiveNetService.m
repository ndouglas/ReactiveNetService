//
//  NSNetService+ReactiveNetService.m
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSNetService+ReactiveNetService.h"
#import "ReactiveNetService.h"
#import "RNSNetServiceBrowserDelegate.Private.h"
#import "RNSNetServiceDelegate.Private.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#import <objc/runtime.h>

static void *RNSNetServiceTXTRecordDictionaryKey = &RNSNetServiceTXTRecordDictionaryKey;

@interface RACSignal (ReactiveNetService)
- (RACSignal *)rns_retryWithDelay:(NSTimeInterval)_interval;
@end

@implementation NSNetService (ReactiveNetService)

+ (RACSignal *)rns_resolvedServicesWithTXTRecordsOfType:(NSString *)type inDomain:(NSString *)domain {
    RACSignal *resolvedServicesWithTXTRecordsSignal = [[[[[self rns_resolvedServicesOfType:type inDomain:domain]
        map:^RACSignal *(RACSequence *services) {
            RACSignal *result = nil;
            if (!services.head) {
                result = [RACSignal return:[RACTuple new]];
            } else {
                result = [RACSignal combineLatest:[services map:^RACSignal *(NSNetService *service) {
                    return [service rns_lookupTXTRecordSignal];
                }]];
            }
            return result;
        }]
        switchToLatest]
        distinctUntilChanged]
        map:^RACSequence *(RACTuple *resolvedServices) {
            RACSequence *result = resolvedServices.rac_sequence;
            return result;
        }];
    RACSignal *result = [[[[RACSignal return:[RACSequence empty]]
        concat:resolvedServicesWithTXTRecordsSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_resolvedServicesWithTXTRecordsOfType: %@ inDomain: %@]", self, type, domain];
    return result;
}

+ (RACSignal *)rns_resolvedServicesOfType:(NSString *)type inDomain:(NSString *)domain {
    RACSignal *resolvedServicesSignal = [[[[[self rns_servicesOfType:type inDomain:domain]
        map:^RACSignal *(RACSequence *_services_) {
            RACSignal *result = nil;
            if (!_services_.head) {
                result = [RACSignal return:[RACTuple new]];
            } else {
                result = [RACSignal combineLatest:[_services_ map:^RACSignal *(NSNetService *service) {
                    return [service rns_resolutionSignal];
                }]];
            }
            return result;
        }]
        switchToLatest]
        distinctUntilChanged]
        map:^RACSequence *(RACTuple *resolvedServices) {
            return resolvedServices.rac_sequence;
        }];
    RACSignal *result = [[[[RACSignal return:[RACSequence empty]]
        concat:resolvedServicesSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_resolvedServicesOfType: %@ inDomain: %@]", self, type, domain];
    return result;
}

+ (RACSignal *)rns_servicesOfType:(NSString *)type inDomain:(NSString *)domain {
    RACSignal *serviceSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RNSNetServiceBrowserDelegate *delegate = [RNSNetServiceBrowserDelegate new];
            NSNetServiceBrowser *browser = [NSNetServiceBrowser new];
            browser.delegate = delegate;
            [browser searchForServicesOfType:type inDomain:domain];
            RACDisposable *subjectDisposable = [[delegate.subject
                rns_retryWithDelay:10.0]
                subscribe:subscriber];
            CFTypeRef delegatePtr = CFBridgingRetain(delegate);
            RACDisposable *result = [RACDisposable disposableWithBlock:^{
                [subjectDisposable dispose];
                [browser stop];
                browser.delegate = nil;
                CFRelease(delegatePtr);
            }];
            return result;
        }];
    RACSignal *result = [[[[RACSignal return:[RACSequence empty]]
        concat:serviceSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_servicesWithTXTRecordsOfType: %@ inDomain: %@]", self, type, domain];
    return result;
}

- (NSURL *)rns_URL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/", self.hostName, (long)self.port]];
}

- (RACSignal *)rns_resolutionSignal {
    NSCAssert([self.delegate isKindOfClass:[RNSNetServiceDelegate class]], @"delegate not of correct class");
    RACSignal *result = [[(RNSNetServiceDelegate *)self.delegate resolveNetService:self timeout:30.0]
        setNameWithFormat:@"[%@ -rns_resolutionSignal]", self];
    return result;
}

- (RACSignal *)rns_lookupTXTRecordSignal {
    NSCAssert([self.delegate isKindOfClass:[RNSNetServiceDelegate class]], @"delegate not of correct class");
    RACSignal *result = [[(RNSNetServiceDelegate *)self.delegate lookupTXTRecord:self]
        setNameWithFormat:@"[%@ -rns_lookupTXTRecordSignal]", self];
    return result;
}

- (NSDictionary *)rns_TXTRecordDictionary {
    return objc_getAssociatedObject(self, RNSNetServiceTXTRecordDictionaryKey) ?: [NSNetService dictionaryFromTXTRecordData:self.TXTRecordData];
}

- (void)rns_setTXTRecordDictionary:(NSDictionary *)txtRecordDictionary {
    objc_setAssociatedObject(self, RNSNetServiceTXTRecordDictionaryKey, txtRecordDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary *)rns_decodedDictionaryFromTXTRecordData:(NSData *)_data {
    NSMutableDictionary *result = [[self dictionaryFromTXTRecordData:_data] mutableCopy];
    for (NSString *key in result.allKeys.copy) {
        result[key] = [[NSString alloc] initWithData:result[key] encoding:NSUTF8StringEncoding];
    }
    return result;
}

@end

@implementation RACSignal (ReactiveNetService)

- (RACSignal *)rns_retryWithDelay:(NSTimeInterval)_interval {
    RACSignal *result = [[self catch:^RACSignal *(NSError *_error_) {
            RACSignal *result = [[[RACSignal empty]
            delay:_interval]
            concat:[RACSignal error:_error_]];
            return result;
        }]
        retry];
    return result;
}

@end
