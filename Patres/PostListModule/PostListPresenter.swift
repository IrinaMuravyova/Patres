//
//  PostListPresenter.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit
import Combine

protocol PostListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refreshData()
    func loadNextPage()
    func loadImage(for: Post)
    func toggleLike(for: Post)
}

class PostListPresenter {
    private var currentPage = 1
    private let postsPerPage = 10
    private var cancellables = Set<AnyCancellable>()
    
    var view: PostListViewProtocol?
    var cell: PostTableViewCell?
    var interactor: PostListInteractorProtocol?

    private func loadPosts(page: Int) {
        interactor?.loadPosts(page: page, limit: postsPerPage)
    }
}

// MARK: - PostListPresenterProtocol
extension PostListPresenter: PostListPresenterProtocol {
    func viewDidLoad() {
        view?.showLoadingIndicator()
    
        NetworkMonitor.shared.isConnectedPublisher
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.loadPosts(page: self?.currentPage ?? 1)
                } else {
                    let posts = CoreDataManager.shared.getPosts()
                    self?.view?.displayPosts(posts)
                }
                self?.view?.hideLoadingIndicator()
            }
            .store(in: &cancellables)
    }
    
    func refreshData() {
        interactor?.clearPosts()
        currentPage = 1
        loadPosts(page: currentPage)
    }
    
    func loadNextPage() {
        currentPage += 1
        loadPosts(page: currentPage)
    }
    
    func loadImage(for post: Post) {
        interactor?.fetchImage(for: post)
    }
    
    func toggleLike(for post: Post) {
        interactor?.toggleLike(for: post)
    }
}

// MARK: - PostListInteractorOutputProtocol
extension PostListPresenter: PostListInteractorOutputProtocol {
    func didLoadPosts(_ posts: [Post]) {
        view?.hideLoadingIndicator()
        view?.displayPosts(posts)
        interactor?.savePostsToCoreData(posts: posts)
    }

    func didFailToLoadPosts(_ error: Error) {
        view?.hideLoadingIndicator()
        view?.showError(error)
    }
    
    func didLoadImage(_ image: UIImage) {
        cell?.updateImage(image)
    }
    
    func didUpdatePost(_ post: Post) {
        view?.updatePost(post)
    }
}
