//
//  EventSubscriber.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//
//  My experiment based on NSNotification

import Foundation

struct EventSubscriberConstants {
    static let notificationPrefix = "net.utiko.ESNotification."
    static let dataKey: String = "net.utiko.es.data"
}

public typealias EventSubscription = NSObjectProtocol

public protocol EventSubscriber: class {
    var subscriptions: [String: EventSubscription]? { get set }
    func subscribe<T: Event>(using: @escaping (T, Any?) -> Void)
    func unsubscribe<T: Event>(event: T.Type)
    func unsubscribeAll()
}

fileprivate struct TinySubscriptionAssociatedKeys {
    static var subscriptions: UInt8 = 0
}

public extension EventSubscriber {
    
    public var subscriptions: [String: EventSubscription]? {
        get {
            return objc_getAssociatedObject(self, &TinySubscriptionAssociatedKeys.subscriptions) as? [String: EventSubscription]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &TinySubscriptionAssociatedKeys.subscriptions, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func subscribe<T: Event>(using: @escaping (_ event: T) -> Void) {
        subscribe { (event: T, _) in
            using(event)
        }
    }
    
    public func subscribe<T: Event>(using: @escaping (_ event: T, _ object: Any?) -> Void) {
        let key = EventSubscriberConstants.notificationPrefix + String(describing: T.self)
        let notificationName = NSNotification.Name(key)

        removeSubscription(forKey: key)
        let subscription = NotificationCenter.default.addObserver(forName: notificationName,
                                                                  object: nil,
                                                                  queue: nil) { (notification) in
            guard let userInfo = notification.userInfo,
            let event = userInfo[EventSubscriberConstants.dataKey] as? T else { return }
            using(event, notification.object)
        }
        if subscriptions == nil { subscriptions = [:] }
        subscriptions?[key] = subscription
    }
    
    private func removeSubscription(forKey key: String) {
        if let subscriptions = subscriptions, let subscription = subscriptions[key] {
            NotificationCenter.default.removeObserver(subscription)
            self.subscriptions?[key] = nil
        }
    }
    
    public func unsubscribe<T: Event>(event: T.Type) {
        let key = EventSubscriberConstants.notificationPrefix + String(describing: T.self)
        removeSubscription(forKey: key)
    }
    
    public func unsubscribeAll() {
        guard let subscriptions = subscriptions else { return }

        for (_, subscription) in subscriptions {
            NotificationCenter.default.removeObserver(subscription)
        }
        self.subscriptions?.removeAll()
    }
}
