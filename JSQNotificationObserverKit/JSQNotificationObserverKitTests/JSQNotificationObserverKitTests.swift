//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQNotificationObserverKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQNotificationObserverKit
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest
import Foundation
import UIKit

import JSQNotificationObserverKit


// MARK: Fakes

class TestSender {
    let sender = NSUUID().UUIDString
}

struct TestValue {
    let value = NSUUID().UUIDString
}


// MARK: Test case

class JSQNotificationObserverKitTests: XCTestCase {

    func test_Example_NotificationEmptyTuple_WithoutSender() {

        // GIVEN: a notification
        let notif = Notification<Void, AnyObject>(name: "Notification")

        let expect = self.expectationWithDescription("\(__FUNCTION__)")

        // GIVEN: an observer
        let observer = NotificationObserver(notification: notif, handler: { (value, sender) -> Void in
            XCTAssertNil(sender, "Sender should be nil")
            expect.fulfill()
        })

        // WHEN: the notification is posted
        postNotification(notif, value: ())

        // THEN: the observer receives the notification and executes its handler
        self.waitForExpectationsWithTimeout(2, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_Example_NotificationDictionary_WithSender() {

        // GIVEN: a userInfo dictionary
        let userInfo = ["someKey": 100, "anotherKey": NSDate()]

        // GIVEN: a notification
        let notif = Notification<[String: NSObject], JSQNotificationObserverKitTests>(name: "ExampleNotification", sender: self)

        let expect = self.expectationWithDescription("\(__FUNCTION__)")

        // GIVEN: an observer
        let observer = NotificationObserver(notification: notif, handler: { (value, sender) -> Void in
            XCTAssertEqual(value, userInfo, "Value should equal expected value")
            XCTAssertEqual(sender!, self, "Sender should equal expected sender")
            expect.fulfill()
        })

        // WHEN: the notification is posted
        postNotification(notif, value: userInfo)

        // THEN: the observer receives the notification and executes its handler
        self.waitForExpectationsWithTimeout(2, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_Example_NotificationDictionary_WithoutSender() {

        // GIVEN: a userInfo dictionary
        let userInfo = ["someKey": 100, "anotherKey": NSDate()]

        // GIVEN: a notification without a sender
        let notif = Notification<[String: NSObject], AnyObject>(name: "ExampleNotification")

        let expect = self.expectationWithDescription("\(__FUNCTION__)")

        // GIVEN: an observer
        let observer = NotificationObserver(notification: notif, queue: NSOperationQueue.mainQueue(), center: NSNotificationCenter.defaultCenter(), handler: { (value, sender) -> Void in
            XCTAssertEqual(value, userInfo, "Value should equal expected value")
            XCTAssertNil(sender, "Sender should be nil")
            expect.fulfill()
        })

        // WHEN: the notification is posted
        postNotification(notif, value: userInfo)

        // THEN: the observer receives the notification and executes its handler
        self.waitForExpectationsWithTimeout(2, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_ThatNotificationIsPosted_AndReceivedByObserver_WithValueAndSender() {

        // GIVEN: a sender, value, notification, and observer
        let fakeSender = TestSender()
        let fakeValue = TestValue()
        let notification = Notification<TestValue, TestSender>(name: "NotificationName", sender: fakeSender)

        let expectation = self.expectationWithDescription("\(__FUNCTION__)")

        let observer = NotificationObserver(notification: notification, handler: { (value, sender) -> Void in
            XCTAssertEqual(value.value, fakeValue.value, "Values should be equal")
            XCTAssertEqual(fakeSender.sender, sender!.sender, "Senders should be equal")
            expectation.fulfill()
        })

        // WHEN: the notification is posted
        postNotification(notification, value: fakeValue)

        // THEN: the observer receives the notification and executes its handler
        self.waitForExpectationsWithTimeout(2, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_ThatNotificationIsPosted_AndReceivedByObserver_WithValueOnly() {

        // GIVEN: value, notification without a sender, and observer
        let fakeValue = TestValue()
        let notification = Notification<TestValue, AnyObject>(name: "NotificationName")

        let expectation = self.expectationWithDescription("\(__FUNCTION__)")

        let observer = NotificationObserver(notification: notification, handler: { (value, sender) -> Void in
            XCTAssertEqual(value.value, fakeValue.value, "Values should be equal")
            XCTAssertNil(sender, "Sender should be nil")
            expectation.fulfill()
        })

        // WHEN: the notification is posted without a specific sender
        postNotification(notification, value: fakeValue)

        // THEN: the observer receives the notification and executes its handler
        self.waitForExpectationsWithTimeout(2, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_ThatObserverUnregistersForNotificationsOnDeinit_WithValueSenderHandler() {

        // GIVEN: a notification and observer
        let fakeValue = TestValue()
        let notification = Notification<TestValue, TestSender>(name: "NotificationName", sender: TestSender())

        var didCallHandler = false
        var observer: NotificationObserver? = NotificationObserver(notification: notification, handler: { (value, sender) -> Void in
            didCallHandler = true
        })

        observer = nil

        // WHEN: the notification is posted after the observer is dealloc'd
        postNotification(notification, value: fakeValue)
        
        // THEN: the observer does not receive the notification and does not execute its handler
        XCTAssertFalse(didCallHandler)
    }
    
}
