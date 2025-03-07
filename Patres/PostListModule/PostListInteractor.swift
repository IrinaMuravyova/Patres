//
//  PostListInteractor.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import Foundation

class PostListInteractor: PostListInteractorProtocol {
    var presenter: PostListInteractorOutputProtocol?
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared

    func loadPosts(page: Int, limit: Int) {
        networkManager.fetch(page: page, limit: limit) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.presenter?.didLoadPosts(posts)
            case .failure(let error):
                self?.presenter?.didFailToLoadPosts(error)
            }
        }
    }

    func loadPostsFromCoreData() {
        let posts = coreDataManager.getPosts()
        presenter?.didLoadPosts(posts)
    }

    func savePostsToCoreData(posts: [Post]) {
        coreDataManager.update(posts: posts, context: coreDataManager.mainContext)
    }
}
