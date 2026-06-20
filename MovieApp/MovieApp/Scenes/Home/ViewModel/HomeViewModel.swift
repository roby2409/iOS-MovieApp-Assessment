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
