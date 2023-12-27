//
//  ProfileView.swift
//  Chessy
//
//  Created by yasha on 01.12.2023.
//

import SwiftUI

struct ProfileView: View {
    
    private var userDefaults: UserDefaults {
        if let userDefaults = UserDefaults(suiteName: "group.com.yasha424.ChessyChess") {
            return userDefaults
        }
        return UserDefaults()
    }
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var user: User? = nil
    private let loginService = Service()
    @State private var buttonText = "Edit"
    @State private var bio = ""
    @State private var isRegistering = false
    @State private var username = ""
    @State private var passwordConfirm = ""
    @State private var errorMessage = ""
    @EnvironmentObject private var userObject: UserObject
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            if let user = user {
                HStack {
                    Spacer()
                    Button(buttonText) {
                        if buttonText == "Edit" {
                            withAnimation(.spring) {
                                buttonText = "Done"
                            }
                        } else {
                            withAnimation(.spring) {
                                buttonText = "Edit"
                            }
                            Task {
                                if self.user?.username != username {
                                    await loginService.updateUsername(email: user.email, name: username)
                                    userObject.user?.username = username
                                }
                                if self.user?.bio != bio {
                                    await loginService.updateBio(email: user.email, bio: bio)
                                    userObject.user?.bio = bio
                                }
                            }
                        }
                    }
                    .padding()
                }
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(16)
                VStack(spacing: 16) {
                    TextField(user.username, text: $username)
                        .disabled(buttonText == "Edit")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .glassView()
                    TextField("Bio", text: $bio)
                        .disabled(buttonText == "Edit")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: buttonText == "Edit" ? 40 : 120)
                        .padding()
                        .glassView()
                }
                Spacer()
                Button {
                    self.user = nil
                    email = ""
                    password = ""
                    userDefaults.setValue(email, forKey: "email")
                    userDefaults.setValue(password, forKey: "password")
                    userObject.user = nil
                    errorMessage.setWithAnimation("")
                } label: {
                    Text("Logout")
                        .padding()
                        .glassView()
                }
                .glassView()
                .padding(16)
            } else {
                Spacer()
                VStack(spacing: 16) {
                    if errorMessage != "" {
                        Text(errorMessage)
                            .opacity(errorMessage == "" ? 0 : 1)
                            .frame(height: 40)
                            .padding(.horizontal)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    TextField(isRegistering ? "Username" : "Email", text: isRegistering ? $username : $email)
                        .padding()
                        .glassView()
                    TextField(isRegistering ? "Email" : "Password", text: isRegistering ? $email : $password)
                        .padding()
                        .glassView()
                    if isRegistering {
                        SecureField("Password", text: $password)
                            .padding()
                            .glassView()
                        SecureField("Confirm Password", text: $passwordConfirm)
                            .padding()
                            .glassView()
                    }
                }
                .padding()
                .glassView()
                .padding(.vertical)
                Spacer()

                Button(isRegistering ? "Login" : "Register") {
                    withAnimation(.spring) {
                        isRegistering = !isRegistering
                    }
                }
                .padding()

                Button {
                    Task {
                        if !isRegistering {
                            do {
                                user = try await loginService.login(email: email, password: password)
                                bio = user?.bio ?? ""
                                userDefaults.setValue(password, forKey: "password")
                                userDefaults.setValue(email, forKey: "email")
                                userObject.user = user
                                errorMessage.setWithAnimation("")
                            } catch APIError.error(let message) {
                                errorMessage.setWithAnimation(message)
                            }
                        } else {
                            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                            
                            if username.count < 4 {
                                errorMessage.setWithAnimation("Username must be 4 characters or longer")
                            } else if !emailPred.evaluate(with: email) {
                                errorMessage.setWithAnimation("Invalid email")
                            } else if password.count < 8 {
                                errorMessage.setWithAnimation("Password must be longer than 8 characters")
                            } else if password.first(where: { "A"..."Z" ~= $0 }) == nil {
                                errorMessage.setWithAnimation("Password must contain at least one uppercase letter")
                            } else if password.first(where: { "0"..."9" ~= $0 }) == nil {
                                errorMessage.setWithAnimation("Password must contain at least one digit")
                            } else if password != passwordConfirm {
                                errorMessage.setWithAnimation("Password didn't match")
                            } else {
                                errorMessage.setWithAnimation("")
                                do {
                                    let success = try await loginService.register(email: email, username: username, password: password)
                                    if success {
                                        isRegistering = false
                                        do {
                                            user = try await loginService.login(email: email, password: password)
                                            bio = user?.bio ?? ""
                                            userDefaults.setValue(password, forKey: "password")
                                            userDefaults.setValue(email, forKey: "email")
                                            userObject.user = user
                                            errorMessage.setWithAnimation("")
                                        } catch APIError.error(let message) {
                                            errorMessage.setWithAnimation(message)
                                        }
                                    } else {
                                        errorMessage.setWithAnimation("Something went wrong")
                                    }
                                } catch APIError.error(let message) {
                                    errorMessage.setWithAnimation(message)
                                }
                            }
                        }
                    }
                } label: {
                    Text(isRegistering ? "Register" : "Login")
                        .padding()
                        .glassView()
                }
                .task {
                    email = userDefaults.string(forKey: "email") ?? ""
                    password = userDefaults.string(forKey: "password") ?? ""
                    if email != "", password != "" {
                        do {
                            user = try await loginService.login(email: email, password: password)
                            bio = user?.bio ?? ""
                            userObject.user = user
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .onTapGesture { UIApplication.shared.endEditing() }
        .padding()
        .customBackground()
    }
}

extension String {
    mutating func setWithAnimation(_ newValue: String) {
        withAnimation(.spring) {
            self = newValue
        }
    }
}
