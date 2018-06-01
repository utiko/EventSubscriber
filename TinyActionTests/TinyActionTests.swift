//
//  TinyActionTests.swift
//  TinyActionTests
//
//  Created by Kostiantyn Kolesnyk on 6/1/18.
//  Copyright © 2018 Kostiantyn Kolesnyk. All rights reserved.
//

import XCTest
@testable import TinyAction

class TinyActionTests: XCTestCase, TinySubscriber {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSubscribtion() {
        
        struct ActionWithParameters: TinyAction {
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

        struct FirstAction: TinyAction {}
        struct SecondAction: TinyAction {}
        
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
        
        struct FirstAction: TinyAction {}
        struct SecondAction: TinyAction {}
        
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
        enum AuthState: TinyAction {
            case signIn
            case signOut
        }
        
        func signIn() {
            AuthState.signIn.perform()
        }
        func signOut() {
            AuthState.signOut.perform()
        }

        var actionTriggered = false
        var localAuthState: AuthState = .signIn
        
        subscribe { (state: AuthState) in
            actionTriggered = true
            localAuthState = state
        }
        
        signIn()
        XCTAssertEqual(localAuthState, AuthState.signIn, "Wrong state")

        signOut()
        XCTAssertEqual(localAuthState, AuthState.signOut, "Wrong state")

        XCTAssertEqual(actionTriggered, true, "Action was not triggered")
    }
}
