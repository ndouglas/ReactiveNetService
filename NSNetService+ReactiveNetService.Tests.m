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
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface NSNetService_ReactiveNetServiceTests : XCTestCase <NSNetServiceDelegate> {
}
@property (strong, nonatomic, readwrite) NSNetService *server;
@property (copy, nonatomic, readwrite) NSString *type;
@property (copy, nonatomic, readwrite) NSString *serviceName;
@property (copy, nonatomic, readwrite) NSDictionary *TXTRecord;
@end

@implementation NSNetService_ReactiveNetServiceTests
@synthesize server;
@synthesize type;
@synthesize serviceName;
@synthesize TXTRecord;

- (void)setUp {
	[super setUp];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self.type = [NSString stringWithFormat:@"_%@._tcp", UUID];
    self.serviceName = [[NSUUID UUID] UUIDString];
    self.TXTRecord = @{
        @"key" : @"value",
    };
    self.server = [[NSNetService alloc] initWithDomain:@"local" type:self.type name:self.serviceName port:1234];
    self.server.TXTRecordData = [NSNetService dataFromTXTRecordDictionary:self.TXTRecord];
    self.server.delegate = self;
    [self.server publish];
}

- (void)tearDown {
    [self.server stop];
    self.server.delegate = nil;
    self.server = nil;
	[super tearDown];
}

- (void)testServicesOfTypeInDomain {
    __block NSArray *services = nil;
	[[NSNetService rns_servicesOfType:self.type inDomain:@"local"]
        subscribeNext:^(NSArray *_services_) {
            services = _services_;
        }];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_servicesOfType:self.type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName];
        }]
        subscribeCompleted:^{
            [expectation1 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [self.server stop];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_servicesOfType:self.type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation2 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [self.server publish];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_servicesOfType:self.type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName];
        }]
        subscribeCompleted:^{
            [expectation3 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [self.server stop];
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_servicesOfType:self.type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation4 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


- (void)testResolvedServicesOfTypeInDomain {
    __block NSArray *services = nil;
	[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
        subscribeNext:^(NSArray *_services_) {
            services = _services_;
        }];
    
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName] && [_services_.firstObject hostName] && [(NSNetService *)_services_.firstObject port] == 1234;
        }]
        subscribeCompleted:^{
            [expectation1 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation2 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server publish];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName] && [_services_.firstObject hostName] && [(NSNetService *)_services_.firstObject port] == 1234;
        }]
        subscribeCompleted:^{
            [expectation3 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_resolvedServicesOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation4 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testResolvedServicesWithTXTRecordsOfTypeInDomain {
    __block NSArray *services = nil;
	[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
        subscribeNext:^(NSArray *_services_) {
            services = _services_;
        }];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName] && [_services_.firstObject hostName] && [[_services_.firstObject TXTRecordData] isEqual:[NSNetService dataFromTXTRecordDictionary:self.TXTRecord]] && [(NSNetService *)_services_.firstObject port] == 1234;
        }]
        subscribeCompleted:^{
            [expectation1 fulfill];
        }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation2 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [server publish];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"service seen"];
    [[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 1 && [[_services_.firstObject name] isEqualToString:self.serviceName] && [_services_.firstObject hostName] && [[_services_.firstObject TXTRecordData] isEqual:[NSNetService dataFromTXTRecordDictionary:self.TXTRecord]] && [(NSNetService *)_services_.firstObject port] == 1234;
        }]
        subscribeCompleted:^{
            [expectation3 fulfill];
        }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];

    [server stop];
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"service removed"];
    [[[NSNetService rns_resolvedServicesWithTXTRecordsOfType:type inDomain:@"local"]
        takeUntilBlock:^BOOL(NSArray *_services_) {
            return _services_.count == 0;
        }]
        subscribeCompleted:^{
            [expectation4 fulfill];
        }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
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
