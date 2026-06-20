//
//  HomeViewModel.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    let movies = BehaviorRelay<[Movie]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    private var searchDisposable: Disposable?
    
    private(set) var currentPage = 1
    private(set) var totalPages = 1
    private var currentQuery: String?
    
    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading.value
    }
    
    func fetchMovies(searchKey: String? = nil) {
        // reset pagination on new search/discover
        currentPage = 1
        totalPages = 1
        currentQuery = searchKey
        load(page: 1, searchKey: searchKey, reset: true)
    }
    
    func fetchNextPage() {
        guard canLoadMore else { return }
        load(page: currentPage + 1, searchKey: currentQuery, reset: false)
    }
    
    private func load(page: Int, searchKey: String?, reset: Bool) {
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
                self.movies.accept(newResults)
            } else {
                self.movies.accept(self.movies.value + newResults)
            }
            self.isLoading.accept(false)
        }, onError: { [weak self] error in
            debugPrint("error \(error)")
            self?.errorMessage.accept("Error Bro")
            self?.isLoading.accept(false)
        })
    }
}
