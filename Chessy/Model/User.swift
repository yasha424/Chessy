//
//  User.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.12.2023.
//

import Foundation

class UserObject: ObservableObject {
    @Published var user: User?
    
    init(user: User? = nil) {
        self.user = user
    }
}

struct User: Codable {
    var username: String
    var email: String
    var rating: Int
    var bio: String?
}
