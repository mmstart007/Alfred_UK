//
//  AlfredTests.m
//  AlfredTests
//
//  Created by Arjun Busani on 18/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AlfredWallet.h"
#import "AlfredCreditCard.h"
@interface AlfredTests : XCTestCase

@end

@implementation AlfredTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

-(void)testAlfredCreditCard{
    AlfredCreditCard *card = [[AlfredCreditCard alloc] initWithNumber:@"12345050505005" andHolder:@"Miguel Carvajal"];
    XCTAssert([[card getExpiracy] isEqualToString:@"07/2015"],@"YES");
    

}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
