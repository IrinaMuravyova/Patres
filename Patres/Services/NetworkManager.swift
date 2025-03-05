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
    
    private var posts: [Post] = []
    private var avatarCache: [Int: String] = [:]
    private let imageCache = NSCache<NSString, UIImage>()
    
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
                    let group = DispatchGroup()
                    
                    for post in postsData {
                        if let userId = post["userId"] as? Int,
                           let title = post["title"] as? String,
                           let text = post["body"] as? String {

                            group.enter()
                            self.fetchUserAvatar(userId: userId) { avatarUrl in
                                let post = Post(
                                    userPicture: avatarUrl,
                                    title: title,
                                    text: text,
                                    liked: false
                                )
                                self.posts.append(post)
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        completion(.success(self.posts))
                    }
                }
                
            } catch let error {
                completion(.failure(error))
            }
            
        }
    }
    
    private func fetchUserAvatar(userId: Int, completion: @escaping (String) -> Void) {
        if let cachedAvatar = avatarCache[userId] {
            completion(cachedAvatar)
            return
        }
        let photoId = 90 + userId
        let avatarUrl = "https://picsum.photos/id/\(photoId)/200"
        print("avatarUrl ", avatarUrl)
        avatarCache[userId] = avatarUrl
        completion(avatarUrl)
    }
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            completion(cachedImage)
            return
        }
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url as NSString)
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                completion(nil)
            }
        }
    }
}
