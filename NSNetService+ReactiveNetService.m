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
#import <objc/runtime.h>
#import <YOLOKit/YOLO.h>

static void *RNSNetServiceTXTRecordDictionaryKey = &RNSNetServiceTXTRecordDictionaryKey;

@interface RACSignal (ReactiveNetService)
- (RACSignal *)rns_retryWithDelay:(NSTimeInterval)_interval;
@end

@implementation NSNetService (ReactiveNetService)

+ (RACSignal *)rns_resolvedServicesWithTXTRecordsOfType:(NSString *)type inDomain:(NSString *)domain {
    RACSignal *resolvedServicesWithTXTRecordsSignal = [[[[[self rns_resolvedServicesOfType:type inDomain:domain]
        map:^RACSignal *(NSArray *services) {
            return services.count ? [RACSignal combineLatest:services.map(^RACSignal *(NSNetService *service) {
                    return [service rns_lookupTXTRecordSignal];
                })] : [RACSignal return:[RACTuple new]];
        }]
        switchToLatest]
        distinctUntilChanged]
        map:^NSArray *(RACTuple *resolvedServices) {
            return resolvedServices.allObjects;
        }];
    return [[[[RACSignal return:@[]]
        concat:resolvedServicesWithTXTRecordsSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_resolvedServicesWithTXTRecordsOfType: %@ inDomain: %@]", self, type, domain];
}

+ (RACSignal *)rns_resolvedServicesOfType:(NSString *)type inDomain:(NSString *)domain {
    RACSignal *resolvedServicesSignal = [[[[[self rns_servicesOfType:type inDomain:domain]
        map:^RACSignal *(NSArray *services) {
            return services.count ? [RACSignal combineLatest:services.map(^RACSignal *(NSNetService *service) {
                    return [service rns_resolutionSignal];
                })] : [RACSignal return:[RACTuple new]];
        }]
        switchToLatest]
        distinctUntilChanged]
        map:^NSArray *(RACTuple *resolvedServices) {
            return resolvedServices.allObjects;
        }];
    return [[[[RACSignal return:@[]]
        concat:resolvedServicesSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_resolvedServicesOfType: %@ inDomain: %@]", self, type, domain];
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
    return [[[[RACSignal return:@[]]
        concat:serviceSignal]
        distinctUntilChanged]
        setNameWithFormat:@"[%@ +rns_servicesWithTXTRecordsOfType: %@ inDomain: %@]", self, type, domain];
}

- (NSURL *)rns_URL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/", self.hostName, (long)self.port]];
}

- (RACSignal *)rns_resolutionSignal {
    NSCAssert([self.delegate isKindOfClass:[RNSNetServiceDelegate class]], @"delegate not of correct class");
    return [[(RNSNetServiceDelegate *)self.delegate resolveNetService:self timeout:30.0]
        setNameWithFormat:@"[%@ -rns_resolutionSignal]", self];
}

- (RACSignal *)rns_lookupTXTRecordSignal {
    NSCAssert([self.delegate isKindOfClass:[RNSNetServiceDelegate class]], @"delegate not of correct class");
    return [[(RNSNetServiceDelegate *)self.delegate lookupTXTRecord:self]
        setNameWithFormat:@"[%@ -rns_lookupTXTRecordSignal]", self];
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
    return [[[self catch:^RACSignal *(NSError *_error_) {
            RACSignal *result = [[[RACSignal empty]
            delay:_interval]
            concat:[RACSignal error:_error_]];
            return result;
        }]
        retry]
        setNameWithFormat:@"[%@] -rns_retryWithDelay: %@", self, @(_interval)];
}

@end
