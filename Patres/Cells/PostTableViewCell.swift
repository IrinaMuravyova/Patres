//
//  PostTableViewCell.swift
//  Patres
//
//  Created by Irina Muravyeva on 05.03.2025.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    
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
    
    private let likedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var currentImageUrl: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let subStackView = UIStackView(arrangedSubviews: [userPicture, titleLabel])
        subStackView.axis = .horizontal
        subStackView.spacing = 10
        subStackView.alignment = .center
        subStackView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [subStackView, textLabelCustom, likedIcon])
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userPicture.image = UIImage(systemName: "person") 
        currentImageUrl = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        userPicture.layer.cornerRadius = userPicture.frame.height / 2
        userPicture.clipsToBounds = true
    }
    
    func configure(with post: Post) {
        titleLabel.text = post.title
        textLabelCustom.text = post.text
        currentImageUrl = post.userPicture

        NetworkManager.shared.loadImage(from: post.userPicture) { [weak self] image in
            guard let self = self, self.currentImageUrl == post.userPicture else { return }
            DispatchQueue.main.async {
                self.userPicture.image = image
            }
        }
    }
}

