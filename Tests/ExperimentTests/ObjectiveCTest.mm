//
//  TestTest.m
//  ExperimentTests
//
//  Created by Brian Giori on 7/20/21.
//

#import <XCTest/XCTest.h>
#import <Experiment/Experiment-Swift.h>
#import <AnalyticsConnector/AnalyticsConnector-Swift.h>
#import <dispatch/dispatch.h>

@interface ObjectiveCTest : XCTestCase

@end

@implementation ObjectiveCTest

- (void)testObjectiveCBasic {
    Variant *expectedVariant = [[Variant alloc] init:@"on" payload:@"payload"];
    
    ExperimentConfig *conf = [ExperimentConfig new];
    ExperimentUserBuilder *builder = [ExperimentUserBuilder new];
    builder = [builder userId:@"test"];
    ExperimentUser *user = [builder build];
    id<ExperimentClient> client = [Experiment initializeWithApiKey:@"client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3" config:conf];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [client fetchWithUser:user completion:^(id<ExperimentClient> _Nonnull client, NSError * _Nullable error) {
        Variant *variant = [client variant:@"sdk-ci-test"];
        XCTAssertTrue([variant isEqual:expectedVariant]);
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

@end
