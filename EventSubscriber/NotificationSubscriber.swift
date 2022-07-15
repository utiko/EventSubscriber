//
//  EventSubscriber.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//
//  My experiment based on NSNotification

import Foundation

public typealias NotificationSubscription = NSObjectProtocol

public protocol NotificationSubscriber: class {
    func subscribe<T: NotificationEvent>(using: @escaping (T, Any?) -> Void)
    func unsubscribe<T: NotificationEvent>(event: T.Type)
    func unsubscribeAll()
}

public extension NotificationSubscriber {
    
    var subscriptions: [String: NotificationSubscription]? {
        get {
            return objc_getAssociatedObject(self, &NotificationSubscriptionAssociatedKeys.subscriptions) as? [String: NotificationSubscription]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &NotificationSubscriptionAssociatedKeys.subscriptions, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func subscribe<T: NotificationEvent>(using: @escaping (_ event: T) -> Void) {
        subscribe { (event: T, _) in
            using(event)
        }
    }
    
    func subscribe<T: NotificationEvent>(using: @escaping (_ event: T, _ object: Any?) -> Void) {
        let key = NotificationSubscriberConstants.notificationPrefix + String(describing: T.self)
        let notificationName = NSNotification.Name(key)

        removeSubscription(forKey: key)
        let subscription = NotificationCenter.default.addObserver(forName: notificationName,
                                                                  object: nil,
                                                                  queue: nil) { (notification) in
            guard let userInfo = notification.userInfo,
            let event = userInfo[NotificationSubscriberConstants.dataKey] as? T else { return }
            using(event, notification.object)
        }
        if subscriptions == nil { subscriptions = [:] }
        subscriptions?[key] = subscription
    }
    
    func unsubscribe<T: NotificationEvent>(event: T.Type) {
        let key = NotificationSubscriberConstants.notificationPrefix + String(describing: T.self)
        removeSubscription(forKey: key)
    }
    
    func unsubscribeAll() {
        guard let subscriptions = subscriptions else { return }

        for (_, subscription) in subscriptions {
            NotificationCenter.default.removeObserver(subscription)
        }
        self.subscriptions?.removeAll()
    }
    
    private func removeSubscription(forKey key: String) {
        if let subscriptions = subscriptions, let subscription = subscriptions[key] {
            NotificationCenter.default.removeObserver(subscription)
            self.subscriptions?[key] = nil
        }
    }
}

internal struct NotificationSubscriberConstants {
    static let notificationPrefix = "net.utiko.ESNotification."
    static let dataKey: String = "net.utiko.es.data"
}

private struct NotificationSubscriptionAssociatedKeys {
    static var subscriptions: UInt8 = 0
}

