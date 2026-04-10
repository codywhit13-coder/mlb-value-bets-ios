//
//  FontLoader.swift
//  MLBValueBets
//
//  Registers bundled .ttf files with Core Text at process start so SwiftUI's
//  `Font.custom(...)` calls resolve them by PostScript name. We deliberately
//  register at runtime via CTFontManagerRegisterFontsForURL instead of listing
//  the files under UIAppFonts in Info.plist — this keeps the font list in
//  Swift (visible + diffable) and keeps project.yml free of INFOPLIST_KEY
//  array entries that XcodeGen fights with.
//
//  Registration is idempotent: calling it more than once in a process is safe
//  (subsequent registrations return an "already registered" CFError which we
//  silently ignore). This matters because the unit-test bundle hosts the main
//  app via TEST_HOST — the app's `init()` may not fire before test rendering,
//  so `ViewSnapshotTests.setUp` also calls this.
//

import Foundation
import CoreText

enum FontLoader {

    /// The .ttf files we ship in MLBValueBets/Resources/Fonts/. Names here
    /// MUST match the filenames on disk (without extension).
    private static let fontFileNames: [String] = [
        "BebasNeue-Regular",
        "Barlow-Regular",
        "Barlow-Medium",
        "Barlow-SemiBold",
        "Barlow-Bold",
        "IBMPlexMono-Regular",
        "IBMPlexMono-Medium",
        "IBMPlexMono-Bold",
    ]

    /// Registers every bundled font with Core Text. Safe to call more than once.
    static func registerCustomFonts() {
        let bundle = Bundle(for: TokenBundleMarker.self)
        for name in fontFileNames {
            guard let url = bundle.url(forResource: name, withExtension: "ttf")
                ?? Bundle.main.url(forResource: name, withExtension: "ttf") else {
                #if DEBUG
                print("[FontLoader] Missing font file: \(name).ttf")
                #endif
                continue
            }
            var cfError: Unmanaged<CFError>?
            let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &cfError)
            if !ok, let err = cfError?.takeRetainedValue() {
                // Error code 105 == kCTFontManagerErrorAlreadyRegistered.
                // We call this function from both App.init and test setUp, so
                // double-registration is expected and harmless.
                let code = CFErrorGetCode(err)
                if code != 105 {
                    #if DEBUG
                    print("[FontLoader] Failed to register \(name): \(err)")
                    #endif
                }
            }
        }
    }
}

/// Empty marker class used solely to resolve `Bundle(for:)` at runtime.
/// `Bundle(for:)` picks the bundle containing the given class, which is the
/// main app bundle in production and still the main app bundle in tests
/// (because the test target hosts MLBValueBets via TEST_HOST).
private final class TokenBundleMarker {}
