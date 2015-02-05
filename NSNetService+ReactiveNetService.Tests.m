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

- (void)testServicesOfTypeInDomain {
    __block RACSequence *services = nil;
	[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        services = _services_;
    }];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    takeUntilBlock:^BOOL(RACSequence *_services_) {
        return _services_.array.count == 1 && [[_services_.head name] isEqualToString:@"Test"];
    }]
    subscribeCompleted:^{
        [expectation1 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    takeUntilBlock:^BOOL(RACSequence *_services_) {
        return _services_.array.count == 0;
    }]
    subscribeCompleted:^{
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server publish];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    takeUntilBlock:^BOOL(RACSequence *_services_) {
        return _services_.array.count == 1 && [[_services_.head name] isEqualToString:@"Test"];
    }]
    subscribeCompleted:^{
        [expectation3 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_servicesOfType:type inDomain:@"local"]
    takeUntilBlock:^BOOL(RACSequence *_services_) {
        return _services_.array.count == 0;
    }]
    subscribeCompleted:^{
        [expectation4 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

/**

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
*/

- (void)testErrorInServicesOfTypeInDomain {
    XCTestExpectation *expectation = [self expectationWithDescription:@"error returned"];
	[[NSNetService rns_servicesOfType:@"invalidServiceType" inDomain:@"local"]
    subscribeNext:^(RACSequence *_services_) {
        XCTAssertNil(_services_.head);
    } error:^(NSError *_error_) {
        XCTAssertEqualObjects(_error_.domain, NSURLErrorDomain);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:50.0 handler:nil];
}

- (void)netService:(NSNetService *)netService didNotPublish:(NSDictionary *)errorDictionary {
    XCTFail(@"Failed to publish service: %@", RNSErrorForErrorDictionary(errorDictionary));
}

- (void)netServiceWillPublish:(NSNetService *)netService {
    NSLog(@"Service will publish: %@", netService);
}

- (void)netServiceDidPublish:(NSNetService *)netService {
    NSLog(@"Service did publish: %@", netService);
}

- (void)netServiceDidStop:(NSNetService *)netService {
    NSLog(@"Service did stop: %@", netService);
}

@end
