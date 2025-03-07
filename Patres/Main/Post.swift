//
//  Post.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

struct Post: Decodable {
    let id: String
    let userPicture: String
    let title: String
    let text: String
    var isLiked: Bool
    
    init(id: String, userPicture: String, title: String, text: String, isLiked: Bool) {
        self.id = id
        self.userPicture = userPicture
        self.title = title
        self.text = text
        self.isLiked = isLiked
    }
        
    init?(from postEntity: PostEntity) {
        guard let id = postEntity.id,
              let userPicture = postEntity.userPicture,
              let title = postEntity.title,
              let text = postEntity.text else { return nil }
        
        self.id = id
        self.userPicture = userPicture
        self.title = title
        self.text = text
        self.isLiked = postEntity.isLiked
    }
}
