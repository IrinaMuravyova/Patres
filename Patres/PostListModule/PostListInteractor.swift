//
//  PostListInteractor.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit

protocol PostListInteractorProtocol: AnyObject {
    func loadPosts(page: Int, limit: Int)
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

class PostListInteractor {
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    private var allPosts: [Post] = []
    
    var presenter: PostListInteractorOutputProtocol?

    private func preloadImages(for posts: [Post]) {
        for post in posts {
            networkManager.loadImage(from: post.userPicture) { _ in
            }
        }
    }
}

// MARK: - PostListInteractorProtocol
extension PostListInteractor: PostListInteractorProtocol {
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
        if let index = allPosts.firstIndex(where: { $0.id == post.id }) {
            allPosts[index].isLiked.toggle()
            presenter?.didUpdatePost(allPosts[index])
        }
    }
}
