//
//  EventSubscriberTests.swift
//  EventSubscriberTests
//
//  Created by Kostiantyn Kolesnyk on 6/1/18.
//  Copyright © 2018 Kostiantyn Kolesnyk. All rights reserved.
//

import XCTest
@testable import EventSubscriber

class EventSubscriberTests: XCTestCase, NotificationSubscriber {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSubscribtion() {
        
        struct EventWithParameters: NotificationEvent {
            var message: String
            var value: Int
        }
        
        func performEvent() {
            EventWithParameters(message: "Blah", value: 10).send()
        }
        
        var eventTriggered = false
            
        subscribe { (event: EventWithParameters) in
            eventTriggered = true
            XCTAssertEqual(event.message, "Blah", "Wrong message")
            XCTAssertEqual(event.value, 10, "Wrong value")
        }
        
        performEvent()
        
        XCTAssertEqual(eventTriggered, true, "Event was not triggered")
    }
    
    func testSingleEventUnsubscribe() {
        var firstEventTriggered = false
        var secondEventTriggered = false

        struct FirstEvent: NotificationEvent {}
        struct SecondEvent: NotificationEvent {}
        
        func performEvents() {
            FirstEvent().send()
            SecondEvent().send()
        }
        
        subscribe { (event: FirstEvent) in
            firstEventTriggered = true
        }
        subscribe { (event: SecondEvent) in
            secondEventTriggered = true
        }
        
        performEvents()
        
        XCTAssertEqual(firstEventTriggered, true, "First event wasn't triggered")
        XCTAssertEqual(secondEventTriggered, true, "Second event wasn't triggered")
        
        firstEventTriggered = false
        secondEventTriggered = false
        
        unsubscribe(event: FirstEvent.self)
        
        performEvents()
        
        XCTAssertEqual(firstEventTriggered, false, "First event wasn't unsubscribed")
        XCTAssertEqual(secondEventTriggered, true, "Second event wasn't triggered")
    }
    
    func testUnsubscribeAll() {
        var firstEventTriggered = false
        var secondEventTriggered = false
        
        struct FirstEvent: NotificationEvent {}
        struct SecondEvent: NotificationEvent {}
        
        func performEvents() {
            FirstEvent().send()
            SecondEvent().send()
        }
        
        subscribe { (event: FirstEvent) in
            firstEventTriggered = true
        }
        subscribe { (event: SecondEvent) in
            secondEventTriggered = true
        }
        
        performEvents()
        
        XCTAssertEqual(firstEventTriggered, true, "First event wasn't triggered")
        XCTAssertEqual(secondEventTriggered, true, "Second event wasn't triggered")
        
        firstEventTriggered = false
        secondEventTriggered = false
        
        unsubscribeAll()
        
        performEvents()
        
        XCTAssertEqual(firstEventTriggered, false, "First event wasn't unsubscribed")
        XCTAssertEqual(secondEventTriggered, false, "Second event wasn't unsubscribed")
    }
    
    func testEnumEvent() {
        
        class AuthorizationService {
            
            enum AuthStateChangeEvent: NotificationEvent {
                case signIn
                case signOut
            }
            
            func signIn() {
                /* [Some sign in jobs] */
                
                // Call the event
                AuthStateChangeEvent.signIn.send()
            }
            
            func signOut() {
                /* [Some sign out jobs] */
                
                // Call the event
                AuthStateChangeEvent.signOut.send()
            }
        }
        
        class AuthorizationChangeHandler: NotificationSubscriber {

            public var authorized: Bool = false

            init() {
                subscribe { [weak self] (event: AuthorizationService.AuthStateChangeEvent) in
                    switch event {
                    case .signIn: self?.authorized = true
                    case .signOut: self?.authorized = false
                    }
                }
            }
            
            deinit {
                unsubscribeAll()
            }
        }
        
        let authService = AuthorizationService()
        let authHandler = AuthorizationChangeHandler()

        authService.signIn()
        XCTAssertEqual(authHandler.authorized, true, "Wrong state")

        authService.signOut()
        XCTAssertEqual(authHandler.authorized, false, "Wrong state")
    }
    
    func testMemoryLeak() {
        struct SomeEvent: NotificationEvent {}
        
        class SomeSubscriber: NotificationSubscriber {
            deinit {
                unsubscribeAll()
            }
        }

        var subscriber: SomeSubscriber?  = SomeSubscriber()
        weak var subscriberCheck = subscriber

        var blockRun = false
        
        subscriber?.subscribe{ (_: SomeEvent) in
            blockRun = true
        }

        subscriber = nil
        
        SomeEvent().send()

        XCTAssertNil(subscriberCheck, "Memory leak occured")
        XCTAssertFalse(blockRun, "Subscription still exists")
    }
}


