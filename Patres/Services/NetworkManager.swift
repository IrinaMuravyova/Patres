//
//  NetworkManager.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetch(completion: @escaping(Result<[Post], Error>) -> ()) {
        let url = "https://jsonplaceholder.typicode.com/posts/"
        AF.request(url).validate().response { response in
            guard let data = response.data else {
                if let error = response.error {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                var posts: [Post] = []
                if let postsData = try JSONSerialization.jsonObject(with: data, options:[]) as? [[String: Any]] {
                    for post in postsData {
                        if let title = post["title"] as? String,
                           let text = post["body"] as? String {
                            posts.append(Post(
                                userPicture: "person",
                                title: title,
                                text: text,
                                liked: false))
                        }
                    }
                    completion(.success(posts))
                }
                
            } catch let error {
                completion(.failure(error))
            }
            
        }
    }
    
}
