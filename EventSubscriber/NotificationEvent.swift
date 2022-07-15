//
//  Event.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//

import Foundation

public protocol NotificationEvent {
    func send()
}

public extension NotificationEvent {
    func send() {
        sendEvent(event: self)
    }
    
    func send(withObject object: Any) {
        sendEvent(event: self, object: object)
    }
}

private extension NotificationEvent {
    private func sendEvent<T: NotificationEvent>(event: T, object: Any? = nil) {
        let key = NotificationSubscriberConstants.notificationPrefix + String(describing: type(of: event))
        let notificationName = NSNotification.Name(key)
        
        let userInfo = [NotificationSubscriberConstants.dataKey: event]
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
}
