//
//  NetworkManager.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

import UIKit
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetch(page: Int, limit: Int, completion: @escaping(Result<[Post], Error>) -> ()) {
        
        let url = "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=\(limit)"
        AF.request(url).validate().response { response in
            guard let data = response.data else {
                if let error = response.error {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                if let postsData = try JSONSerialization.jsonObject(with: data, options:[]) as? [[String: Any]] {
                    var fetchedPosts: [Post] = []
                    
                    let group = DispatchGroup()
                    
                    for post in postsData {
                        if let userId = post["userId"] as? Int,
                           let id = post["id"] as? Int,
                           let title = post["title"] as? String,
                           let text = post["body"] as? String {

                            group.enter()
                            self.fetchUserAvatar(userId: userId) { avatarUrl in
                                let post = Post(
                                    id: String(id),
                                    userPicture: avatarUrl,
                                    title: title,
                                    text: text,
                                    isLiked: false
                                )
                                fetchedPosts.append(post)
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        completion(.success(fetchedPosts))
                    }
                }
                
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    private func fetchUserAvatar(userId: Int, completion: @escaping (String) -> Void) {
        let photoId = 90 + userId
        let avatarUrl = "https://picsum.photos/id/\(photoId)/200"
        completion(avatarUrl)
    }
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) { 
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("Load image error: \(error)")
                completion(nil)
            }
        }
    }
}
