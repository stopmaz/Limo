//
//  LimeoAppApp.swift
//  LimeoApp
//
//  Created by melih can durmaz on 16.11.2025.
//

import SwiftUI
import SwiftData

/*
 ============================================================================
                        Developer Notes (README)
 ============================================================================
 
 This app currently uses an IN-APP reminder system (the "Upcoming" list
 on the Home screen) and does NOT schedule system-level notifications
 (i.e., notifications that appear when the app is closed).

 ---
 TO ADD LOCAL SYSTEM NOTIFICATIONS LATER (Requires Developer Account for full testing):
 ---
 
 1.  **Requesting Permission:**
     * You must first ask the user for permission to send notifications.
     * A good place to do this is in `SettingsView.swift` or during an
         onboarding flow.
     * Code:
         ```swift
         import UserNotifications
 
         func requestNotificationPermission() {
             UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                 if granted {
                     print("Notification permission granted.")
                 } else if let error {
                     print(error.localizedDescription)
                 }
             }
         }
         ```

 2.  **Scheduling a Notification:**
     * When a `Subscription` is saved (in `AddSubscriptionViewModel.swift`)
         or updated, you would schedule a local notification.
     * You'll need to create a `NotificationManager` class to handle
         this logic cleanly.
     * The logic would look something like this:
 
         ```swift
         func scheduleNotification(for subscription: Subscription) {
             let content = UNMutableNotificationContent()
             content.title = "Subscription Due: \(subscription.title)"
             content.body = "Your payment of $\(subscription.price, specifier: "%.2f") is due today."
             content.sound = UNNotificationSound.default
 
             // Calculate the trigger date (e.g., on the paymentDate at 9:00 AM)
             var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: subscription.paymentDate)
             dateComponents.hour = 9
             dateComponents.minute = 0
 
             let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
             
             // For recurring (e.g., monthly) subscriptions, you'd set `repeats: true`.
             // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) // This is more complex!
             // You'd need to schedule the *next* payment date, not the one just entered if it's in the past.
 
             let request = UNNotificationRequest(identifier: subscription.id.uuidString,
                                                 content: content,
                                                 trigger: trigger)
 
             UNUserNotificationCenter.current().add(request) { error in
                 if let error {
                     print("Error scheduling notification: \(error)")
                 }
             }
         }
 
         // Don't forget to remove/update notifications when a sub is deleted or edited!
         func removeNotification(for subscription: Subscription) {
             UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [subscription.id.uuidString])
         }
         ```

 3.  **Push Notifications vs. Local Notifications:**
     * What's described above are **Local Notifications**. They are scheduled
         by the app and run on the device. They do not require a server.
     * **Push Notifications** (APNs) are sent from your *server* to Apple,
         who then "pushes" them to the device. This is for server-side
         events (e.g., a new message) and *does* require the
         "Push Notifications" capability in Xcode and an Apple Developer Program membership.
     * For this app, **Local Notifications** are all you need.
 
 ============================================================================
*/

@main
struct LimeoApp: App {
    
    // 0 = System, 1 = Light, 2 = Dark
    @AppStorage("preferredTheme") private var preferredTheme: Int = 0

    // Create the SwiftData Model Container
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Subscription.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var currentTheme: ColorScheme? {
        switch preferredTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .preferredColorScheme(currentTheme)
            .tint(Color.accentGreen) // Set the global accent color
        }
        // Inject the ModelContainer into the environment
        .modelContainer(container)
    }
}
