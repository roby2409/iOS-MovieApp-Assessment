//
//  ReviewsViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//


import UIKit
import RxSwift
import RxCocoa

class ReviewsViewController: UIViewController {
    
    private let navTitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    
    private let movieId: Int
    private let viewModel: ReviewsViewModel
    private let disposeBag = DisposeBag()
    
    private var isLoadingMore = false
    
    init(movieId: Int) {
        self.movieId = movieId
        self.viewModel = ReviewsViewModel(movieId: movieId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.secondaryBg
        
        buildLayout()
        setupTableView()
        setupBindings()
        viewModel.fetchReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


private extension ReviewsViewController {
    
    func buildLayout() {
        navTitleLabel.text = "Reviews"
        navTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        view.addSubview(navTitleLabel)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyLabel.text = "No reviews yet"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.backgroundColor = AppColor.backgroundColor
        
        let footer = LoadingFooterCollectionReusableView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        tableView.tableFooterView = footer
        footer.isHidden = true
    }
}


private extension ReviewsViewController {
    
    func setupBindings() {
        viewModel.reviews
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reviews in
                guard let self else { return }
                self.tableView.reloadData()
                self.emptyLabel.isHidden = !reviews.isEmpty
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self else { return }
                self.isLoadingMore = loading && !self.viewModel.reviews.value.isEmpty
                if let footer = self.tableView.tableFooterView as? LoadingFooterCollectionReusableView {
                    footer.isHidden = !self.isLoadingMore
                    footer.setLoading(self.isLoadingMore)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}


extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reviews.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.reuseId, for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        let review = viewModel.reviews.value[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        guard contentHeight > 0 else { return }
        
        let distanceToBottom = contentHeight - frameHeight - offsetY
        if distanceToBottom < 200 {
            debugPrint("📜 Near bottom — distanceToBottom: \(Int(distanceToBottom))")
            viewModel.fetchNextPage()
        }
    }
}


class ReviewTableViewCell: UITableViewCell {
    static let reuseId = "ReviewTableViewCell"
    
    private let cardView = ReviewCardView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    func configure(with review: Review) {
        cardView.configure(with: review)
    }
}


class ReviewsViewModel {
    let movieId: Int
    
    let reviews = BehaviorRelay<[Review]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    private var disposable: Disposable?
    
    private(set) var currentPage = 1
    private(set) var totalPages = 1
    
    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading.value
    }
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    func fetchReviews() {
        currentPage = 1
        totalPages = 1
        load(page: 1, reset: true)
    }
    
    func fetchNextPage() {
        guard canLoadMore else {
            debugPrint("⛔️ Skip fetchNextPage — canLoadMore: \(canLoadMore), currentPage: \(currentPage), totalPages: \(totalPages)")
            return
        }
        debugPrint("➡️ fetchNextPage triggered — loading page \(currentPage + 1) of \(totalPages)")
        load(page: currentPage + 1, reset: false)
    }
    
    private func load(page: Int, reset: Bool) {
        disposable?.dispose()
        isLoading.accept(true)
        
        
        disposable = Observable<ReviewResponse>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let task = APIManager.shared.hitAPIWithResultAndError(
                endpoint: .movie,
                path: "\(self.movieId)/reviews?page=\(page)&language=en-US",
                httpMethod: .get,
                model: ReviewResponse.self
            ) { result in
                switch result {
                case .success(let data, _):
                    observer.onNext(data)
                    observer.onCompleted()
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        .subscribe(onNext: { [weak self] data in
            guard let self else { return }
            self.currentPage = data.page ?? page
            self.totalPages = data.totalPages ?? 1
            
            let newResults = data.results ?? []
            if reset {
                self.reviews.accept(newResults)
            } else {
                self.reviews.accept(self.reviews.value + newResults)
            }
            self.isLoading.accept(false)
            debugPrint("✅ Reviews page \(self.currentPage)/\(self.totalPages) loaded — total now: \(self.reviews.value.count)")
        }, onError: { [weak self] error in
            debugPrint("❌ Reviews error: \(error)")
            self?.errorMessage.accept("Failed to load reviews")
            self?.isLoading.accept(false)
        })
    }
}
