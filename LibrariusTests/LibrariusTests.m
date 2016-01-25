//
//  LibrariusTests.m
//  LibrariusTests
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Specta.h>
#import <Expecta.h>
#import "LBRAlertContent_TableViewController.h"

SpecBegin(LBRAlertContent_TableViewController)
describe(@"LBRAlertContent_TableViewController", ^{
   it(@"should initialize, not be nil", ^{
       LBRAlertContent_TableViewController *testController = [[LBRAlertContent_TableViewController alloc] initWithStyle:UITableViewStylePlain];
       
       expect(testController).toNot.equal(nil);
   });
});

SpecEnd
 
/*
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LBRAlertContent_TableViewController.h"

@interface LibrariusTests : XCTestCase

@end

@implementation LibrariusTests

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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
*/
