# Notification Handling on WatchKit

As we’ve lived with the Apple Watch for over 2 years now, we’ve learned that notifications are one of the main interaction modes on the device. If anything, they’ve become even more important as Apple has expanded the notification experience to include things like mutable content, attachments, and guaranteed on-watch local notifications.

To our users, notification handling on an Apple Watch may look very similar to notification handling on other iOS devices. As developers, though, we need to realize that the limitations inherent to WatchKit require different approaches to fully integrating notifications than you would need when using UIKit.

This talk covers configuring a modern notification experience with the `UserNotifications` framework and what you must consider when designing your Apple Watch experience with notifications in mind. Namely, `WatchKit` _is not_ `UIKit` and `InterfaceController` _is not_ `UIViewController`. Understanding these differences from the beginning is key to avoid painting yourself into a corner when implementing notification handing.

