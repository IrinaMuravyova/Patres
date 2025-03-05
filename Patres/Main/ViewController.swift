//
//  ViewController.swift
//  Patres
//
//  Created by Irina Muravyeva on 04.03.2025.
//

import UIKit

class ViewController: UIViewController {
    let tableView = UITableView()
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        NetworkManager.shared.fetch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let fetchedPosts):
                    self?.posts = fetchedPosts
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func setup(_ cell: UITableViewCell, with post: Post) {
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let userPicture: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        NSLayoutConstraint.activate([
            userPicture.widthAnchor.constraint(equalToConstant: 30),
            userPicture.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let title: UILabel = {
            let label = UILabel()
            label.text = post.title
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            label.contentMode = .scaleAspectFit
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let text: UILabel = {
            let label = UILabel()
            label.contentMode = .scaleAspectFit
            label.numberOfLines = 0
            label.text = post.text
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let liked: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "heart")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true
            return imageView
        }()
        
        let subStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 10
            stack.alignment = .center
            stack.distribution = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        subStackView.addArrangedSubview(userPicture)
        subStackView.addArrangedSubview(title)
        
        let stackView = UIStackView(arrangedSubviews: [subStackView, text, liked])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant:  -10),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let post = posts[indexPath.row]
        setup(cell, with: post)
        return cell
    }
}
