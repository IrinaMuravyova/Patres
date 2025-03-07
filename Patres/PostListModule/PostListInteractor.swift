//
//  PostListInteractor.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit

protocol PostListInteractorProtocol: AnyObject {
    func loadPosts(page: Int, limit: Int)
    func loadPostsFromCoreData()
    func savePostsToCoreData(posts: [Post])
    func clearPosts()
    func fetchImage(for post: Post)
    func toggleLike(for: Post)
}

protocol PostListInteractorOutputProtocol: AnyObject {
    func didLoadPosts(_ posts: [Post])
    func didFailToLoadPosts(_ error : Error)
    func didLoadImage(_ image: UIImage)
    func didUpdatePost(_ post: Post)
}
class PostListInteractor: PostListInteractorProtocol {
    var presenter: PostListInteractorOutputProtocol?
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    private var allPosts: [Post] = []

    func loadPosts(page: Int, limit: Int) {
        networkManager.fetch(page: page, limit: limit) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.preloadImages(for: posts)
                self?.allPosts.append(contentsOf: posts)
                self?.savePostsToCoreData(posts: posts)
                self?.presenter?.didLoadPosts(self?.allPosts ?? [])
            case .failure(let error):
                self?.presenter?.didFailToLoadPosts(error)
            }
        }
    }

    private func preloadImages(for posts: [Post]) {
        for post in posts {
            networkManager.loadImage(from: post.userPicture) { _ in
            }
        }
    }
    
    func loadPostsFromCoreData() {
        let posts = coreDataManager.getPosts()
        
        for post in posts {
            if let imageEntity = coreDataManager.fetchPostEntity(for: post.id),
               let imageData = imageEntity.imageData,
               let image = UIImage(data: imageData) {
                presenter?.didLoadImage(image)
            }
        }
        
        presenter?.didLoadPosts(posts)
    }

    func savePostsToCoreData(posts: [Post]) {
        coreDataManager.update(posts: posts, context: coreDataManager.mainContext)
        
        for post in posts {
            networkManager.loadImage(from: post.userPicture) { [weak self] image in
                guard let self = self, let image = image else { return }
                self.coreDataManager.saveImage(image, for: post)
            }
        }
    }
    
    func clearPosts() {
        allPosts.removeAll()
        coreDataManager.deletePosts()
    }
    
    func fetchImage(for post: Post) {
        if let postEntity = coreDataManager.fetchPostEntity(for: post.id), let imageData = postEntity.imageData {
            guard  let image = UIImage(data: imageData) else { return }
                presenter?.didLoadImage(image)
        } else {
            NetworkManager.shared.loadImage(from: post.userPicture) { [weak self] image in
                if let image = image {
                    self?.coreDataManager.saveImage(image, for: post)
                    self?.presenter?.didLoadImage(image)
                }
            }
        }
    }
    
    func toggleLike(for post: Post) {
        coreDataManager.toggleLike(for: post.id)
        var updatedPost = post
        updatedPost.isLiked.toggle()
        presenter?.didUpdatePost(updatedPost)
    }
}
