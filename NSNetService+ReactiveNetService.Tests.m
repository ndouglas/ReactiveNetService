//
//  NSNetService+ReactiveNetService.Tests.m
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveNetService.h"

@interface NSNetService_ReactiveNetServiceTests : XCTestCase <NSNetServiceDelegate> {
    NSNetService *server;
    NSString *type;
    NSDictionary *TXTRecord;
}
@end

@implementation NSNetService_ReactiveNetServiceTests

- (void)setUp {
	[super setUp];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    type = [NSString stringWithFormat:@"_%@._tcp", UUID];
    TXTRecord = @{
        @"key" : @"value",
    };
    server = [[NSNetService alloc] initWithDomain:@"local" type:type name:@"Test" port:1234];
    server.TXTRecordData = [NSNetService dataFromTXTRecordDictionary:TXTRecord];
    server.delegate = self;
    [server publish];
}

- (void)tearDown {
    [server stop];
    server.delegate = nil;
    server = nil;
	[super tearDown];
}

/**
- (void)testServicesOfTypeInDomain {
    __block RACSequence *services = nil;
	[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        services = _services_;
    }];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
}

- (void)testResolvedServicesOfTypeInDomain {
    __block RACSequence *services = nil;
	[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        services = _services_;
    }];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    NDD_TEST_NOTNIL([services.head hostName])
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    NDD_TEST_NOTNIL([services.head hostName])
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
}

- (void)testResolvedServicesWithTXTRecordsOfTypeInDomain {
    __block RACSequence *services = nil;
	[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        services = _services_;
    }];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    NDD_TEST_NOTNIL([services.head hostName])
    NDD_TEST_EQUAL_OBJECTS([services.head TXTRecordData], [NSNetService dataFromTXTRecordDictionary:TXTRecord])
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 1)
    NDD_TEST_EQUAL_OBJECTS([services.head name], @"Test")
    NDD_TEST_NOTNIL([services.head hostName])
    NDD_TEST_EQUAL_OBJECTS([services.head TXTRecordData], [NSNetService dataFromTXTRecordDictionary:TXTRecord])    
    [server stop];
    NDD_TEST_WAIT_UNTIL_TRUE(services.array.count == 0)
    [server publish];
}

- (void)testErrorInServicesOfTypeInDomain {
    __block NSError *error = nil;
	[[NSNetService rns_servicesOfType:@"invalidServiceType" inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        XCTAssertNil(_services_.head)
    } error:^(NSError *_error_) {
        error = _error_;
    }];
    NDD_TEST_WAIT_UNTIL_TRUE(error != nil)
    NDD_TEST_EQUAL_OBJECTS(error.domain, NSStringFromClass([NSNetService class]))
}

- (void)netService:(NSNetService *)netService didNotPublish:(NSDictionary *)errorDictionary {
    XCTFail(@"Failed to publish service: %@", RNSErrorForErrorDictionary(errorDictionary))
}

- (void)netServiceWillPublish:(NSNetService *)netService {
    NDD_TRACE_ENTRY
    NDD_TRACE_OBJECT(_netService)
    NDD_ASSERT(_netService)
    DTSLog(@"Service will publish: %@", _netService);
    NDD_TRACE_EXIT
}

- (void)netServiceDidPublish:(NSNetService *)netService {
    NSLog(@"Service did publish: %@", _netService);
}

- (void)netServiceDidStop:(NSNetService *)netService {
    NSLog(@"Service did stop: %@", _netService);
}
*/

@end
