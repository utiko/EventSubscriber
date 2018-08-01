# EventSubscriber

Allows to create event types with strong structure of parameters.

You can create event based on enums and structs, subscribe and handle it at different places of your application.

Use ```Event``` protocol to deeclare an event type.
Conform ```EventSubscriber``` protocol to allow object subscribe for events
Pass event type into a ```subscribe()``` function block as parameter type to subscribe for specific event.
Not forget to call ```unsubscribeAll()``` method on deinit.

Please look at EventSubscriberTests for more clear understanding.

## Author

Kostia Kolesnyk, tiko@utiko.net

## License

EventSubscriber is available under the MIT license. See the LICENSE file for more info.
