//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var searchWorkItem: DispatchWorkItem?
    
    private let viewModel = HomeViewModel() // Inisialisasi ViewModel
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = AppColor.secondaryBg
        appBarView.backgroundColor = AppColor.secondaryBg
        collectionView.backgroundColor = AppColor.backgroundColor
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search movies..."
        searchBar.backgroundImage = UIImage()
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.background = UIImage()
            searchField.backgroundColor = AppColor.secondaryBg
            searchField.layer.cornerRadius = 12
            searchField.clipsToBounds = true
            searchField.rightViewMode = .never
            searchField.textColor = .label
        }
        
    }
    
    private func setupBindings() {
        viewModel.movies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                // Lu bisa reload data di sini
                self?.collectionView.reloadData()
                debugPrint("Data updated: \(movies.count) movies")
            })
            .disposed(by: disposeBag)
        

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { loading in
                
            })
            .disposed(by: disposeBag)
    }
}


extension HomeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: searchText)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        if let query = searchBar.text {
            performSearch(query: query)
            searchBar.resignFirstResponder()
        }
    }
    
    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            // Kalau kosong, tarik data discover (default)
            viewModel.fetchMovies()
            return
        }

        viewModel.fetchMovies(searchKey: trimmed)
    }
}



class HomeViewModel {
    let movies = BehaviorRelay<[Movie]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    private var searchDisposable: Disposable?
    
    func fetchMovies(searchKey: String? = nil, page: Int = 1) {
        searchDisposable?.dispose()
        
        isLoading.accept(true)
        
        let isSearching = searchKey != nil && !searchKey!.isEmpty
        let endPoint: Endpoint = isSearching ? .searchMovie : .discoverMovie
        
        var query = "page=\(page)&include_adult=false&language=en-US"
        if let searchKey {
            query += "&query=\(searchKey)"
        }
        
        searchDisposable = Observable<DiscoverMovie>.create { observer in
            let task = APIManager.shared.hitAPIWithResultAndError(
                endpoint: endPoint,
                query: query,
                httpMethod: .get,
                model: DiscoverMovie.self
            ) { result in
                switch result {
                case .success(let data, _):
                    observer.onNext(data)
                    observer.onCompleted()
                case .error(let error):
                    debugPrint("error \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        .subscribe(onNext: { [weak self] data in
            self?.movies.accept(data.results ?? [])
            self?.isLoading.accept(false)
        }, onError: { [weak self] error in
            self?.errorMessage.accept("Error Bro")
            self?.isLoading.accept(false)
        })
    }
}
