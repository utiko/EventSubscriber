//
//  EventTests.swift
//  EventTests
//
//  Created by Kostiantyn Kolesnyk on 6/1/18.
//  Copyright © 2018 Kostiantyn Kolesnyk. All rights reserved.
//

import XCTest
@testable import EventSubscriber

class EventSubscriberTests: XCTestCase, EventSubscriber {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSubscribtion() {
        
        struct ActionWithParameters: Event {
            var message: String
            var value: Int
        }
        
        func performAction() {
            ActionWithParameters(message: "Blah", value: 10).perform()
        }
        
        var actionTriggered = false
            
        subscribe { (action: ActionWithParameters) in
            actionTriggered = true
            XCTAssertEqual(action.message, "Blah", "Wrong message")
            XCTAssertEqual(action.value, 10, "Wrong value")
        }
        
        performAction()
        
        XCTAssertEqual(actionTriggered, true, "Action was not triggered")
    }
    
    func testSingleActionUnsubscribe() {
        var firstActionTriggered = false
        var secondActionTriggered = false

        struct FirstAction: Event {}
        struct SecondAction: Event {}
        
        func performActions() {
            FirstAction().perform()
            SecondAction().perform()
        }
        
        subscribe { (action: FirstAction) in
            firstActionTriggered = true
        }
        subscribe { (action: SecondAction) in
            secondActionTriggered = true
        }
        
        performActions()
        
        XCTAssertEqual(firstActionTriggered, true, "First action wasn't triggered")
        XCTAssertEqual(secondActionTriggered, true, "Second action wasn't triggered")
        
        firstActionTriggered = false
        secondActionTriggered = false
        
        unsubscribe(action: FirstAction.self)
        
        performActions()
        
        XCTAssertEqual(firstActionTriggered, false, "First action wasn't unsubscribed")
        XCTAssertEqual(secondActionTriggered, true, "Second action wasn't triggered")
    }
    
    func testUnsubscribeAll() {
        var firstActionTriggered = false
        var secondActionTriggered = false
        
        struct FirstAction: Event {}
        struct SecondAction: Event {}
        
        func performActions() {
            FirstAction().perform()
            SecondAction().perform()
        }
        
        subscribe { (action: FirstAction) in
            firstActionTriggered = true
        }
        subscribe { (action: SecondAction) in
            secondActionTriggered = true
        }
        
        performActions()
        
        XCTAssertEqual(firstActionTriggered, true, "First action wasn't triggered")
        XCTAssertEqual(secondActionTriggered, true, "Second action wasn't triggered")
        
        firstActionTriggered = false
        secondActionTriggered = false
        
        unsubscribeAll()
        
        performActions()
        
        XCTAssertEqual(firstActionTriggered, false, "First action wasn't unsubscribed")
        XCTAssertEqual(secondActionTriggered, false, "Second action wasn't unsubscribed")
    }
    
    func testEnumAction() {
        
        class AuthorizationService {
            
            enum AuthStateChangeAction: Event {
                case signIn
                case signOut
            }
            
            func signIn() {
                /* [Some sign in jobs] */
                
                // Call the action
                AuthStateChangeAction.signIn.perform()
            }
            
            func signOut() {
                /* [Some sign out jobs] */
                
                // Call the action
                AuthStateChangeAction.signOut.perform()
            }
        }
        
        class AuthorizationChangeHandler: EventSubscriber {

            public var authorized: Bool = false

            init() {
                subscribe { [weak self] (action: AuthorizationService.AuthStateChangeAction) in
                    switch action {
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
        struct Action: Event {}
        
        class SomeSubscriber: EventSubscriber {
            deinit {
                unsubscribeAll()
            }
        }

        var subscriber: SomeSubscriber?  = SomeSubscriber()
        weak var subscriberCheck = subscriber

        var blockRun = false
        
        subscriber?.subscribe{ (_: Action) in
            blockRun = true
        }

        subscriber = nil
        
        Action().perform()

        XCTAssertNil(subscriberCheck, "Memory leak occured")
        XCTAssertFalse(blockRun, "Subscription still exists")
    }
}


