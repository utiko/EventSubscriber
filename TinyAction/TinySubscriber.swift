//
//  TinySubscriber.swift
//
//  Created by Kostia Kolesnyk on 10/29/17.
//  Copyright © 2017 uTiko. All rights reserved.
//
//  My experiment based on NSNotification

struct TinySubscriberConstants {
    static let notificationPrefix = "TSNotification"
    static let dataKey: String = "ts_data"
}

typealias TinySubscription = NSObjectProtocol

protocol TinySubscriber: class {
    var subscriptions: [String: TinySubscription]? { get set }
    func subscribe<T: TinyAction>(using: @escaping (T, Any?) -> Void)
    func unsubscribe<T: TinyAction>(action: T.Type) 
    func unsubscribeAll()
}

private var subscriptionsAssociationKey: UInt8 = 0

extension TinySubscriber {
    
    var subscriptions: [String: TinySubscription]? {
        get {
            return objc_getAssociatedObject(self, &subscriptionsAssociationKey) as? [String: TinySubscription]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &subscriptionsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func subscribe<T: TinyAction>(using: @escaping (_ action: T) -> Void) {
        subscribe { (action: T, _) in
            using(action)
        }
    }
    
    func subscribe<T: TinyAction>(using: @escaping (_ action: T, _ object: Any?) -> Void) {
        let key = TinySubscriberConstants.notificationPrefix + String(describing: T.self)
        let notificationName = NSNotification.Name(key)

        removeSubscription(forKey: key)
        let subscription = NotificationCenter.default.addObserver(forName: notificationName,
                                                                  object: nil,
                                                                  queue: nil) { (notification) in
            guard let userInfo = notification.userInfo,
            let action = userInfo[TinySubscriberConstants.dataKey] as? T else { return }
            using(action, notification.object)
        }
        if subscriptions == nil { subscriptions = [:] }
        subscriptions?[key] = subscription
    }
    
    func removeSubscription(forKey key: String) {
        if let subscriptions = subscriptions, let subscription = subscriptions[key] {
            NotificationCenter.default.removeObserver(subscription)
            self.subscriptions?[key] = nil
        }
    }
    
    func unsubscribe<T: TinyAction>(action: T.Type) {
        let key = TinySubscriberConstants.notificationPrefix + String(describing: T.self)
        removeSubscription(forKey: key)
    }
    
    func unsubscribeAll() {
        guard let subscriptions = subscriptions else { return }

        for (_, subscription) in subscriptions {
            NotificationCenter.default.removeObserver(subscription)
        }
        self.subscriptions?.removeAll()
    }
}
