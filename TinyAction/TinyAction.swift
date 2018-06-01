//
//  TinyAction.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//

import Foundation

protocol TinyAction {
    func perform()
}

extension TinyAction {
    func perform() {
        performAction(action: self)
    }
    
    func perform(withObject object: Any) {
        performAction(action: self, object: object)
    }
    
    private func performAction<T: TinyAction>(action: T, object: Any? = nil) {
        let key = TinySubscriberConstants.notificationPrefix + String(describing: type(of: action))
        let notificationName = NSNotification.Name(key)
        
        let userInfo = [TinySubscriberConstants.dataKey: action]
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
}
