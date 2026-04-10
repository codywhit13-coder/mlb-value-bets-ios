//
//  HapticService.swift
//  MLBValueBets
//
//  Thin wrapper around UIKit feedback generators. Centralizes haptic
//  patterns so the whole app vibrates consistently.
//
//  Usage:
//      HapticService.light()    // filter chip tap, nav link
//      HapticService.medium()   // share button
//      HapticService.success()  // sign-in success
//      HapticService.error()    // sign-in failure
//      HapticService.selection()  // already used by filter chips
//

import UIKit

enum HapticService {

    // MARK: - Impact

    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    // MARK: - Notification

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // MARK: - Selection

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
