//
//  PostListViewController.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit

class PostListViewController: UIViewController {
    private var posts: [Post] = []
    private var currentPage = 1
    private var isLoading = false
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    var presenter: PostListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        presenter.viewDidLoad()
    }

    @objc private func refreshData() {
        presenter.refreshData()
    }

    func displayPosts(_ posts: [Post]) {
        self.posts = posts
        // обновите tableView, чтобы отобразить данные
    }

    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    func showError(_ error: Error) {
        // обработка ошибки
    }
}
