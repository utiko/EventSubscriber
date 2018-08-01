//
//  TinyAction.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//

import Foundation

public protocol Event {
    func perform()
}

public extension Event {
    public func perform() {
        performAction(action: self)
    }
    
    public func perform(withObject object: Any) {
        performAction(action: self, object: object)
    }
    
    private func performAction<T: Event>(action: T, object: Any? = nil) {
        let key = EventSubscriberConstants.notificationPrefix + String(describing: type(of: action))
        let notificationName = NSNotification.Name(key)
        
        let userInfo = [EventSubscriberConstants.dataKey: action]
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
}
