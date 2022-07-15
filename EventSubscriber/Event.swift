//
//  Event.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//

import Foundation

public protocol Event {
    func send()
}

public extension Event {
    func send() {
        sendEvent(event: self)
    }
    
    func send(withObject object: Any) {
        sendEvent(event: self, object: object)
    }
}

private extension Event {
    private func sendEvent<T: Event>(event: T, object: Any? = nil) {
        let key = EventSubscriberConstants.notificationPrefix + String(describing: type(of: event))
        let notificationName = NSNotification.Name(key)
        
        let userInfo = [EventSubscriberConstants.dataKey: event]
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
}
