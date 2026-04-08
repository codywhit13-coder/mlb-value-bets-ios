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
            Color.brandBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 48)

                    // Logo + title
                    VStack(spacing: 12) {
                        Image(systemName: "baseball.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.brandAmber)

                        Text("MLB Value Bets")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.brandTextPrimary)

                        Text("Expert analysts. Real value.")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                    .padding(.bottom, 12)

                    // Form
                    VStack(spacing: 16) {
                        field(title: "Email",
                              text: $vm.email,
                              placeholder: "you@example.com",
                              keyboard: .emailAddress,
                              contentType: .emailAddress)

                        secureField(title: "Password",
                                    text: $vm.password,
                                    contentType: isSignUpMode ? .newPassword : .password)

                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(Color.lossRed)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                                        .tint(.black)
                                } else {
                                    Text(isSignUpMode ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.brandAmber)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(vm.isWorking)

                        if !isSignUpMode {
                            Button("Forgot password?") {
                                Task { await vm.sendPasswordReset() }
                            }
                            .font(.footnote)
                            .foregroundStyle(Color.brandTextSecondary)
                        }

                        Button {
                            isSignUpMode.toggle()
                            vm.errorMessage = nil
                        } label: {
                            Text(isSignUpMode
                                 ? "Already have an account? Sign in"
                                 : "No account yet? Create one — it's free")
                                .font(.footnote)
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
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
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.brandTextSecondary)
            TextField(placeholder, text: text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(12)
                .background(Color.brandSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.brandTextPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brandBorder, lineWidth: 1)
                )
        }
    }

    private func secureField(title: String,
                             text: Binding<String>,
                             contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.brandTextSecondary)
            SecureField("••••••••", text: text)
                .textContentType(contentType)
                .padding(12)
                .background(Color.brandSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.brandTextPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brandBorder, lineWidth: 1)
                )
        }
    }
}
