//
//  DetailViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    @IBOutlet weak var navTitleLabel: UILabel!
    
    // MARK: - Programmatic UI
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let backdropImageView = UIImageView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let taglineLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingLabel = UILabel()
    private let overviewLabel = UILabel()
    
    private let trailerContainerView = UIView()
    private let trailerThumbnailImageView = UIImageView()
    private let playButton = UIButton(type: .system)
    
    private let reviewsContainerView = UIView()
    private let reviewsTitleLabel = UILabel()
    private let reviewsStackView = UIStackView()
    private let seeAllReviewsButton = UIButton(type: .system)
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Data
    private let movieId: Int
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    private var currentTrailer: Video?
    
    init(movieId: Int) {
        self.movieId = movieId
        self.viewModel = MovieDetailViewModel(movieId: movieId)
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.secondaryBg
        self.navTitleLabel.text = "Movie Name"
        
        buildLayout()
        setupBindings()
        viewModel.fetchAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Layout
private extension DetailViewController {
    
    func buildLayout() {
        setupScrollView()
        setupHeaderSection()
        setupTrailerSection()
        setupReviewsSection()
        setupLoadingIndicator()
    }
    
    func setupScrollView() {
        scrollView.backgroundColor = AppColor.backgroundColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navTitleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    func setupHeaderSection() {
        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true
        backdropImageView.layer.cornerRadius = 12
        backdropImageView.backgroundColor = .secondarySystemBackground
        backdropImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.backgroundColor = .secondarySystemBackground
        posterImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        posterImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 2
        
        taglineLabel.font = .italicSystemFont(ofSize: 13)
        taglineLabel.textColor = .secondaryLabel
        taglineLabel.numberOfLines = 2
        
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .secondaryLabel
        
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, taglineLabel, metaLabel, ratingLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        
        let posterInfoStack = UIStackView(arrangedSubviews: [posterImageView, infoStack])
        posterInfoStack.axis = .horizontal
        posterInfoStack.spacing = 12
        posterInfoStack.alignment = .top
        
        overviewLabel.font = .systemFont(ofSize: 14)
        overviewLabel.numberOfLines = 0
        overviewLabel.textColor = .label
        
        contentStackView.addArrangedSubview(backdropImageView)
        contentStackView.addArrangedSubview(posterInfoStack)
        contentStackView.addArrangedSubview(overviewLabel)
    }
    
    func setupTrailerSection() {
        let title = sectionTitleLabel(text: "Trailer")
        
        trailerThumbnailImageView.contentMode = .scaleAspectFill
        trailerThumbnailImageView.clipsToBounds = true
        trailerThumbnailImageView.layer.cornerRadius = 12
        trailerThumbnailImageView.backgroundColor = .secondarySystemBackground
        trailerThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        trailerThumbnailImageView.isUserInteractionEnabled = true
        
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playTrailerTapped), for: .touchUpInside)
        
        trailerContainerView.translatesAutoresizingMaskIntoConstraints = false
        trailerContainerView.addSubview(trailerThumbnailImageView)
        trailerContainerView.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            trailerThumbnailImageView.topAnchor.constraint(equalTo: trailerContainerView.topAnchor),
            trailerThumbnailImageView.leadingAnchor.constraint(equalTo: trailerContainerView.leadingAnchor),
            trailerThumbnailImageView.trailingAnchor.constraint(equalTo: trailerContainerView.trailingAnchor),
            trailerThumbnailImageView.bottomAnchor.constraint(equalTo: trailerContainerView.bottomAnchor),
            trailerThumbnailImageView.heightAnchor.constraint(equalToConstant: 200),
            
            playButton.centerXAnchor.constraint(equalTo: trailerContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: trailerContainerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 56),
            playButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(playTrailerTapped))
        trailerThumbnailImageView.addGestureRecognizer(tap)
        
        contentStackView.addArrangedSubview(title)
        contentStackView.addArrangedSubview(trailerContainerView)
        trailerContainerView.isHidden = true // hide sampai data trailer datang
    }
    
    func setupReviewsSection() {
        reviewsTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        reviewsTitleLabel.text = "Reviews"
        
        reviewsStackView.axis = .vertical
        reviewsStackView.spacing = 12
        
        seeAllReviewsButton.setTitle("See All Reviews", for: .normal)
        seeAllReviewsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        seeAllReviewsButton.addTarget(self, action: #selector(seeAllReviewsTapped), for: .touchUpInside)
        
        let sectionStack = UIStackView(arrangedSubviews: [reviewsTitleLabel, reviewsStackView, seeAllReviewsButton])
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        sectionStack.translatesAutoresizingMaskIntoConstraints = false
        
        reviewsContainerView.translatesAutoresizingMaskIntoConstraints = false
        reviewsContainerView.addSubview(sectionStack)
        
        NSLayoutConstraint.activate([
            sectionStack.topAnchor.constraint(equalTo: reviewsContainerView.topAnchor),
            sectionStack.leadingAnchor.constraint(equalTo: reviewsContainerView.leadingAnchor),
            sectionStack.trailingAnchor.constraint(equalTo: reviewsContainerView.trailingAnchor),
            sectionStack.bottomAnchor.constraint(equalTo: reviewsContainerView.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(reviewsContainerView)
        reviewsContainerView.isHidden = true
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func sectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }
}

// MARK: - Bindings
private extension DetailViewController {
    
    func setupBindings() {
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                if loading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.detail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] detail in
                self?.renderDetail(detail)
            })
            .disposed(by: disposeBag)
        
        viewModel.trailer
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] video in
                self?.renderTrailer(video)
            })
            .disposed(by: disposeBag)
        
        viewModel.reviews
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reviews in
                self?.renderReviews(reviews)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    func renderDetail(_ detail: MovieDetail?) {
        guard let detail else { return }
        
        navTitleLabel.text = detail.title
        titleLabel.text = detail.title
        taglineLabel.text = detail.tagline
        taglineLabel.isHidden = (detail.tagline?.isEmpty ?? true)
        overviewLabel.text = detail.overview
        
        let genreText = detail.genres?.compactMap { $0.name }.joined(separator: ", ") ?? ""
        let runtimeText = detail.runtime != nil ? "\(detail.runtime!) min" : ""
        let releaseYear = detail.releaseDate?.prefix(4) ?? ""
        metaLabel.text = [String(releaseYear), runtimeText, genreText]
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
        
        if let vote = detail.voteAverage {
            ratingLabel.text = String(format: "⭐ %.1f (%d votes)", vote, detail.voteCount ?? 0)
        }
        
        loadImage(into: backdropImageView, path: detail.backdropPath, size: "w780")
        loadImage(into: posterImageView, path: detail.posterPath, size: "w342")
    }
    
    func renderTrailer(_ video: Video?) {
        currentTrailer = video
        guard let video, let thumbURL = video.thumbnailURL else {
            trailerContainerView.isHidden = true
            return
        }
        trailerContainerView.isHidden = false
        loadImage(into: trailerThumbnailImageView, url: thumbURL)
    }
    
    func renderReviews(_ reviews: [Review]) {
        reviewsStackView.arrangedSubviews.forEach {
            reviewsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        guard !reviews.isEmpty else {
            reviewsContainerView.isHidden = true
            return
        }
        
        reviewsContainerView.isHidden = false
        reviewsTitleLabel.text = "Reviews (\(viewModel.totalReviews.value))"
        
        let previewReviews = Array(reviews.prefix(3))
        previewReviews.forEach { review in
            let card = ReviewCardView()
            card.configure(with: review)
            reviewsStackView.addArrangedSubview(card)
        }
        
        seeAllReviewsButton.isHidden = viewModel.totalReviews.value <= 3
    }
}

// MARK: - Actions
private extension DetailViewController {
    
    @objc func playTrailerTapped() {
        guard let url = currentTrailer?.youtubeURL else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func seeAllReviewsTapped() {
        let reviewsVC = ReviewsViewController(movieId: movieId)
        navigationController?.pushViewController(reviewsVC, animated: true)
    }
}

// MARK: - Image Loading Helper
private extension DetailViewController {
    
    func loadImage(into imageView: UIImageView, path: String?, size: String = "w500") {
        guard let url = TMDBImage.url(path: path, size: size) else { return }
        loadImage(into: imageView, url: url)
    }
    
    func loadImage(into imageView: UIImageView, url: URL) {
        imageView.image = nil
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView.image = image }
        }.resume()
    }
}
