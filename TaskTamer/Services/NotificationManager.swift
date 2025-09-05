//
//  NotificationManager.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 9/4/25.
//

import Foundation
import UserNotifications
import SwiftUI
import UIKit

/// A simple manager for daily local notifications with enable/disable and configurable time.
@MainActor
final class NotificationManager: ObservableObject {

    // MARK: - Public API

    /// Toggle to enable/disable the daily reminder. Setting this will schedule or cancel notifications.
    @Published var isEnabled: Bool {
        didSet { Task { await handleToggleChange() } }
    }

    /// The local time (hour/minute) for the daily reminder.
    @Published var reminderTime: Date {
        didSet { Task { await handleTimeChange() } }
    }

    @Published var triedToEnableButNoPermission: Bool = false

    /// The current notification authorization state.
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Opens the app's system settings (e.g., if user enables reminders but permission is denied).
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// Call from App/Scene lifecycle (e.g., onAppear of root view or on foreground)
    /// to keep `authorizationStatus` in sync with system settings.
    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await updateAuthorizationStatus(settings.authorizationStatus)
    }

    // MARK: - Init / Storage

    private let center = UNUserNotificationCenter.current()
    private let reminderId = "daily-reminder-notification-id"

    private enum Keys {
        static let isEnabled = "NotificationManager.isEnabled"
        static let reminderTime = "NotificationManager.reminderTime" // stored as TimeInterval since reference date
    }

    init(defaultTime: Date = NotificationManager.default9am()) {
        // Load persisted values
        let storedEnabled = UserDefaults.standard.object(forKey: Keys.isEnabled) as? Bool ?? false
        let storedTimeInterval = UserDefaults.standard.object(forKey: Keys.reminderTime) as? TimeInterval

        self.isEnabled = storedEnabled
        self.reminderTime = storedTimeInterval.map { Date(timeIntervalSinceReferenceDate: $0) } ?? defaultTime

        Task {
            await refreshAuthorizationStatus()
            // Ensure scheduled state matches what we have saved
            if isEnabled {
                await ensureScheduled()
            } else {
                await cancelScheduled()
            }
        }
    }

    // MARK: - Internal Handlers

    private func handleToggleChange() async {
        persistState()
        if isEnabled {
            // If enabling, ensure permission and schedule
            let ok = await ensureAuthorization()
            if ok {
                await ensureScheduled()
            } else {
                // Authorization not granted; flip back off to reflect reality.
                self.isEnabled = false
                triedToEnableButNoPermission = true
                persistState()
            }
        } else {
            // If disabling, cancel any scheduled notifications
            await cancelScheduled()
        }
    }

    private func handleTimeChange() async {
        persistState()
        guard isEnabled else { return }
        // Re-schedule at the new time
        await ensureScheduled()
    }

    // MARK: - Authorization

    /// Requests authorization if needed; returns true if authorized to alert.
    private func ensureAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        await updateAuthorizationStatus(settings.authorizationStatus)

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            let granted = await requestAuthorization()
            if granted {
                let newSettings = await center.notificationSettings()
                await updateAuthorizationStatus(newSettings.authorizationStatus)
            }
            return granted
        @unknown default:
            return false
        }
    }

    private func requestAuthorization() async -> Bool {
        do {
            // Request alert, sound, and badge for a typical reminder.
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            // If request throws (rare), treat as not granted.
            return false
        }
    }

    private func updateAuthorizationStatus(_ status: UNAuthorizationStatus) async {
        self.authorizationStatus = status
    }

    // MARK: - Scheduling

    private func ensureScheduled() async {
        // Remove any previous instance to avoid duplicates, then schedule fresh.
        await cancelScheduled()

        let content = UNMutableNotificationContent()
        content.title = "Let's tame some tasks!"
        content.body = "What tasks should you tackle (or ignore) today?"
        content.sound = .default
        // You can customize a categoryIdentifier here if you plan actions.

        // Build daily repeating trigger at the local hour/minute from reminderTime.
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            // If scheduling fails, reflect that reminders aren't effectively enabled.
            self.isEnabled = false
            persistState()
        }
    }

    private func cancelScheduled() async {
        center.removePendingNotificationRequests(withIdentifiers: [reminderId])
        center.removeDeliveredNotifications(withIdentifiers: [reminderId])
    }

    // MARK: - Persistence

    private func persistState() {
        UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled)
        UserDefaults.standard.set(reminderTime.timeIntervalSinceReferenceDate, forKey: Keys.reminderTime)
    }

    // MARK: - Helpers

    nonisolated private static func default9am() -> Date {
        var comps = DateComponents()
        comps.hour = 9
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
}
