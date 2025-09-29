//
//  TestTest.m
//  ExperimentTests
//
//  Created by Brian Giori on 7/20/21.
//

#import <XCTest/XCTest.h>
#import <Experiment/Experiment-Swift.h>
#import <dispatch/dispatch.h>

void assertVariantEqualExpected(Variant *expected, Variant *actual) {
    NSMutableDictionary *metadata = [expected.metadata mutableCopy];
    if (metadata == nil && actual.metadata != nil) {
        metadata = [NSMutableDictionary dictionary];
    }
    if (metadata != nil && actual.metadata != nil) {
        metadata[@"evaluationId"] = actual.metadata[@"evaluationId"];
    }
    
    Variant *matchedExpected = [[Variant alloc] init:expected.value payload:expected.payload expKey:expected.expKey key:expected.key metadata:metadata];
    
    XCTAssertNotNil(actual.metadata[@"evaluationId"]);
    XCTAssertEqualObjects(matchedExpected, actual);
    XCTAssertTrue([matchedExpected isEqual:actual]);
}

@interface ObjectiveCTest : XCTestCase

@end

@implementation ObjectiveCTest

- (void)testObjectiveCBasic {
    Variant *expectedVariant = [[Variant alloc] init:@"on" payload:@"payload" expKey:nil key:@"on" metadata:nil];
    
    ExperimentConfigBuilder *confBuilder = [ExperimentConfigBuilder new];
    confBuilder = [confBuilder debug:YES];
    ExperimentConfig *conf = [confBuilder build];
    
    ExperimentUserBuilder *builder = [ExperimentUserBuilder new];
    builder = [builder userId:@"test"];
    ExperimentUser *user = [builder build];
    
    id<ExperimentClient> client = [Experiment initializeWithApiKey:@"client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3" config:conf];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [client fetchWithUser:user completion:^(id<ExperimentClient> _Nonnull client, NSError * _Nullable error) {
        Variant *variant = [client variant:@"sdk-ci-test"];
        assertVariantEqualExpected(expectedVariant, variant);
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

@end
