// Copyright © 2019 Brad Howes. All rights reserved.

import Foundation

/**
 Manage subscriptions to event notifications. Events can be anything but are usually defined as an enum.
 */
public class SubscriptionManager<Event> {

    public typealias NotifierProc = (Event) -> Void
    public typealias UnsubscribeProc = () -> Void

    private var subscriptions = [UUID: NotifierProc]()

    private struct Token: SubscriberToken {
        private let unsubscribeProc: UnsubscribeProc
        fileprivate init(_ unsubscribeProc: @escaping UnsubscribeProc) { self.unsubscribeProc = unsubscribeProc }
        public func unsubscribe() { unsubscribeProc() }
    }

    private var lastEvent: Event?
    private let cacheEvent: Bool

    public init(_ cacheEvent: Bool = false) { self.cacheEvent = cacheEvent }

    /**
     Establish a connection between the SubscriptionManager and the notifier such that any future Events will be sent
     to the notifier.

     - parameter subscriber: the object that is subscribing -- if it dies, then the subscription is automatically
     removed.
     - parameter notifier: the closure to invoke for each new Event
     - returns: a token that knows how to unsubscribe
     */
    @discardableResult
    public func subscribe<O: AnyObject>(_ subscriber: O, notifier: @escaping NotifierProc) -> SubscriberToken {
        let uuid = UUID()
        let token = Token { [weak self] in self?.subscriptions.removeValue(forKey: uuid) }
        subscriptions[uuid] = { [weak subscriber] kind in
            if subscriber != nil {
                notifier(kind)
            }
            else {
                token.unsubscribe()
            }
        }

        if let event = lastEvent, cacheEvent {
            DispatchQueue.main.async { notifier(event) }
        }

        return token
    }

    public func notify(_ event: Event) {
        if cacheEvent { lastEvent = event }
        subscriptions.values.forEach { $0(event) }
    }
}
