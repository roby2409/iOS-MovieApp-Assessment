//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    static let reuseId = "MovieCell"
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title ?? "-"
        if let vote = movie.voteAverage {
            ratingLabel.text = String(format: "⭐ %.1f", vote)
        } else {
            ratingLabel.text = "-"
        }
        
        posterImageView.image = nil
        imageTask?.cancel()
        
        guard let url = TMDBImage.url(path: movie.posterPath) else { return }
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.posterImageView.image = image
            }
        }
        imageTask?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        posterImageView.image = nil
    }
}
