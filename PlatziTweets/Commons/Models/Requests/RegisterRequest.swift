//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 25/02/21.
//

import Foundation

struct ResgisterRequest: Codable {
    let email: String
    let password: String
    let names: String
}
