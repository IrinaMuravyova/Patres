//
//  ViewController.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private var posts: [Post] = []
    private var currentPage = 1
    private let postsPerPage = 10
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        loadPosts(page: currentPage)
    }
    
    private func loadPosts(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        NetworkManager.shared.fetch(page: page, limit: postsPerPage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let fetchedPosts):
                    self?.preloadImages(for: fetchedPosts)
                    self?.posts.append(contentsOf: fetchedPosts)
                    self?.tableView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    print(error)
                }
                self?.isLoading = false
            }
        }
    }
    
    private func preloadImages(for posts: [Post]) {
        for post in posts {
            NetworkManager.shared.loadImage(from: post.userPicture) { _ in
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 && !isLoading {
            loadPosts(page: currentPage)
        }
    }
}

// MARK: - UISettings
extension ViewController {
    func setupUI() {
        setupTableView()
    }
}

// MARK: - TableViewDelegate, TableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        
        if let cachedImage = NetworkManager.shared.imageCache.object(forKey: post.userPicture as NSString) {
            cell.configure(with: post, image: cachedImage)
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
