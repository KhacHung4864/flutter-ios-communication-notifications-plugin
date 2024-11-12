import Intents
import UIKit
import UserNotifications

class CommunicationNotificationPlugin {

    // Function to check if a notification with the same content has been delivered
    func hasDuplicateNotification(_ notificationInfo: NotificationInfo, completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getDeliveredNotifications { deliveredNotifications in
            // Loop through the delivered notifications
            for deliveredNotification in deliveredNotifications {
                // Check the content of the delivered notification
                if let notificationContent = deliveredNotification.request.content as? UNMutableNotificationContent,
                   notificationContent.title == notificationInfo.senderName && notificationContent.body == notificationInfo.content {
                    // If a duplicate notification is found, return true
                    completion(true)
                    return
                }
            }
            
            // If no duplicate notification is found, return false
            completion(false)
        }
    }

    func  showNotification(_ notificationInfo: NotificationInfo) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings {
            settings in switch settings.authorizationStatus {
            case .authorized:
                self.hasDuplicateNotification(notificationInfo) { hasDuplicate in
                    if !hasDuplicate {
                        // If no duplicate notification is found, proceed to show the new notification
                        self.dispatchNotification(notificationInfo)
                    }
                }
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                    didAllow, _ in
                    if didAllow {
                        self.hasDuplicateNotification(notificationInfo) { hasDuplicate in
                            if !hasDuplicate {
                                // If no duplicate notification is found, proceed to show the new notification
                                self.dispatchNotification(notificationInfo)
                            }
                        }
                    }
                }
            default: return
            }
        }
    }
    
    func dispatchNotification(_ notificationInfo: NotificationInfo) {
    if #available(iOS 15.0, *) {
        let uuid = UUID().uuidString
        let currentTime = Date().timeIntervalSince1970
        let identifier = "\(IosCommunicationConstant.prefixIdentifier):\(uuid):\(currentTime)"

        var content = UNMutableNotificationContent()
        
        content.title = notificationInfo.senderName
        content.body = notificationInfo.content
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm"))
        content.categoryIdentifier = identifier
        content.userInfo = ["data": notificationInfo.value]
        
        var personNameComponents = PersonNameComponents()
        personNameComponents.nickname = notificationInfo.senderName
        
        let avatar = INImage(imageData: notificationInfo.pngImage)
        
        if let bannerURL = saveImageToDisk(notificationInfo.bannerImage) {
            do {
                let bannerAttachment = try UNNotificationAttachment(identifier: "banner", url: bannerURL, options: nil)
                content.attachments = [bannerAttachment]
            } catch {
                print("Error creating banner attachment: \(error)")
            }
        }

        
        let senderPerson = INPerson(
            personHandle: INPersonHandle(value: notificationInfo.value, type: .unknown),
            nameComponents: personNameComponents,
            displayName: notificationInfo.senderName,
            image: avatar,
            contactIdentifier: nil,
            customIdentifier: nil,
            isMe: false,
            suggestionType: .none
        )
        
        let mPerson = INPerson(
            personHandle: INPersonHandle(value: "", type: .unknown),
            nameComponents: nil,
            displayName: nil,
            image: nil,
            contactIdentifier: nil,
            customIdentifier: nil,
            isMe: true,
            suggestionType: .none
        )
        
        let intent = INSendMessageIntent(
            recipients: [mPerson],
            outgoingMessageType: .outgoingMessageText,
            content: notificationInfo.content,
            speakableGroupName: INSpeakableString(spokenPhrase: notificationInfo.senderName),
            conversationIdentifier: notificationInfo.senderName,
            serviceName: nil,
            sender: senderPerson,
            attachments: nil
        )
        
        intent.setImage(avatar, forParameterNamed: \.sender)
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate(completion: { error in
            if let error = error {
                print("Error donating interaction: \(error)")
            }
        })
        
        do {
            content = try content.updating(from: intent) as! UNMutableNotificationContent
        } catch {
            print("Error updating content from intent: \(error)")
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        let closeAction = UNNotificationAction(identifier: "close", title: "Close", options: .destructive)
        let category = UNNotificationCategory(identifier: identifier, actions: [closeAction], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().add(request)
    }
}

// Helper function to save image data to disk
func saveImageToDisk(_ imageData: Data) -> URL? {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let imageFileURL = temporaryDirectory.appendingPathComponent("bannerImage_\(UUID().uuidString).jpg")
    
    do {
        try imageData.write(to: imageFileURL)
        return imageFileURL
    } catch {
        print("Error saving image to disk: \(error)")
        return nil
    }
}

}
