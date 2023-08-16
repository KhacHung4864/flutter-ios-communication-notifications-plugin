## iOS Communication Notifications

- Ref: [Apple Docs](https://developer.apple.com/documentation/usernotifications/implementing_communication_notifications)


## Screenshots:

<p>
<img src="https://github.com/lambiengcode/ios_communication_notification/raw/main/screenshots/IMG_0768.png?raw=true" width="200px" />
<img src="https://github.com/lambiengcode/ios_communication_notification/raw/main/screenshots/IMG_0769.jpg?raw=true" width="200px" />
</p

## Features

* support show communication notifications on ios 15 or above
* support callback onclick notification

## Configuration

- Install package

```terminal
flutter pub add ios_communication_notification
```

```terminal
flutter clean && flutter pub get
```
<br/>

- Config XCode

> Capabilities
1. Open your Project in XCode.
2. Click on `Runner`, then Target `Runner`
3. Click on Signing & Capabilities
4. Add Capability
5. Add Communication Notifications

> Info.plist
1. Open `Info.plist`
2. Add `NSUserActivityTypes` as type array
3. Add `INSendMessageIntent` as the element of the newly created array

<br/>

- Config AppDelegate Extension

1. Open `AppDelegate.swift`
2. Copy the below piece of code and add it at the end of the file

```swift
import UIKit
import ios_communication_notification

extension AppDelegate {
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 15.0, *) {
            if (notification.request.identifier.starts(with: IosCommunicationConstant.prefixIdentifier)) {
                completionHandler([.banner, .badge, .sound, .list])
            }
        }
        
        return super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if #available(iOS 15.0, *) {
            if (response.notification.request.identifier.starts(with: IosCommunicationConstant.prefixIdentifier)) {
                let userInfo = response.notification.request.content.userInfo
                
                IosCommunicationNotificationPlugin.shared.onClickNotification(userInfo)
                
                completionHandler()
            }
        }
        
        return super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
```

## Usage

- Check available for show communication notifications

```dart
// if iOS 15 or above
final bool isAvailableForCommunication = await IosCommunicationNotification().isAvailable();
```

- Show notification

```dart
IosCommunicationNotification().showNotification(
  NotificationInfo(
    senderName: "lambiengcode",
    imageBytes: imageBuffer,
    value: "This is payload, will receive when click this notification",
    content: "Hello Flutter"
  ),
);
```

- Get initial payload - useful for check and get payload if app start from click communication notification

```dart
IosCommunicationNotification().getInitialPayload().then((payload) {
    // TODO: do somethings
});
```

- Set onClick callback function
  
```dart
IosCommunicationNotification().setOnClickNotification((payload) {
    // TODO: do somethings
});
```

### ReactionBoxParamenters
| parameter                  | description                                                                           | default                                                                                                                                                                               |
| -------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| senderName          | Title of notification - sender message notification                                           |required|
| imageBytes                  | Avatar of sender |required|
| content            | Message content                                                        | required |
| value               | Payload notification                            | required |      

## Download Askany

<p>
<a href="https://apps.apple.com/vn/app/askany/id1589217505"><img src="https://askany.com/images/app-store.png" height="60px" width="180px"/></a>
<a href="https://play.google.com/store/apps/details?id=com.askany"><img src="https://askany.com/images/ch-play.png" height="60px" width="180px"/></a>
</p>

## License - lambiengcode

```terminal
MIT License

Copyright (c) 2022 Askany

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
