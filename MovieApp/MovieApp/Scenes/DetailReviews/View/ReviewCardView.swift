//
//  ReviewCardView.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//

import UIKit

class ReviewCardView: UIView {
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 18
        return iv
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .label
        label.numberOfLines = 4
        return label
    }()
    
    private var imageTask: URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = AppColor.secondaryBg
        layer.cornerRadius = 12
        
        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, makeAuthorStack()])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, contentLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func makeAuthorStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [authorLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }
    
    func configure(with review: Review) {
        authorLabel.text = review.author?.isEmpty == false ? review.author : (review.authorDetails?.username ?? "Anonymous")
        
        if let rating = review.authorDetails?.rating {
            ratingLabel.text = String(format: "⭐ %.1f", rating)
        } else {
            ratingLabel.text = nil
        }
        
        contentLabel.text = review.content?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        avatarImageView.image = nil
        imageTask?.cancel()
        guard let url = review.authorDetails?.avatarURL else { return }
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.avatarImageView.image = image }
        }
        imageTask?.resume()
    }
}
