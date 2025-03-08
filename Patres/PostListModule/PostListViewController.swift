//
//  PostListViewController.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit

protocol PostListViewProtocol: AnyObject {
    func displayPosts(_ posts: [Post])
    func showLoadingIndicator()
    func hideLoadingIndicator() 
    func showError(_ error: Error)
    func updatePost(_ post: Post)
}

class PostListViewController: UIViewController {
    private let tableView = UITableView()
    private var posts: [Post] = []
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    var presenter: PostListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let presenter = presenter else {
            fatalError("Presenter is not initialized")
        }
        
        setupUI() 
        presenter.viewDidLoad()
    }

    @objc private func didPullToRefresh() {
        presenter.refreshData()
        refreshControl.endRefreshing()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        setupTableView()
        setupLoadingIndicator()
    }

    func setupTableView() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        guard posts.count > indexPath.row else {
                return UITableViewCell()
            }
        
        let post = posts[indexPath.row]
        cell.presenter = presenter
        
        if let postEntity = CoreDataManager.shared.fetchPostEntity(for: post.id),
           let imageData = postEntity.imageData,
           let storedImage = UIImage(data: imageData) {
            cell.configure(with: post, image: storedImage)
        } else {
            cell.configure(with: post, image: nil)
            NetworkManager.shared.loadImage(from: post.userPicture) { image in
                DispatchQueue.main.async {
                    if let updatedCell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                        updatedCell.configure(with: post, image: image)
                    }
                }
            }
        }
        
        return cell
    }
}

extension PostListViewController: PostListViewProtocol {
    func displayPosts(_ posts: [Post]) {
        self.posts = posts
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    func showError(_ error: Error) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }

        let alert = UIAlertController(title: "Error",
                                      message: "An error has occurred. Please restart the application.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        
        alert.addAction(okAction)

        DispatchQueue.main.async {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func updatePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension PostListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        let tableViewHeight = scrollView.frame.size.height

        if contentHeight - scrollOffset <= tableViewHeight {
            presenter?.loadNextPage()
        }
    }
}
