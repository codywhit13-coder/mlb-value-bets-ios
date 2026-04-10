//
//  LoginView.swift
//  MLBValueBets
//
//  Email/password sign-in screen.
//  NOTE: App Store Reader App pattern — no pricing or upgrade UI.
//  Users can sign up for a free account inside the app since the account itself is free.
//

import SwiftUI

struct LoginView: View {
    @Bindable var vm: AuthViewModel
    @State private var isSignUpMode: Bool = false

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    Spacer(minLength: Theme.Spacing.xxxl)

                    // Hero
                    VStack(spacing: Theme.Spacing.md) {
                        // Diamond glyph instead of system baseball — feels
                        // more like a fintech mark and matches the web's
                        // diamond accent on PIN ✓ chips.
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.brandSurface)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.brandBlue.opacity(0.40), lineWidth: 1)
                                )
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.brandBlue)
                        }
                        .shadow(color: Color.brandBlue.opacity(0.30), radius: 24, x: 0, y: 0)

                        Text("MLB VALUE BETS")
                            .font(Theme.Font.display(34))
                            .tracking(2)
                            .foregroundStyle(Color.brandTextPrimary)

                        Text("MODEL-BACKED PICKS  ·  REAL EDGE")
                            .font(Theme.Font.overline(10))
                            .tracking(2)
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                    .padding(.bottom, Theme.Spacing.md)

                    // Form
                    VStack(spacing: Theme.Spacing.lg) {
                        field(
                            title: "EMAIL",
                            text: $vm.email,
                            placeholder: "you@example.com",
                            keyboard: .emailAddress,
                            contentType: .emailAddress
                        )

                        secureField(
                            title: "PASSWORD",
                            text: $vm.password,
                            contentType: isSignUpMode ? .newPassword : .password
                        )

                        if let error = vm.errorMessage {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11, weight: .bold))
                                Text(error)
                                    .font(Theme.Font.body(12))
                            }
                            .foregroundStyle(Color.lossRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(Color.lossRed.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                        }

                        Button {
                            Task {
                                if isSignUpMode {
                                    await vm.signUp()
                                } else {
                                    await vm.signIn()
                                }
                            }
                        } label: {
                            HStack {
                                if vm.isWorking {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUpMode ? "CREATE ACCOUNT" : "SIGN IN")
                                        .font(Theme.Font.heading(14, weight: .bold))
                                        .tracking(2)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color.brandBlue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                            .shadow(color: Color.brandBlue.opacity(0.40), radius: 18, x: 0, y: 0)
                        }
                        .disabled(vm.isWorking)

                        if !isSignUpMode {
                            Button("Forgot password?") {
                                Task { await vm.sendPasswordReset() }
                            }
                            .font(Theme.Font.body(12))
                            .foregroundStyle(Color.brandTextSecondary)
                        }

                        Button {
                            isSignUpMode.toggle()
                            vm.errorMessage = nil
                        } label: {
                            Text(isSignUpMode
                                 ? "Already have an account? Sign in"
                                 : "No account yet? Create one — it's free")
                                .font(Theme.Font.body(12))
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                        .padding(.top, Theme.Spacing.xs)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)

                    Spacer(minLength: Theme.Spacing.xl)
                }
            }
        }
    }

    // MARK: - Field helpers

    private func field(title: String,
                       text: Binding<String>,
                       placeholder: String,
                       keyboard: UIKeyboardType,
                       contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Font.overline(10))
                .tracking(1.5)
                .foregroundStyle(Color.brandBlue)
            TextField(placeholder, text: text)
                .font(Theme.Font.body(15))
                .textContentType(contentType)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(Theme.Spacing.md)
                .background(Color.brandSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                .foregroundStyle(Color.brandTextPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .stroke(Color.brandBorder, lineWidth: 1)
                )
        }
    }

    private func secureField(title: String,
                             text: Binding<String>,
                             contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Font.overline(10))
                .tracking(1.5)
                .foregroundStyle(Color.brandBlue)
            SecureField("••••••••", text: text)
                .font(Theme.Font.body(15))
                .textContentType(contentType)
                .padding(Theme.Spacing.md)
                .background(Color.brandSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                .foregroundStyle(Color.brandTextPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .stroke(Color.brandBorder, lineWidth: 1)
                )
        }
    }
}
