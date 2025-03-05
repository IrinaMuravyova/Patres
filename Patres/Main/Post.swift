//
//  Post.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

struct Post: Decodable {
    let userPicture: String
    let title: String
    let text: String
    var liked: Bool
}
