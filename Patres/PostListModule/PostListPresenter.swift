//
//  PostListPresenter.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import Foundation

class PostListPresenter: PostListPresenterProtocol {
    var view: PostListViewProtocol?
    var interactor: PostListInteractorProtocol?
    var router: PostListRouterProtocol?

    func viewDidLoad() {
        view?.showLoadingIndicator()
        interactor?.loadPosts(page: 1, limit: 10)
    }

    func refreshData() {
        interactor?.loadPosts(page: 1, limit: 10)
    }

    func didLoadPosts(_ posts: [Post]) {
        view?.hideLoadingIndicator()
        view?.displayPosts(posts)
        interactor?.savePostsToCoreData(posts: posts)
    }

    func didFailToLoadPosts(_ error: Error) {
        view?.hideLoadingIndicator()
        view?.showError(error)
    }
}
