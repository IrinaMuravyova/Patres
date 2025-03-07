//
//  PostTableViewCell.swift
//  Patres
//
//  Created by Irina Muravyeva on 05.03.2025.
//

import UIKit

protocol PostTableViewCellProtocol: AnyObject {
    func updateImage(_ image: UIImage)
}

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    private var post: Post?
    var presenter: PostListPresenterProtocol!
    
    private let userPicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textLabelCustom: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let likedIcon: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "heart")
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        return button
    }()
    
    private var currentImageUrl: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let subStackView = UIStackView(arrangedSubviews: [userPicture, titleLabel])
        subStackView.axis = .horizontal
        subStackView.spacing = 10
        subStackView.alignment = .center
        subStackView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [subStackView, textLabelCustom, likeButton])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            userPicture.widthAnchor.constraint(equalToConstant: 30),
            userPicture.heightAnchor.constraint(equalToConstant: 30),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userPicture.image = UIImage(systemName: "person")
        userPicture.layer.cornerRadius = 0
        currentImageUrl = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        userPicture.layer.cornerRadius = userPicture.frame.height / 2
        userPicture.clipsToBounds = true
    }
    
    @objc private func likeButtonTapped() {
        guard let post = post else { return }
        presenter?.toggleLike(for: post)
    }
    
    func configure(with post: Post, image: UIImage?) {
        self.post = post
        titleLabel.text = post.title
        textLabelCustom.text = post.text
        currentImageUrl = post.userPicture
        
        presenter?.loadImage(for: post)
        
        userPicture.image = image
        userPicture.layer.cornerRadius = self.userPicture.frame.height / 2
        
        likeButton.setImage(UIImage(systemName: post.isLiked ? "heart.fill" : "heart"), for: .normal)
    }
}

extension PostTableViewCell: PostTableViewCellProtocol {
    func updateImage(_ image: UIImage) {
        self.imageView?.image = image
    }
}
