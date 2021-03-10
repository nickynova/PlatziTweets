//
//  PostRequest.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 25/02/21.
//

import Foundation

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: PostRequestLocation?
}
