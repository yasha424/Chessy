//
//  URLs.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.12.2023.
//

import Foundation

struct URLs {
    static var baseUrl: String {
        return ProcessInfo.processInfo.environment["baseUrl"] ?? "http://localhost:3000/"
    }
    static var login: URL? {
        return URL(string: "\(URLs.baseUrl)api/login")
    }
    static var register: URL? {
        return URL(string: "\(URLs.baseUrl)api/register")
    }
    static var getPuzzles: URL? {
        return URL(string: "\(URLs.baseUrl)api/puzzles")
    }
    static var savePuzzle: URL? {
        return URL(string: "\(URLs.baseUrl)api/save-puzzle")
    }

    static func updateBio(email: String) -> URL? {
        return URL(string: "\(URLs.baseUrl)api/users/\(email)/bio")
    }
    
    static func updateUsername(email: String) -> URL? {
        return URL(string: "\(URLs.baseUrl)api/users/\(email)/username")
    }
}
