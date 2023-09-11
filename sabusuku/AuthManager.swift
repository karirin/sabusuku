//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase

extension AuthManager {
    var currentUserId: String? {
        return user?.uid
    }
}

class AuthManager: ObservableObject {
    @Published var user: User?

    static var shared: AuthManager!

    var onLoginCompleted: (() -> Void)?

       init() {
           user = Auth.auth().currentUser
           if user == nil {
               anonymousSignIn()
           }
       }

       func anonymousSignIn() {
           Auth.auth().signInAnonymously { result, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
               } else if let result = result {
                   print("Signed in anonymously with user ID: \(result.user.uid)")
                   self.user = result.user
                   self.onLoginCompleted?()
               }
           }
       }
   }

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn()
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}

