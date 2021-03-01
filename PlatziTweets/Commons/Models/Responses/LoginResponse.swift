//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 25/02/21.
//

import Foundation


struct LoginResponse: Codable {
    let user: User
    let token: String
}
