//
//  Service.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.12.2023.
//

import Foundation

struct RegisterError: Decodable {
    let error: String
}

class Service {
    
    init() {}
    
    func login(email: String, password: String) async throws -> User? {
        if let url = URLs.login {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "POST"
            
            var data: Data
            var response: URLResponse
            request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            do {
                (data, response) = try await URLSession.shared.data(for: request)
            } catch {
                return nil
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    return user
                } catch {
                    return nil
                }
            } else {
                var error: RegisterError
                do {
                    error = try JSONDecoder().decode(RegisterError.self, from: data)
                } catch {
                    return nil
                }
                throw APIError.error(message: error.error)
            }
        }
        
        return nil
    }
    
    func updateBio(email: String, bio: String) async -> Bool {
        if let url = URLs.updateBio(email: email) {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "PUT"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: ["bio": bio])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let (_, response) = try await URLSession.shared.data(for: request)
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Success")
                    return true
                }
                print(-1)
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        return false
    }
    
    func updateUsername(email: String, name: String) async -> Bool {
        if let url = URLs.updateUsername(email: email) {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "PUT"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: ["username": name])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let (_, response) = try await URLSession.shared.data(for: request)
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Success")
                    return true
                }
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        return false
    }
    
    func register(email: String, username: String, password: String) async throws -> Bool {
        if let url = URLs.register {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: ["username": username, "email": email, "password": password])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            var data: Data
            var response: URLResponse
            do {
                (data, response) = try await URLSession.shared.data(for: request)
            } catch {
                return false
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                return true
            } else {
                var error: RegisterError
                do {
                    error = try JSONDecoder().decode(RegisterError.self, from: data)
                } catch {
                    return false
                }
                throw APIError.error(message: error.error)
            }
        }
        
        return false
    }
}

enum APIError: Error {
    case error(message: String)
}
